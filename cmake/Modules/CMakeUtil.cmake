function(getLibPath lib libdir libpath)
    if (${lib}_RELEASE)
        if (NOT ${lib}_DEBUG)
            get_filename_component(_libDir ${${lib}_RELEASE} DIRECTORY)
            get_filename_component(_lib ${${lib}_RELEASE} NAME)

            set(${libdir} ${_libDir} PARENT_SCOPE)
            set(${libpath} ${_lib} PARENT_SCOPE)
        else ()
            get_filename_component(_libDir_d ${${lib}_DEBUG} DIRECTORY)
            get_filename_component(_lib_d ${${lib}_DEBUG} NAME)
            get_filename_component(_libDir ${${lib}_RELEASE} DIRECTORY)
            get_filename_component(_lib ${${lib}_RELEASE} NAME)

            set(${libdir} ${_libDir} ${_libDir_d} PARENT_SCOPE)
            set(${libpath} debug ${_lib_d} optimized ${_lib} PARENT_SCOPE)
        endif()
    endif()

endfunction(getLibPath)

function(sourceGroup1 relative root_arg)
    set(args)
    set(remove_root)
    # get operator REMOVE and operand
    foreach(narg IN LISTS ARGN)
        if (narg STREQUAL "REMOVE")
            set(remove_root 1)
        else()
            if (remove_root EQUAL 1)
                set (remove_root ${narg})
                string(LENGTH ${remove_root} remove_root_len)
            else()
                list(APPEND args ${narg})
            endif()
        endif()
    endforeach()
    
    if (remove_root EQUAL 1)
        message(FATAL_ERROR "REMOVE operator must follow an operand")
    endif()
    
    foreach(narg IN LISTS args)
        if (relative)
            file(RELATIVE_PATH arg ${relative} ${narg})
        else ()
            set(arg ${narg})
        endif()

        get_filename_component(_base_dir ${arg} DIRECTORY)
        if (_base_dir)
            string(REPLACE / \\ tab ${_base_dir})
            if (tab)
                if (remove_root)
                    string(FIND ${tab} ${remove_root} _str_idx)
                    if (_str_idx EQUAL 0) 
                        string(SUBSTRING ${tab} ${remove_root_len} -1 tab)
                    endif()
                endif()
            endif()
            string(CONCAT _tab ${root_arg} \\ ${tab})
            unset(tab)
        else (_base_dir)
            set(_tab ${root_arg})
        endif(_base_dir)

        source_group(${_tab} FILES ${narg})
    endforeach()
endfunction(sourceGroup1)

function(sourceGroup root_arg)
    sourceGroup1("" ${root_arg} ${ARGN})
endfunction(sourceGroup)

function (genInterfaceFiles output_list)
    foreach(in_file IN LISTS ARGN)
        get_filename_component(file_name ${in_file} NAME_WE)

        set(out_header_name ${file_name}_h.h)
        set(out_header ${CMAKE_CURRENT_BINARY_DIR}/${out_header_name})
        set(out_iid_name ${file_name}_h.c)
        set(out_iid ${CMAKE_CURRENT_BINARY_DIR}/${out_iid_name})

        add_custom_command(
            OUTPUT ${out_header} ${out_iid}
            DEPENDS ${in_file}
            COMMAND midl /header ${out_header_name} /iid ${out_iid_name} ${in_file}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            )

        set_property(SOURCE $[out_header} APPEND PROPERTY OBJECT_DEPENDS ${in_file})

        set_source_files_properties(
            ${out_header}
            ${out_iid}
            PROPERTIES
            GENERATED TRUE
            )

        set_source_files_properties(${in_file} PROPERTIES HEADER_FILE_ONLY TRUE)

        list(APPEND _output_list ${out_header} ${out_iid})
    endforeach()
    sourceGroup1("${CMAKE_CURRENT_BINARY_DIR}" Generated ${_output_list})
    set(${output_list} ${_output_list} PARENT_SCOPE)
endfunction (genInterfaceFiles)

