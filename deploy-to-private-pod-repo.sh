#!/bin/bash

function deploy {
  VERSION_NUMBER="$1"
  if GIT_DIR=.git git rev-parse $VERSION_NUMBER >/dev/null 2>&1
  then
      printf "Version tag already exist, exiting...\n"
      exit
  fi

  printf "Deploying version $VERSION_NUMBER to private cocoapods...\n";

  TEMPLATE="`cat CoreSDK.podspec.template`"
  PODSPEC="${TEMPLATE/<VERSION_NUMBER>/$VERSION_NUMBER}"
  printf "$PODSPEC" > CoreSDK.podspec

  git tag -a "$VERSION_NUMBER" -m "$VERSION_NUMBER"

  git push --tags

  pod emapod push CoreSDK.podspec --allow-warnings

  printf "[$VERSION_NUMBER] deployed to private cocoapod."
}

if [ -z $1 ]; then
  printf "USAGE: \r\n./deploy-to-private-pod-repo.sh <version-number>\n";
  exit
else
  deploy $1
fi
