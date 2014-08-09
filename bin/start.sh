#!/bin/sh

TENANT=1
URL="http://example.com/mutex/$TENANT"

if [ $(curl --write-out %{http_code} --silent --output /dev/null "$URL/set?user=$USER") = 200 ]; then
  echo "mutex has been set"
  # TODO here: start your tool
  curl "$URL/release?user=$USER"
else
  curl "$URL/"
fi
