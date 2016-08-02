#repo环境简介及实现
内容：

- 环境简介
- 功能需求
- 项目分支整体规划
- 功能实现

# 环境简介
![image](https://github.com/openthos/system-analysis/blob/master/other/doc/git.svg)  
将aosp的代码和android-x86的代码拉到本地创建本地mirror;  
开发从本地mirror上拉取代码，上传代码  
本地mirror每天将新入库的代码上传到github  
# 功能需求
1.从sourcefourge上将android-x86下载到本地，做成本地mirror;
2.将本地代码实时同步到github上，方便不在lab的人员能够获得最新的android源码
# 项目分支整体规划
1.目前状况:  
现在基于android-x86 lillipop上开发，从上面直接拉出新的分支:multiwindow;  
计划release稳定的OS版本，拉出新的分支:multiwindow-l-bugfix;停止新的feature合入,进行已知的bug fix工作;  
2.升级计划  
将multiwindow分支的代码升级到android-M版本；  
# 功能实现
创建本地mirror,创建新的开发分支  
https://github.com/openthos/system-analysis/blob/master/other/doc/android-x86%E6%BA%90%E4%BB%A3%E7%A0%81%E5%BC%80%E5%8F%91%E7%9A%84%E9%83%A8%E7%BD%B2.doc  
将本地mirror上代码上传到github    
https://github.com/openthos/system-analysis/blob/master/other/doc/android-x86%E6%BA%90%E4%BB%A3%E7%A0%81github%E6%89%98%E7%AE%A1%E9%83%A8%E7%BD%B2.doc  
合并mirror  
https://github.com/openthos/system-analysis/blob/master/git/create_mirror.md


