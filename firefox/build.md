## 官方wiki
官方wiki写的很详细,请仔细看.  
https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Simple_Firefox_for_Android_build
## 预装工具: 
```
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install yasm git python-dbus mercurial automake autoconf autoconf2.13 build-essential ccache python-dev python-pip python-setuptools unzip uuid zip zlib1g-dev openjdk-7-jdk wget libncurses5:i386 libstdc++6:i386 zlib1g:i386
```
### watchman:
git clone https://github.com/facebook/watchman.git
### Rust:
curl -sf -L https://static.rust-lang.org/rustup.sh | sh

### sdk下载:lh@192.168.0.180:~/wjx/sdk.tar.bz
### ndk下载:lh@192.168.0.180:~/wjx/android-ndk-r12b-linux-x86_64.zip

## 代码下载:
已经下载好的代码:lh@192.168.0.180:~/wjx/cd4cdcc9ad6c45dad8b8d8c0d40e459db2bca8a1.bzip2.hg
```
mkdir mozilla-central
hg init mozilla-central
cd mozilla-central

hg unbundle /path/to/cd4cdcc9ad6c45dad8b8d8c0d40e459db2bca8a1.bzip2.hg
hg pull
hg update
```
## 编译:

### 配置target为arm
```
# Build Firefox for Android Artifact Mode:
ac_add_options --enable-application=mobile/android
ac_add_options --target=arm-linux-androideabi
#ac_add_options --enable-artifact-builds

# With the following Android SDK:
ac_add_options --with-android-sdk="/home/linux/tools/Sdk"
ac_add_options --with-android-ndk="/home/linux/tools/android-ndk-r12b"

# Write build artifacts to:
mk_add_options MOZ_OBJDIR=./objdir-frontend
mk_add_options MOZ_MAKE_FLAGS="-j4"
```
### 配置target为:i386
```
# Build Firefox for Android Artifact Mode:
ac_add_options --enable-application=mobile/android
ac_add_options --target=i386-linux-android
#ac_add_options --enable-artifact-builds

# With the following Android SDK:
ac_add_options --with-android-sdk="/home/linux/tools/Sdk"
ac_add_options --with-android-ndk="/home/linux/tools/android-ndk-r12b"

# Write build artifacts to:
mk_add_options MOZ_OBJDIR=./objdir-frontend
mk_add_options MOZ_MAKE_FLAGS="-j4"
```
再次推荐官方wiki:  
https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Simple_Firefox_for_Android_build
