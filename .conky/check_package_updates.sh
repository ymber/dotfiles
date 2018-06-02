#!/bin/sh

if [ "$1" = "packages" ]; then
    if [ -e "${TMPDIR}/checkup-db-${USER}-packages/db.lck" ]; then
        echo "database locked"
        exit 1
    else
        if [ "$2" = "short" ]; then
            UPDATES=$(CHECKUPDATES_DB="${TMPDIR}/checkup-db-${USER}-packages/" checkupdates)
            echo "$UPDATES" | tail -n 15
            UPDATE_COUNT=$(wc -l <<< "$UPDATES")
            echo "$(expr $UPDATE_COUNT - 15) not listed"
        else
            CHECKUPDATES_DB="${TMPDIR}/checkup-db-${USER}-packages/" checkupdates
        fi
    fi
elif [ "$1" = "count" ]; then
    if [ -e "${TMPDIR}/checkup-db-${USER}-count/db.lck" ]; then
        echo "database locked"
        exit 1
    else
        CHECKUPDATES_DB="${TMPDIR}/checkup-db-${USER}-count/" checkupdates | wc -l
    fi
else
    echo "invalid argument"
    exit 1
fi
