# 问题描述
某些U盘反复插拔之后在文件管理器中不再显示U盘内容
# 问题分析过程
```
拔掉U盘之后不能够再次识别的log:
10-27 10:19:56.506 D/DirectVolume( 1990): Volume usb0 /mnt/media_rw/usb0 disk 8:32 removed
10-27 10:19:56.506 D/Vold    ( 1990): Volume usb0 state changing 4 (Mounted) -> 0 (No-Media)                                                                                                                
10-27 10:19:56.506 D/MountService( 2286): volume state changed for /storage/usb0 (mounted -> unmounted)
10-27 10:19:56.507 D/MountService( 2286): sendStorageIntent Intent { act=android.intent.action.MEDIA_UNMOUNTED dat=file:///storage/usb0 flg=0x4000000 (has extras) } to UserHandle{-1}
10-27 10:19:56.507 D/MountService( 2286): volume state changed for /storage/usb0 (unmounted -> removed)
10-27 10:19:56.507 D/MountService( 2286): sendStorageIntent Intent { act=android.intent.action.MEDIA_REMOVED dat=file:///storage/usb0 flg=0x4000000 (has extras) } to UserHandle{-1}
拔掉U盘之后能够再次识别的log:
10-14 09:50:57.342 D/DirectVolume( 1974): Volume usb0 /mnt/media_rw/usb0 partition 8:33 removed
10-14 09:50:57.342 D/Vold    ( 1974): Volume usb0 state changing 4 (Mounted) -> 5 (Unmounting)
10-14 09:50:57.342 D/MountService( 2276): volume state changed for /storage/usb0 (mounted -> unmounted)
10-14 09:50:57.343 D/MountService( 2276): sendStorageIntent Intent { act=android.intent.action.MEDIA_UNMOUNTED dat=file:///storage/usb0 flg=0x4000000 (has extras) } to UserHandle{-1}
10-14 09:50:57.343 D/MountService( 2276): volume state changed for /storage/usb0 (unmounted -> bad_removal)
10-14 09:50:57.345 D/MountService( 2276): sendStorageIntent Intent { act=android.intent.action.MEDIA_BAD_REMOVAL dat=file:///storage/usb0 flg=0x4000000 (has extras) } to UserHandle{-1}
10-14 09:50:57.345 D/MountService( 2276): sendStorageIntent Intent { act=android.intent.action.MEDIA_EJECT dat=file:///storage/usb0 flg=0x4000000 (has extras) } to UserHandle{-1}
10-14 09:50:57.345 D/ExternalStorage( 3541): After updating volumes, found 1 active roots
10-14 09:50:57.346 D/MediaProvider( 2676): deleting all entries for storage StorageVolume:
```
可以知道在于是否有分区,通过调查知道在没有分区时是不会主动umount的;
# 解决方案
在system/vold中,卸载U盘时卸载挂载
