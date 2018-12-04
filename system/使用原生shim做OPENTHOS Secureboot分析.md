# 使用原生shim做OPENTHOS Secureboot分析
***注: 原生指shim的官方开发者编译的且去微软做过程序签名的版本***
## 原生shim是如何引导Linux的
1. shim.efi在微软做了签名，签后程序命名为boot{$ARCH}.efi  
2. shim.efi固定引导同目录下的grub{$ARCH}.efi；对于文件名不为grub{$ARCH}.efi的，需要以参数的形式提供给shim.
3. grub{$ARCH}.efi再根据grub.cfg中操作系统条目及用户的选择来启动对应的linux系统。  


**在原生系统如ubuntu上，U盘上相关文件为：**  
```bash
FAT32:/EFI/
└── BOOT
    ├── BOOTx64.EFI
    └── grubx64.efi
```  
其安装后硬盘上的相关文件为：  
```bash
ESP:/efi
├── boot
│   └── grub
│       ├── efi.img
│       ├── font.pf2
│       ├── grub.cfg
│       ├── loopback.cfg
│       └── x86_64-efi
│           ├── acpi.mod
│           ├── adler32.mod
│           ├── ahci.mod
│           ├── .........
│           ├── xzio.mod
│           └── zfscrypt.mod
├── EFI
│   ├── BOOT
│   │   ├── BOOTx64.EFI
│   │   ├── fbx64.efi
│   │   └── grubx64.efi
│   └── ubuntu
│       ├── BOOTX64.CSV
│       ├── fw
│       ├── fwupx64.efi
│       ├── grub.cfg
│       ├── grubx64.efi
│       ├── mmx64.efi
│       └── shimx64.efi
└── grub2
    └── grub.cfg
```  
　　通过查看文件信息：  
```bash
test@test-THTF-T-Series:~$ sudo ls -l /boot/efi/EFI/BOOT/BOOTx64.EFI /boot/efi/EFI/ubuntu/shimx64.efi
-rwx------ 1 root root 1196736 Nov 14 02:14 /boot/efi/EFI/BOOT/BOOTx64.EFI
-rwx------ 1 root root 1196736 Nov 14 02:14 /boot/efi/EFI/ubuntu/shimx64.efi
```  
　　可以确定BOOT下面的BOOTx64.EFI与ubuntu下面的shimx64.efi是同一文件。而在各自同目录下都有一个名为grubx64.efi文件。  
　　再来看一下NVRAM中保存的引导记录：  
```bash
test@test-THTF-T-Series:~$ sudo efibootmgr -v
BootCurrent: 0000
Timeout: 1 seconds
BootOrder: 0000,0002
Boot0000* ubuntu	HD(1,GPT,1a2a2e76-1d5d-4cc4-b6b0-d3cf0681a2e4,0x800,0x100000)/File(\EFI\UBUNTU\SHIMX64.EFI)
Boot0002* Hard Drive	BBS(HD,,0x0)/VenHw(5ce8128b-2cec-40f0-8372-80640e3dc858,0200)..GO..NO..........H.G.S.T. .H.T.S.5.4.1.0.1.0.A.9.E.6.8.0...................\.,.@.r.d.=.X..........A...........................>..Gd-.;.A..MQ..L. . . . . . .D.J.0.1.2.W.A.4.J.0.1.5.S.3........BO..NO..........P.h.i.s.o.n. .S.M.2.8.0.2.5.6.G.P.M.C.1.5.B.-.S.1.0.C.2...................\.,.@.r.d.=.X..........A...........................>..Gd-.;.A..MQ..L.1.0.9.C.7.0.4.6.C.0.D.9.0.0.2.3.3.0.3.6........BO
```  
　　可以看到创建了一条使用SHIMX64.EFI启动，名为ubuntu的引导记录项，且系统设定的引导顺序正是这条记录优先。  
　　Secureboot时：  
1. 如果系统能够正常按NVRAM中设定的引导顺序启动，则UEFI系统固件将会校验SHIMX64.EFI，签名信息验证无误后从SHIMX64.EFI启动。再由SHIMX64.EFI对同目录下的grubx64.efi进行验签后启动  
2. 如果引导记录项缺失，或是因为某种其他原因系统无法从SHIMX64.efi启动，将会按UEFI中设定的硬盘、Ｕ盘的顺序，逐个来找第一个FAT32或是ESP分区下的/EFI/BOOT/BOOTx64.EFI（查找时不区分大小写），签名信息验证无误后从该BOOTx64.EFI启动，再由BOOTx64.EFI进一步对同目录下的grubx64.efi进行验签后启动。  

