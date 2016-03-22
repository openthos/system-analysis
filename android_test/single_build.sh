#!/bin/bash

if [ $# -ne 1 ]; then
        echo -e "Usage: $0 android-x86_Repo_Path"
        exit
fi

#release_name=""
android_x86_repo="$1"
android_test_path=$(pwd)

source $android_test_path/tmp_build/envar

target_build="android_x86-eng"

cd $android_x86_repo
release_name=` awk '/path="build" name="platform\/build"/ {print $6}' .repo/manifest.xml | cut -d '"' -f 2 `
echo -e "\033[32mAndroid-x86: $release_name\033[0m"

#release_name="kitkat-x86"

if [ "${Releases[2]}"x = "$release_name"x ]; then
export PATH=$JDK1_6:$PATH
java -version
javac -version

fi

sec=$(date +%s)

source build/envsetup.sh

lunch $target_build

m -j8 iso_img

echo -e "\n----- out directory: out/target/product/ -----\n"
