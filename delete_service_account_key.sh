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
export environment=$1
export project_id=$(gcloud config list --format 'value(core.project)')

function check_variables () {
    if [  -z "${project_id}" ]; then
        printf "ERROR: GCP PROJECT_ID is not set.\n\n"
        printf "To view the current PROJECT_ID config: gcloud config list project \n\n"
        printf "To view available projects: gcloud projects list \n\n"
        printf "To update project config: gcloud config set project PROJECT_ID \n\n"
        exit
    fi
}

function delete_iam_key () {
    export private_key_id=$(gcloud -q iam service-accounts keys list --iam-account "${environment}@$project_id.iam.gserviceaccount.com" --managed-by=user --format 'value(name)' |head -1)
    if [  -z "${private_key_id}" ]; then
        printf "No Service account keys to delete for ${environment}@$project_id.iam.gserviceaccount.com \n\n"
        exit
    fi
    gcloud -q iam service-accounts keys delete ${private_key_id} --iam-account "${environment}@$project_id.iam.gserviceaccount.com"
    delete_iam_key_status=$?
    if [ "$delete_iam_key_status" -eq 0 ]; then
        delete_secret_key
    fi
}


function delete_secret_key () {
    active_secrets=$(gcloud secrets versions list ${environment} --format value'(name,state)' |grep enabled | awk '{print $1}')
    number_of_versions=$(echo "$active_secrets" | wc -l)
    
    if [  -z "$private_key_id" ]; then
        printf "ERROR: Private key id unknown.\n\n"
        printf "ERROR: Exiting since we can't determine the secret to delete.\n\n"
        exit
    fi
    
    count=0
    for x in ${active_secrets}
    do
        secret_private_key_id=$(gcloud secrets versions access $x --secret="${environment}" | base64 -D |grep private_key_id |awk -F\" '{print $4}')
        if [ "${private_key_id}" = "${secret_private_key_id}" ]; then
            printf "Secret version $x matches Service account: ${environment}@$project_id.iam.gserviceaccount.com Key ID: ${private_key_id}\n\n"
            gcloud secrets versions destroy $x --secret="${environment}" --quiet --project ${project_id}
            break
        else
            printf "Secret version $x does not match Service account: ${environment}@$project_id.iam.gserviceaccount.com Key ID: ${private_key_id}\n\n"
        fi
        count=$((count + 1))
    done

    if [ "$count" -eq "$number_of_versions" ];then
        printf "No Secret versions found Service account: ${environment}@$project_id.iam.gserviceaccount.com Key ID: ${private_key_id}\n\n"
        printf "Manual investigation required to determine if secret was manually delete or never existed in Secrets manager \n\n"
    fi
}


check_variables
delete_iam_key

