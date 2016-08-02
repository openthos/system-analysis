#How to create Mirror(merge lollipop and marshmallow)
##1.Create the mirror of the lollipop
```
mkdir /opt/git/test/android-x86/  
cd /opt/git/test/android-x86/  
repo init -u git://gitscm.sf.net/gitroot/android-x86/manifest -b lollipop-x86  --mirror  
repo sync  
```
##2.Create the mirror of the marshmallow
```
cp .repo/manifests/default.xml ../lollipop.xml  
rm .repo -rf  
repo init -u git://gitscm.sf.net/gitroot/android-x86/manifest -b marshmallow-x86  --mirror  
repo sync  
cp .repo/manifests/default.xml ../marshmallow.xml 
```
##3.merge them into the same repo
修改aosp的fetch  
```
-           fetch="https://android.googlesource.com/" />  
+           fetch="清华源" />  
```
将两个xml的库都合并到一起，最终的xml文件是lollipop.xml || marshmallow.xml  
##4.上传multiwindow-l-bugfix的代码到mirror上  
下载一份干净的multiwindow-l-bugfix代码:
```
repo start multiwindow-l-bugfix --all  
repo forall -c 'git push git://192.168.0.185/composition/android-x86/$REPO_PROJECT.git multiwindow-l-bugfix:refs/heads/multiwindow-l-bugfix'  
```
##5.create the manifest.xml of the repo
创建一个本地目录:
```
repo init -u git://192.168.0.185/composition/android-x86/manifest.git -b lollipop-x86  
cd .repo/manifests/  
git checkout -b multiwindow-l-bugfix  
cp 我们现在的multiwindow-l-bugfix的xml　default.xml  
修改aosp的fetch:  
-           fetch="https://android.googlesource.com/" />  
+           fetch="git://192.168.0.185/composition/android-x86/" />  
git add default.xml  
git commit  
git push git://192.168.0.185/composition/android-x86/manifest.git multiwindow-l-bugfix:refs/heads/multiwindow-l-bugfix  
```
此时,就ok了.  
repo init -u git://192.168.0.185/composition/android-x86/manifest.git -b multiwindow-l-bugfix  

marshmallow上的和multiwindow-l-bugfix的方式一样．  
