##
# \file     CMakeLists.txt
# \brief    Main CMake file for the project.
#
# Copyright (C) 2023 Deniz Eren (deniz.eren@outlook.com)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#

cmake_minimum_required( VERSION 3.22 )

# Set the toolchain file to QNX 7.1
if( DEFINED ENV{QNX_HOST} )
    set( CMAKE_TOOLCHAIN_FILE
        ${CMAKE_SOURCE_DIR}/workspace/cmake/Toolchain/qnx710-x86_64.toolchain.cmake )
endif()

project( template-project )

# Append module paths to CMAKE_MODULE_PATH
list( APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/workspace/cmake/Modules )

# Read configuration items from config/ files
file( STRINGS "${PROJECT_SOURCE_DIR}/config/PROGRAM_VERSION" PROGRAM_VERSION )
file( STRINGS "${PROJECT_SOURCE_DIR}/config/CONFIG_EXAMPLE" CONFIG_EXAMPLE )

add_compile_options( -Wall )

add_compile_definitions( PROGRAM_VERSION="${PROGRAM_VERSION}" )
add_compile_definitions( CONFIG_EXAMPLE=${CONFIG_EXAMPLE} )

project( template-project
         VERSION ${PROGRAM_VERSION}
         LANGUAGES C CXX )

set( SSH_PORT "6022" CACHE STRING "SSH port number" )

include( CodeCoverageProfiler )

# Compiler settings
set( CMAKE_CXX_STANDARD 17 )
set( CMAKE_CXX_STANDARD_REQUIRED True )

# Enable output of compile commands during generation
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

install( FILES ${CMAKE_SOURCE_DIR}/README.md
    DESTINATION share/${CMAKE_PROJECT_NAME}
    COMPONENT bin )

install( FILES ${CMAKE_SOURCE_DIR}/README.md
    DESTINATION share/${CMAKE_PROJECT_NAME}
    COMPONENT dev )

install( FILES ${CMAKE_SOURCE_DIR}/LICENSE
    DESTINATION share/${CMAKE_PROJECT_NAME}
    COMPONENT bin )

install( FILES ${CMAKE_SOURCE_DIR}/LICENSE
    DESTINATION share/${CMAKE_PROJECT_NAME}
    COMPONENT dev )

# Install headers
install( DIRECTORY ${CMAKE_SOURCE_DIR}/${CMAKE_PROJECT_NAME}
    DESTINATION include/
    COMPONENT dev )

list( APPEND C_SOURCE_FILES
    ${CMAKE_SOURCE_DIR}/src/example.c )

# aux_source_directory(
#     ${CMAKE_SOURCE_DIR}/src/some/path/to/other/source/folders C_SOURCE_FILES )

add_executable( ${CMAKE_PROJECT_NAME}
    ${CMAKE_SOURCE_DIR}/src/main.c
    ${C_SOURCE_FILES} )

target_include_directories( ${CMAKE_PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/> )

if( CMAKE_BUILD_TYPE MATCHES Profiling )
    target_link_libraries( ${CMAKE_PROJECT_NAME} ${QNX_PROFILING_LIBRARY} )
else()
    target_link_libraries( ${CMAKE_PROJECT_NAME} )
endif()

install( TARGETS ${CMAKE_PROJECT_NAME}
    DESTINATION bin/
    COMPONENT bin )

include( CTest )

code_coverage_flags()
code_profiling_flags()

add_subdirectory( tests )

# Package settings
set( CPACK_GENERATOR "TGZ" )
set( CPACK_SYSTEM_NAME ${CMAKE_SYSTEM_NAME}${BUILD_TYPE_NAME} )
set( CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF )
set( CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR} )
set( CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR} )
set( CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH} )
set( CPACK_PACKAGE_VERSION ${PROJECT_VERSION} )
set( CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/README.md" )
set( CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE" )
set( CPACK_ARCHIVE_COMPONENT_INSTALL ON )
set( CPACK_ARCHIVE_BIN_FILE_NAME
    ${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME} )

set( CPACK_ARCHIVE_DEV_FILE_NAME
    ${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_NAME}-dev )

include( CPack )
