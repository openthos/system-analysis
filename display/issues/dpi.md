http://blog.csdn.net/xyz_lmn/article/details/38304427  
http://api.apkbus.com/guide/practices/screens_support.html  
# DPI基础  
1. 怎么计算屏幕物理尺寸  
cat /sys/kernel/debug/dri/0/i915_display_info  
physical dimensions: 340x190mm  
屏幕对角线长度:(width^2+height^2)^1/2  
inch和cm兑换:1inch=2.54cm  
所以屏幕尺寸为:(34*34+19*19)^(1/2)/2.54=15.3inch  
2. 屏幕的密度:
分辨率/屏幕尺寸  
我的显示器目前分辨率位1920x1080,对角线的分辨率个数为:(w_resolution^2+h_resolution^2)^1/2  
所以屏幕的DPI为:对角线的分辨率个数/屏幕尺寸:2202.9071700822983/15.3=143  
3. 怎么根据屏幕密度选择合适的配置文件  
frameworks/base/core/java/android/content/res/Configuration.java:resourceQualifierString  
所以SurfaceFlinger中屏幕密度的计算方式看起来比较怪异  
UI中包含资源:矢量图形,字体,bmp图像,如果没有bmp图像,那么就可以只写一个布局,然后实际的px=dp*(dpi/160)进行计算;  
但是其中bmp图像不能进行缩放,所以需要根据不同的分辨率进行调整  
目前来看需要根据物理屏幕尺寸和密度两种维度进行布局  
4. 目前对策为:只选择一套布局(layout),最终的长宽通过计算得出px=dp*(dpi/160)  
通过在一个dpi为160上标准的PC上进行布局调整,调整完毕后在其他PC上应该就只是进行缩放  
图片适配:如果目前dpi为143,那么就选择160dpi的图片,通过压缩图片填充  
缺点:会损失部分性能
# 已经实验过的策略:

原来我们的做法是:

布局里面全部使用dp单位,android app的布局使用px

px = dp *( dpi / 160)

那么实际的高度:

以分辨率位1920*1080和物理尺寸为:52*29cm为例

dpi=sqrt{1920^2+1080^2}/(sqrt(52^2+29^2)/2.54)=93

px=40*(93/160)=24

物理高度=px/1080*29=24/1080*29=696/1080=0.6cm

在分辨率位1920*1080和物理尺寸为:31*17cm为例

dpi=sqrt{1920^2+1080^2}/(sqrt(31^2+17^2)/2.54)=157

px=40*(157/160)=40

物理高度=px/1080*17=40/1080*17=680/1080=0.6cm

1.同样分辨率下保持dpi相同,所以有相同的宽高比

2.相同分辨率下,物理屏幕尺寸不通,会选择不同的drawable


两边使用dp单位最后的结果是实际的屏幕高度一样,而不是按照比例放大缩小;

这个方式是不可行的;

在相同分辨率下保持dpi相同

在1920*1080分辨率的屏幕上都使用240dpi,在1366*768分辨率的屏幕上都使用sqrt(pow(1366,2)+pow(768,2))*160/sqrt(pow(1920,2)+pow(1080,2))=113dpi

按照比例减小

结果:

布局是按照相同比例放大缩小,看起来大屏和小屏的比例是一致的;

但是在1366*768上字体模糊;

计算分析:

因为两个屏幕都是310x190mm物理尺寸的,不同的是支持的分辨率,导致dpi;

两个布局看起来是一样的,就是物理尺寸一样,那么

字体所占的像素点=dpi*高度H

在1366*768上字体所占像素点:113*高度H,在1920*768上字体所占像素点:160*高度H,这就要求在1366上使用更少的像素点表达一个字体,所以必然看起来模糊;

正确的做法是:在降低分辨率的时候还使用同样的像素点来表达字体,看起来的感觉就是字体变大了;

现状:在布局和字体中现在没有办法找到一个合适的平衡点;

# 部分关键代码分析
```
frameworks/base/tools/layoutlib/bridge/src/com/android/layoutlib/bridge/bars/CustomBar.java
-->frameworks/base/tools/layoutlib/bridge/src/com/android/layoutlib/bridge/impl/ResourceHelper.java
---->frameworks/base/core/java/android/util/TypedValue.java->applyDimension
```
所有单位的换算都在这里,但是这里不能动,一修改就影响所有的app;
在这里sp单位和dp是一样的;

原因:  
frameworks/base/core/java/android/view/DisplayInfo.java  
getMetricsWithSize中有计算sp需要的参数  
```
case COMPLEX_UNIT_SP:
	return value * metrics.scaledDensity;
outMetrics.densityDpi = outMetrics.noncompatDensityDpi = logicalDensityDpi;
        outMetrics.density = outMetrics.noncompatDensity =
                logicalDensityDpi * DisplayMetrics.DENSITY_DEFAULT_SCALE(1.0f);
outMetrics.scaledDensity = outMetrics.noncompatScaledDensity = outMetrics.density;
```
