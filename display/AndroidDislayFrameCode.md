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

mesa->egl:1.0.0
```
Surface.cpp::dequeuebuffer<--android_surface_dequeue_buffer<--droid_get_buffers_with_format<--dri2_dpy->dri2_loader_extension.getBuffersWithFormat<-----
________________________________________________________________________________________________________________________________________________________|
| mesa/src/mesa/drivers/dri/i965/brw_context.c
-<--intel_query_dri2_buffers<--intel_update_dri2_buffers<--intel_update_renderbuffers<--intel_prepare_render
```

调整大小:
```
1.WM::setForcedDisplaySize->setForcedDisplaySizeLocked->reconfigureDisplayLocked->sendEmptyMessage(H.SEND_NEW_CONFIGURATION)-->mActivityManager.updateConfiguration(null)->
updateConfigurationLocked
| (1) change the current configuration, and (2) make sure the given activity is running with the (now) current configuration.
|_> broadcastIntentLocked
|_> app.thread.scheduleConfigurationChanged(configCopy)-->handleConfigurationChanged

relaunchActivityLocked<--ensureActivityConfigurationLocked<--ensureActivitiesVisibleLocked

activityResumed<--
```
```
D/ViewRootImpl( 2132): java.lang.Throwable
D/ViewRootImpl( 2132):  at android.view.ViewRootImpl.performTraversals(ViewRootImpl.java:1228)
D/ViewRootImpl( 2132):  at android.view.ViewRootImpl.doTraversal(ViewRootImpl.java:1067)
D/ViewRootImpl( 2132):  at android.view.ViewRootImpl$TraversalRunnable.run(ViewRootImpl.java:5892)
D/ViewRootImpl( 2132):  at android.view.Choreographer$CallbackRecord.run(Choreographer.java:767)
D/ViewRootImpl( 2132):  at android.view.Choreographer.doCallbacks(Choreographer.java:580)
D/ViewRootImpl( 2132):  at android.view.Choreographer.doFrame(Choreographer.java:550)
D/ViewRootImpl( 2132):  at android.view.Choreographer$FrameDisplayEventReceiver.run(Choreographer.java:753)
D/ViewRootImpl( 2132):  at android.os.Handler.handleCallback(Handler.java:739)
D/ViewRootImpl( 2132):  at android.os.Handler.dispatchMessage(Handler.java:95)
D/ViewRootImpl( 2132):  at android.os.Looper.loop(Looper.java:135)
D/ViewRootImpl( 2132):  at android.app.ActivityThread.main(ActivityThread.java:5254)
D/ViewRootImpl( 2132):  at java.lang.reflect.Method.invoke(Native Method)
D/ViewRootImpl( 2132):  at java.lang.reflect.Method.invoke(Method.java:372)
D/ViewRootImpl( 2132):  at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:903)
D/ViewRootImpl( 2132):  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:698)

 performTraversals-->measureHierarchy-->relayoutWindow--> performLayout-->performDraw
```
在调整完
###修改调节分辨率:  
画图中需要修改几处位置，从上到下:  
应用申请buffer来画图，和surfaceflinger行程了producer<->consumer的循环；在应用程序画图来看是surface的参数,当surface的参数改变时去dequeuebuffer时如果发现size不对，BufferQueueCore会重新分配buffer;  
下面是合成环节:  
合成的buffer要向下发送给drm_gralloc，这里也是构建了一个producer<->consumer的循环，但是中间进行dequeueBuffer和queueBuffer的是egl,中间暂时相当于一个黑盒子，不太好修改，正在慢慢尝试如何修改。

合成完之后发送给drm_gralloc  
这一部分primary屏是不分配buffer的，所以只需要修改参数供上面读取。
