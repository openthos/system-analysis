# 会议纪要<备忘>
## 2017/05/09
### 1.Mesa
Mesa是Android-x86工作的重中之重，而且因为如下原因很容易出现问题：  
 1.Mesa升级比较快，而且可能更加侧重桌面系统，对于Android考虑的并不是很充分，升级mesa很容易出现问题(Android.mk，功能问题)
需要花费更多时间来研究这个问题.  
这方面可以多向maurossi学习  
和Mesa相关的还有LLVM，需要了解一些LLVM的背景和知识  
 2.和Mesa相关的drm_gralloc库，版本太旧而且不是主流，所以考虑使用gbn（还没有调研）
gbn的Advantage:  

    1.upstream  
    2.collaborate with hwcomposer  

gbn的Disadvantage:  

    和kernel结合比较紧密，可能需要经常升级kernel才能更高地支持GPU  
未来这块可能的形式为：  

    镜像中带有gbn+drm_gralloc,如果硬件支持gbn，则使用gbn；否则使用backup的drm_gralloc  

Who I should pay attention:  
marrosi  
emill  

https://groups.google.com/forum/#!msg/android-x86-devel/I2zF_Xey8tg/gjnjNYotBQAJ;context-place=forum/android-x86-devel

`-------------------------------------------------------------------------`
