为什么chroot之后ping不通  
可以通过strace ping 192.168.0.1  
socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) = 3  
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = -1 EACCES (Permission denied)  
那么就是访问SOCK_DGRAM时有问题,没有权限  
system/core/include/private/android_filesystem_config.h  
#define AID_NET_RAW       3004  /* can create raw INET sockets */  
那么在/etc/group中加入如下:  
net_raw:x:3004:root  
root有权限访问编号位3004组  
更深一步的原因:  
Hi there, I was trying to fix this problem myself on my android archarm chroot and found the solution. 
Turns out that android is more strict on what apps can do with the network, for sandboxing purposes, 
so there's the kernel setting CONFIG_ANDROID_PARANOID_NETWORK that adds these restrictions.
