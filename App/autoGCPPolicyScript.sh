#!/bin/bash
#################################################
#################################################
### Run script as follows
###   chmod +x autoGCPPolicyScript.sh
###   ./autoGCPPolicyScript.sh
#################################################
#################################################
# Setup peripheral scripts to execute
chmod +x idPolicyFiles.sh
chmod +x gcloudPolicyFilePush.sh
# Define directories as variables (env dependent)
dir=$(pwd)
gcp_repo="$HOME/IAE/Cloud/GCP AP/GitLocal/csp-access-policies"
# (env independent)
mkdir "$dir/temp_OutputDir"
mkdir "$dir/Logs"
ptchFile="$dir/temp_OutputDir/patchfile.patch"
patchedPolicyFile="$dir/temp_OutputDir/patchedPolicyFile"
#################################################
# ID YMLs updated in repo in (n) days
#     This script will call GIT
./idPolicyFiles.sh "$gcp_repo" "$dir"
#################################################
# Log File Creator
now=$(date +"%Y%m%d")
logFile="$dir/Logs/GCPAuto.logFile.$now.txt"
printf "Auto GCP Policy Push Script Logging\nRun Timestamp: " > "$logFile"
date >> "$logFile"
#################################################
# Run for each polciy file updated in repo
while IFS='' read -r line || [[ -n "$line" ]]; do
  ###   define file for each run
  repoPolicyName=$(echo "$line" | cut -d "/" -f 5)
  gcpPolicyName=$(grep -i "$repoPolicyName" < ./References/policyMappingFile.txt | cut -d "^" -f 2)
  gcpPolicyFile="$dir/temp_OutputDir/$gcpPolicyName.yml"
  gcloud projects get-iam-policy "$gcpPolicyName" > "$gcpPolicyFile"
  repoPolicyYml=$(echo "$gcp_repo/$line")
  ###   Log print - project name && Full Diff && PatchFile
  printf "#############################\n#############################\n$repoPolicyName reported for sync\n#############################\nDiff Report\n" >> "$logFile"
  diff "$repoPolicyYml" "$gcpPolicyFile" >> "$logFile"
  ###   Create & Apply patch file
  diff "$repoPolicyYml" "$gcpPolicyFile"| grep -B 1 -i "serviceaccount:[0-9][0-9][0-9][0-9][0-9]" > "$ptchFile"
  diff "$repoPolicyYml" "$gcpPolicyFile"| grep -B 1 -A 2 -i "< etag:" >> "$ptchFile"
  if [ -s "$ptchFile" ]
  then
  ## if patch not empty, patch file and rename
    ###   Log print - patch file
    printf "#############################\nPatch Input File\n" >> "$logFile"
    cat "$ptchFile" >> "$logFile"
    ####  PROD        ####
    patch "$repoPolicyYml" -i "$ptchFile" -o "$repoPolicyYml" ### --> Patched file should replace the repo file
    ####  LoggingMode ####
      # patch "$repoPolicyYml" -i "$ptchFile" -o "$patchedPolicyFile.$repoPolicyName" ### --> patch to temp file
  else
  ## if patch file empty, copy the origianl yml as the patched yml
    printf "#############################\nPatch File Empty\n" >> "$logFile"
    ####  LoggingMode ####
      # cp "$repoPolicyYml" "$patchedPolicyFile.$repoPolicyName"
  fi
  ###   Run gcloud Policy Update script
  ####PROD####
    ./gcloudPolicyFilePush.sh "$repoPolicyYml" "$gcpPolicyName"
  ####  LoggingMode ####
    # mv "$patchedPolicyFile.$repoPolicyName" "$dir/Logs/reportingOnly.$now.$repoPolicyName"  # move patched file to logs for reporting
done < ./PolicyFilesToUpdate.txt
#################################################
### Remove files no longer needed
    rm -r "$dir/PolicyFilesToUpdate.txt"
    rm -r "$dir/BucketFilesToUpdate.txt"
    rm -r "$dir/temp_OutputDir"
