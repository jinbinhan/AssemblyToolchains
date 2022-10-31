#!/bin/bash

path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd "$path"
# echo "更新目录:${path}"
git reset --hard && git pull && chmod -R 750 ./ && chown -R www:www ./
echo "update success! The current version is: $(git rev-parse --short HEAD)"
VERSION=$(curl -sL https://api.github.com/repos/jinbinhan/AssemblyToolchains/releases | jq -r ".[0].name")
echo $VERSION
