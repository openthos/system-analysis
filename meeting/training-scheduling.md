根据Intel Desktop PC / Tablet PC的硬件特性和Andoid-x86移植常见问题，草拟以下培训大纲，供进一步讨论，以确定最终的大纲。


* Beginning Android NDK
  - init
  - zygote
  - binder overview
  - RefBase
  - AIDL / HIDL
  - Android Makefile (Android.mk)
* Graphic HAL
  - egl
  - mesa
  - drm
  - android graphic: allocator / bufferqueue / composer / mapper
  - multiscreen
  - SurfaceFlinger overview
* Audio HAL
  - AudioTrack
  - AudioEffect
  - AudioRecord
  - AudioPolicy
  - AudioFlinger overview
* Input / Sensors
  - Motion sensors
  - Environmental sensors
  - Position sensors
  - Sensors HAL
  - Gamepad / Mouse / Touchpanel etc.
  - EventHub / InputListener / InputDispatcher
  - Virtual Input Device
* RIL
  - huawei m2m ril
  - voice
  - sms
  - data service (tdd, fdd ...)
* Bluetooth / Wifi
  - WifiService overview
  - wpa_supplicant / p2p_wpa_supplicant
  - nl80211 / wext
  - Wifi HAL overview
  - BluetoothService overview
  - Bluetooth HAL
* Camera HAL overview
  - uvc camera
  - v4l2
* Power HAL
  - power supply class
  - ACPI
  - PowerManagerService overview
  - wake_lock

内容比较广，可以建议黄sir以此为线索分享一下自己发现问题、分析问题并解决问题的经验和方法，供团队学习。Graphic部分是对用户体验和系统性能影响最大的部分，也是涉及模块最多的部分，建议能够投入两天以上的时间。

