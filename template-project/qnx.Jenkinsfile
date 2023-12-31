/**
 * \file    Jenkinsfile
 * \brief   An example Jenkinsfile Groovy script that projects can use
 *
 * Copyright (C) 2023 Deniz Eren (deniz.eren@outlook.com)
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

node('jenkins-agent') {

    def sshport = "9922";
    def buildpath = "/var/tmp/$NODE_NAME";

    // You will normally define projectpath as /opt/project_repo, however for
    // this template-project setup we need to specify it as follows:
    def projectpath = "/opt/project_repo/template-project";

    try {
        stage('Checkout and setup dev environment') {
            sh(script: """
                rm -rf $buildpath
                mkdir -p $buildpath
            """)

            checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                extensions: [[$class: 'RelativeTargetDirectory',
                    relativeTargetDir: "$buildpath/template-project"]],
                userRemoteConfigs: [[
                    credentialsId: '',
                    url: '/opt/project_repo'
                ]]])

            def publisher = LastChanges.getLastChangesPublisher \
                null, "SIDE", "LINE", true, true, \
                "", "", "", "$buildpath/template-project", ""

            publisher.publishLastChanges()

            sh(script: """
                $projectpath/workspace/ci/scripts/setup-dev-env.sh \
                    -d $projectpath/workspace/dev/.Dockerfile

                mkdir -p /home/jenkins/Images

                $projectpath/workspace/ci/scripts/setup-qnx710-qemu.sh \
                    -d $projectpath/workspace/emulation/qnx710/Dockerfile \
                    -i /home/jenkins/Images/disk-raw
            """)
        }

        stage('Testing with coverage') {
            sh(script: """
                $projectpath/workspace/ci/scripts/start-emulation.sh \
                    -i /home/jenkins/Images/disk-raw \
                    -p $sshport

                $projectpath/workspace/ci/scripts/build-exec-qnx710.sh \
                    -v \
                    -b /data/home/root/build_coverage \
                    -r /root/workspace/template-project \
                    -t Coverage \
                    -p $sshport

                docker exec --user root --workdir /root dev-env bash -c \
                    "source .profile \
                    && /root/workspace/dev/.setup-profile.sh \
                    && cd /data/home/root/build_coverage \
                    && ctest --output-junit test_results.xml || (exit 0)"

                $projectpath/workspace/ci/scripts/stop-qnx710.sh \
                    -b /data/home/root/build_coverage \
                    -p $sshport

                $projectpath/workspace/ci/scripts/stop-emulation.sh

                docker exec --user root --workdir /root dev-env bash -c \
                    "source .profile \
                    && /root/workspace/dev/.setup-profile.sh \
                    && cd /data/home/root/build_coverage \
                    && lcov --gcov-tool=\\\$QNX_HOST/usr/bin/ntox86_64-gcov \
                        -t \"test_coverage_results\" -o tests.info \
                        -c -d /data/home/root/build_coverage \
                        --base-directory=/root/workspace/template-project \
                        --no-external --quiet \
                    && genhtml -o /data/home/root/build_coverage/cov-html \
                        tests.info --quiet"

                rm -rf $WORKSPACE/test-coverage
                rm -rf $WORKSPACE/test_results.xml

                docker cp \
                    dev-env:/data/home/root/build_coverage/cov-html \
                        $WORKSPACE/test-coverage

                docker cp \
                    dev-env:/data/home/root/build_coverage/test_results.xml \
                        $WORKSPACE/test_results.xml
            """)

            junit('test_results.xml')

            publishHTML(target : [allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'test-coverage',
                reportFiles: 'index.html',
                reportName: 'Test Coverage Report',
                reportTitles: 'Test Coverage Report'])
        }

        stage('Testing with Valgrind') {
            sh(script: """
                rm -rf $WORKSPACE/valgrind-*.xml

                $projectpath/workspace/ci/scripts/start-emulation.sh \
                    -i /home/jenkins/Images/disk-raw \
                    -p $sshport

                #
                # Run Valgrind with tool memcheck
                #
                rm -rf /data/home/root/build_memcheck

                export QNX_PREFIX_CMD="valgrind \
                    --tool=memcheck \
                    --leak-check=full \
                    --show-leak-kinds=all \
                    --track-origins=yes \
                    --verbose \
                    --xml=yes --xml-file=valgrind-memcheck.xml"

                $projectpath/workspace/ci/scripts/build-exec-qnx710.sh \
                    -v \
                    -b /data/home/root/build_memcheck \
                    -c template-project \
                    -r /root/workspace/template-project \
                    -t Profiling \
                    -s 1 \
                    -p $sshport

                docker exec --user root --workdir /root dev-env bash -c \
                    "source .profile \
                    && /root/workspace/dev/.setup-profile.sh \
                    && cd /data/home/root/build_memcheck \
                    && ctest --verbose || (exit 0)"

                # If program needs to be slayed, then specify the additional
                # option below:
                #   -k memcheck-amd64-nto
                $projectpath/workspace/ci/scripts/stop-qnx710.sh \
                    -b /data/home/root/build_memcheck \
                    -p $sshport

                docker cp \
                    dev-env:/data/home/root/build_memcheck/valgrind-memcheck.xml \
                    $WORKSPACE/

                #
                # Run Valgrind with tool helgrind
                #
                rm -rf /data/home/root/build_helgrind

                export QNX_PREFIX_CMD="valgrind \
                    --tool=helgrind \
                    --history-level=full \
                    --conflict-cache-size=5000000 \
                    --verbose \
                    --xml=yes --xml-file=valgrind-helgrind.xml"

                $projectpath/workspace/ci/scripts/build-exec-qnx710.sh \
                    -v \
                    -b /data/home/root/build_helgrind \
                    -c template-project \
                    -r /root/workspace/template-project \
                    -t Profiling \
                    -s 1 \
                    -p $sshport

                docker exec --user root --workdir /root dev-env bash -c \
                    "source .profile \
                    && /root/workspace/dev/.setup-profile.sh \
                    && cd /data/home/root/build_helgrind \
                    && ctest --verbose || (exit 0)"

                # If program needs to be slayed, then specify the additional
                # option below:
                #   -k helgrind-amd64-nto
                $projectpath/workspace/ci/scripts/stop-qnx710.sh \
                    -b /data/home/root/build_helgrind \
                    -p $sshport

                docker cp \
                    dev-env:/data/home/root/build_helgrind/valgrind-helgrind.xml \
                    $WORKSPACE/

                #
                # Run Valgrind with tool drd
                #
                rm -rf /data/home/root/build_drd

                export QNX_PREFIX_CMD="valgrind \
                    --tool=drd \
                    --verbose \
                    --xml=yes --xml-file=valgrind-drd.xml"

                $projectpath/workspace/ci/scripts/build-exec-qnx710.sh \
                    -v \
                    -b /data/home/root/build_drd \
                    -c template-project \
                    -r /root/workspace/template-project \
                    -t Profiling \
                    -s 1 \
                    -p $sshport

                docker exec --user root --workdir /root dev-env bash -c \
                    "source .profile \
                    && /root/workspace/dev/.setup-profile.sh \
                    && cd /data/home/root/build_drd \
                    && ctest --verbose || (exit 0)"

                # If program needs to be slayed, then specify the additional
                # option below:
                #   -k drd-amd64-nto
                $projectpath/workspace/ci/scripts/stop-qnx710.sh \
                    -b /data/home/root/build_drd \
                    -p $sshport

                docker cp \
                    dev-env:/data/home/root/build_drd/valgrind-drd.xml \
                    $WORKSPACE/

                #
                # Run Valgrind with tool exp-sgcheck
                #
                rm -rf /data/home/root/build_exp-sgcheck

                export QNX_PREFIX_CMD="valgrind \
                    --tool=exp-sgcheck \
                    --verbose \
                    --xml=yes --xml-file=valgrind-exp-sgcheck.xml"

                $projectpath/workspace/ci/scripts/build-exec-qnx710.sh \
                    -v \
                    -b /data/home/root/build_exp-sgcheck \
                    -c template-project \
                    -r /root/workspace/template-project \
                    -t Profiling \
                    -s 1 \
                    -p $sshport

                docker exec --user root --workdir /root dev-env bash -c \
                    "source .profile \
                    && /root/workspace/dev/.setup-profile.sh \
                    && cd /data/home/root/build_exp-sgcheck \
                    && ctest --verbose || (exit 0)"

                # If program needs to be slayed, then specify the additional
                # option below:
                #   -k exp-sgcheck-amd64-nto
                $projectpath/workspace/ci/scripts/stop-qnx710.sh \
                    -b /data/home/root/build_exp-sgcheck \
                    -p $sshport

                docker cp \
                    dev-env:/data/home/root/build_exp-sgcheck/valgrind-exp-sgcheck.xml \
                    $WORKSPACE/

                $projectpath/workspace/ci/scripts/stop-emulation.sh

                # Have a copy of the repository in the workspace so Valgrind
                # source-code displays works
                rm -rf $WORKSPACE/workspace
                cp -r /opt/workspace $WORKSPACE/
            """)

            publishValgrind(pattern: 'valgrind-*.xml',
                sourceSubstitutionPaths: '/root/workspace:workspace')
        }

        stage('Release') {
            sh(script: """
                docker exec --user root --workdir /root dev-env \
                    bash -c "source .profile \
                        && /root/workspace/dev/.setup-profile.sh \
                        && mkdir -p build_release \
                        && cd build_release \
                        && cmake -DSSH_PORT=$sshport -DCMAKE_BUILD_TYPE=Release \
                                ../workspace/template-project \
                        && make -j8 \
                        && cpack \
                        && DIR=\\\"Release/template-project/\\\$(date \\\"+%Y-%m-%d-%H%M%S%Z\\\")\\\" \
                        && mkdir -p \\\"\\\$DIR\\\" \
                        && cp *-*.tar.gz \\\"\\\$DIR\\\""

                docker cp \
                    dev-env:/root/build_release/Release/template-project \
                    /var/Release/
            """)
        }
    }
    catch (err) {
        currentBuild.result = 'FAILURE'
    }
    finally {
        stage('Clean-up') {
            sh(script: """
                docker stop dev-env qemu-env || (exit 0)
                docker rm dev-env qemu-env || (exit 0)

                rm -rf $buildpath
            """)
        }
    }
}
