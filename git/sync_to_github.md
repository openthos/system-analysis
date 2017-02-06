# 将oslab内部服务器代码同步到github上
## 1.获取"创建仓库"权限,可以看到openthos右边有绿色的"New"图标  
## 2.创建对应的仓库:仓库名最好和历史命名相似  
.gitignore选取android类  
license选取Apache 2.0  
## 3.在openthos/OTO multiwindow branch上在default.xml里添加相应的库项
##4.重新同步代码
#遇到的问题:
repo sync时提示输入github的用户名和密码

## 同步到github上的思路
### 1.有两个manifest文件来管理仓库  
其中一个是180服务器上仓库里的manifest:提供给实验室开发人员下载代码  
另外一个是github上的manifest:提供给所有能够看到github的开发人员下载代码  
而同步的原因是:实验室内部为了方便开发,在实验室内部搭建了一个mirror服务器;而开发人员也是push到实验室内部的服务器;而我们还需要通过github平台提供最新的代码给所有的开发人员,所以需要做一下同步;  
manifest中对每一个仓库采用如下方法管理:
```
  <remote  name="x86"
           fetch="git://gitscm.sf.net/gitroot/android-x86/" />
           <!-- fetch="." -->
  <remote  name="github"
fetch=".." />
<project path="bootable/newinstaller" name="openthos/oto_bootable_newinstaller" remote="github" revision="multiwindow" />
path:repo init方式之后仓库中的位置    
name:repo init --mirror之后在mirror上仓库的位置   
remote:remote的名称,指定了下载地址;也允许采用".",".."等目录管理的写法,就是相对于manifest库位置的相对位置;
revision:branch或者tag
```
180内部和github上下载之后的代码组织方式是不会更改的,即path是相同的;否则出来不同的代码组织目录会造成很多的问题;
### 2.维护了一个提交记录文本  
查找multiwindow分之上最新的sha号,在提交记录中查找,如果能够找到则说明已经提交过了;否则需要push到github上;
