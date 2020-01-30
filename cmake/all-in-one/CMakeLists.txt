#
# ccmake and cmake
#
# Author Naoki Takahashi
# Email s16c1077hq@s.chibakoudai.jp
#

message(" ----------------------------------------------------- ")
message("Cmake is ${CMAKE_COMMAND}")

cmake_minimum_required(VERSION 3.10)

function(Flag flag init_flag flag_message)
	if(NOT DEFINED ${flag})
		set(${flag} ${init_flag} CACHE BOOL "${flag_message} : true or false" FORCE)
	endif()
endfunction(Flag)

function(Path path init_path path_message)
	if(NOT DEFINED ${path})
		set(${path} ${init_path} CACHE PATH "${path_message}" FORCE)
	endif()
endfunction(Path)

function(FindFiles result_files top_directories exts)
	set(directory_pattern /*.)

	foreach(top_directory ${top_directories})
		set(directory_pattern_path ${directory_pattern})

		while(true)
			foreach(ext ${exts})
				file(GLOB result_file "${top_directory}${directory_pattern_path}${ext}")
				set(result_files_handler ${result_files_handler} ${result_file})

			endforeach()
			file(GLOB found_file "${top_directory}${directory_pattern_path}*")

			if(found_file)
				set(directory_pattern_path /*${directory_pattern_path})
			else()
				break()
			endif()
		endwhile()
	endforeach()
	set(${result_files} ${result_files_handler} PARENT_SCOPE)
endfunction(FindFiles)

function(FindDirectoryFromFile result_directories input_files)
	foreach(input_file ${input_files})
		get_filename_component(input_directory ${input_file} DIRECTORY)
		set(match_directory false)

		foreach(result_directory_handler ${result_directories_handler})
			if("${result_directory_handler}" MATCHES "${input_directory}")
				set(match_directory true)
			endif()
		endforeach()
		if(NOT ${match_directory})
				set(result_directories_handler ${result_directories_handler} ${input_directory})
		endif()
	endforeach()
	set(${result_directories} ${result_directories_handler} PARENT_SCOPE)
endfunction(FindDirectoryFromFile)

if(NOT PROJECT_NAME)
	get_filename_component(DEFAULT_PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME_WE)
	set(PROJECT_NAME ${DEFAULT_PROJECT_NAME} CACHE STRING "Project name" FORCE)
endif(NOT PROJECT_NAME)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif(NOT CMAKE_BUILD_TYPE)

project(${PROJECT_NAME} CXX C)
message("Project is ${PROJECT_NAME}")

set(CMAKE_CXX_STANDARD 14)

if(NOT MAIN_FILENAME)
	set(MAIN_FILENAME main CACHE STRING "Main file name" FORCE)
endif(NOT MAIN_FILENAME)

set(CXX_SOURCE_FILE_EXTS cpp;cxx;cc)
set(CXX_INCLUDE_FILE_EXTS hpp;h)

Flag(USE_GCOV false "GCOV mode")
Flag(CMAKE_VERBOSE_MAKEFILE false "Verbose option")

Flag(CHILD_PROJECT false "Child project")

Flag(USE_PYTHON2 false "Find and link Python2.7 library")
Flag(USE_PYTHON2_WITHOUT_NUMPY false "Find and link Python2.7 library")
Flag(USE_PYTHON3 false "Find and link Python3.7 library")
Flag(USE_PCL false "Find and link PCL library")
Flag(USE_RBDL false "Find and link RBD library")
Flag(USE_BOOST false "Find and link Boost library")
Flag(USE_CV false "Find and link OpenCV")
Flag(USE_EIGEN3 false "Find and link Eigen3")
Flag(USE_ICE false "Find and link ZeroC Ice")
Flag(USE_ODE false "Find and link Open Dynamicx Engine")
Flag(USE_SSH false "Find and link OpenSSH library")
Flag(USE_GL false "Find and link OpenGLW")
Flag(USE_SPDLOG false "Find and link spdlog library")
Flag(USE_QT false "Find and link qt")

set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} stdc++ pthread m)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Winline -Wextra -Wall -g -O0")

if(USE_GCOV)
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fprofile-arcs -ftest-coverage")
endif(USE_GCOV)

Path(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/binary "Out file output directory")
Path(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/libraries "Library file output directory")
Path(INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include "Include directory")
Path(SOURCE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/source "Source directory")

if(NOT EXISTS ${EXECUTABLE_OUTPUT_PATH})
	message("Not found executable path")
	file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
endif()

if(NOT EXISTS ${LIBRARY_OUTPUT_PATH})
	message("Not found output library path")
	file(MAKE_DIRECTORY ${LIBRARY_OUTPUT_PATH})
endif()

if(NOT EXISTS ${INCLUDE_DIRECTORY})
	message("Not found include path")
	file(MAKE_DIRECTORY ${INCLUDE_DIRECTORY})
endif()

if(NOT EXISTS ${SOURCE_DIRECTORY})
	message(FATAL_ERROR "Not found source path")
endif()

set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${INCLUDE_DIRECTORY})

if(USE_PYTHON3)
	find_package(Python 3.7 REQUIRED COMPONENTS NumPy Interpreter Development)
	if(Python_FOUND AND Python_NumPy_FOUND)
		message(" ---- Find Python 3.7 ${Python_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${Python_INCLUDE_DIRS} ${Python_NumPy_INCLUDE_DIRS})
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${Python_LIBRARIES})
		set(USE_PYTHON2 false)
		set(USE_PYTHON2_WITHOUT_NUMPY false)
	else()
		message(FATAL_ERROR " ---- Not find Python 3.7")
	endif()
endif(USE_PYTHON3)

if(USE_PYTHON2)
	find_package(Python 2.7 REQUIRED COMPONENTS NumPy Interpreter Development)
	if(Python_FOUND AND Python_NumPy_FOUND)
		message(" ---- Find Python 2.7 ${Python_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${Python_INCLUDE_DIRS} ${Python_NumPy_INCLUDE_DIRS})
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${Python_LIBRARIES})
		set(USE_PYTHON3 false)
		set(USE_PYTHON2_WITHOUT_NUMPY false)
	else()
		message(FATAL_ERROR " ---- Not find Python 2.7")
	endif()
endif(USE_PYTHON2)

if(USE_PYTHON2_WITHOUT_NUMPY)
	find_package(Python 2.7 REQUIRED COMPONENTS Interpreter Development)
	if(Python_FOUND)
		message(" ---- Find Python 2.7 ${Python_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${Python_INCLUDE_DIRS})
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${Python_LIBRARIES})
	else()
		message(FATAL_ERROR " ---- Not find Python 2.7")
	endif()
endif(USE_PYTHON2_WITHOUT_NUMPY)

if(USE_PCL)
	find_package(PCL REQUIRED)
	if(PCL_FOUND)
		message(" ---- Found PCL ${PCL_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${PCL_INCLUDE_DIRS})
		foreach(PCL_LIBRARY ${PCL_LIBRARIES})
			if("${PCL_LIBRARY}" MATCHES "flann") 
				if(APPLE)
					if(${FLANN_USE_STATIC})
						set(PCL_MODIFICATE_LIBRARYIES ${PCL_MODIFICATE_LIBRARYIES} ${PCL_ROOT}/lib/lib${PCL_LIBRARY}.a)
					else()
						set(PCL_MODIFICATE_LIBRARYIES ${PCL_MODIFICATE_LIBRARYIES} ${PCL_ROOT}/lib/lib${PCL_LIBRARY}.dylib)
					endif()
				elseif(UNIX)
					set(PCL_MODIFICATE_LIBRARYIES ${PCL_MODIFICATE_LIBRARYIES} ${PCL_ROOT})
				endif()
			else()
				set(PCL_MODIFICATE_LIBRARYIES ${PCL_MODIFICATE_LIBRARYIES} ${PCL_LIBRARY})
			endif()
		endforeach()
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${PCL_MODIFICATE_LIBRARYIES})
		add_definitions(${PCL_DEFINITIONS})
	else()
		message(FATAL_ERROR " ---- Not found PCL")
	endif()
	set(USE_BOOST true FORCE)
endif(USE_PCL)

if(USE_RBDL)
	set(RBDL_INCLUDE_DIR $ENV{RBDL_PATH})
	set(RBDL_LIBRARY_DIR $ENV{RBDL_LIBRARY_PATH})
	if(EXISTS ${RBDL_INCLUDE_DIR})
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${RBDL_INCLUDE_DIR})
	else()
		message(FATAL_ERROR "Not found RBDL_PATH directory path")
	endif()
	if(EXISTS ${RBDL_LIBRARY_DIR})
		if(APPLE)
			file(GLOB RBDL_LIBRARIES "${RBDL_LIBRARY_DIR}/lib*.dylib")
		elseif(UNIX)
			file(GLOB RBDL_LIBRARIES "${RBDL_LIBRARY_DIR}/lib*.so")
		endif()
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${RBDL_LIBRARIES})
	else()
		message(FATAL_ERROR "Not found RBDL_LIBRARY_PATH directory path")
	endif()
	set(USE_EIGEN3 true FORCE)
endif(USE_RBDL)

if(USE_QT)
	find_package(Qt5Core REQUIRED)
	find_package(Qt5Widgets REQUIRED)
	if(Qt5Core_FOUND AND Qt5Widgets_FOUND)
		set(CMAKE_AUTOMOC ON)
		set(CMAKE_AUTOUIC ON)
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${Qt5Core_INCLUDE_DIRS} ${Qt5Widgets_INCLUDE_DIRS})
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Widgets_LIBRARIES})
	endif()
endif(USE_QT)

if(USE_SPDLOG)
	if(APPLE)
		set(SPDLOG_INCLUDE_DIR /usr/local/include/)

	elseif(UNIX)
		set(SPDLOG_INCLUDE_DIR NotFound)

	endif(APPLE)

	message("Found spdlog ${SPDLOG_INCLUDE_DIR}")
	set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${SPDLOG_INCLUDE_DIR})
endif(USE_SPDLOG)

if(USE_GL)
	find_package(OpenGL REQUIRED)

	if(OpenGL_FOUND)
		message(" ---- Found OpenGL ${OpenGL_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${OpenGL_INCLUDE_DIRS})

	else()
		message(FATAL_ERROR " ---- Not Found OpenGL")

	endif()
	if(APPLE)
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${OpenGL_LIBRARIES} glfw "-framework OpenGL")

	elseif(UNIX)
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${OpenGL_LIBRARIES} glfw)

	endif()
endif(USE_GL)

if(USE_SSH)
	if(APPLE)
		set(LIBSSH_TOP_DIR /usr/local)

	elseif(UNIX)
		set(LIBSSH_TOP_DIR /usr)

	endif()
	set(libssh_INCLUDE_DIRS ${LIBSSH_TOP_DIR}/include)
	set(libssh_LIBRARIES_DIR ${LIBSSH_TOP_DIR}/lib)

	if(EXISTS ${libssh_INCLUDE_DIRS} AND EXISTS ${libssh_LIBRARIES_DIR})
		message(" ---- Found libssh ${libssh_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${libssh_INCLUDE_DIRS})
		file(GLOB libssh_LIBRARIES "${libssh_LIBRARIES_DIR}/libssh*.dylib")

	else()
		message(FATAL_ERROR " ---- Not Found libssh Top Directories")

	endif()

	set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${libssh_LIBRARIES})
endif(USE_SSH)


if(USE_ODE)
	if(APPLE)
		set(ODE_TOP_DIRECTORIES /usr/local/Cellar/ode-drawstuff/0.13/)

	elseif(UNIX)
		set(ODE_TOP_DIRECTORIES /usr/local)

	endif()
	set(ODE_INCLUDE_DIR ${ODE_TOP_DIRECTORIES}/include)
	set(ODE_LIBRARIES_DIR ${ODE_TOP_DIRECTORIES}/lib)

	if(EXISTS ${ODE_INCLUDE_DIR} AND EXISTS ${ODE_LIBRARIES_DIR})
		message(" ---- Found Ode ${ODE_INCLUDE_DIR}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${ODE_INCLUDE_DIR})
		file(GLOB ODE_LIBRARIES "${ODE_LIBRARIES_DIR}/lib*.a")

	else()
		message(FATAL_ERROR " ---- Not Found Ode Top Directories")

	endif()
	if(APPLE)
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${ODE_LIBRARIES} "-framework AGL -framework OpenGL -framework GLUT")

	elseif(UNIX)
		set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${ODE_LIBRARIES} drawstuff GL GLU glut X11 "ode")

	endif()
endif(USE_ODE)

if(USE_CV)
	find_package(OpenCV REQUIRED)

	if(OpenCV_FOUND)
		message(" ---- Found OpenCV ${OpenCV_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${OpenCV_INCLUDE_DIRS})

	else(OpenCV_FOUND)
		message(FATAL_ERROR " ---- Not Found OpenCV")

	endif(OpenCV_FOUND)

	set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${OpenCV_LIBRARIES})
endif(USE_CV)

if(USE_BOOST)
	find_package(Boost	REQUIRED COMPONENTS thread system)

	if(Boost_FOUND)
		message(" ---- Found Boost ${Boost_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${Boost_INCLUDE_DIRS})

	else(Boost_FOUND)
		message(FATAL_ERROR " ---- Not Found Boost")

	endif(Boost_FOUND)

	set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${Boost_LIBRARIES} Boost::thread)
endif(USE_BOOST)

if(USE_EIGEN3)
	if(APPLE)
		find_package(Eigen3	REQUIRED COMPONENTS Dense Core Geometry)

		if(Eigen3_FOUND)
			message(" ---- Found Eigen3 ${EIGEN3_INCLUDE_DIRS}")
			set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${EIGEN3_INCLUDE_DIRS})

		else(Eigen3_FOUND)
			message(FATAL_ERROR " ---- Not Found Eigen3")

		endif(Eigen3_FOUND)
	elseif(UNIX)
		if(EXISTS $ENV{EIGEN3_INCLUDE_DIR})
			message(" ---- Used Unix Eigen3 Dir $ENV{EIGEN3_INCLUDE_DIR}")
			set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} $ENV{EIGEN3_INCLUDE_DIR})

		else()
			find_package(Eigen3 REQUIRED)
			if(Eigen3_FOUND)
				message(" ---- Found Eigen3 ${EIGEN3_INCLUDE_DIR}")
				set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${EIGEN3_INCLUDE_DIR})

			else()
				message(" ---- Not Defind EIGEN3_INCLUDE_DIRS")
			endif(Eigen3_FOUND)
		endif()
	endif()
endif(USE_EIGEN3)

if(USE_ICE)
	find_package(Ice REQUIRED COMPONENTS Ice++11 IceBox++11 IceSSL++11 IceGrid++11 IceDiscovery++11)

	if(Ice_FOUND)
		message(" ---- Found Ice ${Ice_INCLUDE_DIRS}")
		set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${Ice_INCLUDE_DIRS})
		add_definitions("-D ICE_CPP11_MAPPING")
		
		if(NOT ICE_DIR)
			set(ICE_DIR ice CACHE PATH "find .ice file" FORCE)
		endif()

		if(EXISTS ${ICE_DIR})
			file(GLOB ICE_FILES "${ICE_DIR}/*.ice")
			if(NOT ICE_OUTPUT_DIRECTORY)
				set(ICE_OUTPUT_DIRECTORY ice_create_files CACHE PATH "Ice create file out-put directory" FORCE)
			endif()
			
			if(NOT EXISTS ${Ice_SLICE2CPP_EXECUTABLE})
				message(FATAL_ERROR " ---- Not found ice slice")
			endif()
			if(NOT DEFINED ICE_FILES)
				message(FATAL_ERROR " ---- Not found ice files")
			endif()
			if(NOT EXISTS ${ICE_OUTPUT_DIRECTORY})
				message(FATAL_ERROR " ---- Not found ice output directory")
			endif()

			get_filename_component(ICE_OUTPUT_DIRECTORY ${ICE_OUTPUT_DIRECTORY} ABSOLUTE)

			foreach(ICE_FILE ${ICE_FILES})
				get_filename_component(ICE_CREATE_FILENAME ${ICE_FILE} NAME_WE)
				set(ICE_OUTPUT_FILES ${ICE_OUTPUT_FILES} ${ICE_OUTPUT_DIRECTORY}/${ICE_CREATE_FILENAME}.cpp ${ICE_OUTPUT_DIRECTORY}/${ICE_CREATE_FILENAME}.h)

			endforeach(ICE_FILE)

			add_custom_command(OUTPUT ${ICE_OUTPUT_FILES} DEPENDS ${ICE_FILES} COMMAND "${Ice_SLICE2CPP_EXECUTABLE}" ARGS ${ICE_FILES} --output-dir ${ICE_OUTPUT_DIRECTORY})

			foreach(ICE_OUTPUT_FILE ${ICE_OUTPUT_FILES})
				if("${ICE_OUTPUT_FILE}" MATCHES ".cpp")
					set(SOURCE_FILES ${SOURCE_FILES} ${ICE_OUTPUT_FILE})
				endif()
			endforeach(ICE_OUTPUT_FILE)

			set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${ICE_OUTPUT_DIRECTORY})

		else()
			message(" ---- Not found ice directory")

		endif()
	else(Ice_FOUND)
		message(FATAL_ERROR " ---- Not Found Ice")

	endif(Ice_FOUND)

	set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${Ice_LIBRARIES})
endif(USE_ICE)

if(CHILD_PROJECT)
	if(NOT MATHER_PROJECT_INCLUDE_DIRECTORIES)
		set(MATHER_PROJECT_INCLUDE_DIRECTORIES NONE CACHE PATH "Mather project include directory path" FORCE)
	endif(NOT MATHER_PROJECT_INCLUDE_DIRECTORIES)

	if(NOT MATHER_PROJECT_LIBRARY_DIRECTORIES)
		set(MATHER_PROJECT_LIBRARY_DIRECTORIES NONE CACHE PATH "Mather project library directory path" FORCE)
	endif(NOT MATHER_PROJECT_LIBRARY_DIRECTORIES)

	foreach(MATHER_PROJECT_INCLUDE_DIRECTORY ${MATHER_PROJECT_INCLUDE_DIRECTORIES})
		if(NOT EXISTS ${MATHER_PROJECT_INCLUDE_DIRECTORY})
			message(FATAL_ERROR "Not found mather project include directories")
		endif(NOT EXISTS ${MATHER_PROJECT_INCLUDE_DIRECTORY})
	endforeach(MATHER_PROJECT_INCLUDE_DIRECTORY)

	foreach(MATHER_PROJECT_LIBRARY_DIRECTORY ${MATHER_PROJECT_LIBRARY_DIRECTORIES})
		if(NOT EXISTS ${MATHER_PROJECT_LIBRARY_DIRECTORY})
			message(FATAL_ERROR "Not found mather project library directories")
		endif(NOT EXISTS ${MATHER_PROJECT_LIBRARY_DIRECTORY})
	endforeach(MATHER_PROJECT_LIBRARY_DIRECTORY)

	set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${MATHER_PROJECT_INCLUDE_DIRECTORIES})

	foreach(MATHER_PROJECT_LIBRARY_DIRECTORY ${MATHER_PROJECT_LIBRARY_DIRECTORIES})
		file(GLOB MATHER_PROJECT_LIBRARY_FILE_STATIC "${MATHER_PROJECT_LIBRARY_DIRECTORY}/*.a")
		set(MATHER_PROJECT_LIBRARY_FILES ${MATHER_PROJECT_LIBRARY_FILES} ${MATHER_PROJECT_LIBRARY_FILE_STATIC})
	endforeach(MATHER_PROJECT_LIBRARY_DIRECTORY)
endif(CHILD_PROJECT)

set(SOURCE_DIRECTORIES ${SOURCE_DIRECTORIES} ${SOURCE_DIRECTORY})

FindFiles(CXX_SOURCE_FILES "${SOURCE_DIRECTORIES}" "${CXX_SOURCE_FILE_EXTS}")
FindFiles(CXX_INCLUDE_FILES "${SOURCE_DIRECTORIES}" "${CXX_INCLUDE_FILE_EXTS}")
FindDirectoryFromFile(CXX_INCLUDE_DIRECTORIES "${CXX_INCLUDE_FILES}")

set(SOURCE_FILES ${CXX_SOURCE_FILES})
set(INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${CXX_INCLUDE_DIRECTORIES})

include_directories(${INCLUDE_DIRECTORIES})

foreach(SOURCE_FILE ${SOURCE_FILES})
	if(NOT "${SOURCE_FILE}" MATCHES "${MAIN_FILENAME}")
		get_filename_component(LIBRARY_FILENAME ${SOURCE_FILE} NAME_WE)

		if("${SOURCE_FILE}" MATCHES ".cpp" OR "${SOURCE_FILE}" MATCHES ".c")
			set(LIBRARY_SOURCE_FILES ${LIBRARY_SOURCE_FILES} ${SOURCE_FILE})
			set(LIBRARY_FILES ${LIBRARY_FILES} ${LIBRARY_FILENAME})

		endif()
	else()
		set(MAIN_SOURCE_FILE ${SOURCE_FILE})

	endif()
endforeach(SOURCE_FILE)

if(LIBRARY_SOURCE_FILES)
	set(PROJECT_LIBRARY ${PROJECT_NAME})
	add_library(${PROJECT_LIBRARY} ${LIBRARY_SOURCE_FILES})
endif()

set(OUT_TARGET_NAME ${PROJECT_NAME}.out)

add_executable(${OUT_TARGET_NAME} ${MAIN_SOURCE_FILE})

if(LIBRARY_SOURCE_FILES)
	add_dependencies(${OUT_TARGET_NAME} ${PROJECT_LIBRARY})
endif()

if(CHILD_PROJECT)
	set(ALL_LINK_LIBRARIES ${ALL_LINK_LIBRARIES} ${MATHER_PROJECT_LIBRARY_FILES})
endif(CHILD_PROJECT)

target_link_libraries(${OUT_TARGET_NAME} ${ALL_LINK_LIBRARIES} ${PROJECT_LIBRARY})

message(" ----------------------------------------------------- ")

