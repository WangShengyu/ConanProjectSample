cmake_minimum_required (VERSION 3.6)

project(Sample)

set(TOP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")
LIST(APPEND CMAKE_MODULE_PATH "${TOP_DIR}/cmake/Modules")

include(CMakeUtil)

listSubdir(${PROJECT_SOURCE_DIR} project_subdirs)

# add hdr files
globDirs(${PROJECT_SOURCE_DIR} project_subdirs project_hdr_files *.h)

# add src files
globDirs(${PROJECT_SOURCE_DIR} project_subdirs project_src_files *.cpp)

set(public_include_dir ${PROJECT_SOURCE_DIR}/public)
set(private_include_dir ${PROJECT_SOURCE_DIR}/private)

add_library(${PROJECT_NAME} SHARED ${project_src_files} ${project_hdr_files} )
target_include_directories(${PROJECT_NAME} PRIVATE ${private_include_dir} PUBLIC ${public_include_dir})

conan_target_link_libraries(${PROJECT_NAME})

# specify output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
  COMPILE_FLAGS "/WX"
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/$<CONFIG>
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/$<CONFIG>
)