function (copyFiles output_list)
    foreach(in_file IN LISTS ARGN)
        get_filename_component(file_name ${in_file} NAME)

        set(out_file_name ${file_name})
        set(out_file ${CMAKE_CURRENT_BINARY_DIR}/${out_file_name})

        add_custom_command(
            OUTPUT ${out_file}
            DEPENDS ${in_file}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${in_file} ${out_file}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            )

        set_property(SOURCE $[out_file} APPEND PROPERTY OBJECT_DEPENDS ${in_file})

        set_source_files_properties(
            ${out_file}
            PROPERTIES
            GENERATED TRUE
            )

        set_source_files_properties(${in_file} PROPERTIES HEADER_FILE_ONLY TRUE)

        list(APPEND _output_list ${out_file})
    endforeach()
    sourceGroup1("${CMAKE_CURRENT_BINARY_DIR}" Generated ${_output_list})
    set(${output_list} ${_output_list} PARENT_SCOPE)
endfunction (copyFiles)

function (findRuntime package)
    string(TOUPPER ${package} PACKAGE)
    foreach (libname IN LISTS ARGN)
    
        find_file(${libname}_RUNTIME_DEBUG ${libname}d.dll
            PATHS ${${PACKAGE}_DIR}
            ${${PACKAGE}_ROOT}
            ${${PACKAGE}_ROOT}/bin
            ${${PACKAGE}_DIR}/bin
            ${${PACKAGE}_ROOT}/lib
            ${${PACKAGE}_DIR}/lib
            NO_DEFAULT_PATH)

        find_file(${libname}_RUNTIME_RELEASE ${libname}.dll
            PATHS ${${PACKAGE}_DIR}
            ${${PACKAGE}_ROOT}
            ${${PACKAGE}_ROOT}/bin
            ${${PACKAGE}_DIR}/bin
            ${${PACKAGE}_ROOT}/lib
            ${${PACKAGE}_DIR}/lib
            NO_DEFAULT_PATH)

        if (NOT ${libname}_RUNTIME_DEBUG)
            list(APPEND RUNTIME_DEBUG ${${libname}_RUNTIME_RELEASE})
        else()
            list(APPEND RUNTIME_DEBUG ${${libname}_RUNTIME_DEBUG})
        endif()
        list(APPEND RUNTIME_RELEASE ${${libname}_RUNTIME_RELEASE})

        unset(${libname}_RUNTIME_RELEASE)
        unset(${libname}_RUNTIME_DEBUG)
    endforeach()

    set(${PACKAGE}_RUNTIME_DEBUG ${RUNTIME_DEBUG} PARENT_SCOPE)
    set(${PACKAGE}_RUNTIME_RELEASE ${RUNTIME_RELEASE} PARENT_SCOPE)
endfunction()

