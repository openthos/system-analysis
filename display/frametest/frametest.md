帧率自动化测试:

声明:gputrace-gen来自于https://github.com/olvaffe/gputrace

前提：  
远程连接到android-x86上  

1.安装应用，复制播放的文件,复制脚本文件
```
adb install vlc.apk
adb push test.mp4 /storage/emulated/legacy/DCIM/Camera/test.mp4
adb shell mkdir /data/gputrace
adb push gputrace-gen /data/gputrace/
adb shell chmod 777 /data/gputrace/gputrace-gen
```
2.启动apk播放视频
```
adb shell am start -n org.videolan.vlc/org.videolan.vlc.StartActivity
可以通过一下命令播放视频
adb shell am start -a android.intent.action.VIEW -d file:///storage/emulated/legacy/DCIM/Camera/test.mp4 -t video/*
```
3.开始帧率测试
```
adb shell < script
cat script
./data/gputrace/gputrace-gen start
slepp 150
./data/gputrace/gputrace-gen stop
./data/gputrace/gputrace-gen dump > /data/gputrace/gputrace.log
```
4.帧率计算:
```
adb pull /data/gputrace/gputrace.log .
line=`cat gputrace.log |grep drm_vblank_event|wc -l`
frame=`expr $line / 150`
echo $frame
```
---------------------------------------------------------------------------------
**CTS is responsible for install VLC.apk,push test.mp4,gputrace-gen,frametest.sh to the specific position,**
```
./frametest.sh > result       if 'result' is digital,result should be OK
```
