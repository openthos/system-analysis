# Openthos源码中branch简介
## Openthos分支:
android-x86 lollipop multiwindow分支(<font color=green>正在开发中的分支</font>):  
```
repo init -u git://192.168.0.185/composition/android-x86/manifest.git -b multiwindow
```
android-x86 lollipop base分支:
```
repo init -u git://192.168.0.185/composition/android-x86/manifest.git -b lollipop-x86
```
android-x86 marshmallow base分支:
```
repo init -u git://192.168.0.185/composition/android-x86/manifest.git -b marshmallow-x86
```
## kernel:
kernel基本上都附有openthos和android-x86的部分patch(关于驱动的,可以不用关心)
```
git clone git://192.168.0.185/lollipop-x86/kernel/common -b branch
```
可用的分支
```
  android-3.0.x
  android-3.10
  android-3.18
  android-4.0
  kernel-4.0
  kernel-4.4
  kernel-4.8
  kernel-4.9rc5
```
如果有下载问题和编译问题请及时反馈.  
If you have any issue about downloading or compilation,please tell us(yuchen@mail.tsinghua.edu.cn);
