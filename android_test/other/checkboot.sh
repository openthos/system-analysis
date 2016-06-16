#!/bin/bash

if [ $# -ne 1 ]; then
echo -e "Usage: $0 Android-x86_IP"
exit
fi

IP="$1"

#check network
ping -c 3 $IP
if [ $? -ne 0 ]; then
echo -e "\033[31mNetwork ERROR!\033[0m"
exit
fi
echo -e "\033[32mNetwork OK!\033[0m"

#check adb
adb connect $IP | grep "connected"
if [ $? -ne 0 ]; then
echo -e "\033[31mADB connection ERROR!\033[0m"
exit
fi

adb shell uname -a
if [ $? -ne 0 ]; then
echo -e "\033[31mADB shell ERROR!\033[0m"
exit
fi

echo -e "\033[32mADB shell OK!\033[0m"

#check android desktop
#ps_=$(adb shell ps)

adb shell ps |grep -i zygote
if [ $? -eq 0 ]; then
	zygote=1
else
	zygote=0
fi
adb shell ps |grep -i system_server
if [ $? -eq 0 ]; then
	system_server=1
else
	system_server=0
fi
adb shell ps |grep -i launcher
if [ $? -eq 0 ]; then
	launcher=1
else
	launcher=0
fi

if [ $zygote -eq 1 -a $system_server -eq 1 -a $launcher -eq 1 ];then
echo -e "\033[32mAndroid-x86 desktop OK!\033[0m"
else
echo -e "\033[31mAndroid-x86 desktop ERROR!\033[0m"
fi

