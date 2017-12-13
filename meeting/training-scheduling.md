根据Intel Desktop PC / Tablet PC的硬件特性和Andoid-x86移植常见问题，草拟以下培训大纲，供进一步讨论，以确定最终的大纲。

* Android-x86 porting introduction
  - Porting goal
  - Differences from AOSP
  - Steps of porting
    - Prepare codebase (manifest)
    - Device configuration
    - Fix building errors
    - Fix boot failure

* Android building system
  - Device configuration makefiles
  - Android Makefile (Android.mk)
  - Android-x86 iso
  - Kernel building
  - ninja / kati / blueprint / soong

* Kernel porting
  - Policy
  - android/common tree
  - Drivers patches
  - Mauro's tree

* Android-x86 Booting
  - initrd.img
  - init
  - ueventd
  - init.sh
  - zygote
  - system_server
  - HAL selection
  - HIDL HAL

* Beginning Android NDK
  - binder overview (X)
  - RefBase (X)
  - AIDL / HIDL (X)
  
* Graphic HAL
  - egl (X)
  - drm_gralloc
  - mesa
  - libdrm
  - GPUs support status
    - Intel (i915 / i965)
    - AMD (radeon / amdgpu)
    - Nvidia (nouveau)
    - Vmware (vmwgfx)
    - Qemu (virgl)
  - uvesafb / v86d
  - Software renderer: llvmpipe / SwiftShader
  - Issues: RGBA_8888, YV12
  - gbm_gralloc + drm_hwcomposer
  - minigbm + iacomposer
  - android graphic: allocator / bufferqueue / composer / mapper (X)
  - multiscreen
  - SurfaceFlinger overview (X)

* Audio HAL
  - libaudio
  - HDMI audio
  - IntelHDMI
  - AudioTrack (X)
  - AudioEffect (X)
  - AudioRecord (X)
  - AudioPolicy (X)
  - AudioFlinger overview (X)

* Input
  - Powe button
  - Touchscreen calibration
  - Gamepad / Mouse / Touchpanel etc.
  - EventHub / InputListener / InputDispatcher
  - Virtual Input Device

* Sensors HAL
  - libsensors
    - kbdsensor
    - iio-sensors
    - hdaps / s103t_sensor / w500_sensor
    - intel hsb sensor
  - Sensor HAL selection  
  - Motion sensors (X)
  - Environmental sensors (X)
  - Position sensors (X)

* Vold (mount daemon)
  - ntfs
  - exfat
  - iso9660 / udf
  - blkid / e2fsprogs
  - SDCARD=
  - vold 2.0 modification (historical)

* RIL
  - Historical changes
  - huawei m2m ril (X)
  - voice (X)
  - sms (X)
  - data service (tdd, fdd ...) (X)

* Wifi
  - Fix for 8.0
  - Interface name
  - Unsolved issues: p2p / wifi display
  - WifiService overview (X)
  - wpa_supplicant / p2p_wpa_supplicant (X)
  - nl80211 / wext (X)
  - Wifi HAL overview (X)

* Bluetooth
  - Bluetooth HAL, history
  - Fix for 8.0
  - btattach / rtk_hciattach
  - BluetoothService overview (X)

* Hardware accelerated codec
  - ffmpeg / stagefright-plugins
  - libva / vaapi
  - frameworks/av patches

* Camera HAL overview
  - uvc camera
  - v4l2 (X)

* Power HAL
  - x86power
  - libsuspend
  - power supply class (?)
  - ACPI (X)
  - PowerManagerService overview (X)
  - wake_lock (X)

* NativeBridge support (houdini)
  - introduction
  - libnb / libhoudini
  - vendor/intel/houdini

* GMS integration
  - vendor/google
  - opengapps

* Miscellaneous
  - Superuser
  - Firmware
  - Settings
  - Add prebuilt apps
  - Lights HAL

内容比较广，可以建议黄sir以此为线索分享一下自己发现问题、分析问题并解决问题的经验和方法，供团队学习。Graphic部分是对用户体验和系统性能影响最大的部分，也是涉及模块最多的部分，建议能够投入两天以上的时间。

