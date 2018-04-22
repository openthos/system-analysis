#  编译带Xposed框架的multiwindow 
陈威（三寸丁）    2018/04/22  
chanuei@sina.com  
## 一、如何编译带Xposed框架的multiwindow
  ssh登录180服务器，有如下目录
  1. /mnt/SSD/Xposed目录
  2. /mnt/SSD/multiwindow_xposed目录
  3. /mnt/SSD/multiwindow目录
  是必须的
  
  复制到自己的docker下，其中multiwindow目录可以自己从185服务器上repo建立。  
  
  multiwindow_xposed，可以先从185服务器上repo multiwindow分支成multiwindow_xposed。然后用/mnt/SSD/multiwindow_xposed/art掉换掉你repo出来的multiwindow_xposed/art，并将/mnt/SSD/multiwindow_xposed/framework/base/cmds/xposed复制到repo出来的multiwindow_xposed/framework/base/cmds/下  
  
  Xposed目录下的make_xposed_oto_img.sh是编译脚本  

```bash
  #!/bin/bash
  XPOSED_OTO_SRC_DIR=~/test/multiwindow_xposed
  OTO_SRC_DIR=~/test/multiwindow
  
  BOTO=efi.tar.bz2
  BOTO_HOME=bootable/newinstaller/install/refind
  
  OTO_INITRD=out/target/product/x86_64/oto_initrd.img
  OTO_INSTALL=out/target/product/x86_64/install.img
  OTO_RAMDISK=out/target/product/x86_64/ramdisk.img
  OTO_KERNEL=out/target/product/x86_64/kernel
  OTO_DATA=out/target/product/x86_64/data.img
  .........
```
#Xposed/XposedTools/build.conf

```
[General]
  outdir = /root/test/multiwindow_xposed/out
  javadir = /root/test/Xposed/XposedBrigde
   
  [Build]
  # Please keep the base version number and add your custom suffix
  version = 89 (custom build by David Chan / %s)
  # makeflags = -j4
 
 [GPG]
 sign = release
 user = 852109AA!
 
 # Root directories of the AOSP source tree per SDK version
 [AospDir]
 19 = /android/aosp/440
 21 = /android/aosp/500
 22 = /root/test/multiwindow_xposed
```

根据自己docker下的目录情况改参数XPOSED_OTO_SRC_DIR及OTO_SRC_DIR参数：  
如multiwindows_xposed在docker apple下的位置为用户home目录，则XPOSED_OTO_SRC_DIR=~/multiwindow_xposed  
修改完成后运行 ./make_xposed_oto_img.sh即可创建xposed_x86_64_oto.img  

dd把xposed_x86_64_oto.img写在U盘上即可  

## 二、编译时可能遇到的几个问题（均与perl模拟不全有关）

