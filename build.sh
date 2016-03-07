#!/bin/bash

unset LD_LIBRARY_PATH

#linux_repo="/c/repo/linux"
linux_repo="/media/vdb1/xly/linux"
linux_config="$linux_repo/arch/x86/configs/x86_64_defconfig"

tmp_branch="/home/chy/xly/kernelci/test_"
branch_name="$1"
commit_id="$2"

buildroot_path="/home/chy/xly/kernelci/buildroot"
buildroot_linux="$buildroot_path/output/build/linux-custom"
buildroot_config="/home/chy/xly/kernelci"

cd $linux_repo

#git checkout $branch_name

git checkout $commit_id 

        if [ $? -ne 0 ]; then
        echo -e "git checkout $commit_id ERROR!"
        exit
        fi  

#echo -e "Syncing from $linux_repo to $buildroot_linux"
#rsync -au --chmod=u=rwX,go=rX --exclude .svn --exclude .git --exclude .hg --exclude .bzr --exclude CVS --exclude .stamp_rsynced $linux_repo/ $buildroot_linux

rm -rf $buildroot_linux

cp $buildroot_config/buildroot_config $buildroot_path/.config

echo -e "
BR2_DEFCONFIG=\"$buildroot_path/configs/qemu_x86_64_defconfig\"
BR2_LINUX_KERNEL_CUSTOM_LOCAL_PATH=\"$linux_repo\"
BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=\"$linux_config\"" >> $buildroot_path/.config

#exit

cd $buildroot_path
sec=$(date +%s)

make -j8

        if [ $? -ne 0 ]; then
        echo -e "make ERROR!"
        exit
        fi  

cd $buildroot_path/output/images

declare -A file_time
for file_ in $(ls)
do
	time_=$(stat -c %Y $file_)
        if [ $time_ -gt $sec ]; then
	file_time[$file_]=$time_

		if [ "$file_"x = "bzImage"x ]; then
		rm $tmp_branch/$commit_id
		fi
        fi  
done

echo -e "$sec $branch_name $commit_id --> (${!file_time[@]})" >> $tmp_branch/build.log
echo -e "Output files: (\033[32m ${!file_time[@]} \033[0m) in $buildroot_path/output/images"

