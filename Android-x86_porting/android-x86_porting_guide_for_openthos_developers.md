#Android-x86 Porting Guide for OPENTHOS Developers

本文通过对android-x86的移植过程做完整的记录，提高OPENTHOS开发者对android-x86项目的整体理解，是HAL开发的入门指导。
##从远程仓库获取源代码
- 初始化本地源代码仓库
```
mkdir oreo-x86
cd oreo-x86
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b oreo-x86
```
- 在oreo-x86/.repo/manifests目录中可见**android-x86.xml**、 **default.xml**两个文件，其中：
default.xml用于描述远程AOSP源代码仓库；
android-x86.xml用于描述andriod-x86源代码仓库。
- 配置AOSP源代码仓库
由于部分国家或地区Google访问受限，可用tsinghua tuna源替换googlesource源提高源代码同步速度。
```
sed -i 's:android.googlesource.com:aosp.tuna.tsinghua.edu.cn:g' .repo/manifests/default.xml
```
- android-x86.xml中remove-project标签用于描述在AOSP项目中移除的项目，部分需要被修改的项目也通过此方法进行替换。
- 为了完整的重现移植流程，暂时从android-x86.xml中移除如下项目：
```
<remove-project name="device/generic/common" />
<remove-project name="device/generic/x86" />
<remove-project name="device/generic/x86_64" />
<project path="device/generic/common" name="device/generic/  common" remote="x86" revision="oreo-x86" />
<project path="device/generic/firmware" name="device/generic/firmware" remote="x86" revision="oreo-x86" />
<project path="device/generic/x86" name="device/generic/x86" remote="x86" revision="oreo-x86" />
<project path="device/generic/x86_64" name="device/generic/x86_64" remote="x86" revision="oreo-x86" />
```
- 从远程仓库下载源代码
```
repo sync -f -j1
```
##创建设备配置文件
本文档中，添加的设备配置文件vendor name为tsinghua，device name为openthos_32、openthos_64，对应32位、64位openthos。本文档以openthos_64为例，openthos_32类似。
- 创建文件夹
```
mkdir device/tsinghua/openthos_64
```
- 从android-x86获取common、firmware
```
cd device/tsinghua
git clone git://git.osdn.net/gitroot/android-x86/device/generic/firmware -b oreo-x86
git clone git://git.osdn.net/gitroot/android-x86/device/generic/common -b oreo-x86
```
- 修改common、firmware中的设备配置文件路径
```
for var in `grep -rl device/generic`; do sed -i 's:device/generic:device/tsinghua:g' $var; done
```
- 创建device/tsinghua/openthos_64/vendorsetup.sh文件，用于在lunch宏中添加openthos_64设备选项
```
add_lunch_combo openthos_64-eng
add_lunch_combo openthos_64-userdebug
add_lunch_combo openthos_64-user
```
- 创建device/tsinghua/openthos_64/AndroidProducts.mk文件
```
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/openthos_64.mk
```
- 创建device/tsinghua/openthos_64/BoardConfig.mk文件，用于配置设备
```
TARGET_NO_BOOTLOADER := true
TARGET_CPU_ABI := x86_64
TARGET_ARCH := x86_64
TARGET_ARCH_VARIANT := x86_64

TARGET_2ND_CPU_ABI := x86
TARGET_2ND_ARCH := x86
TARGET_2ND_ARCH_VARIANT := x86_64

TARGET_CPU_ABI_LIST_64_BIT := $(TARGET_CPU_ABI) $(TARGET_CPU_ABI2) $(NATIVE_BRIDGE_ABI_LIST_64_BIT)
TARGET_CPU_ABI_LIST_32_BIT := $(TARGET_2ND_CPU_ABI) $(TARGET_2ND_CPU_ABI2) $(NATIVE_BRIDGE_ABI_LIST_32_BIT)
TARGET_CPU_ABI_LIST := $(TARGET_CPU_ABI) $(TARGET_CPU_ABI2) $(TARGET_2ND_CPU_ABI) $(TARGET_2ND_CPU_ABI2) $(NATIVE_BRIDGE_ABI_LIST_64_BIT) $(NATIVE_BRIDGE_ABI_LIST_32_BIT)

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_USERDATAIMAGE_PARTITION_SIZE := 576716800
BOARD_CACHEIMAGE_PARTITION_SIZE := 69206016
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 512
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

include device/tsinghua/common/BoardConfig.mk
```
- 创建device/tsinghua/openthos_64/openthos_64.mk文件
```
# includes the base of Android-x86 platform
$(call inherit-product,device/tsinghua/common/x86_64.mk)

# Overrides
PRODUCT_NAME := openthos_64
PRODUCT_BRAND := Android-x86
PRODUCT_DEVICE := openthos_64
PRODUCT_MODEL := Generic Android-x86_64
```
##编译并测试
运行
```
. build/envsetup.sh
```
运行
```
lunch
```
并选择**openthos_64-userdebug**
```
You're building on Linux

Lunch menu... pick a combo:
     1. aosp_arm-eng
     2. aosp_arm64-eng
     3. aosp_mips-eng
     4. aosp_mips64-eng
     5. aosp_x86-eng
     6. aosp_x86_64-eng
     7. openthos_32-eng
     8. openthos_32-userdebug
     9. openthos_32-user
     10. openthos_64-eng
     11. openthos_64-userdebug
     12. openthos_64-user

Which would you like? [aosp_arm-eng] 11
```
运行
```
make iso_img -j32
```
此时，可以去喝咖啡。