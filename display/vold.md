# Vold总结  
### 目前Vold支持的文件系统格式:
ext2,ext3,ext4,fat32,fat16,extfat,iso9660;  
### 不支持的重要格式:NTFS  
### 不支持一个在一块物理设备上存在多个分区.  

## Android Vold设计的部分思路
### 一个U盘只有一个分区,在代码中是指volume;
/storage/usb0中usb0即是volume的label,如果存在多个分区那么当有一个分区成功挂载到/storage/usb0上时,其他所有的分区都放弃挂载;  
这种是不合理的设计,在AndroidM已经修复,不再使用固定的挂载点而是根据分区的Label动态创建挂载点;
### 修改思路:
修改挂载点位动态设置;
### 修改的部分为:
HAL层vold和Framework层的MountService相关业务逻辑
