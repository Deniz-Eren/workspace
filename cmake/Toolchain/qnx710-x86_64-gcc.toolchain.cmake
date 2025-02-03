# \file     qnx710-x86_64-gcc.toolchain.cmake
# \brief    CMake QNX 7.1 cross-compile toolchain for x86_64 platform.
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

# The name of the target operating system
set( CMAKE_SYSTEM_NAME qnx710 )
set( arch x86_64 )

# Set toolchain prefix to find the correct tools
set( _CMAKE_TOOLCHAIN_PREFIX    $ENV{QNX_HOST}/usr/bin/ntox86_64- )

# which compilers to use for C and C++
set( CMAKE_C_COMPILER           $ENV{QNX_HOST}/usr/bin/qcc )
set( CMAKE_C_COMPILER_TARGET    gcc_nto${arch} )
set( CMAKE_CXX_COMPILER         $ENV{QNX_HOST}/usr/bin/ntox86_64-c++ )
set( CMAKE_CXX_COMPILER_TARGET  gcc_nto${arch} )

# Set some known tools
set( CMAKE_NM       $ENV{QNX_HOST}/usr/bin/ntox86_64-nm )
set( CMAKE_AR       $ENV{QNX_HOST}/usr/bin/ntox86_64-ar )
set( CMAKE_READELF  $ENV{QNX_HOST}/usr/bin/ntox86_64-readelf )
set( CMAKE_STRIP    $ENV{QNX_HOST}/usr/bin/ntox86_64-strip )

# where is the target environment located
set( CMAKE_FIND_ROOT_PATH
    $ENV{QNX_TARGET}/usr
    $ENV{QNX_TARGET}/x86_64
    $ENV{QNX_TARGET}/x86_64/usr )

# adjust the default behavior of the FIND_XXX() commands:
# search programs in the host environment
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )

# search headers and libraries in the target environment
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )

# set gcov executable
set( QNX_GCOV_EXE $ENV{QNX_HOST}/usr/bin/ntox86_64-gcov )

# set profiling library
set( QNX_PROFILING_LIBRARY $ENV{QNX_TARGET}/x86_64/usr/lib/libprofilingS.a )

# Googletest
set( ENV{GTEST_ROOT} $ENV{QNX_TARGET}/x86_64/usr/ )
set( GTEST_MAIN_LIBRARY $ENV{QNX_TARGET}/x86_64/usr/lib/libgtestS.a )
