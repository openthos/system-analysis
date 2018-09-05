# OpenThos5.1引导及安装说明

引导代码初始来源于Android X86项目
## Android X86项目引导原理
众所周知谷歌的Android发行之初并不是面向PC的，因此其也不是设计用于从BIOS或UEFI启动的。
因此虽然AOSP中的代码可以按X86或X86_64的方式编译，但其并不能用于真实的PC，除却BSP方面的问题便是引导的原因了。
### 标准Android系统的启动流程
1. 硬件的BOOTROM根据芯片相应管脚的电平高低决定是进行出厂线刷还是正常启动逻辑。简单理解就是从Flash启动还是等着从USB等接口上喂数据。下面以正常启动流程来讲述  
2. BOOTROM根据引脚配置决定从FLASH中启动，由于NAND，NVME等等FLASH都不具备XIP特性，因此BOOTROM需要从这样的代码里面把系统加载到内存里执行。但实际上由于同一样芯片上可以运行Linux也可能运行Windows Embedded，甚至其他各种各样的RTOS。BOOTROM也不知道需要加载多少代码，因此厂家默认将是复制比较小的一块程序代码到内存。这段代码我们可以看着Stage1 BootCode。然后就将控制权交给Stage1 BootCode。
3. 前面我们讲到此时系统内存中没有整个操作系统的其他部分，只有Stage1 BootCode，而通常这个Stage1 BootCode都只能非常小，其计量单位以K计。依赖着这个BootCode要想加载全部的系统进内存，通常也不现实。因为此时，首先系统工作在一个极其低效率的状态，通常是12MHz或是24MHz这样的主频上，大量的外设也没有初始化。因此现代操作系统通常在这一步，初始化核心外设，设置系统工作频率。这些工作干完了，空间也就用得差不多，已经不足以加载全部的操作系统。这部分代码通常由汇编来实现，轻轻松松的一个C运行时库都可能撑爆这个空间。因此为了完成后续的工作，Stage1 BootCode就需要从Flash中取出正式的引导程序，这里我们称之为Stage2 BootCode，并为Stage2 BootCode设置好C运行时库的栈。然后将控制权交给Stage2 BootCode。
4. Stage2 BootCode通常是用C语言编写的，可以实现较为复杂的功能，比如与用户的基本互动，可以是但不限于命令行或图形界面。这一块对原生Android来讲就是FastBoot. 当然在不同的设备上Fashboot都经过了相应的定制，甚至中人是遵循了Fastboot的协议，全部代码都由设备厂商重写的也有可能。这一步，Fastboot将根据设备厂商定义的按义或FLASH特定块（Android称之为BCB，Boot Control Block)检查启动参数，以决定是留在Fastboot命令行下、还是执行Fastboot刷机脚本、还是进行Recovery程序、抑或是进行正常的启动。Fastboot命令行及脚本执行都属于Fastboot模式，不再分析。  
4.1 如果是要进入Recovery模式，对需要由Fastboot进行初始化的设备进行初始化后，加载内核并设置ramdisk为recovery分区。Recovery不是本文研究重点。  
4.2 如果是正常启动模式，对需要由Fastboot进行初始化的设备进行初始化后，加载内核并设置ramdisk为ramdisk分区，并指示system及data分区分别位于flash上的什么地方，然后便将控制权交给Kernnel.  
5. Kernel在执行过程中将在init.rc等文件的指示下进行Android系统运行所需要的一系列初始化工作，并挂system、data等相关分区，随后调用zygote进入Android环境。  
因此在PC上运行Android系统需要对其进行一定的改造，让其能从BIOS或是UEFI逐步引导到Android环境
### Android X86的引导流程
0. Stage1 BootCode由BIOS装载（仅限于Legacy BIOS机器），即硬盘上的启动扇区（不具体分析，可以参考MBR格式的硬盘分区资料）
1. Stage2 BootCode由Stage1 BootCode或UEFI装载，对于Android_x86项目而言，即为Grub2。Grub2不具备识别BCB块内容直接进入到recovery状态的能力。因此Android—X86上未实现recovery分区。
2. Stage2 BootCode加载内核及相应的ramdisk。 但由于体系结构的差异，直接加载原生Android的ramdisk分区将会导致启动过程中出现一系列的问题。因此黄志伟先生用busybox先做了一个initrd. 在这个系统中先将环境处理成符合Android的要求后再将系统Switch-root到Android的ramdisk. 下面简要分析
```bash
echo -n Detecting OPENTHOS...

[ -z "$SRC" -a -n "$BOOT_IMAGE" ] && SRC=`dirname $BOOT_IMAGE`

for c in `cat /proc/cmdline`; do
        case $c in
                iso-scan/filename=*)
                        eval `echo $c | cut -b1-3,18-`
                        ;;
                *)
                        ;;
        esac
done

mount -t tmpfs tmpfs /android
cd /android
while :; do
       for device in ${ROOT:-/dev/[hmnsv][dmrv][0-9a-z]*}; do
               check_root $device && break 2
               mountpoint -q /mnt && umount /mnt
        done
        sleep 1
        echo -n .
done
```
首先通过iso-scan来扫描哪个硬盘分区上存在Android-X86的iso镜像或特定文件夹下是否有system.sfs文件　　
然后在check_root这一步通过loop设备一层层的挂系统，iso:/ramdisk.img->/android   iso:/system.sfs—>/sfs  sfs/system.img->/android/system。　　
```bash
if [ -n "$INSTALL" ]; then
        zcat /src/install.img | ( cd /; cpio -iud > /dev/null )
fi
```
判断是否要启动安装程序进行安装  
```
if [ -x system/bin/ln -a \( -n "$DEBUG" -o -n "$BUSYBOX" \) ]; then
        mv /bin /lib .
        sed -i 's|\( PATH.*\)|\1:/bin|' init.environ.rc
        rm /sbin/modprobe
        busybox mv /sbin/* sbin
        rmdir /sbin
        ln -s android/bin android/lib android/sbin /
        hash -r
fi
...
# Other normal steps
load_modules
```
为下一步启动Android准备好设备驱动
```bash
mount_data
mount_sdcard
setup_tslib
setup_dpi
...
echo > /proc/sys/kernel/hotplug
```
设置Android所需要环境  
```bash
exec ${SWITCH:-switch_root} /android /init
```
3. 跳转到Android环境中去。
# OpenThos的改进之处
OpenThos基本上参照了Android-X86的引导流程。
但OpenThos做了如下工作：
1. 将引导程序于Ｇrub2切换到Refind
2. 将/android/system的源从iso文件、.sfs变更到硬盘上的/system分区
3. 将原代码中关于DEBUG模式重复出现的调用shell的代码段抽象成函数
```bash
debug_shell()
{
  pushd

  if [ -e system/bin/sh ] && [ -x system/bin/sh ]; then
    echo Running MirBSD Korn Shell...
    USER="($1)" system/bin/sh -l 2>&1
  else
    echo Running busybox ash...
    sh 2>&1
  fi

  popd
}
```
4. 对于取内核引导时获得的参数抽像了方法，构建了函数　　
```bash
get_param_from_bootargs()
  {
    if [ "$#" -ne 1 ]; then
      dbg_echo "get_param_from_bootargs: The func should be called with 1 parameters, but $# parameters found"
      return $ERROR_PARMETER
    fi

    for c in `cat $CMDLINE`; do
      case $c in
      $1=*)
        local tempParam="$(echo $c | cut -d"=" -f2)"
        if [ -n "$tempParam" ]; then
          eval $1=$tempParam
          return $VALUE_FOUND
        fi
        ;;
      *)
        ;;
      esac
    done

    dbg_echo "get_param_from_bootargs: No value for $1 found"
    return $VALUE_MISS
  }
  ```
  5. 为解决系统安装后部分分区调整而导致分区编号错乱而导到的加载失败，构建了通过UUID来加载分区的方法。
  ```
  #----------------------------------
  # by: David Chan (chanuei@sina.com)
  # date: 2016-08-31
  #
  # Func: mount_part_via_uuid
  # Param:
  #   $1, uuid of the part to be loaded.
  #   $2, mountpoint, the part to be mounted to.
  #   $3, options, "ro" "rw" etc.
  mount_part_via_uuid()
  {
    if [ "$#" -ne 3 ] && [ "$#" -ne 2 ]; then
      dbg_echo "mount_part_via_uuid: The func should be called with 2 parameters, but $# parameters found"
      return $ERROR_PARMETER
    fi

    if [ ! -d "$2" ]; then
      mkdir -p $2
    fi
    local fsType
    get_hd_fstype $1 fsType
    if [ $?=$PARAM_FOUND ] && [ "$#" -eq 3 ]; then
      local varMountOption="-o $3"
    fi
    dbg_echo "fsType for $1 is $fsType"
    if [ "$fsType" = "ntfs" ] || [ "$fsType" = "NTFS" ]; then
      hdPart="$(for c in `blkid | grep -m 1 -i $1`; do  echo $c | grep -i "/dev" | cut -d":" -f1; done)"
      dbg_echo "mount.ntfs-3g $hdPart $2"
      mount.ntfs-3g $hdPart $2
    else
      dbg_echo "mount -t $fsType $varMountOption UUID=$1 $2"
      mount -t $fsType $varMountOption UUID=$1 $2
    fi
  }
```
6. 对于黄志伟先生在init中类似如下的代码进行了便于阅读的处理，并进行了大量的函数化工作  
`for device in ${ROOT:-/dev/[hmnsv][dmrv][0-9a-z]*}; do`
```bash
for i in /sys/block/$d/$d* /sys/block/$d; do
                        [ -e $i/partition ] && p=1
                        [ $p -eq 1 -a "$i" = "/sys/block/$d" ] && break
                        echo $i | grep -q -E "boot|rpmb" && continue
                        [ -d $i ] && ( grep "`basename $i:`" $tempfile || echo "`basename $i` unknown" )
                done
```
改进为类似下面这们便于阅读及直观理解的代码结构：  
```
disk=$(basename $1)
        for i in /sys/block/$disk/$disk*;do
                partNum=$(cat $i/partition)
                case $partNum in
                1)
                        ker_part=/dev/$(basename $i)
                        ;;
                2)
                        sys_part=/dev/$(basename $i)
                        ;;
                3)
                        data_part=/dev/$(basename $i)
                        ;;
                *)
                        ;;
                esac
        done
```

