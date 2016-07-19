# system-analysis
### Goal
analysis&update&implementation systems in OTO.

### work list
- kernels & drivers
- system libs
- android libs
- support for OTO autotest
- support for kernel CI

## kernelci-analysis

### download this repo and the android-x86 linux kernel
```
git clone https://github.com/openthos/system-analysis.git

git clone git://gitscm.sf.net/gitroot/android-x86/kernel/common
```

### install packages
```
sudo apt-get install git-core gnupg flex bison gperf build-essential 
zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 
lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache 
libgl1-mesa-dev libxml2-utils xsltproc unzip 
apache2

#set up the apache2, to run it normally.
cd /path/to/apache2/web/root
mkdir ~lkp
cp -rf /path/to/kernelci-analysis/web_server/*  ~lkp/
```

### set the configuration variables
1. edit `tmp_branch/envar`, set the correct android-x86 linux kernel directory `eg: /path/to/kernel/common` and a directory in the apache2 web root `eg: /var/www/html/~lkp`

2. run `crontab -e`, add a line `* */1 * * * /path/to/updateGIT.sh`. every one hour the updateGIT.sh is executed.

### configuration files

 - buildroot configuration file: `buildroot/buildroot_config2`
 - linux kernel configuration file: `buildroot/linux_config`

## about android-x86 test

### see android_test/README.md

