#!/bin/bash

release_name=""
android_x86_repo=""
target_build="android_x86-eng"

cd $android_x86_repo
sec=$(date +%s)

source build/envsetup.sh

lunch $target_build

m -j8 iso_img

echo -e "\n----- out directory: out/target/product/ -----\n"

