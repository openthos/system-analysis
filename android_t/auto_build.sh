#!/bin/bash

#ubuntu 14.04
#Android 5.x (Lollipop) - Android 6.0 (Marshmallow): Java 7
#Android 2.3.x (Gingerbread) - Android 4.4.x (KitKat): Java 6

android_x86_repo=""

marshmallow_x86_repo=""
marshmallow_x86_repo=""
lollipop_x86=""
kitkat_x86=""

sudo apt-get update
sudo apt-get install openjdk-7-jdk openjdk-6-jdk

sudo update-alternatives --config java
sudo update-alternatives --config javac

sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip python python-networkx clang

releases=(marshmallow-x86 lollipop-x86 kitkat-x86)

exit 

for rel in ${releases[*]}
do
cd android_x86_repo


done




 
