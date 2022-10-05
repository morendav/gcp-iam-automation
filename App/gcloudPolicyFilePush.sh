#!/bin/bash
#################################################
#################################################
### This script will push file to gcloud
###   Inputs: [1] policy file to Push
###           [2] Project to push to
#################################################
#################################################
patchedPolicyFile="$1"
projectName="$2"
gcloud projects set-iam-policy "$projectName" "$patchedPolicyFile"
