#!/bin/bash

linux_repo="/media/vdb1/xly/common"

tmp_branch="/home/chy/xly/kernelci/ka/tmp_branch"
build_sh="/home/chy/xly/kernelci/ka/build.sh"

cd $linux_repo

git fetch origin

        if [ $? -ne 0 ]; then
        echo -e "git fetch ERROR!"
        exit
        fi  

remote_branches=$(git branch -r | sed -e "1d" -e  "s/origin\///")

echo -e "All branches: ($remote_branches)"

#remote_branches="master"
remote_branches="kernel-4.4"

for br_ in $remote_branches
do 

	old_br_com=(`cat $tmp_branch/$br_`) #old_branch_commit

git checkout $br_

br_com=(`git log -1 --pretty=format:"%H %cd" --date=raw` )

if [ "${old_br_com[0]}"x = "${br_com[0]}"x ]
then
	continue
else
	echo ${br_com[@]} > $tmp_branch/$br_
fi

#git log --pretty=format:"%H %cd" --date=raw "$old_commit_id"..

#x#do not contain old_commit_id 
#branch_log=$(git log --pretty=format:"%H" ${old_br_com}..)

branch_log=$(git log --pretty=format:"%H" --since=${old_br_com[1]} )

echo -e "Branch $br_: ($branch_log)"

for log_ in $branch_log
do 
	echo '#!/bin/bash' > $tmp_branch/$log_
	echo -e "/bin/bash $build_sh $br_ $log_" >> $tmp_branch/$log_

	chmod 755 $tmp_branch/$log_
	echo -e "\033[32m Running $br_ $tmp_branch/$log_ \033[0m"
	/bin/bash $tmp_branch/$log_

	sleep 1
done

#for loop
done

