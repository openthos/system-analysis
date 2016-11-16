1.download AOSP source
First download the latest source from Tsinghua TUNA.
Then Update from Google(You can visti goole)
```
repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r24
```
2.Compile AOSP
HOST:Ubuntu 16.04
```
sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip
  ```
Modify 
```
linux@linux-THTF-T-Series:~/aosp/aosp/build$ git diff .
diff --git a/core/clang/HOST_x86_common.mk b/core/clang/HOST_x86_common.mk
index 0241cb6..77547b7 100644
--- a/core/clang/HOST_x86_common.mk
+++ b/core/clang/HOST_x86_common.mk
@@ -8,6 +8,7 @@ ifeq ($(HOST_OS),linux)
 CLANG_CONFIG_x86_LINUX_HOST_EXTRA_ASFLAGS := \
   --gcc-toolchain=$($(clang_2nd_arch_prefix)HOST_TOOLCHAIN_FOR_CLANG) \
   --sysroot=$($(clang_2nd_arch_prefix)HOST_TOOLCHAIN_FOR_CLANG)/sysroot \
+  -B$($(clang_2nd_arch_prefix)HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/bin \
   -no-integrated-as
```
  
