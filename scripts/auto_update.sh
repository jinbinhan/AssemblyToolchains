#!/bin/bash

path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd "$path"
# echo "更新目录:${path}"
#check if v.txt exists or not than create it adn write 0
if [ ! -f "v.txt" ]; then
    echo "0" >v.txt
fi
# get the local version from local file v.txt
local_version=$(cat v.txt)
new_version=$(git describe --tags $(git rev-list --tags --max-count=1)) #get newest version from github
#compare the local version and newest version
if [ "$local_version" != "$new_version" ]; then
    # echo "发现新版本:${new_version}"
    #ask user to update or not
    read -p "New version ${new_version} found,do you want to update?(y/n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git pull
        git checkout ${new_version}
        echo "Update to ${new_version} successfully!"
        #update the local version
        echo ${new_version} >v.txt
    else
        echo "Update canceled!"
    fi
fi

# git reset --hard && git pull && chmod -R 750 ./ && chown -R www:www ./
# echo "update success!"
# echo "The current tag name is ${new_version}"
