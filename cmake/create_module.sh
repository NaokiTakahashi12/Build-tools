#! /bin/bash

default_module_name=NonNameModule

mkdir -p $default_module_name/build && cp `dirname $0`/CMakeLists.txt $default_module_name/build/

if [ "$(uname)" == 'Darwin' ]; then
	gsed -i -e "12i set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} `cd $(dirname $0) && pwd`/module)" $default_module_name/build/CMakeLists.txt
else
	sed -i -e "12i set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} `cd $(dirname $0) && pwd`/module)" $default_module_name/build/CMakeLists.txt
fi

