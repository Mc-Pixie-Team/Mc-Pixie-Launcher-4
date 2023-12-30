cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(zip VERSION 1.0.0 LANGUAGES C)
add_library(zip SHARED pixie.c pixie.def zip.c)
add_executable(zip1 pixie.c)

set_target_properties(zip PROPERTIES
    PUBLIC_HEADER pixie.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "pixie"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
