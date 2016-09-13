#########################################################################
# File Name: frametest.sh
# Author: wangjx
# mail: wangjianxing5210@163.com
# Created Time: 2016年09月07日 星期三 09时54分54秒
#########################################################################
#!/bin/bash

if [ -e /data/gputrace/gputrace-gen ];then
	chmod 777 /data/gputrace/gputrace-gen
else
	echo "Missing test script gputrace-gen"
	exit
fi

am start -n org.videolan.vlc/org.videolan.vlc.StartActivity

am start -a android.intent.action.VIEW -d file:///storage/emulated/legacy/DCIM/Camera/test.mp4 -t video/*


./data/gputrace/gputrace-gen start
slepp 150
./data/gputrace/gputrace-gen stop
./data/gputrace/gputrace-gen dump > /data/gputrace/gputrace.log

line=`cat gputrace.log |grep drm_vblank_event|wc -l`
frame=`expr $line / 150`
echo $frame
