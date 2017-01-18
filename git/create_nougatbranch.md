# 合并Android-x86 Nougat-x86分支到185服务器的合成仓库中
## 185合成仓库介绍:
按照android source的管理办法,一套android的source中包含多个仓库,而多个仓库是通过repo和manifest来管理的;  
不同的source只需要拣选仓库和仓库的分支或者tag,组合称一套source;我们也按照android的这种管理办法,在185上搭建了一个合成仓库;  
## 任务描述:
将android-x86的nougat分支做到实验室内部的mirror上,方便实验室内部下载;
## 步骤
### 1.下载android-x86源码  
```
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b nougat-x86  
repo sync --no-tags --no-clone-bundle  
```
### 2.上传manifests.git的nougat-x86分支进入android-x86代码的
```
cd .repo/manifests/
git checkout -b nougat-x86
git add .;git commit
```
上传到server上
```
git push git://192.168.0.185/composition/android-x86/manifest nougat-x86:refs/heads/nougat-x86
```
### 3.上传代码到mirror上  
首先在所有的仓库下确定上传的url
```
repo forall -c 'git remote add work git://192.168.0.185/composition/android-x86/$REPO_PROJECT $@'
repo forall -c 'git push work nougat-x86:refs/heads/nougat-x86'
```
## 中间会遇到问题:
### 1.仓库的名称和路径不对
这个就不知道android是怎么考虑的了,除了新增了将近80个库,其他的库的路径也不一致,导致上传失败;   
fix办法:  
修改project的name即在server上的代码路径
###2.新增了许多库没有办法,只能在server上新建仓库了
```
git init --bare 仓库.git
chown gitdaemon:nogroup 仓库.git
```
## 同步测试
```
repo init -u git://192.168.0.185/composition/android-x86/manifes -b nougat-x86
```
问题:
```
git clone git://192.168.0.185/composition/android-x86/platform/hardware/libhardware -b nougat-x86
Cloning into 'libhardware'...
fatal: Remote branch nougat-x86 not found in upstream origin
```
没有找到这个分支,检查分支中...
