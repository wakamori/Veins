cmake_minimum_required(VERSION 2.6)
set(CMAKE_BUILD_TYPE ${KONOHA_BUILD_TYPE})

project(veins)

if(NOT APPLE)
    find_library(HAVE_LIB_UUID uuid)
    if(NOT HAVE_LIB_UUID)
        message(FATAL_ERROR "libuuid not found. Please install uuid-dev or libuuid-devel.")
    endif(NOT HAVE_UUID_LIB)
endif(NOT APPLE)

find_library(HAVE_LIB_SSL ssl)
if(NOT HAVE_LIB_SSL)
    message(FATAL_ERROR "libssl not found.")
endif(NOT HAVE_LIB_SSL)

find_library(HAVE_LIB_CRYPTO crypto)
if(NOT HAVE_LIB_CRYPTO)
    message(FATAL_ERROR "libcrypto not found.")
endif(NOT HAVE_LIB_CRYPTO)

set(PACKAGE_SOURCE_CODE veins.c)
set(PACKAGE_SCRIPT_CODE veins.k)

if(NOT KONOHA_VERSION)
    set(KONOHA_VERSION "1.0")
endif(NOT KONOHA_VERSION)

set(PACKAGE_NAME    ${PROJECT_NAME})
set(KONOHA_PACKAGE_DIR konoha/package/${KONOHA_VERSION}/konoha.${PROJECT_NAME})

set(INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR}
    ${KONOHA_INCLUDE_DIRS})
include_directories(${INCLUDE_DIRS})

add_definitions(-D_SETUP)

add_library(${PACKAGE_NAME} SHARED ${PACKAGE_SOURCE_CODE})
set_target_properties(${PACKAGE_NAME} PROPERTIES PREFIX "")
target_link_libraries(${PACKAGE_NAME} konoha)
if(NOT APPLE)
    target_link_libraries(${PACKAGE_NAME} ${HAVE_LIB_UUID})
endif(NOT APPLE)
target_link_libraries(${PACKAGE_NAME} ${HAVE_LIB_SSL} ${HAVE_LIB_CRYPTO})

install(TARGETS ${PACKAGE_NAME} DESTINATION ${KONOHA_PACKAGE_DIR})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_SCRIPT_CODE} DESTINATION ${KONOHA_PACKAGE_DIR})

