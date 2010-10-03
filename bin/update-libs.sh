#! /bin/bash
LIBS="dlib ddf particle graphics hid input physics render lua resource script gameobject gui sound gamesys tools"

set -e
[ -z $DYNAMO_HOME ] && echo "DYNAMO_HOME not set" && exit 1

for lib in $LIBS; do
    echo "Checking '$lib'..."
    if [ ! -e ../$lib ]; then
        cd ..
        echo $lib
        repo="overrated.dyndns.org:/repo/$lib"
        if [ -n "$USER_OVERRATED" ]; then
            repo="$USER_OVERRATED@$repo"
        fi
        git clone $repo
        cd $lib
    else
        cd ../$lib

        git fetch
        LOG=`git log origin/master..`
        if [ ! -z "$LOG" ]; then
            echo "You have local commits in '$lib' that needs to be pushed."
            exit 1
        fi
    fi
done

for lib in $LIBS; do
    echo "Updating and building $lib"
    cd ../$lib

    git pull --rebase
    waf configure --prefix=$DYNAMO_HOME
    waf clean

    tmp=`uname -s`
    if [ "MINGW" == ${tmp:0:5} ]; then
        # Avoid some windows related problem in waf
        # Still present?
        set +e
        waf
        set -e
    fi
    waf
    waf install
done
