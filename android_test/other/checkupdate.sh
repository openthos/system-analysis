#!/bin/bash
# based on git log info

up2="$1" #up2github
#git config --global credential.helper cache

android_repo_path="/opt/git/lollipop-x86"
Repo="/home/xly/repository/bin/repo"

dirname_path=$(cd `dirname $0`; pwd)

manifest_dir="/home/xly/local_repo/manifest"
prj_multi_xml="$manifest_dir/default.xml"

#check_all_projects_update
if [ "$1"x = "projects_update"x ];then
update_flag=0
md_file="projects_update.md"
echo '# multiwindow projects update' > /tmp/$md_file
echo $(date -R) >> /tmp/$md_file

cd $manifest_dir
git checkout master

fi
#check_all_projects_update

cd $android_repo_path

all_projects=$($Repo list | awk '$3 !~ /^(git-repo|manifest)/ {print $3}')
all_projects+="  platform/packages/apps/OtoSettings"
#echo $all_projects
#exit

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

	#check_all_projects_update
	if [ "$1"x = "projects_update"x ];then

	grep "${multi_loginfo[0]}"  $manifest_dir/$md_file
	if [ $? -ne 0 ]; then
	echo -e "\033[31mgrep $prj_multi ERROR!\033[0m"
	update_flag=1
	fi

	multi_loginfo_tmp=$(echo ${multi_loginfo[@]})
	printf "\x2D %50s $multi_loginfo_tmp \n" $prj_ >> /tmp/$md_file
	continue
	fi
	#check_all_projects_update

	#check_github_multi
	if [ "$1"x = "check_github_multi"x ];then
	echo -e "\033[32m$prj_\033[0m"

	prj_multi=$( echo $prj_ | sed "s/^platform\///g" ) #exclude kernel/common
	grep "path=\"$prj_multi\"" $prj_multi_xml | grep "revision=\"multiwindow\""
	if [ $? -ne 0 ]; then
	echo -e "\033[31mgrep $prj_multi ERROR!\033[0m"
	fi

	continue
	fi #check_github_multi

	#up2
	if [ "$up2"x = "up2github"x ];then
	sleep 2
	echo -e "\033[32m$prj_\033[0m"

	git remote -v | grep  "github.com/openthos" > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	echo -e "\033[31m$prj_ git remote github.com/openthos ERROR!\033[0m"
	continue
	fi

###new git remote
#	new_gitremote=$( git remote -v | awk ' /github.com\/openthos/ { gsub(/openthos_/,"oto_",$2); print $2; exit}')
#	sudo git remote remove github
#	sudo git remote add github $new_gitremote
###new git remote

### git push base
	if [ "$prj_"x = "kernel/common"x ];then
	echo -e "\033[1m$prj_\033[0m"
	git push github kernel-4.0
	git push github kernel-4.4

	elif [ "$prj_"x = "platform/external/libusb_aah"x ];then
	echo -e "\033[1m$prj_\033[0m"
	git push github master

	elif [ "$prj_"x = "platform/packages/apps/OtoSettings"x ];then
	echo -e "\033[1m$prj_\033[0m"
	git push github base

	else
	git log -1 lollipop-x86 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	echo -e "\033[1maosp:refs/tags/android-5.1.1_r30\033[0m"
	git push github refs/tags/android-5.1.1_r30:lollipop-x86

	else
	echo -e "\033[1mx86:lollipop-x86\033[0m"
	git push github lollipop-x86:lollipop-x86
	fi
	fi
###

	git push github multiwindow
	if [ $? -ne 0 ]; then
	echo -e "\033[31mPush $repo_name ERROR!\033[0m"
	fi

	git push github singlewindow

	continue
	fi #up2

	echo -e "\033[32m$prj_\033[0m"
	echo -e "               \033[1m${base_loginfo[@]}\033[0m"
	echo -e "multiwindow  : ${multi_loginfo[@]}"
	echo -e "singlewindow : ${single_loginfo[@]}"
	echo '------------------------------'

done

#check_all_projects_update
if [ "$1"x = "projects_update"x ];then
if [ "$update_flag" -eq 1 ];then
echo -e "\033[32mCOPY $md_file\033[0m"
cp /tmp/$md_file "${manifest_dir}/"

cd $manifest_dir
git commit -a -m "projects update $(date -R)"
git push github master

#push update to github
/bin/bash $dirname_path/checkupdate.sh up2github 2>&1 > /tmp/push.log

fi
fi

