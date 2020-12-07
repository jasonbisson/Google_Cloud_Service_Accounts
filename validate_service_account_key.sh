#!/bin/bash
#set -x
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# -ne 1 ]; then
    echo $0: usage: Requires argument of i.e. senddata
    exit 1
fi

export name=$1
export project_id=$(gcloud config list --format 'value(core.project)')

function decrypt_file () {
    gcloud secrets versions access latest --secret="${name}" | base64 -D > $name.json
    export GOOGLE_APPLICATION_CREDENTIALS=$PWD/$(ls -t ${name}*.json |head -1)
}

function check_buckets () {
    python snippets.py implicit
}

function remove_file () {
    rm -f ${name}*.json*
}

decrypt_file
check_buckets
remove_file
