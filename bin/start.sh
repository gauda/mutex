#!/bin/sh

usage() { echo "Usage: $0 -u <url> -p <program to start>" 1>&2; exit 1; }

while getopts ":u:p:" opt; do
  case "${opt}" in
    u)
      url=$OPTARG
      ;;
    p)
      program=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${url}" ] || [ -z "${program}" ]; then
    usage
fi

if [ $(curl --write-out %{http_code} --silent --output /dev/null "${url}/set?user=$USER") = 200 ]; then
  echo "mutex has been set"
  ${program}
  curl "${url}/release?user=$USER"
else
  curl "${url}/"
fi
