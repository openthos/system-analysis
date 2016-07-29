#!/bin/bash

if [ $# -ne 1 ]; then
        echo -e "Usage: $0 project_name "
        exit
fi

android_x86_dir="/opt/git/lollipop-x86"

path=""
eval $( grep "name=\"$1\"" $android_x86_dir/.repo/manifest.xml | awk '{print $2}' )

if [ ! $path ];then
echo -e "\033[31m Invalid Project Name ! \033[0m"
exit
fi

repo_path=$path
github_name="oto_$(echo $repo_path |sed "s/\//_/g")"

echo $github_name


