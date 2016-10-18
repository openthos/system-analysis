http://blog.csdn.net/xyz_lmn/article/details/38304427  
http://api.apkbus.com/guide/practices/screens_support.html  
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
