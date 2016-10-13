# 问题描述
1.在系统自动休眠之后,灭屏;  
2.按powerkey唤醒系统,亮屏  
3.此时系统界面显示正常,但是无法操作;  
4.再次按下powerkey,系统可以正常操作;  
# 调查过程
1.按下powerkey,选择"睡眠",再次唤醒就可以正常操作  
主动休眠和被动休眠的过程有什么不同吗?  
2.使用getevent工具可以看到按键事件是一直可以上报的,而且上层的鼠标焦点也可以移动,  
这个问题应该是事件没有有效处理,或者是应用没有接收到input事件  
# 中间结果
休眠唤醒之后可以使用如下命令  
svc power stayon true  
svc power stayon false  
界面可以正常操作;  
可以考虑在显示屏亮之后加上如上操作,调用函数入口地址:  
frameworks/base/cmds/svc/src/com/android/commands/svc/PowerCommand.java