function(listSubdir curdir result)
    file(GLOB children RELATIVE ${curdir} LIST_DIRECTORIES true ${curdir}/*)
    foreach (child IN LISTS children)
        if (IS_DIRECTORY ${curdir}/${child})
            list(APPEND dirlist ${child})
        endif()
    endforeach()
    # append .
    set(${result} ${dirlist} . PARENT_SCOPE)
endfunction()

function(globDirs curdir directories result)
    foreach(pattern IN LISTS ARGN)
        foreach(dir IN LISTS ${directories})
            if (dir STREQUAL .)
                file(GLOB files RELATIVE ${curdir} ${curdir}/${pattern})
                list(APPEND filelists ${files})
            else ()
                file(GLOB_RECURSE files RELATIVE ${curdir} ${curdir}/${dir}/${pattern})
                list(APPEND filelists ${files})
            endif()
        endforeach()
    endforeach()
    set(${result} ${filelists} PARENT_SCOPE)
endfunction()
macro(groupAutomoc)
    # from 3.8, qt uses moc_compilation.cpp rather than Project_automoc.cpp
    IF(CMAKE_MINOR_VERSION LESS 8)
        SET(_groupAutomocGenerateFile ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_automoc.cpp)
        sourceGroup1(${CMAKE_CURRENT_BINARY_DIR} Generated ${_groupAutomocGenerateFile})
    ELSE()
        SET(_groupAutomocGenerateFile ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_autogen/moc_compilation.cpp)
        sourceGroup1(${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_autogen Generated ${_groupAutomocGenerateFile})
    ENDIF()
    
    set_source_files_properties(${_groupAutomocGenerateFile} PROPERTIES
            GENERATED TRUE
            COMPILE_FLAGS "/wd4896 /wd4819")
    
    UNSET(_groupAutomocGenerateFile)
endmacro()


macro(getRuntimes modules)
    foreach (config_t IN LISTS CMAKE_CONFIGURATION_TYPES)
        string(TOUPPER ${config_t} config)
        set(RUNTIME_LIBRARY_${config})
        foreach (module IN LISTS ${modules})
            string(TOUPPER ${module} module)
            list(APPEND RUNTIME_LIBRARY_${config} ${${module}_RUNTIME_${config}})
        endforeach()
    endforeach()
endmacro()

macro(separateString content result)
    string(REPLACE "*" ";" ${result} ${content})
endmacro()

macro(getModuleInstalls moduleName)	
    get_target_property(output_name ${moduleName} OUTPUT_NAME)
    if (${output_name} STREQUAL output_name-NOTFOUND)
        set(output_name ${moduleName})
    endif()
    get_target_property(moduleName_runtime ${moduleName} RUNTIME_OUTPUT_DIRECTORY)
    get_target_property(moduleName_archive ${moduleName} ARCHIVE_OUTPUT_DIRECTORY)
    get_target_property(moduleName_inc_dirs ${moduleName} SDK_INC_DIRS)
    get_target_property(moduleName_inc_files ${moduleName} SDK_INC_FILES)
    
    set(${moduleName}_inc_list)
    if (NOT ${moduleName_inc_dirs} STREQUAL moduleName_inc_dirs-NOTFOUND)
        separateString(${moduleName_inc_dirs} inc_list)
        foreach(inc_dir IN LISTS inc_list)
            file(GLOB_RECURSE files ${inc_dir}/*.h)
            list(APPEND ${moduleName}_inc_list ${files})
        endforeach()
    endif()
    if (NOT ${moduleName_inc_files} STREQUAL moduleName_inc_files-NOTFOUND)
        separateString(${moduleName_inc_files} inc_list)
        list(APPEND ${moduleName}_inc_list ${inc_list})
    endif()
    
    IF (${moduleName_runtime} STREQUAL moduleName_runtime-NOTFOUND)
        SET(moduleName_runtime)
    ELSE()
        SET(moduleName_runtime ${moduleName_runtime}/${output_name}.dll)
    ENDIF()
    
    IF (${moduleName_archive} STREQUAL moduleName_archive-NOTFOUND)
        SET(moduleName_archive)
    ELSE()
        SET(moduleName_archive ${moduleName_archive}/${output_name}.lib)
    ENDIF()
endmacro()


macro(copyIfUnexist target file dest)
    add_custom_command(TARGET ${target}
        POST_BUILD 
        COMMAND IF NOT EXIST "${dest}" ( ${CMAKE_COMMAND} -E copy "${file}" "${dest}" )
    )
endmacro()

macro(installRuntimes target)
    add_custom_command(TARGET ${target}
        POST_BUILD 
        COMMAND IF $<CONFIG>==Debug (
             ${CMAKE_COMMAND} -E copy_if_different ${RUNTIME_LIBRARY_DEBUG} $<TARGET_FILE_DIR:${target}>
        ) ELSE (
            ${CMAKE_COMMAND} -E copy_if_different ${RUNTIME_LIBRARY_RELEASE} $<TARGET_FILE_DIR:${target}>
        )
        
    )
endmacro()

macro(getInstallRuntimes target runtimes)
    getRuntimes(${runtimes})
    installRuntimes(${target})
endmacro()

macro(getRuntimePath outname path newbase)
    GET_FILENAME_COMPONENT(${outname} ${path} NAME_WE)
    set(${outname} ${newbase}/${${outname}}.dll)
endmacro()

MACRO(addPrecompileEX pchFile)
    SET_SOURCE_FILES_PROPERTIES(${project_src_files} PROPERTIES COMPILE_FLAGS /Yu${pchFile}.h)
    SET_SOURCE_FILES_PROPERTIES(${ARGN}${pchFile}.cpp PROPERTIES COMPILE_FLAGS /Yc${pchFile}.h)
ENDMACRO()

MACRO(addPrecompile)
    addPrecompileEX(stdafx private/)
ENDMACRO()

function(uniqueLists)
    foreach (l IN ARGN)
        list(REMOVE_DUPLICATES l)
    endforeach()
endfunction(uniqueLists)
