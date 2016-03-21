## Android-x86 autotest

***OS***: Ubuntu 14.04 (Trusty)

* Java Development Kit (JDK):
Android 5.x (Lollipop): Java 7 (openjdk 7)
Android 6.0 (Marshmallow): Java 7 (openjdk 7)
Android 4.4.x (KitKat): Java 6 (Oracle 6)

* Update the default Java version
`
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
`

* Installing required packages
` sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip`
 `sudo apt-get install python python-mako python-networkx clang yasm`

* Android-x86 releases
marshmallow-x86
Based on Android 6.0 release (Marshmallow).
lollipop-x86
Based on Android 5.0 release (Lollipop).
kitkat-x86
Based on Android 4.4 release (KitKat).

