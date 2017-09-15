# AOSP中的OTA升级

## 什么是OTA升级
OTA，全称Over The Air。 OTA升级即意味着设备可以在线升级，而无须返厂进行。  
OTA升级由用户启动或后台自动调用厂商内置在设备中的系统升级程序来完成升级的过程。  
在Android平台上，通常升级程序先从设备厂商的升级服务器上下载对应该设备的“update.zip”，该升级包有可能是一个完备升级包，也有可能是一个增量升级包。  
## 完全升级包与增量升级包的区别
完全升级包，本身包含设备上运行所需的全部软件。对于Android平台而言，在升级过程中/system，甚至/boot分区将会全部清楚。升级后的系统不依赖于升级前的任何系统程序。  
增量升级包，只包含本次升级过程对系统所需变更的软件部分，升级过程中不会擦除/system及/boot分区。  
## AOSP中是否包含创建OTA升级包的代码
AOSP中包含有完整的OTA升级包创建工具及相关代码。
### build/make/core/Makefile
第2259行 AOSP O版本，其他版本代码行号可能有所不同
```Makefile
ifeq ($(build_ota_package),true)
# -----------------------------------------------------------------
# OTA update package

name := $(TARGET_PRODUCT)
ifeq ($(TARGET_BUILD_TYPE),debug)
  name := $(name)_debug
endif
name := $(name)-ota-$(FILE_NAME_TAG)

INTERNAL_OTA_PACKAGE_TARGET := $(PRODUCT_OUT)/$(name).zip

$(INTERNAL_OTA_PACKAGE_TARGET): KEY_CERT_PAIR := $(DEFAULT_KEY_CERT_PAIR)

ifeq ($(AB_OTA_UPDATER),true)
$(INTERNAL_OTA_PACKAGE_TARGET): $(BRILLO_UPDATE_PAYLOAD)
else
$(INTERNAL_OTA_PACKAGE_TARGET): $(BRO)
endif

$(INTERNAL_OTA_PACKAGE_TARGET): $(BUILT_TARGET_FILES_PACKAGE) \
		build/tools/releasetools/ota_from_target_files
	@echo "Package OTA: $@"
	$(hide) PATH=$(foreach p,$(INTERNAL_USERIMAGES_BINARY_PATHS),$(p):)$$PATH MKBOOTIMG=$(MKBOOTIMG) \
	   ./build/tools/releasetools/ota_from_target_files -v \
	   --block \
	   --extracted_input_target_files $(patsubst %.zip,%,$(BUILT_TARGET_FILES_PACKAGE)) \
	   -p $(HOST_OUT) \
	   -k $(KEY_CERT_PAIR) \
	   $(if $(OEM_OTA_CONFIG), -o $(OEM_OTA_CONFIG)) \
	   $(BUILT_TARGET_FILES_PACKAGE) $@

.PHONY: otapackage
otapackage: $(INTERNAL_OTA_PACKAGE_TARGET)

endif    # build_ota_package
```
### 该如何编译生成otapackage版本的update.zip
编译时指定目标为otapackage
```bash
make otapackage
```
### lunch时选择aosp_x86-eng平台,为什么我编译otapackage目标，会提示“ninja: error: unknown target 'otapackage'”
前面的Makefile可以看出，要想编译otapackage目标，需要build_ota_package变量的值true。而在该Makefile第2027行开始。  
 
```Makefile
build_ota_package := true
ifeq ($(TARGET_SKIP_OTA_PACKAGE),true)
    build_ota_package := false
endif
ifeq ($(BUILD_OS),darwin)
    build_ota_package := false
endif
ifneq ($(strip $(SANITIZE_TARGET)),)
    build_ota_package := false
endif
ifeq ($(TARGET_PRODUCT),sdk)
    build_ota_package := false
endif
ifneq ($(filter generic%,$(TARGET_DEVICE)),)
    build_ota_package := false
endif
ifeq ($(TARGET_NO_KERNEL),true)
    build_ota_package := false
endif
ifeq ($(recovery_fstab),)
    build_ota_package := false
endif
ifeq ($(TARGET_BUILD_PDK),true)
    build_ota_package := false
endif
```  
而device/generic/x86/BoardConfig.mk文件的第7行
```Makefile
TARGET_NO_KERNEL := true
```
这一参数为true导致到build_ota_package变量为false，才决定了在AOSP中默认无法以编译otapackage目标。
