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


[[ "$#" -ne 2 ]] && { echo "Usage : `basename "$0"` --name <unique_name>"; exit 1; }
[[ "$1" = "--name" ]] &&  export name=$2

export project_id=$(gcloud config list --format 'value(core.project)')
export requestor=$(gcloud config list --format 'value(core.account)')
export time=$(date +"%m-%d-%y-%T")

function check_variables () {
    if [  -z "$project_id" ]; then
        printf "ERROR: GCP PROJECT_ID is not set.\n\n"
        printf "To view the current PROJECT_ID config: gcloud config list project \n\n"
        printf "To view available projects: gcloud projects list \n\n"
        printf "To update project config: gcloud config set project PROJECT_ID \n\n"
        exit
    fi
    
    if [  -z "$requestor" ]; then
        printf "ERROR: Requestor is not set.\n\n"
        printf "Run gcloud config get-value account \n\n"
        printf "To view the active account \n\n"
        printf "To update the core account config: gcloud init \n\n"
        exit
    fi
    
    if [ ${#name} -lt 5 ]; then
        printf "Service account must be between 6-30 characters\n"
        exit
    fi
}

function create_service_account () {
    gcloud iam service-accounts create  ${name} --display-name "${name}" --description "Who: ${requestor} When: ${time}" --project ${project_id}
}

check_variables
create_service_account
