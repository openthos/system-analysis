# 1.download AOSP source
First download the latest source from Tsinghua TUNA.
Then Update from Google(You can visti goole)
```
repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r24
```
# 2.Compile AOSP
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
# 3.Compose Xposed
 - 1.download all repo in https://github.com/rovo89
 - 2.read XposedTools/README.md
 ```
 configure XposedTolls/build.conf
 javadir=XposdedBridge_dir
 ./build.pl -a java(error)
 I use android studio to compile the jar:download SDK API23 and fix build error.
 ```
 ./build.pl -t x86:22
 
 # repo sync Error
 ```
 error: RPC failed; curl 56 GnuTLS recv error (-54): Error in the pull function.
 git config --global http.postBuffer 1048576000
 ```
