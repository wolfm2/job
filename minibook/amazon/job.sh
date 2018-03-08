#!/bin/bash

# TODO
# Make repo shallow
# prevent writing outside dir

# NOTE:
# make non sudoable uid
# make job repo; add deploy pub key
# git clone ssh://git@github.com/wolfm2/job.git
# git config user.email wolfm2@newschool.edu
# git config user.name eydu
# cron: * * * * * ~/Desktop/gitJobPoll.sh

GIT='/usr/bin/git'
PYT='/home/wolfm2/anaconda3/bin/python'
RSY='/usr/bin/rsync'

# option to keep past runs

function doJobIn() {
  cd ~/jobin
  FOUT=`$GIT fetch 2>&1`
  if [ -n "$FOUT" ]; then # check for new stuff
    date
    echo Doing...
    $GIT pull
    $RSY --delete -av minibook/ ~/jobout/minibook --exclude dataIn.?? --exclude job.log # update files
    cd ~/jobout
    $PYT ~/jobin/main.py
  fi
}

function doJobOut() {
  cd ~/jobout   

  find minibook -type f -not -size +90M -exec git add {} \; # add small/unpacked/multipart zips
  COMMIT=`$GIT commit -am "Output: \`date\`" | grep -E 'nothing to commit|nothing added to commit'`
  if [ -z "$COMMIT" ]; then
    echo Pushing...
    $GIT push 
  fi 
}

########
# MAIN #
########

mkdir -p ~/jobout/minibook
exec &> ~/jobout/minibook/job.log

doJobIn
doJobOut
ls -lR # get file list

exit 0
# any better way to flatten/prune history?
rm -rf .git/ 
git init
git remote add origin ssh://git@github.com/wolfm2/jobout.git
git config user.email wolfm2@newschool.edu
git config user.name eydu
git add .gitignore minibook 
git commit -am "flattened"
git push -f origin master

