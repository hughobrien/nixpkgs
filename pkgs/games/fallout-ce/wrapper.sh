#!/usr/bin/env bash

NOTICE=0
FAULT=0

REQUIRED_FILES=(master.dat critter.dat)
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "Required file $f not found in $PWD, note the files are case-sensitive"
        NOTICE=1 FAULT=1
    fi
done

if [ ! -d "data/sound/music" ]; then
    echo "data/sound/music directory not found in $PWD. This may prevent in-game music from functioning."
    NOTICE=1
fi

if [ $NOTICE ]; then
    echo "Please reference the installation instructions at https://github.com/alexbatalov/fallout2-ce"
fi

exit $FAULT
