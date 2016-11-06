
function(AddTarget)
	set(__one_val
		NAME
		TYPE
		SOURCE_DIR
		OUTPUT_NAME)
	set(__multi_val
		DEPENDENCIES
		INCLUDE_DIRS
		RESOURCES
		CMAKE
		FIND_PKG
		EXTRA_CMAKE
		LINK_LIB
		QT_LIB)
	set(__options)
	cmake_parse_arguments(AddTarget "${__options}" "${__one_val}" "${__multi_val}" ${ARGN})

	if(AddTarget_NAME EQUAL "")
		message(ERROR "Missing target name")
	endif(AddTarget_NAME EQUAL "")
	set(__extra_link_libraries)
	set(__extra_headers)
	set(__target_dependecies)

	file(GLOB_RECURSE AddTarget_SRC ${AddTarget_SOURCE_DIR}/*.c ${AddTarget_SOURCE_DIR}/*.cpp ${AddTarget_SOURCE_DIR}/*.h ${AddTarget_SOURCE_DIR}/*.hpp)
	set(${AddTarget_NAME}__HEADERS_PATH "${AddTarget_SOURCE_DIR}" CACHE STRING "" FORCE)

	message(STATUS "> Creating ${AddTarget_TYPE} with name: ${AddTarget_NAME}")
	if(AddTarget_TYPE STREQUAL app)
		add_executable("${AddTarget_NAME}" "${AddTarget_SRC}")
	elseif(AddTarget_TYPE STREQUAL test)
		enable_testing()
		add_executable("${AddTarget_NAME}" "${AddTarget_SRC}")
	elseif(AddTarget_TYPE STREQUAL static_lib)
		add_library("${AddTarget_NAME}" STATIC "${AddTarget_SRC}")
	elseif(AddTarget_TYPE STREQUAL shared_lib)
		add_library("${AddTarget_NAME}" SHARED "${AddTarget_SRC}")
	endif(AddTarget_TYPE STREQUAL app)

	if(AddTarget_OUTPUT_NAME)
		set_target_properties( ${AddTarget_NAME} PROPERTIES OUTPUT_NAME "${AddTarget_OUTPUT_NAME}" )
	endif(AddTarget_OUTPUT_NAME)

	if(AddTarget_CMAKE)
		foreach(find_item IN LISTS AddTarget_CMAKE)
			find_package(${find_item} REQUIRED)
			if(${find_item} STREQUAL "GTest")
				list(APPEND __extra_link_libraries ${GTEST_BOTH_LIBRARIES})
			endif(${find_item} STREQUAL "GTest")
		endforeach(find_item IN LISTS AddTarget)
	endif(AddTarget_CMAKE)

	if(AddTarget_FIND_PKG)
		foreach(pkg IN LISTS AddTarget_FIND_PKG)
			PKG_SEARCH_MODULE(PC_LIBGIT2 libgit2)
		endforeach(pkg IN LISTS AddTarget_FIND_PKG)
	endif(AddTarget_FIND_PKG)

	if(AddTarget_EXTRA_CMAKE)
		foreach(extra_item IN LISTS AddTarget_EXTRA_CMAKE)
			find_package(${extra_item} REQUIRED)
		endforeach(extra_item IN LISTS AddTarget_EXTRA_CMAKE)
	endif(AddTarget_EXTRA_CMAKE)

	if(AddTarget_QT_LIB)
		set(CMAKE_AUTOMOC ON)
		set(CMAKE_INCLUDE_CURRENT_DIR ON)
		foreach(qt_item IN LISTS AddTarget_QT_LIB)
			find_package(Qt5${qt_item} REQUIRED)
			list(APPEND __extra_link_libraries Qt5::${qt_item})
		endforeach()
	endif(AddTarget_QT_LIB)

	if(AddTarget_LINK_LIB)
		foreach(lib IN LISTS AddTarget_LINK_LIB)
			list(APPEND __extra_link_libraries ${${lib}})
		endforeach(lib IN LISTS AddTarget_LINK_LIB)
	endif(AddTarget_LINK_LIB)

	if(AddTarget_DEPENDENCIES)
		foreach(dependency IN LISTS AddTarget_DEPENDENCIES)
			foreach(dependencies_lib IN LISTS ${dependency}__extra_link_libraries)
				list(APPEND __extra_link_libraries ${dependencies_lib})
			endforeach(dependencies_lib IN LISTS ${AddTarget_DEPENDENCIES}__extra_link_libraries)
			list(APPEND __extra_link_libraries ${dependency})
			list(APPEND __target_dependecies ${dependency})
			list(APPEND __extra_headers ${${dependency}__HEADERS_PATH})
		endforeach(dependency IN LISTS AddTarget_DEPENDENCIES)
	endif(AddTarget_DEPENDENCIES)

	if(__target_dependecies)
		list(REMOVE_DUPLICATES __target_dependecies)
		add_dependencies(${AddTarget_NAME} ${__target_dependecies})
	endif(__target_dependecies)

	if(__extra_headers)
		target_include_directories(${AddTarget_NAME} PUBLIC ${__extra_headers})
	endif(__extra_headers)

	if(__extra_link_libraries)
		set(${AddTarget_NAME}__extra_link_libraries ${__extra_link_libraries} CACHE STRING "" FORCE)
		list(REMOVE_DUPLICATES __extra_link_libraries)
		target_link_libraries("${AddTarget_NAME}" "${__extra_link_libraries}")
	endif(__extra_link_libraries)

	if(AddTarget_TYPE STREQUAL test)
		add_test(AllTestsIn${AddTarget_NAME} "${AddTarget_NAME}")
	endif()
endfunction(AddTarget)
