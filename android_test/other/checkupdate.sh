#!/bin/bash
# based on git log info

up2="$1" #up2github
#git config --global credential.helper cache

android_repo_path="/opt/git/lollipop-x86"
Repo="/home/xly/repository/bin/repo"

cd $android_repo_path

all_projects=$($Repo list | awk '$3 !~ /^(git-repo|manifest)/ {print $3}')
#echo $all_projects

for prj_ in $all_projects
do
	cd $android_repo_path

	#echo $prj_ 
	#cd $prj_*
	cd "${prj_}.git"
	if [ $? -ne 0 ]; then
	echo -e "\033[31m$prj_\033[0m"
	echo '------------------------------'
	continue
	fi

	base_loginfo=(` git log -1 --pretty=format:"%h %cd %ae \"%an\"" --date=iso `)
	if [ ! -n "${base_loginfo[5]}" ]; then
	echo -e "\033[31m$prj_\033[0m"
	echo '------------------------------'
	continue
	fi

	multi_loginfo=(` git log multiwindow -1 --pretty=format:"%h %cd %ae \"%an\"" --date=iso `)
	single_loginfo=(` git log singlewindow -1 --pretty=format:"%h %cd %ae \"%an\"" --date=iso `)

	if [ "${base_loginfo[0]}"x = "${multi_loginfo[0]}"x -a "${base_loginfo[0]}"x = "${single_loginfo[0]}"x ]
	then
		continue
	fi

	#up2
	if [ "$up2"x = "up2github"x ];then
	sleep 2
	echo -e "\033[32m$prj_\033[0m"

	git remote -v | grep  "github.com/openthos" > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	echo -e "\033[31m$prj_ git remote github.com/openthos ERROR!\033[0m"
	continue
	fi

### git push base
	if [ "$prj_"x = "kernel/common"x ];then
	echo -e "\033[1m$prj_\033[0m"
	sudo git push github kernel-4.0
	sudo git push github kernel-4.4

	elif [ "$prj_"x = "platform/external/libusb_aah"x ];then
	echo -e "\033[1m$prj_\033[0m"
	sudo git push github master

	else
	git log -1 lollipop-x86 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	echo -e "\033[1maosp:refs/tags/android-5.1.1_r30\033[0m"
	sudo git push github refs/tags/android-5.1.1_r30:lollipop-x86

	else
	echo -e "\033[1mx86:lollipop-x86\033[0m"
	sudo git push github lollipop-x86:lollipop-x86
	fi
	fi
###

	sudo git push github multiwindow
	if [ $? -ne 0 ]; then
	echo -e "\033[31mPush $repo_name ERROR!\033[0m"
	fi

	sudo git push github singlewindow

	continue
	fi #up2

	echo -e "\033[32m$prj_\033[0m"
	echo -e "               \033[1m${base_loginfo[@]}\033[0m"
	echo -e "multiwindow  : ${multi_loginfo[@]}"
	echo -e "singlewindow : ${single_loginfo[@]}"
	echo '------------------------------'

done

