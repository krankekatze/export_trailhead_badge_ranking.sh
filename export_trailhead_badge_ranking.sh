#!/bin/bash

set -u -o pipefail

readonly SHOULD_OUTPUT_WEB_NAME=true

readonly INPUT_FILENAME="trailhead.csv"
readonly OUTPUT_FILENAME="result.csv"

readonly IO_DIRECTORY_PATH="$(cd "$(dirname "$0")" && pwd)"

readonly INPUT_FILE_PATH="${IO_DIRECTORY_PATH%/}/${INPUT_FILENAME#/}"
readonly OUTPUT_FILE_PATH="${IO_DIRECTORY_PATH%/}/${OUTPUT_FILENAME#/}"

function scrape_trailhead() {
  # remove space from Internal Field Separator
  while IFS= read -r csv_line
  do
    local url
    url=$(echo "${csv_line}" | cut -d ',' -f 1 | xargs)

    local name
    name=$(echo "${csv_line}" | cut -d ',' -f 2 | xargs)

    [ -z "${name}" ] && {
      echo "Cannot parse csv: name: ${csv_line}"
      continue
    }

    local html
    html="$(curl -Lso- "${url}" | tr -d '\n')" || {
      echo "Cannot retrieve html: ${csv_line}"
      continue
    }

    local number_of_badges
    number_of_badges=$(echo "${html}" |
      grep -oP '<div[^>]* data-test-badges-count>\K[0-9]+(?=<)' |
      xargs) || {
        echo "Cannot retrieve the number of badges : ${csv_line}"
        continue
      }

    local number_of_points
    number_of_points=$(echo "${html}" |
      grep -oP '<div[^>]* data-test-points-count>\K[0-9,]+(?=<)' |
      xargs) || {
        echo "Cannot retrieve the number of points : ${csv_line}"
        continue
      }

    local rank
    rank=$(echo "${html}" |
      grep -oP '<a[^>]* data-test-current-rank[^>]*><img[^>]* alt="\K[^"]+(?=")' |
      xargs) || {
        echo "Cannot retrieve the rank : ${csv_line}"
        continue
      }

    local header="number of badges,number of points,rank,name"
    local output="${number_of_badges//,/},${number_of_points//,/},${rank//,/},${name//,/ }"

    if $SHOULD_OUTPUT_WEB_NAME
    then
      local web_name
      web_name=$(echo "${html}" |
        grep -oP '<meta property="og:title" content="\K[^"]+(?=")' |
        cut -d "|" -f 2 |
        xargs
        ) || {
          echo "Cannot retrieve web name : ${csv_line}"
          continue
        }

      header="${header},web name"
      output="${output},${web_name//,/ }"
    fi

    echo "${output}"
  done
  return 0
}

########## Main ##########

[ -f "${INPUT_FILE_PATH}" ] || {
  echo "File does not exist: ${INPUT_FILE_PATH}" 1>&2
  exit 1
}
[ -r "${INPUT_FILE_PATH}" ] || {
  echo "File cannot read: ${INPUT_FILE_PATH}" 1>&2
  exit 1
}

scrape_trailhead < "${INPUT_FILE_PATH}" |
  uniq |
  sort -nr |
  nl -s ',' -w 2 -n rz |
  tee "${OUTPUT_FILE_PATH}" |
  column -t -s ','

exit 0
