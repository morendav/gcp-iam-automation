#!/bin/bash
#################################################
#################################################
### This script will id files changed in the
### last n days from the git hub master branch repo
###   Inputs: [1] GitHub Local copy of origin branch
###           [2] Directory from autoGCPPolicyScript --> where to push temp folder to
###   Output: [1] policFilesToUpdate.txt  --> populated with the policies udpated since last run
#################################################
#################################################
cd "$1"
nDays="1"
git pull upstream master
git log --pretty=format: --name-only --since="$nDays day ago" | sort | uniq | grep -i ".yml" > "$2/PolicyFilesToUpdate.txt"
git log --pretty=format: --name-only --since="$nDays day ago" | sort | uniq | grep -i ".json" > "$2/BucketFilesToUpdate.txt"
