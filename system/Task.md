# System组任务记录
## 任务分配<2017/03/22>:
### 陈威:
1.trustboot  
2.GUI SLIENT BOOT(进度80%)
### 肖络元
1.automount  
### 王建兴    
电源管理（sleep/wakeup） 
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
### 王建兴
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
