##
# \file     CodeCoverageProfiler.cmake
# \brief    CMake module file for code coverage, profiling and static analysis
#           toolchains.
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

option( DISABLE_COVERAGE_HTML_GEN
        "Disable clang-tidy static analysis checks" OFF )

if( "${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR
    "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" )

    option( DISABLE_CLANG_TIDY "Disable clang-tidy static analysis checks" OFF )

    option( ENABLE_CLANG_ADDRESS_SANITIZER
        "Enable clang AddressSanitizer checks" OFF )

    option( ENABLE_CLANG_THREAD_SANITIZER
        "Enable clang ThreadSanitizer checks" OFF )

endif()

option( ENABLE_VALGRIND_MEMCHECK
    "Enable Valgrind profiling with memcheck tool" OFF )

option( ENABLE_VALGRIND_HELGRIND
    "Enable Valgrind profiling with helgrind tool" OFF )

option( ENABLE_VALGRIND_DRD
    "Enable Valgrind profiling with drd tool" OFF )

if( CMAKE_BUILD_TYPE MATCHES Coverage )
    add_compile_definitions( DEBUG_BUILD=1 )
    add_compile_definitions( COVERAGE_BUILD=1 )
    set( BUILD_TYPE_NAME "-cov" )
elseif( CMAKE_BUILD_TYPE MATCHES Profiling )
    add_compile_definitions( DEBUG_BUILD=1 )
    add_compile_definitions( PROFILING_BUILD=1 )
    set( BUILD_TYPE_NAME "-pro" )
elseif( CMAKE_BUILD_TYPE MATCHES Debug )
    add_compile_definitions( DEBUG_BUILD=1 )
    set( BUILD_TYPE_NAME "-g" )
elseif( CMAKE_BUILD_TYPE MATCHES Release )
    add_compile_definitions( RELEASE_BUILD=1 )
    set( BUILD_TYPE_NAME "" )
endif()

