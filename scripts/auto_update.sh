#!/bin/bash

path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd "$path"
# echo "更新目录:${path}"
git reset --hard && git pull && chmod -R 750 ./ && chown -R www:www ./
echo "update success! The current version is: $(git rev-parse --short HEAD)"
# VERSION=$(curl -sL https://api.github.com/repos/jinbinhan/AssemblyToolchains/releases | jq -r ".[0].name")
wget -qO- -t1 -T2 "https://api.github.com/repos/jinbinhan/AssemblyToolchains/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'
echo $VERSION
