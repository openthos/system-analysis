# 2017年2月１４－１５日从ｒ３０到r38的升级日志
记录本次升级操作的动作，以备后查
##　整体策略
### 指向aosp部分的进行了升级并把r38 merge到ｍｕｌｔｉｗｉｎｄｏｗ分支  
在ｍｉｒｒｏｒ服务器上.repo/manifest.xml 把其中的 aosp 这个 remote 的 fetch 从 
https://android.googlesource.com 改为 https://aosp.tuna.tsinghua.edu.cn/。
```
<manifest>
   <remote  name="aosp"
-           fetch="https://android.googlesource.com"
+           fetch="https://aosp.tuna.tsinghua.edu.cn"
            review="android-review.googlesource.com" />

   <remote  name="github"
```
同时，修改 .repo/manifests.git/config，将
```
url = https://android.googlesource.com/platform/manifest
```
更改为
```
url = https://aosp.tuna.tsinghua.edu.cn/platform/manifest
```
这样server就可以同步下来就可以同步下来所有的tag  
在本地同步下来所有的tag,然后讲指向aosp部分的库切换到一个分支用来做合并工作
(我临时将manifest.xml中指向x86部分的project删除，repo的动作都是只针对aosp部分)，然后将android-5.1.1_r38合并到multiwindow分支
```
git merge android-5.1.1_r38
```
其中manifests中有两个库在aosp范围内冒充ａｏｓｐ,其实指向我们自己的分支
```
external/libusb_aah   这个库应该指向aosp的主分支而不是android-5.1.1_r38的tag
packages/apps/Printer  这个库是openthos自己的应用
```
这两个库应该被整理

### 另一部分保持了指向lollipop-x86分支(openthos从android-x86拉取时的快照状态)  
在分支合并前从manifest删除指向x86的project,合并上传完毕后恢复回来就好
### 另一部分和github保持同步(即志伟push到github上的部分)
在分支合并前从manifest删除指向x86的project,并从github上pull下来，然后上传
```
project bootable/newinstaller/
project build/
project device/generic/common/
project frameworks/av/
project frameworks/base/
project frameworks/native/
project kernel/
project packages/apps/CertInstaller/
project packages/apps/Email/
project packages/apps/Exchange/
project packages/apps/Settings/
project packages/apps/UnifiedEmail/
project packages/providers/DownloadProvider/
project system/core/ 
```
可以正常编译，初步使用没有问题；
### 其他
openthos启用了openssl库，这个库没有变更到r38版本，仍然和ＣＭ的分支保持相同；
## 潜在问题
１．从github上下载的代码因为没有vendor/intel/houdini，所以不支持arm的apps;  
<font color=red>全员应知晓</font>
