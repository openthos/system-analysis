activity画图的顺序:
```
ViewRootImpl:draw-->ViewRootImpl:drawSoftware
Surface:lockCanvas->android_view_Surface.cpp:nativeLockCanvas-->Surface.cpp:lock-->Surface.cpp:dequeueBuffer-->mGraphicBufferProducer->dequeueBuffer 　　获取surface
View:draw-->Canvas:drawXXX-->HardwareCanvas:-->GLES20Canvas:drawXXX-->android_view_GLES20Canvas.cpp::android_view_GLES20Canvas_drawXXX-->存入DisplayListRenderer　　绘图
Surface:unlockCanvasAndPost->android_view_Surface.cpp:nativeUnlockCanvasAndPost-->Surface::unlock-->Surface::queueBuffer-->mGraphicBufferProducer->queueBuffer  释放surface,并通知surfaceflinger
```
SurfaceFlinger合成:
```

```

是FramebufferNativeWindow作为NativeWindow  
将buf post给显示器:
```
SurfaceFlinger::postFramebuffer-->HWComposer.commit-->intel HWComposer::set-->mesa eglswapBuffers-->mesa platform_android.c:droid_swap_buffers-->droid_window_enqueue_buffer
那么FramebufferNativeWindow中
```

Producer<->Consumer
```
BpIGraphicBufferProducer::queueBuffer-->BnIGraphicBufferProducer::queueBuffer-->BufferQueueProducer::queueBuffer-->BufferQueueCore->mConsumerListener::onFrameAvailable(***--＞Layer::onFrameAvailable)-->FramebufferSurface::onFrameAvailable
```
注册回调:
```
Layer::onFirstRef-->SurfaceFlingerConsumer::setContentsChangedListener-->SurfaceFlingerConsumer::setFrameAvailableListener
```
Consumer处理:
```
Layer::onFrameAvailable-->SurfaceFlinger::signalLayerUpdate-->SurfaceFlinger::onMessageReceived-->SurfaceFlinger::handleMessageRefresh-->SurfaceFlinger::handleMessageRefresh-->SurfaceFlinger::setUpHWComposer-->DisplayDevice::beginFrame-->
```
###修改调节分辨率:  
画图中需要修改几处位置，从上到下:  
应用申请buffer来画图，和surfaceflinger行程了producer<->consumer的循环；在应用程序画图来看是surface的参数,当surface的参数改变时去dequeuebuffer时如果发现size不对，BufferQueueCore会重新分配buffer;  
下面是合成环节:  
合成的buffer要向下发送给drm_gralloc，这里也是构建了一个producer<->consumer的循环，但是中间进行dequeueBuffer和queueBuffer的是egl,中间暂时相当于一个黑盒子，不太好修改，正在慢慢尝试如何修改。

合成完之后发送给drm_gralloc  
这一部分primary屏是不分配buffer的，所以只需要修改参数供上面读取。
