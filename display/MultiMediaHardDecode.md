# 视频硬解码
# 在CM-x86-14上硬解码工作复现步骤
参考链接:(https://groups.google.com/forum/#!topic/android-x86-devel/wqkZpqW46TQ)  
下载代码:
```
repo init -u git://git.osdn.jp/gitroot/android-x86/manifest -b nougat-x86 -m cm.xml
```
修改:
```
rm -rf system/bt/vendor_libs/test_vendor_lib
vendor/cm/build/tasks/kernel.mk
https://github.com/meijjaa/android_external_ffmpeg/tree/cm-14.1-x86-n3.1.5
https://github.com/meijjaa/android_external_stagefright-plugins/tree/cm-14.1-x86_n3.1
```
fetch这两个库的提交:
```
https://github.com/cwhuang/intel-vaapi-driver
https://github.com/cwhuang/libva
```
单独从cm上克隆这个仓库,Gallery依赖这个repo生成的静态库,否则会出错.(我不知道其他人有没有遇到这个问题)
```
https://github.com/CyanogenMod/android_external_ahbottomnavigation.git
```
recovery编译出错,做了如下注释:
```
build/target/product/embedded.mk  注释掉recovery
--- a/target/product/embedded.mk
+++ b/target/product/embedded.mk
@@ -67,7 +67,6 @@ PRODUCT_PACKAGES += \
      logwrapper \
      mkshrc \
      reboot \
-    recovery \
bootable/recovery/updater/Android.mk 注释掉eng TAG diff --git
a/updater/Android.mk b/updater/Android.mk

-LOCAL_MODULE_TAGS := eng
+#LOCAL_MODULE_TAGS := eng
```
优先使用ffmpeg,编译vaapi
```
device/generic/common$ git diff .
diff --git a/media_codecs.xml b/media_codecs.xml
index 7aaa8e1..5b31bac 100644
--- a/media_codecs.xml
+++ b/media_codecs.xml
@@ -78,7 +78,7 @@ Only the three quirks included above are recognized at this point:
 -->

 <MediaCodecs>
+    <Include href="media_codecs_ffmpeg.xml" />
     <Include href="media_codecs_google_audio.xml" />
     <Include href="media_codecs_google_video.xml" />
-    <Include href="media_codecs_ffmpeg.xml" />
 </MediaCodecs>
diff --git a/packages.mk b/packages.mk
index c590b84..f957a59 100644
--- a/packages.mk
+++ b/packages.mk
@@ -45,6 +45,7 @@ PRODUCT_PACKAGES := \
     wacom-input \
     Terminal \
     busybox \
+    i965_drv_video \
```
