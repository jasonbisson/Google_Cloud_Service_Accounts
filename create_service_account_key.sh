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
export service_account=$(gcloud iam service-accounts describe ${name}@${project_id}.iam.gserviceaccount.com --project ${project_id})

function check_variables () {
    if [  -z "${project_id}" ]; then
        printf "ERROR: GCP PROJECT_ID is not set.\n\n"
        printf "To view the current PROJECT_ID config: gcloud config list project \n\n"
        printf "To view available projects: gcloud projects list \n\n"
        printf "To update project config: gcloud config set project PROJECT_ID \n\n"
        exit
    fi
    
    if [  -z "${service_account}" ]; then
        printf "ERROR: Service account does not exist.\n\n"
        printf "Review if there is a typo or permission issue to describe a service account \n\n"
        exit
    fi
}


function create_secret () {
    gcloud secrets versions list ${name} |grep enabled
    result=$?
    if [ $result -eq 0 ]; then
        #Adds version to an existing secret
        gcloud iam service-accounts keys create - --iam-account="${name}@$project_id.iam.gserviceaccount.com" | base64 | gcloud secrets versions add ${name} --data-file -
    else
        #Creates a new secret
        gcloud iam service-accounts keys create - --iam-account="${name}@$project_id.iam.gserviceaccount.com" | base64 | gcloud secrets create ${name} --replication-policy=automatic --data-file -
    fi
    #clean up dash
    rm -
}

check_variables
create_secret
