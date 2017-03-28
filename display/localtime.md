# OPENTHOS实现保存localtime到BIOS而不是UTC时间
有两种方式保存时间到BIOS:  
1.每隔一段时间从NTP获取UTC时间,来和本地时间做对比,如果相差比较大则需要校准BIOS时间  
2.在setting中手动设置时间  
而读取时间的例子:logcat时间戳,时钟应用,SystemUI应用  
特性:写时间操作次数较少,读时间频繁  

时间设定:APP->AlarmManager->System库->bionic->系统vsdo调用->通用rtc层->特定rtc驱动曾->硬件  
时间获取和设定是相反的  
我们能动的是:通用rtc层,System库,AlarmManager,APP  
但是第一个排除的是读操作不能APP层修改,它的位置实在太多了;剩下的位置就比较有限了;  
## 方法一:修改通用rtc层好处:在相对底层的位置就屏蔽了UTC和localtime的差别,但是应该修改比较多;
缺点:另外是rtc层的修改让sys和proc的接口不能如实反应真实的BIOS时间,这个是最不能让主流内核接收的;  
修改System库:方法一:每次经过这里的时候都进行时区的运算,简单,但是因为时区是存储在文件中的,因此发生大量的文件IO实在  
很拖累系统;  
## 方法二:在线程启动的时候读取时区保存到static变量中来避免IO;因为ANdroid中的每一个应用都是一个进程,当有人修改时区参数时  
需要通知所有的进程,最容易的办法是发送全局广播(可以尝试)  
APP->alarmmanager->System(+时区偏移)->bionic->系统vsdo调用->通用rtc层->特定rtc驱动曾->硬件(localtime)->特定rtc驱动曾->通用rtc层->
系统vsdo调用->bionic->System(-时区偏移+时区偏移)->alarmmanager->APP  
## 方法三:修改AlarmManager层,读和写使用不同的参数,在写的过程中加上真实的时区偏移,在读的过程中反馈到Alarm层时通过fake偏移值  
来保证应用读取到的是保存在BIOS中的值(目前采用)  
APP->alarmmanager(+时区偏移)->System->bionic->系统vsdo调用->通用rtc层->特定rtc驱动曾->硬件(localtime)->特定rtc驱动曾->通用rtc层->
系统vsdo调用->bionic->System(零偏移)->alarmmanager->APP  
