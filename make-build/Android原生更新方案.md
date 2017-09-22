# <center> Android原生更新方案分析 </center>
整理：三寸丁 （chanuei@sina.com）  
https://github.com/openthos/system-analysis/blob/master/make-build/AOSP%E4%B8%AD%E7%9A%84OTA%E5%8D%87%E7%BA%A7.md  
一文中我们找到了AOSP中本身包含有OTA更新的相关内容，本文对OTA的更新进行深入的挖掘。  
本文的内容，系在互联网相关内容基础上的翻译及整理，非百分之百地原创，敬请理解。如果本文不经意间引述了您遗落在互联网某个角落的某些内容，您需要主张署名权，请联系本文整理者 chanuei@sina.com

# 介绍

## 功能
* 完整系统升级
  - 可以从之前的任意版本进行升级
  - 也可以在创建时，通过指定回滚保护标志位。这样系统将只能向上升级。
* 增量系统升级
  - 通过bsdiff/imgdiff针对文件系统引导镜像制作的补丁
  - 通常增量升级包要远小于完整升级包
* AOSP代码升级/system、/vendor及/boot镜像
  - 可扩展用于升级特定的固件或是通过插件升级基带软件
* 升级包update.zip文件内嵌数字签名
  - 由android.os.RecoverySystem.VerifyPackage() API进行验签。
  同时Recover Console也会进行验签。
* 可实现掉电后的安全重启
  - 修补后的文件
  - 设备将自动启动到恢复控制台RC，直到升级过程完成
  - RC将在系统其他组件升级完成后进行更新，并启动到init脚本中的单次触发的
  flash-recovery服务
* 创建时，可以指定升级时强制执行“恢复到出厂状态”，用以解决升级包中的userdata
与设备中版本不兼容的问题。
  - 在实际使用中，请仅在开发过程中使用此功能。此功能的滥用，将招至骂声一片。
* Updater程序，实际完成了系统的升级过程。此程序位于签名后的升级包中，而不是
存在于设备中。

## AOSP系统升级组件
* Releasetools
  - 用于从一个target-files-package（TFP）创建数字签名后的系统升级包。
    + TFP由Android*构建系统生成
  - Substitute testing for production keys inside a TFP.
* android.os.RecoverySystem相关API
  - 框架API，用于验证及安装系统更新
  - 
  - 将RC命令写入命令文件/cache/recovery后，重启动系统进行恢复控制台。
  - 也被用于进行“恢复出厂设置”
* 恢复控制台（RC)
  - 可选的引导环境
  - 验证并执行系统升级
  - 执行“恢复到出厂设置”
  - 典型情况下，由RecoverSystem留置的命令文件控制
  - 用于手动交互的隐藏菜单
* Updater
  - 系统升级逻辑，以二进制的形式存在于系统升级包中
  - 其AOSP实现版本用来执行以Edify语言编程的升级脚本
  - 平台相关的任务通过插件的方式实现
* 设置程序中关于系统升级UI的intent

## AOSP中的缺失部分
* 并不是端到端方案中的所有组件都是开放源码的
  - 远程用于存放升级包的服务后端（称为Server）
  - 客户端侧的检查更新及下载升级包的机（称为Fetcher）
  - 客户端侧的通知有更新可用的UI（称为Notifier）
* 明确定义的抽象层有助于使得相关功能可以随时访问
  - 只有server及fetcher关心OTA协议，例外情况是类似OMA-DM这样的一个大型
  系统管理框架中的部件。
  - 大部分情况下Fetcher及Notifier是同一个APK
  - 通过android.os.RecoverySystem相关API，完成系统升级软件的其余部分
  - 与设置程序集成
    + Notifier APK应有一个activity，该activity持有
    android.settings.SYSTEM_UPDATE_SETTINGS intent过滤器，用以检查
    更新
    + 在用户点击“关于设备->系统更新”时触发
  - BootReceiver，用以检查/cache/recovery中的RC消息
  - 没有其他必要的框架层面的修改
    + 任何厂商对框架暴虐性地堆砌代码以支持OTA功能的行为都非常值得怀疑，
    除非是在开发OMA-DM
    
## 限制
* 不支持磁盘的重新分区
  - 请为未来的Android发行版保留足够的/system分区剩余空间
  - 请为未来的引导镜像保留足够的boot及recovery分区剩余空间
  - 同一时刻只能处理一个升级包
  - 升级过程中设备无法使用
  - 升级过程中出现错误通常都需要RMA(进行返修授权，即通常的接受数据损失)

# 文件系统配置

## 分区布局
* boot
  - AOSP引导镜像
  - Linux内核及ramdisk被挂载为根文件系统
  - 包含init，及挂载/system引导Android其余部分的必要工具
* system
  - 全部的Android系统应用及相关库
  - 通常以只读的方式挂载
    + 增量升级依赖于/system处于一个特定的状态
      * 对于启用dm-verity的ext4，降至块设备层进行处理
      * 其他情况下,按逐文件的方式进行处理（陈旧的方法）
    + 任何时候以可读写方式挂载，都将导致ext4的superblock改变
* vendor
  - 在部分android设备上存在，其目的及限制类似于/system
  - 包含一些非AOSP提供的，而是厂商指定的应用及其相关库
* oem
  - 在某些设备上存在，包含厂商特定的oem.prop文件、商标及打包的应用
  - 如果oem.prop文件影响到OTA升级，请通过-o选项将其传递给
  ota_from_target_files
  - OTA升级不会触及这一部分，如果你在这里放置程序，这些程序仅可通过
  Play Store或同类的商店类应用更新
