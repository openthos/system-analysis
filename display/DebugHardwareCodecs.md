* <b>Enable libva-trace:</b><br>
  Add /etc/libva.conf, content:<br>
  LIBVA_TRACE=/data/local/tmp/va.log<br>
  adb shell chown media /data/local/tmp
* <b>Set ffmpeg debug level to DEBUG:</b><br>
  adb shell setprop debug.nam.ffmpeg 1
