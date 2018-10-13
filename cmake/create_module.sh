#! /bin/bash

mkdir -p NonNameModule/build && cp `dirname $0`/CMakeLists.txt NonNameModule/build/

if [ "$(uname)" == 'Darwin' ]; then
	gsed -i -e "12i set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} `cd $(dirname $0) && pwd`/module)" CMakeLists.txt
else
	gsed -i -e "12i set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} `cd $(dirname $0) && pwd`/module)" CMakeLists.txt
fi

