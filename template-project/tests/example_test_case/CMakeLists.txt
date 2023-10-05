# \file     CMakeLists.txt
# \brief    CMake listing file for example tests
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

add_executable( example-test-case ${C_SOURCE_FILES} example-tests.cpp )

target_include_directories( example-test-case PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/> )

if( CMAKE_BUILD_TYPE MATCHES Profiling )
    target_link_libraries( example-test-case PRIVATE
        ${GTEST_LIBRARIES}
        ${QNX_PROFILING_LIBRARY} )
else()
    target_link_libraries( example-test-case PRIVATE
        ${GTEST_LIBRARIES} )
endif()

if( "${CMAKE_C_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" OR
    "${CMAKE_CXX_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" )

    add_custom_target( ssh-example-test-case ALL
        COMMAND ${CMAKE_SOURCE_DIR}/workspace/cmake/Modules/MakeSSHCommand.sh
            -p ${SSH_PORT}
            -s ${CMAKE_CURRENT_BINARY_DIR}/example-test-case
            -r ${CMAKE_BINARY_DIR}
            -o ssh-example-test-case.sh
        BYPRODUCTS ssh-example-test-case.sh
        DEPENDS example-test-case )

    add_test( NAME ssh-example-test-case COMMAND ssh-example-test-case.sh )

else()
    gtest_discover_tests( example-test-case )
endif()

code_coverage_run( example-test-case )

# TODO: implement profiling for unit tests
#valgrind_profiling_run( example-test-case )
