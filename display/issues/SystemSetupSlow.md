# 问题
系统第一次启动非常慢,长达70s  
采用第三种安装方式启动系统时每次都很慢  
# 问题分析
通过不断的打印init的log,可以看出是enable_nativebridge的非常慢,长达60多s
```
<14>[    6.817436] sh: WARNING: linker: [vdso]: unused DT entry: type 0x6ffffef5 arg 0x160sh: + PATH=/sbin:/system/bin:/system/xbin sh: + DMIPATH=/sys/class/dmi/id sh: + cat /sys/class/dmi/id/board_namesh: + BOARD=NTSL1415 sh: + cat /sys/class/dmi/id/product_namesh: + PRODUCT='THTF T Series' sh: + cat /proc/cmdlinesh: + eval 'BOOT_IMAGE=/OpenThos/kernel'sh: + BOOT_IMAGE=/OpenThos/kernel sh: + eval 'root=/dev/ram0'sh: + root=/dev/ram0 sh: + eval 'BOOT_MODE=liveboot'sh: + BOOT_MODE=liveboot sh: + '[' -n  ']'sh: + >/dev/null sh: + 2>&1 sh: + execsh: + hw_sh=/vendor/etc/init.sh sh: + '[' -e /vendor/etc/init.sh ']'sh: + do_initsh: + init_miscsh: + lsusbsh: + grep 1a8d:1000sh: + '[' -d /sys/devices/system/cpu/cpu0/cpufreq ']'sh: + init_hal_audiosh: + init_hal_bluetoothsh: + cat /sys/class/rfkill/rfkill0/typesh: + type=wlan sh: + '[' wlan '=' wlan -o wlan '=' bluetooth ']'sh: + >/sys/class/rfkill/rfkill0/state sh: + echo 1sh: + lsusb -vsh: + awk ' /Class:.E0/ { print $9 } '
<11>[    6.825364] init: modprobe_maininit: modprobe btusb
<14>[    6.828202] sh: + modprobe btusbinit: restorecon_recursive: /sys/module/btrtl
<6>[    6.833529] usbcore: registered new interface driver btusb
<14>[    6.835517] sh: + '[' -n  ']'sh: + init_hal_camerash: + '[' -c /dev/video0 ']'sh: + modprobe vivi
<11>[    6.835520] init: modprobe_maininit: modprobe vivi
<11>[    6.840474] init: restorecon_recursive: /sys/module/btusb
<11>[    6.842207] init: restorecon_recursive: /sys/bus/usb/drivers/btusb
<11>[    6.842315] init: Couldn't probe module 'vivi'
<14>[    6.842467] sh: + init_hal_gpssh: + returnsh: + init_hal_grallocsh: + cat /proc/fbsh: + head -1sh: + set_property ro.hardware.gralloc drmsh: + >>/x86.prop sh: + echo 'ro.hardware.gralloc=drm'sh: + set_drm_modesh: + '[' -n  ']'sh: + init_hal_hwcomposersh: + returnsh: + init_hal_lightssh: + chown 1000.1000 /sys/class/backlight/intel_backlight/brightnesssh: + init_hal_powersh: + >/sys/class/rtc/rtc0/device/power/wakeup sh: + echo disabledsh: + init_hal_sensorssh: + typeset 'hal_sensors=kbd'sh: + cat /sys/class/dmi/id/ueventsh: + 2>/dev/null sh: + ls '/sys/bus/iio/devices/iio:device*'sh: + '[' -n  ']'sh: + set_property ro.hardware.sensors kbdsh: + >>/x86.prop sh: + echo 'ro.hardware.sensors=kbd'sh: + init_tscalsh: + lsusbsh: + awk '{ print $6 }'sh: + init_rilsh: + cat /sys/class/dmi/id/ueventsh: + set_property rild.libpath /system/lib/libreference-ril.sosh: + >>/x86.prop sh: + echo 'rild.libpath=/system/lib/libreference-ril.so'sh: + set_property rild.libargs '-d /dev/ttyUSB2'sh: + >>/x86.prop sh: + echo 'rild.libargs=-d' /dev/ttyUSB2sh: + chmod 640 /x86.propsh: + post_initsh: + enable_nativebridge
<14>[   74.685928] sh: + return 0
```
# 解决方案
```
使用这种方式修改脚本让人很蛋疼,收到2^32次伤害
diff --git a/core/Makefile b/core/Makefile
index 26687cf..db833e2 100644
--- a/core/Makefile
+++ b/core/Makefile
@@ -967,10 +967,6 @@ define build-systemimage-target
   $(shell cp bootable/newinstaller/replace/houdini5_* $(PRODUCT_OUT)/system/)
   $(shell cp bootable/newinstaller/replace/enable_nativebridge $(PRODUCT_OUT)/system/bin/)
   $(shell cp bootable/newinstaller/replace/bootanimation.zip $(PRODUCT_OUT)/system/media/)
-  $(shell cat $(PRODUCT_OUT)/system/etc/init.sh|head -n 425 >$(PRODUCT_OUT)/system/etc/init.sh.bak)
-  $(shell mv $(PRODUCT_OUT)/system/etc/init.sh.bak $(PRODUCT_OUT)/system/etc/init.sh)
-  $(shell echo enable_nativebridge >> $(PRODUCT_OUT)/system/etc/init.sh)
-  $(shell echo return 0 >> $(PRODUCT_OUT)/system/etc/init.sh)
去掉上述选项之后,enable_nativebridge的启动是由属性值property:persist.sys.nativebridge来控制
可以选择讲属性值打开来使能上述功能
```