## OPENTHOS拟如何实现通过原生shim做安全启动  
***问题一、Shim引导boto的路径问题***  
　　OPENTHOS所用的BOTO源自refind，refind在使用过程中需要refind_x64.efi与其对应的驱动等内容于同一个目录下。在OPENTHOS中，为了避免将BOTO误认成其他系统所用到的相关.efi程序，从而最终在BOTO给出的现有操作系统选单中误显示，应将refind_x64.efi及其对应的驱动等内容保存到EFI/BOTO目录下。  
　　为保证U盘或基于硬盘的Fallback启动模式能正常工作，因此必须在U盘的第一个FAT32分区或是ESP分区的EFI/BOOT目录下面留有一个名为bootx64.efi，此efi程序实应为shimx64.efi。  
　　在fallback情况下，名为bootx64.efi的shim系被UEFI系统以无参数的形式启动的，因此下一步只能验证并引导到EFI/BOOT下的grubx64.efi。并不能直接去引导EFI/BOTO下面的refind_x64.efi。  
***问题二、Shim引导boto的签名问题***  
　　Ubuntu及RedHat等一众Linux厂商，由于在原生shim中已经内容了用于验签自己的grubx64.efi的密钥，因此只要是以相同的私钥签名出来的grubx64.efi都可以直接验签。  
　　而OPENTHOS并无相关的密钥，因此无法签出可以由原生shim直接验签的程序来。　　
### 解决引导路径问题的思路
　　使用一个伪程序将其命名为grubx64.efi，在其被shim引导后，将直接调用EFI/BOTO下面的refind_x64.efi。
　　此时Ｕ盘的FAT32分区或是硬盘的EFI/BOOT与EFI/BOTO目录文件结构将如下:  
```bash
ESP:/efi
└── EFI
    ├── BOOT
    │   ├── BOOTx64.EFI
    │   └── grubx64.efi -----> /EFI/BOTO/refind_x64.efi
    └── BOTO
        ├── drivers
        ├── themes
        ├── tools
        ├── grubx64.efi -----> /EFI/BOTO/refind_x64.efi
        ├── refind.conf
        ├── refind_x64.efi
        └── shimx64.efi
```  
　　对于NVRAM中正常的启动引导项，OPENTHOS，通过efibootmgr指定成引导EFI/BOTO/shimx64.efi。这样即便ESP分区中的EFI/BOOT中的内容被别的Linux操作系统在安装过程中替换，启动引导项仍能工作。  
### 解决签名问题的方法
　　按照http://www.rodsbooks.com/refind/secureboot.html 一节所述，用MOK来解决  

```text
          Managing Your MOKs

The preceding instructions provided the basics of getting rEFInd up and running, including using MokManager to enroll a MOK on your computer. If you need to sign binaries, though, you'll have to use additional tools. The OpenSSL package provides the cryptographic tools necessary, but actually signing EFI binaries requires additional software. Two packages for this are available: sbsigntool and pesign. Both are available in binary form from this OpenSUSE Build Service (OBS) repository, and many distributions ship with at least one of them. The following procedure uses sbsigntool. To sign your own binaries, follow these steps (you can skip the first five steps if you've successfully used refind-install's --localkeys option):

    If it's not already installed, install OpenSSL on your computer. (It normally comes in a package called openssl.)
    If you did not re-sign your rEFInd binaries with refind-install's --localkeys option, type the following two commands to generate your public and private keys:

    $ openssl req -new -x509 -newkey rsa:2048 -keyout refind_local.key \
      -out refind_local.crt -nodes -days 3650 -subj "/CN=Your Name/"
    $ openssl x509 -in refind_local.crt -out refind_local.cer -outform DER

    Change Your Name to your own name or other identifying characteristics, and adjust the certificate's time span (set via -days) as you see fit. If you omit the -nodes option, the program will prompt you for a passphrase for added security. Remember this, since you'll need it to sign your binaries. The result is a private key file (refind_local.key), which is highly sensitive since it's required to sign binaries, and two public keys (refind_local.crt and refind_local.cer), which can be used to verify signed binaries' authenticity. The two public key files are equivalent, but are used by different tools—sbsigntool uses refind_local.crt to sign binaries, but MokManager uses refind_local.cer to enroll the key. If you used refind-install's --localkeys option, this step is unnecessary, since these keys have already been created and are stored in /etc/refind.d/keys/.
    Copy the three key files to a secure location and adjust permissions such that only you can read refind_local.key. You'll need these keys to sign future binaries, so don't discard them.
    Copy the refind_local.cer file to your ESP, ideally to a location with few other files. (MokManager's user interface becomes unreliable when browsing directories with lots of files.)
    Download and install the sbsigntool package. Binary links for various distributions are available from the OpenSUSE Build Service, or you can obtain the source code by typing git clone git://kernel.ubuntu.com/jk/sbsigntool.
    Sign your binary by typing sbsign --key refind_local.key --cert refind_local.crt --output binary-signed.efi binary.efi, adjusting the paths to the keys and the binary names.
    Copy your signed binary to a suitable location on the ESP for rEFInd to locate it. Be sure to include any support files that it needs, too.
    Check your refind.conf file to ensure that the showtools option is either commented out or includes mok_tool among its options.
    Reboot. You can try launching the boot loader you just installed, but chances are it will generate an Access Denied message. For it to work, you must launch MokManager using the tool that rEFInd presents on its second row. You can then enroll your refind_local.cer key just as you enrolled the refind.cer key.

At this point you should be able to launch the binaries you've signed. Unfortunately, there can still be problems; see the upcoming section, Secure Boot Caveats, for information on them. Alternatively, you can try using PreLoader rather than Shim.
```