* data
  - 下载的应用
  - 应用数据
  - Davik缓存（legacy）
  - 一般不会被OTA更新所触及
  - 由”恢复出厂设置”擦除
* recovery
  - 可选的AOSP引导镜像
  - 包含有“recovery”程序的ramdisk，为RC的实现
* misc
  - 非常小的空间，不包含文件系统
    + 直接通过块设备node写入的BCB（Bootloader控制块）
  - 用于RC及bootloader间通信
* persistent
  - 缓存用户证书，用以对“恢复出厂设置”进行授权
  - 存放“Fastboot OEM unlock”标志
  - OTA更新不会触及此分区
* metadata
  - 包含加密后的用户数据的密码学元数据
  - OTA更新不会触及此分区
* cache
  - 临时存储，其内容可能随时被擦除
  - 被某些程序用作临时存储或是下载区
    + 需要特殊的APK权限
  - 通常OTA升级包被下载到了这里
    + 现在恢复控制台已经可以直接从userdata分区读取OTA升级包
    + pre-recovery服务将解密包含有升级文件的块，之后再将升级文件载入到
    RC中
  - 被applypatch用作临时存储
  - 将在”恢复出厂设置”时被擦除
  - CDD(兼容性定义文件)中建议100M+的大小，通常设为/system分区的2/3大小

## Android引导镜像
* 容器文件格式，内含metadata、kernel镜像、ramdisk，及可选的二级引导
bootloader镜像
* 由system/core/mkbootimg创建
* 在两处用到
  - 在正常编译过程中，由生成系统调用，以在$OUT创建引导镜像
  - 在基于一个target-files-package装配一个OTA升级包时由Rleasetools创建
* mkbootimg生成后，由boot_signer工具签名
  - system/extras/verity
  - Lollipop及以上系统验证后引导功能的一部分

## fstab
* 设备上所有文件系统的定义文件
  - 不是分区信息，不含偏移/顺序/分区大小等信息
* 由恢复控制台RC、fs_mgr，及Releasetools使用
* 在旧版android中
  - 通常为文件recovery.fstab，仅由恢复控制台RC使用
  - 引导时通过init.rc脚本中的手动命令挂载
  - 现在挂载由fs_mgr完成，与RC共享fstab
* 实现挂载点到设备节点的映射，及文件系统类型指定

# RELEASETOOLS
## Target_Files-Package (TFP)
* 由“make target-files-package”创建
  - 生成逻辑在build/core/Makefile中
* Zip文件，包含有系统特定发行版本的快照，生成OTA升级包所需的全部素材
  - 单个TFP，可以用来创建一个完整镜像升级包
  - 两个TFP，可以创建一个增量升级包
* 子目录中包含镜像内容
  - BOOT/、RECOVERY/、SYSTEM/、VENDOR
  - 预生成的boot及filesystem镜像在IMAGES/下
* 可通过定义"radio文件"来增加额外的设备相关的blobs
(***不知道怎么翻译这里的blob***)
  - 感觉是一个过进名称，事实上并不需要与设备的基带有任何的联系
  - 在AndroidBoard.mk中：
    + $(call add-radio-file, myblob.dat)
  - target-files-package结束于RADIO/目录
  - RealseTools平台相关的扩展处理这些文件

## Android安全性
* 所有APK都经过数字签名
  - 一个应用对应用的升级版本，必须使用相同的密钥进行签名，否则将导致应用的
  数据无法访问。
  - 希望共享user ID的应用必须使用相同的密钥进行签名
  - LCOAL_CERTIFACATE指定了密钥，默认是**testkey**
* 如果不是以预期密钥组中的密钥签名的话，OTA升级包将被系统忽略
* AOSP有5个密钥，存放于build/target/product/security:
  - Testkey：签名APK的默认密钥
  - Platform：核心平台包使用此密钥签名
  - Shared：Home进程及联系人进程交互数据用
  - Media：media/download系统里的包
  - Verity：对boot、recovery，及/system与/vendor的dm-verity root 
  hash值镜像进行签名
* 这些2048位的密钥由openssl以公幂e为3创建
* 不能用内置于build中的AOSP密钥来发布产品
  - 测试用密钥，只能在开发过程中使用，兼容性测试套件CTS中强制要求
  - Relasetools中的*sign_target_files_apks*工具可用来从TFP中将测试
  用密钥转换为真实的产品密钥
    + 用新密钥重新签名所有APK
    + 重新创建以新的verity密钥签名的boot、system、recovery、vendor镜像
    + 替换RC的ramdisk中OTA验证密钥
    + 替换boot ramdisk中的dm-verity root hash密钥
    + 更新IMAGES/下预生成的镜像

## ota_from_target_files
* 位于AOSP源码的build/tools/releasetools目录
* 用于从一个或多个TFP创建OTA升级包的脚本，比较有用的参数是：  
```  
  --incremental-from <TFP>　从源TFP创建一个增量升级包
  --wipe-user-data          OTA升级在安装时将会擦除/data分区
  --no_prereq　　  　  　 　　禁用回滚保护选框
  --package_key             用于对包进行签名的密钥，默认为testkey
  --block                   生成一个块级OTA升级包
  --two-step                将首先升级RC，然后才会执行其他升级任务
                            通常不需要此选项，但当OTA升级包中的updater
                        需要依赖于新内核时，需要用到　　  　  　 　
```  
* 对于大部分平台相关的升级任务，可以通过实现python扩展来完成升级过程中的额外工作
* 创建一个软件升级包应包括全部的镜像、updater的二制制及updater要解析的Edify脚本

## 系统升级包创建
