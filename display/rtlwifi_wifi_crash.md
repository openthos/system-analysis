###1.问题描述
T45反复开关wifi会造成重启
###2.分析过程
-1.定位问题范围:-
同一台机器安装ubuntu反复开关wifi不会重启，而android-x86会重启  
只有这一种型号的机器会发生该问题  
在rmmod　wifi的driver后不会重启  　　
根据现象２,可以推测大概是硬件问题；根据现象1和３,可以推测是上下不兼容的问题  
这种现象基本上是软件问题了，可以使用如下方法:  
`echo 8 > /proc/sys/kernel/printk `  
`cat /proc/kmsg`  
发现该问题最后是在初始化设备时出现问题　　
###3.方案
在configs文件中禁止driver卸载动作
