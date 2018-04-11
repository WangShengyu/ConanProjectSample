cmake_minimum_required (VERSION 3.6)

project(unit_tests)

# set path
set(TOP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")
LIST(APPEND CMAKE_MODULE_PATH "${TOP_DIR}/cmake/Modules")
include(CMakeUtil)

listSubdir(${PROJECT_SOURCE_DIR} project_subdirs)

# add hdr files
globDirs(${PROJECT_SOURCE_DIR} project_subdirs project_hdr_files *.h)

# add src files
globDirs(${PROJECT_SOURCE_DIR} project_subdirs project_src_files *.cpp)

# create .exe
add_executable(${PROJECT_NAME} ${project_src_files} ${project_hdr_files})

set(include_dir
  ${PROJECT_SOURCE_DIR}
  ${PROJECT_SOURCE_DIR}/MathUtilsTests
)
target_include_directories(${PROJECT_NAME} PRIVATE ${include_dir})

# set dependences
add_dependencies(${PROJECT_NAME} Sample)
conan_target_link_libraries(${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} Sample)

