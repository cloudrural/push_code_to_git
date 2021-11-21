#!/bin/bash

# "Usage: $0 [-g <git_repo>] [-b <base_branch>] [-s <source_branch>] [-j <jira_id>] [-c <commit_msg>]"

usage()
{
  echo "Usage: $0 [-g <git_repo>] [-b <base_branch>] [-s <source_branch>] [-j <jira_id>] [-c <commit_msg>]"
  exit 2
}
exit_abnormal() {
  usage
  exit 1
}

while getopts ":j:s:b:g:c:" options; do

  case "${options}" in 
    j)
      JIRA_ID=${OPTARG}
      ;;
    s)
      SRC_BRANCH=${OPTARG}
      ;;
    b)
      BASE_BRANCH=${OPTARG}
      ;;
    g)
      GIT_REPO=${OPTARG}
      ;;
    c)
      COMMIT_MSG=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

_main_func_ () {
    REPO_NAME=$(echo "$GIT_REPO" | sed 's|git@github.com:cloudrural/||;s/.git//')
    COMMIT_ID="$JIRA_ID: $COMMIT_MSG-$(date +%F%T)"
    if [ -d "tmp" ]; then 
       rm -Rf tmp;
    fi

    mkdir tmp

    if [ -d "$REPO_NAME" ]; then
       rm -rf $REPO_NAME; 
    fi

    git clone $GIT_REPO && cd $REPO_NAME
    git checkout $SRC_BRANCH
    cat ../src_files.txt | xargs -I % cp -pvrf ./% ../tmp/
    git checkout $BASE_BRANCH
    cat ../src_files.txt | xargs -I % cp -pvrf ../tmp/% .
    git add . && git commit -m "${COMMIT_ID}"
    git push origin $BASE_BRANCH
}

_main_func_

if [[ _main_func_ ]] ; then
    echo "Successfully Copied the files from $source_branc to $base_branch......!"
else
   echo "Not Success. Please check the variables"
fi
