＃ Openthos第一步
Openthos派生自AOSP,因此同AOSP一样，Openthos的android部分总是从init.rc开始的。  
也同AOSP一样init.rc是一个公式起始。对于Openthos还有一个面向平台的init.android_x86_64.rc。  
具体init.android_x86_64.rc是在init.rc中导入的：  
```bash
  7 import /init.environ.rc
  8 import /init.usb.rc
  9 import /init.${ro.hardware}.rc
 10 import /init.${ro.zygote}.rc
 11 import /init.trace.rc
```
对于Openthos来说${ro.hardware}，即为android_x86_64。这一点定义于device/generic/common/BoardConfig.mk
```bash
75 BOARD_EGL_CFG ?= device/generic/common/gpu/egl_mesa.cfg
76 endif
77 
78 :BOARD_KERNEL_CMDLINE := root=/dev/ram0 androidboot.hardware=$(TARGET_PRODUCT)
79 
80 COMPATIBILITY_ENHANCEMENT_PACKAGE := true
81 PRC_COMPATIBILITY_PACKAGE := true
```  
androidboot.hardware项在编译时被强制指定成了$(TARGET_PRODUCT)，对当前的OPENTHOS来说，也即是android_x86_64  
在init.android_x86_64.rc，由device/generic/common/device.mk在编译时由init.x86.rc复制而成。
```bash
37　     $(if $(wildcard $(PRODUCT_DIR)fstab.$(TARGET_PRODUCT)),$(PRODUCT_DIR)fstab.$(TARGET_PRODUCT),$(LOCAL_PATH)/fstab.x86):root/fstab.$(TARGET_PRODUCT) \
38　     $(if $(wildcard $(PRODUCT_DIR)wpa_supplicant.conf),$(PRODUCT_DIR),$(LOCAL_PATH)/)wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
39    　 $(if $(wildcard $(PRODUCT_DIR)excluded-input-devices.xml),$(PRODUCT_DIR),$(LOCAL_PATH)/)excluded-input-devices.xml:system/etc/excluded-input-devices.xml \
40　     $(if $(wildcard $(PRODUCT_DIR)init.$(TARGET_PRODUCT).rc),$(PRODUCT_DIR)init.$(TARGET_PRODUCT).rc,$(LOCAL_PATH)/init.x86.rc):root/init.$(TARGET_PRODUCT).rc \
41　     $(if $(wildcard $(PRODUCT_DIR)ueventd.$(TARGET_PRODUCT).rc),$(PRODUCT_DIR)ueventd.$(TARGET_PRODUCT).rc,$(LOCAL_PATH)/ueventd.x86.rc):root/ueventd.$(TARGET_PRODUCT).rc \

```  
init.android_x86_64.rc中，在触发fs事件时，mount_all /fs.${ro.hardware}
```bash
 84 
 85 on fs
 86     mount_all /fstab.${ro.hardware}
 87     setprop ro.crypto.fuse_sdcard true
 88 
｀｀｀　　
mount_all命令将根据fstab.${ro.hardware}亦即fstab.android_x86_64来挂载相关文件系统。  
