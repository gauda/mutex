#!/bin/sh

TENANT=1
URL="http://example.com/mutex/$TENANT"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <program to start>"
    exit
fi

if [ $(curl --write-out %{http_code} --silent --output /dev/null "$URL/set?user=$USER") = 200 ]; then
  echo "mutex has been set"
  $@
  curl "$URL/release?user=$USER"
else
  curl "$URL/"
fi
