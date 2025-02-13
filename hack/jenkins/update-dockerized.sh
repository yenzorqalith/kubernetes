#!/usr/bin/env bash

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset

retry() {
  for i in {1..5}; do
    if "$@"; then
      return 0
    else
      sleep "${i}"
    fi
  done
  "$@"
}

# Set artifacts directory
export ARTIFACTS=${ARTIFACTS:-"${WORKSPACE}/artifacts"}
# Produce a JUnit-style XML test report
export KUBE_JUNIT_REPORT_DIR="${ARTIFACTS}"

export LOG_LEVEL=4

cd "${GOPATH}/src/k8s.io/kubernetes"
source "${PWD}/hack/lib/init.sh"
kube::etcd::install
export PATH=${GOPATH}/bin:${PWD}/third_party/etcd:/usr/local/go/bin:${PATH}

make update

if [[ -d "${ARTIFACTS:-}" ]]; then
  # ignore the .git, _output directories and zip up everything else
  zip -y -r "${ARTIFACTS}/updated-files.zip" . -x '*.git*' -x '*_output*'
fi
