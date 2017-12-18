# Android-x86 Porting指导

## 移植概览

- 工具链，AOSP已经提供毋需修改
- Linux Kernel，基于Google [kernel/common](https://android.googlesource.com/kernel/common) ，目前选用kernel 4.9
- Libraries，.so依赖库
- Runtime, art、vold等
- HAL, [Hardware Abstraction Layer](https://source.android.com/devices/architecture/hal-types) 硬件抽象层
- Frameworks
- Apps

## 移植步骤

1. 准备AOSP codebase，按需修改manifest.xml
2. device配置

```
device/generic/{common,firmware,x86,x86_64}
```

定制需要的.mk [makefile文件](http://wiki.ubuntu.org.cn/跟我一起写Makefile)



3. AOSP git projects修改

```
system/{core,vold,bt,media}
frameworks/{native,base,av}
packages/apps/Settings ...
```



4. 增加 x86特定模块

```
bootable/newinstaller
external/drm_gralloc
external/mesa
external/libdrm
kernel
```



5. 应用x86 patches到AOSP中，可使用`git merge`或`git rebase`，某些patch需要重写。
6. 修复编译错误。
7. 尝试启动ISO进桌面，并修复出现的错误，可用工具`logcat`或`dmesg`



注：Android编译系统[Soong](https://android.googlesource.com/platform/build/soong/)使用Android.bp替代Android.mk，Android.bp类似json格式，老版本的简单Android.mk可转换成Android.bp

```
androidmk Android.mk > Android.bp
```



（待续...）





