# System组任务记录
## 任务分配<2017/04/14>:
### 陈威:
1.trustboot  /需要加快进度    
2.GUI SLIENT BOOT(进度80%)  
3.OverLay
### 肖络元
1.follow黄志伟关于硬解码的提交,能够出一份文档   
2.在dev.openthos.org上试行gerrit服务  
3.协助王之旭进行automount的任务  

### 王建兴    
1.openthos代码库整理  
2.电源管理（sleep/wakeup）  
3.3.29的ROM运行速度变慢问题   

### 待分配任务
1.系统部署工具（win->HDD）  
2.磁盘分区方案  
  
关于给网外暴露端口且搭建gerrit问题,以此来解决同步问题  
投影:支持VGA口，支持热插拔资源重新分配  

## 已完成的任务  
### 陈威:
>Ｕ盘安装的优化　
### 肖络元
>window上的parted工具，和陈威一起改进openthos的U盘版  
parted工具移植到windows难度较大，不适合  
>live启动中添加data分区来保存用户数据
>Marshmallow-x86上vold到lollipop-x86上的移植调研
已经基本解决,有待进一步深入使用  
>实验室内部和github代码同步  
### 王建兴
>OPENTHOS在虚拟机上运行问题  
一是鼠標不見了。二是 resolution 過大(好像變成 2560x1600?)。  
>部分应用在U盘版上运行问题:VLC,微信，网易云    
已经解决  
>seafile服务频繁重启问题解决  
不再复现  
>word的字体集成问题  
已经解决  
>openthos使用localtime  
已经解决
>refind和grub2的选择问题
>**已发邮件，等待回复**  
选择refind来引导,存在secure boot的问题
