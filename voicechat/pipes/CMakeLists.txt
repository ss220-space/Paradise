cmake_minimum_required(VERSION 3.10)
project(voicechat_byond_socket)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Platform detection
if(APPLE)
    set(PLATFORM "macos")
elseif(UNIX)
    set(PLATFORM "linux")
elseif(WIN32)
    set(PLATFORM "windows")
endif()

message(STATUS "Building for platform: ${PLATFORM}")

# BYOND SDK paths
if(NOT BYOND_PATH)
    if(NOT TGS_INSTANCE_ROOT)
        set(TGS_INSTANCE_ROOT "/opt/byond" CACHE PATH "TGS instance root path")
    endif()
    set(BYOND_VERSION "515" CACHE STRING "BYOND version")
    set(BYOND_PATH "${TGS_INSTANCE_ROOT}/Byond/${BYOND_VERSION}/byond/bin")
endif()

message(STATUS "BYOND path: ${BYOND_PATH}")

# Source files
set(SOURCES
    main.cpp
    unix/byondapi/byondapi_cpp_wrappers.cpp
)

# Add shared library target
if(PLATFORM STREQUAL "windows")
    add_library(byondsocket SHARED ${SOURCES})
    set_target_properties(byondsocket PROPERTIES
        SUFFIX ".dll"
        PREFIX ""
        OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/windows"
    )
else()
    add_library(byondsocket SHARED ${SOURCES})
    set_target_properties(byondsocket PROPERTIES
        OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/unix"
    )

    # Use 32-bit compilation on Unix
    set_target_properties(byondsocket PROPERTIES
        COMPILE_FLAGS "-m32"
        LINK_FLAGS "-m32"
    )

    # Set correct suffix for platform
    if(APPLE)
        set_target_properties(byondsocket PROPERTIES SUFFIX ".dylib")
    else()
        set_target_properties(byondsocket PROPERTIES SUFFIX ".so")
    endif()
endif()

# Include directories
target_include_directories(byondsocket PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${BYOND_PATH}
)

# Platform-specific settings
if(PLATFORM STREQUAL "windows")
    # Windows: Link against winsock2
    target_link_libraries(byondsocket PRIVATE ws2_32)
    target_compile_options(byondsocket PRIVATE /W3 /D_CRT_SECURE_NO_WARNINGS)
else()
    # Unix/Linux/macOS: Link against pthread
    target_link_libraries(byondsocket PRIVATE pthread)
    target_compile_options(byondsocket PRIVATE
        -Wall -Wno-deprecated -O3 -fno-strict-aliasing -fPIC
    )

    # Link BYOND library
    if(EXISTS "${BYOND_PATH}/libbyond.so")
        target_link_libraries(byondsocket PRIVATE "${BYOND_PATH}/libbyond.so")
    elseif(EXISTS "${BYOND_PATH}/libbyond.dylib")
        target_link_libraries(byondsocket PRIVATE "${BYOND_PATH}/libbyond.dylib")
    endif()
endif()

# Compiler flags
if(MSVC)
    target_compile_options(byondsocket PRIVATE /Od /W3)
else()
    target_compile_options(byondsocket PRIVATE -g -O3)
endif()

message(STATUS "Target: byondsocket")
message(STATUS "Output directory: ${CMAKE_CURRENT_SOURCE_DIR}/${PLATFORM}")
