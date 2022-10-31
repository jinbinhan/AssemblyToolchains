#!/bin/bash

path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd "$path"
# echo "更新目录:${path}"
git reset --hard && git pull && chmod -R 750 ./ && chown -R www:www ./
new_version=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "update success!"
echo "The current tag name is ${new_version}"