7. 将原来关于硬盘的识别由指定/dev/sdxx /dev/nvmexx这样的开头来扫描改进为通过/sys/class/block接口来判定一个设备是否硬盘设备。这样只要该硬盘内核能认识，安装程序就可以准确进行识别，而需要每次见到新的硬盘种类都需要去给init和install脚本打补丁  
8. 将原来存在于可用磁盘列表中的可移动磁盘从列表中清楚，并将所有的大小计数单位由原来的block数量统一为MB，便于安装时直观理解。
## 安装流程
安装流程分为两种分别是Auto及Manual
```bash
hd_install()
{
        hd_prepare_install
        hd_user_guide
        if [ $? -eq 1 ];then
                hd_manual_install
                sum=5;while [[ sum -gt 0 ]];do echo $sum;sum=`expr $sum - 1`;dialog --title " REBOOTING OPENTHOS" --infobox "\n        $sum" 7 30 ;sleep 1; done
        else
                hd_auto_install
        fi
        rebooting
}
```
安装程序载入后选择是Auto还是Manual
### Auto Install
```bash
hd_auto_install()
{
        dialog --title "Auto Install OPENTHOS" --defaultno --yesno "will ERASE whole hard drive,Continue?" 5 45
        if [ $? -eq 0 ];then
                select_whole_dev || rebooting
                rebuild_all_partition /dev/$choice
                hd_install_all /dev/$choice
        fi
        rebooting
}
```
选择硬盘，对硬盘进行分区，最后再将相应内容安装到硬盘上去。
### Manual Install
```bash
hd_manual_install()
{
        until boto_install_hd; do
                if [ $retval -eq 255 ]; then
                        dialog --title ' Error! ' --yes-label Retry --no-label Reboot \
                                --yesno '\nInstallation failed! Please check if you have enough free disk space to install OPENTHOS.' 8 51
                        [ $? -eq 1 ] && rebooting
                fi
        done
        until boto_install_system_hd; do
                if [ $retval -eq 255 ]; then
                        dialog --title ' Error! ' --yes-label Retry --no-label Reboot \
                                --yesno '\nInstallation system failed!' 8 51
                        [ $? -eq 1 ] && rebooting
                fi
        done
        until boto_install_data_hd; do
                if [ $retval -eq 255 ]; then
                        dialog --title ' Error! ' --yes-label Retry --no-label Reboot \
                                --yesno '\nInstallation data failed!' 8 51
                        [ $? -eq 1 ] && rebooting
                fi
        done
        sum=5;while [[ sum -gt 0 ]];do echo $sum;sum=`expr $sum - 1`;dialog --title " REBOOTING OPENTHOS" --infobox "\n        $sum" 7 30 ;sleep 1; done
        rebooting
}
```
分别询问在哪个分区上安装boto(refind)，system，data的内容。  
基本上相关的内容都尽量进行了函数化。
