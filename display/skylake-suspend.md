###1.问题描述
清华同方T45机器在屏幕灭之后会自动重启  
###2.调查分析
根据问题发生的现象可以推断到这个是和睡眠相关的问题，根据以下方法可以进一步缩小和确认问题范围:  
`echo test > /sys/power/wake_lock`　　
`echo mem > /sys/power/state` 　 
上述方法可以防止系统进入suspend;按照上述方法做之后可以看到系统屏幕依然会灭，但是不会重启；  
结论1:问题和suspend过程有关  
分析suspend的过程中的事件:  
`check wake_lock-->suspend devices-->suspend cpu-->physical suspend` 　 
可以在这一系列事件中中断ｓｕｓｐｅｎｄ过程，发现是在suspend devices环节出现问题；  
方向2:判断硬件问题和软件问题  
如果是软件问题就好说了，可以通过调试手段查找；如果是硬件问题，只能是请ｐｃ生产商进行诊断问题；  
这个问题是软件问题，在ｐｃ上获取最后的crash log方法:  
`echo 8 > /proc/sys/kernel/printk`  
拿着手机录下屏幕的日志，慢放查找log  
最后发现日志的最后堆栈是在kernel/sound/soc/intel/skylake/skl-sst-ipc.c文件中，这个最终编译成一个.ko的形式  
存在，通过rmmod snd-soc-skl-ipc.ko和snd-soc-skl.ko之后，机器不再重启  
那么如果永久去除这个ko有什么影响呢?  
通过阅读driver的comment,网上查询，可以确定这个driver是为了cpu内置显卡在插入hdmi时播放声音用的，oto暂时对这个功能不关注  
决定暂时disable掉绕过该问题．
###3.解决方案
在arch/x86/configs/android-x86_64_defconfig中不编译对应的ko
