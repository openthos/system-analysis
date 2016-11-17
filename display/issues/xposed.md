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
 - 3.compile Xposed and android_art with AOSP
```
1.copy 'Xposed' to AOSP 'frameworks/base/cmds/xposed'
2.copy 'android_art' to AOSP 'art'
git checkout -b lollipop 
3.Download XposedBridge.jar and copy to AOSP/out/java
https://www.androidfilehost.com/?w=file-thanks&fid=95916177934548528&mid=97&download_id=hm44v2qm72glg7pmioq0lborm4&tid=1479362933&hc=f8be8adcbff7a2be42517ca2096e90e0127fe2468da9f2f7a6fc5a473e685658
Compile is OK.
```
# 4.Compile
 ```

 configure XposedTolls/build.conf
 javadir=XposdedBridge_dir
 ./build.pl -a java(error)
 I use android studio to compile the jar:download SDK API23 and fix build error.
 ```
 ./build.pl -t x86:22
 ```
 linux@linux-THTF-T-Series:~/aosp/XposedTools$ ./build.pl -t x86:22
Loading config file /home/linux/aosp/XposedTools/build.conf...
Checking requirements...
Expanding targets from 'x86:22'...
  SDK 22, platform x86

Processing SDK 22, platform x86...
Compiling...
Executing: cd /home/linux/aosp/aosp && . build/envsetup.sh >/dev/null && lunch aosp_x86-eng >/dev/null && make -j4 TARGET_CPU_SMP=true xposed libxposed_art libart libart-compiler libart-disassembler libsigchain dex2oat oatdump patchoat
Log: /home/linux/aosp/aosp/out/sdk22/x86/logs/build_20161117_135435.log
                                                                                
Build was successful!

Collecting compiled files...
/home/linux/aosp/aosp/out/target/product/generic_x86/system/bin/app_process32_xposed => /home/linux/aosp/aosp/out/sdk22/x86/files/system/bin/app_process32_xposed
/home/linux/aosp/aosp/out/target/product/generic_x86/system/lib/libxposed_art.so => /home/linux/aosp/aosp/out/sdk22/x86/files/system/lib/libxposed_art.so
/home/linux/aosp/aosp/out/target/product/generic_x86/system/lib/libart.so => /home/linux/aosp/aosp/out/sdk22/x86/files/system/lib/libart.so
/home/linux/aosp/aosp/out/target/product/generic_x86/system/lib/libart-compiler.so => /home/linux/aosp/aosp/out/sdk22/x86/files/system/lib/libart-compiler.so
/home/linux/aosp/aosp/out/target/product/generic_x86/system/lib/libart-disassembler.so => /home/linux/aosp/aosp/out/sdk22/x86/files/system/lib/libart-disassembler.so
/home/linux/aosp/aosp/out/target/product/generic_x86/system/lib/libsigchain.so => /home/linux/aosp/aosp/out/sdk22/x86/files/system/lib/libsigchain.so
/home/linux/aosp/aosp/out/target/product/generic_x86/system/bin/dex2oat => /home/linux/aosp/aosp/out/sdk22/x86/files/system/bin/dex2oat
/home/linux/aosp/aosp/out/target/product/generic_x86/system/bin/oatdump => /home/linux/aosp/aosp/out/sdk22/x86/files/system/bin/oatdump
/home/linux/aosp/aosp/out/target/product/generic_x86/system/bin/patchoat => /home/linux/aosp/aosp/out/sdk22/x86/files/system/bin/patchoat
Creating xposed.prop file...
/home/linux/aosp/aosp/out/sdk22/x86/files/system/xposed.prop
Creating flashable ZIP file...
/home/linux/aosp/aosp/out/sdk22/x86/xposed-v65-sdk22-x86-test.zip

Done!
 ```
 
 # repo sync Error
 ```
 error: RPC failed; curl 56 GnuTLS recv error (-54): Error in the pull function.
 git config --global http.postBuffer 1048576000
 ```