if( "${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR
    "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" )

    if( NOT DISABLE_CLANG_TIDY )
        find_program( TIDY_FOUND clang-tidy )

        if( NOT TIDY_FOUND )
            message( FATAL_ERROR "clang-tidy not found!" )
        endif()

        string( CONCAT TIDY_CHECKS
            "-checks=*,"
                # Specifying the unwanted checks
                "-cppcoreguidelines-pro-bounds-array-to-pointer-decay,"
                "-cppcoreguidelines-pro-type-union-access,"
                "-cppcoreguidelines-pro-type-vararg,"
                "-fuchsia-default-arguments,"
                "-google-readability-todo,"
                "-google-runtime-references,"
                "-hicpp-no-array-decay,"
                "-hicpp-vararg,"
                "-llvm-include-order,"
                "-llvmlibc-implementation-in-namespace,"
                "-llvmlibc-restrict-system-libc-headers,"
                "-readability-braces-around-statements,"
                "-readability-avoid-const-params-in-decls;" )

        set( CMAKE_CXX_CLANG_TIDY
            clang-tidy; -header-filter=src/*pp; ${TIDY_CHECKS} )
    endif()

    if( ENABLE_CLANG_ADDRESS_SANITIZER )
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
            -fsanitize=address -fno-omit-frame-pointer" )

        set( LDFLAGS "${LDFLAGS} -fsanitize=address" )
    endif()

    if( ENABLE_CLANG_THREAD_SANITIZER )
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=thread" )

        set( LDFLAGS "${LDFLAGS} -fsanitize=thread" )
    endif()
endif()

if( ENABLE_VALGRIND_MEMCHECK OR
    ENABLE_VALGRIND_HELGRIND OR
    ENABLE_VALGRIND_DRD )

    find_program( Valgrind_FOUND valgrind )

    if( NOT Valgrind_FOUND )
        message( FATAL_ERROR "valgrind not found!" )
    endif()
endif()


function( code_coverage_flags )
    if( CMAKE_BUILD_TYPE MATCHES Coverage )
        if( "${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR
            "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" )

            find_program( LLVM_COV_PATH llvm-cov )

            if( NOT LLVM_COV_PATH )
                message( FATAL_ERROR "llvm-cov not found!" )
            endif()

            set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} \
                -fprofile-instr-generate -fcoverage-mapping -ggdb"
                PARENT_SCOPE )

            set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
                -fprofile-instr-generate -fcoverage-mapping -ggdb"
                PARENT_SCOPE )

            set( LDFLAGS "${LDFLAGS} -fprofile-instr-generate" PARENT_SCOPE )

        elseif( "${CMAKE_C_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" OR
                "${CMAKE_CXX_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" )

            find_program( LCOV_PATH lcov )
            find_program( GENHTML_PATH genhtml )

            if( NOT LCOV_PATH )
                message( FATAL_ERROR "lcov not found!" )
            endif()

            if( NOT GENHTML_PATH )
                message( FATAL_ERROR "genhtml not found!" )
            endif()

            set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} \
                -ftest-coverage -fprofile-arcs -O0 -g -nopipe -Wc,-auxbase-strip,$@"
                PARENT_SCOPE )

            set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
                -ftest-coverage -fprofile-arcs -O0 -g -dumpbase -dumpdir -save-temps"
                PARENT_SCOPE )

            set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
                -ftest-coverage -fprofile-arcs -p"
                PARENT_SCOPE )

        elseif( CMAKE_COMPILER_IS_GNUCXX )
            find_program( LCOV_PATH lcov )
            find_program( GENHTML_PATH genhtml )

            if( NOT LCOV_PATH )
                message( FATAL_ERROR "lcov not found!" )
            endif()

            if( NOT GENHTML_PATH )
                message( FATAL_ERROR "genhtml not found!" )
            endif()

            set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} \
                --coverage -fprofile-arcs -ftest-coverage -ggdb -O0"
                PARENT_SCOPE )

            set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
                --coverage -fprofile-arcs -ftest-coverage -ggdb -O0"
                PARENT_SCOPE )

        else()
            message( FATAL_ERROR "Code coverage requires Clang or GCC!" )
        endif()
    endif()
endfunction( code_coverage_flags )


function( code_coverage_run exec_target_name )
    if( CMAKE_BUILD_TYPE MATCHES Coverage AND NOT DISABLE_COVERAGE_HTML_GEN )
        if( "${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR
            "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" )

            set( profraw_file
                ${CMAKE_CURRENT_BINARY_DIR}/${exec_target_name}.profraw )

            add_custom_target( ${exec_target_name}-cov-run ALL
                COMMAND LLVM_PROFILE_FILE=${profraw_file}
                        ${CMAKE_CURRENT_BINARY_DIR}/${exec_target_name}
                        || (exit 0)
                DEPENDS ${exec_target_name} )

            set( LLVM_PROFRAW_FILES ${LLVM_PROFRAW_FILES} ${profraw_file}
                CACHE STRING "" )

            set( LLVM_TEST_COV_OBJECTS ${LLVM_TEST_COV_OBJECTS}
                ${CMAKE_CURRENT_BINARY_DIR}/${exec_target_name}
                CACHE STRING "" )

        elseif( "${CMAKE_C_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" OR
                "${CMAKE_CXX_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" )

            add_custom_target( ${exec_target_name}-cov-run ALL
                COMMAND ${CMAKE_CURRENT_BINARY_DIR}/ssh-${exec_target_name}.sh
                        || (exit 0)
                DEPENDS ssh-${exec_target_name} )

        elseif( CMAKE_COMPILER_IS_GNUCXX )
            add_custom_target( ${exec_target_name}-cov-run ALL
                COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${exec_target_name}
                        || (exit 0)
                DEPENDS ${exec_target_name} )
        endif()
    endif()
endfunction( code_coverage_run )


function( code_coverage_gen_html all_cov_runs )
    if( CMAKE_BUILD_TYPE MATCHES Coverage AND NOT DISABLE_COVERAGE_HTML_GEN )
        if( "${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR
            "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" )

            add_custom_target( test-cov-preprocessing ALL
                COMMAND llvm-profdata merge
                    -sparse ${LLVM_PROFRAW_FILES}
                    -o ${CMAKE_CURRENT_BINARY_DIR}/tests.profdata
                DEPENDS ${all_cov_runs} )

            add_custom_target( test-cov-html ALL
                COMMAND llvm-cov show ${LLVM_TEST_COV_OBJECTS}
                    -instr-profile=${CMAKE_CURRENT_BINARY_DIR}/tests.profdata
                    -Xdemangler c++filt -Xdemangler -n
                    -show-line-counts-or-regions
                    -output-dir=${CMAKE_CURRENT_BINARY_DIR}/test-coverage
                    -format="html"
                DEPENDS test-cov-preprocessing )

        elseif( "${CMAKE_C_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" OR
                "${CMAKE_CXX_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" )

            add_custom_target( test-cov-preprocessing ALL
                COMMAND lcov
                    --gcov-tool=${QNX_GCOV_EXE}
                    -t "test_coverage_results" -o unit-tests.info
                    -c -d ${CMAKE_BINARY_DIR}
                    --base-directory=${CMAKE_SOURCE_DIR}
                    --no-external --quiet
                DEPENDS ${all_cov_runs} )

            add_custom_target( test-cov-html ALL
                COMMAND genhtml
                    -o ${CMAKE_CURRENT_BINARY_DIR}/test-coverage unit-tests.info
                    --quiet
                DEPENDS test-cov-preprocessing )

        elseif( CMAKE_COMPILER_IS_GNUCXX )

            add_custom_target( test-cov-preprocessing ALL
                COMMAND lcov -t "test_coverage_results" -o unit-tests.info
                    -c -d ${CMAKE_BINARY_DIR}
                    --base-directory=${CMAKE_SOURCE_DIR}
                    --no-external --quiet
                DEPENDS ${all_cov_runs} )

            add_custom_target( test-cov-html ALL
                COMMAND genhtml
                    -o ${CMAKE_CURRENT_BINARY_DIR}/test-coverage unit-tests.info
                    --quiet
                DEPENDS test-cov-preprocessing )
        endif()
    endif()
endfunction( code_coverage_gen_html )


function( code_profiling_flags )
    if( CMAKE_BUILD_TYPE MATCHES Profiling )
        if( "${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR
            "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" )

            # Currently not handled or needed

        elseif( "${CMAKE_C_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" OR
                "${CMAKE_CXX_COMPILER_ID}" MATCHES "(QNX)?QCC|qcc" )

            set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -finstrument-functions -O0 -g"
                PARENT_SCOPE )

            set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
                -finstrument-functions -O0 -g"
                PARENT_SCOPE )

        elseif( CMAKE_COMPILER_IS_GNUCXX )

            # Currently not handled or needed

        else()
            message( FATAL_ERROR "Code profiling requires Clang or GCC!" )
        endif()
    endif()
endfunction( code_profiling_flags )
