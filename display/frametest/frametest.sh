#########################################################################
# File Name: frametest.sh
# Author: wangjx
# mail: wangjianxing5210@163.com
# Created Time: 2016年09月19日 星期一 09时45分57秒
#########################################################################
#!/bin/bash
VIDEO=test.mp4
androidIP=$1
port=$2
adb connect $androidIP
adb -s $androidIP:$port install vlc.apk
adb -s $androidIP:$port push $VIDEO /storage/emulated/legacy/DCIM/Camera/$VIDEO
adb -s $androidIP:$port shell mkdir /data/gputrace
adb -s $androidIP:$port push gputrace-gen /data/gputrace/
adb -s $androidIP:$port shell chmod 777 /data/gputrace/gputrace-gen
adb -s $androidIP:$port shell am start -n org.videolan.vlc/org.videolan.vlc.StartActivity
adb -s $androidIP:$port shell am start -a android.intent.action.VIEW -d file:///storage/emulated/legacy/DCIM/Camera/$VIDEO -t video/*
adb -s $androidIP:$port shell < script
adb -s $androidIP:$port pull /data/gputrace/gputrace.log .
line=`cat gputrace.log |grep drm_vblank_event|wc -l`
frame=`expr $line / 150`
echo $frame 
