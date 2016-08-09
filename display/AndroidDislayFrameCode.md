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
