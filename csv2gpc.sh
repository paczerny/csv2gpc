#!/bin/bash

if [ -z "$1" ]
then
    echo "Usage:"
    echo "  csv2gpc.sh <filename.csv>"
    echo ""
    echo "Converts <filename.csv> to <filename.gpc>"
    echo "Expect the source file in cp1250 encoding"
    echo ""
    echo "WARNING The script can't handle filenames with spaces"
    exit 0
fi

SRC_FILE=$1
BASE_NAME=${SRC_FILE%.csv}
BASE_NAME=${BASE_NAME%.CSV}
SRC_FILE_CZ=${BASE_NAME}-cz.csv
DST_FILE_CZ=${BASE_NAME}-cz.gpc
DST_FILE=${BASE_NAME}.gpc

iconv -f "cp1250" -t "UTF-8" "${SRC_FILE}" -o "${SRC_FILE_CZ}"

./csv2gpc.rb ${SRC_FILE_CZ} ${DST_FILE_CZ}

iconv -f "UTF-8" -t "cp1250" "${DST_FILE_CZ}" -o "${DST_FILE}"