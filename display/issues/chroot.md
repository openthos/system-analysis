# chroot的自动化脚本
## 1.请将下面的脚本复制到本地:
```
#!/system/bin/sh
set -x
CHMOUNT=/data/ubuntu
TESTMOUNT=/data/mount
CHTMP=tmp.txt
if [ ! -d $CHMOUNT ];then
	mkdir $CHMOUNT
fi
if [ ! -d $TESTMOUNT ];then
	mkdir $TESTMOUNT
fi
blkid > $CHTMP 
while read c
do
	disk=`echo "$c"|awk -F ":" '{print $1}'`
	type=`echo "$c"|awk -F "TYPE" '{print $2}'|awk -F "\"" '{print $2}'`
	mount -t $type $disk $TESTMOUNT
	if [ -d $TESTMOUNT/home ];then
		break;
	fi
done < $CHTMP
mount -t $type $disk $CHMOUNT
mount -t proc proc $CHMOUNT/proc
mount -t sysfs sysfs $CHMOUNT/sys
mount -t devpts devpts $CHMOUNT/dev/pts
if [ ! "`grep net_raw /data/ubuntu/etc/group`" ];then
	echo "inet:x:3003:root" >> $CHMOUNT/etc/group
	echo "net_raw:x:3004:root" >> $CHMOUNT/etc/group
	echo "nameserver 192.168.0.1" /etc/resolv.conf
fi
chroot $CHMOUNT su
export PATH=/usr/bin/:/usr/sbin/:/bin/:/sbin/:$PATH
```
## 2.push到android-x86上
adb push xxx.sh /data/  
adb shell chmod 777 /data/xxx.sh  
## 3.进入android-x86执行xxx.sh

### 问题调查:
- 1.为什么chroot之后ping不通  
可以通过strace ping 192.168.0.1  
socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) = 3  
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = -1 EACCES (Permission denied)  
那么就是访问SOCK_DGRAM时有问题,没有权限  
```
system/core/include/private/android_filesystem_config.h  
#define AID_NET_RAW       3004  /* can create raw INET sockets */  
    { "net_raw",       AID_NET_RAW, },  
    { "inet",          AID_INET, },
```
那么在/etc/group中加入如下:  
net_raw:x:3004:root  
root有权限访问编号位3004组  
更深一步的原因:  
Hi there, I was trying to fix this problem myself on my android archarm chroot and found the solution. 
Turns out that android is more strict on what apps can do with the network, for sandboxing purposes, 
so there's the kernel setting CONFIG_ANDROID_PARANOID_NETWORK that adds these restrictions.