1. Perl模块不全的问题，需要自行安装相关模块，即可解决  
1.1 Config/IniFiles.pm模块  
报错内容：  
```
Can't locate Config/IniFiles.pm in @INC (you may need to install the Config::IniFiles module) (@INC contains:/root/test/Xposed/XposedTools /etc/perl /usr/local/lib/perl/5.18.2 /usr/local/share/perl/5.18.2 /usr/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.18 /usr/share/perl/5.18 /usr/local/lib/site_perl .) at /root/test/Xposed/XposedTools/Xposed.pm line 10.  ·
BEGIN failed--compilation aborted at /root/test/Xposed/XposedTools/Xposed.pm line 10.  ·
Compilation failed in require at ./build.pl line 9. 
BEGIN failed--compilation aborted at ./build.pl line 9.  
```  
解决方法：  
```bash
  root@docker # perl -MCPAN -e 'install Config::IniFiles'
```  
1.2 File/ReadBackwards.pm模块  
报错内容： 
```
Can't locate File/ReadBackwards.pm in @INC (you may need to install the File::ReadBackwards module) (@INC contains: /root/test/Xposed/XposedTools /etc/perl /usr/local/lib/perl/5.18.2 /usr/local/share/perl/5.18.2 /usr/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.18 /usr/share/perl/5.18 /usr/local/lib/site_perl .) at /root/test/Xposed/XposedTools/Xposed.pm line 12. 
BEGIN failed--compilation aborted at /root/test/Xposed/XposedTools/Xposed.pm line 12.  
Compilation failed in require at ./build.pl line 9.  
BEGIN failed--compilation aborted at ./build.pl line 9.  
```
解决方法：
```bash
root@docker # perl -MCPAN -e 'install File::ReadBackwards'
```
1.3 File/Tail.pm模块  
报错内容：  
```
Can't locate File/Tail.pm in @INC (you may need to install the File::Tail module) (@INC contains: /root/test/Xposed/XposedTools /etc/perl /usr/local/lib/perl/5.18.2 /usr/local/share/perl/5.18.2 /usr/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.18 /usr/share/perl/5.18 /usr/local/lib/site_perl .) at /root/test/Xposed/XposedTools/Xposed.pm line 13.  
BEGIN failed--compilation aborted at /root/test/Xposed/XposedTools/Xposed.pm line 13.  
Compilation failed in require at ./build.pl line 9.  
BEGIN failed--compilation aborted at ./build.pl line 9.  
```
解决方法：  
```bash
root@docker # perl -MCPAN -e 'install File::Tail'
```
1.4 Archive/Zip.pm模块  
报错内容：  
```
Can't locate Archive/Zip.pm in @INC (you may need to install the Archive::Zip module) (@INC contains: /root/test/Xposed/XposedTools /etc/perl /usr/local/lib/perl/5.18.2 /usr/local/share/perl/5.18.2 /usr/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.18 /usr/share/perl/5.18 /usr/local/lib/site_perl .) at ./build.pl line 11.  
BEGIN failed--compilation aborted at ./build.pl line 11.  
```
解决方法：  
```bash
root@docker # apt-get install libarchive-zip-perl
```
注意:  
  这个模块比较特殊，不是由perl安装的，而是操作系统安装的。  
1.5 Tie/IxHash.pm模块  报错内容：  
```
Can't locate Tie/IxHash.pm in @INC (you may need to install the Tie::IxHash module) (@INC contains: /root/test/Xposed/XposedTools /etc/perl /usr/local/lib/perl/5.18.2 /usr/local/share/perl/5.18.2 /usr/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.18 /usr/share/perl/5.18 /usr/local/lib/site_perl .) at ./build.pl line 18.
```
解决方法：  
```bash
root@docker # perl -MCPAN -e 'install Tie::IxHash'
```  
## 三、如何在系统中额外添加基于Xposed的插件程序
make_xposed_oto_img.sh文件
```bash
	popd
	rm -rf /tmp/XposedFrameworkInst
	echo Integrater: Xposed framework is successfully merged.

	#cp -f src dest

	mkdir tmpFolder
	pushd tmpFolder
	$OTO_SRC_DIR/build/tools/fileslist.py /system > filelist.txt
	mkuserimg.sh /system system.img ext4 system 0 ~/test/multiwindow/out/target/product/x86_64/root/file_contexts
	......
```  
中间注释掉的#cp -f src dest处，写入相应的复制apk到/system的代码，如
	cp <your Calculator apk path> /system/app/Calculator/Calculator.apk
	
## 四、关于编译的问题
这个脚本共有三大部分，一个是编译Xposed框架，一个是编译multiwindow，最后才是生成集成镜像
前两个编译如果不是必要重新编译，可以注释掉，以节省编译时间。如下所示：
```bash
	pushd XposedTools
	echo XposedTools: Xposed for X86_64 with SDK22 will be built...
	#./build.pl -t x86_64:22
	echo XposedTools: Xposed for X86_64 with SDK22 is successfully built.
	popd
```
文件中的./build.pl -t x86_64:22即为编译xposed
```bash
	pushd $OTO_SRC_DIR
	echo MultiWindow: Openthos Multiwindow will be built...
	#source build/envsetup.sh
	#lunch android_x86_64-user
	#make -j32 oto_img
	if [ $? != 0 ]; then
	  echo [ Error ] MultiWindow: Failed to build oto_img for android_x86_64-user
	  exit $EXIT_OTO_BUILD_FAILED
	fi
```
文件中的source build/envsetup.sh; lunch android_x86_64-user; make -j32 oto_img即为编译multiwindow

注意当art发生修改后，必须通知我（chenwei01@thtfpc.com  chanuei@sina.com）重建art。
