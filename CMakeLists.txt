cmake_minimum_required (VERSION 3.8)

project(ConanProjectSample)

# read args
set(DEVELOP "DEVELOP" CACHE BOOL False)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER ACMakePredefined)
set(USE_FOLDERS ON)
set(CMAKE_CONFIGURATION_TYPES Debug Release)
set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING "Reset the configurations to what we need" FORCE)

# multiple process compilation
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")

# release dbg
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /DEBUG")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /DEBUG")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /OPT:REF /OPT:ICF")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF")

# charset
add_definitions(-DUNICODE -D_UNICODE)

# runtime install path
set(RUNTIME_DESTINATION ./build/bin)

add_subdirectory(cmake)
add_subdirectory(src)
if (${DEVELOP})
  add_subdirectory(unit_tests)
endif()

execute_process(COMMAND git config core.hooksPath .githooks)
