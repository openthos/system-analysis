#apk rename script
You should install "apktool"
for git://192.168.0.185/openthos-apps/Install-Start/apk/
```
#!/bin/bash
set -x
for apk in `ls *.apk`
do 
	#apktool d $apk;
	dir=`echo $apk|awk -F ".apk" '{print $1;}'`
	if [ -d $dir ]
	then 
		cat $dir/AndroidManifest.xml|sed -n 2p|awk '{for(i=1;i<=NF;i++)print $i;}'|grep "package"|awk -F "\"" '{print $2}' |tee tmp
		packagename=`cat tmp`
		echo $apk
		echo $packagename
		mkdir ../convert/$packagename
		mv $apk ../convert/$packagename/"$packagename".apk
		#package="com.chaozhuo.filemanager"
	fi
done

#Install the head apps
for dir in `ls`;do adb shell mkdir /data/app/$dir;adb push $dir /data/app/$dir;done
```
