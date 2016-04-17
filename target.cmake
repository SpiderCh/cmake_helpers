
function(AddTarget)
	set(__one_val
		NAME
		TYPE
		SOURCE_DIR)
	set(__muli_val
		DEPENDENCIES
		INCLUDE_DIRS
		RESOURCES
		CMAKE
		BOOST_LIB
		LINK_LIB
		QT_LIB)
	set(__options)
	cmake_parse_arguments(AddTarget "${__options}" "${__one_val}" "${__multi_val}" ${ARGN})

	if(AddTarget_NAME EQUAL "")
		message(ERROR "Missing target name")
	endif(AddTarget_NAME EQUAL "")

	message(STATUS "Target with name: ${AddTarget_NAME}")
	FILE(GLOB_RECURSE AddTarget_SRC "${AddTarget_SOURCE_DIR}" "*.c" "*.cpp" "*.h" "*.hpp")

	if(AddTarget_TYPE STREQUAL app)
		add_executable("${AddTarget_NAME}" "${AddTarget_SRC}")
	elseif(AddTarget_TYPE STREQUAL static_lib)
		add_library("${AddTarget_NAME}" STATIC "${AddTarget_SRC}")
	elseif(AddTarget_TYPE STREQUAL shared_lib)
		add_library("${AddTarget_NAME}" SHARED "${AddTarget_SRC}")
	endif(AddTarget_TYPE STREQUAL app)


	if(AddTarget_DEPENDENCIES)
		message(STATUS "Got it")
#		target_link_libraries("${AddTarget_NAME}" "${AddTarget_LINK_LIB}")
	endif(AddTarget_DEPENDENCIES)
endfunction(AddTarget)
