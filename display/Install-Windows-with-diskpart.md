# 使用diskpart安装windows
## 制作windows安装盘
准备:一台ubuntu笔记本和一个16G U盘
- 1.以win10为例，请从win官网下载该镜像，然后dd到U盘上`sudo dd if=win.iso of=/dev/sdd`
- 2.将U盘内的所有文件拷贝到你的电脑/home/linux/windows
- 3.使用fdisk工具，将U盘重新分区(这里建议一个partition占据16G的空间)，并重新格式化`mkfs.vfat /dev/sdd1`
- 4.将/home/linux/windows/下所有的文件拷贝到/dev/sdd1的挂载路径下
- 5.设置PC的BIOS设置，可以识别UEFI方式启动
- 6.启动PC，选择UEFI U盘
## 安装windows
如果默认安装，则会产生EFI，msr，recovery，primary分区，但是这里我们需要调整EFI分区的size和预留一部分的primary
分区给OPENTHOS的data使用，所以需要手动分区;  
在windows上分区工具使用diskpart工具，所以首先需要通过`Shift+F10`来调出cmd,然后使用diskpart  
分区方法:
```shell
1.list disk                           显示PC上具有的硬盘
2.select disk 0                       选中disk编号为0的硬盘
3.clean                               删除所有的数据，包括分区数据
4.convert gpt                         选择windows通过UEFI方式启动，就必须使用GUID分区表
5.create partition efi size=1024      创建1024MB大小的系统分区
6.create partition primary size=8096  创建8096MB大小的主分区
7.create partition primary            剩余的空间全部分给这个主分区
```
我们只是需要EFI分区和主分区来安装windows，msr是legacy启动才需要的，recovery分区我们这里省略  
下面只需要选择第二个主分区来安装windows就好了;

参考链接:https://www.windows10.pro/diskpart-gpt-partition/
