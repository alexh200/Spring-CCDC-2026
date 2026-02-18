#!/usr/bin/env bash

if [[ -t 1 ]]; then
  RED="\e[31m"
  GREEN="\e[32m"
  YELLOW="\e[33m"
  RESET="\e[0m"
else
  RED=""
  GREEN=""
  YELLOW=""
  RESET=""
fi



if [[ -z "$1" ]]; then
  echo "Usage: $0 <file>"
  exit 1
fi

input_file="$1"

if [[ -f "$input_file" ]]; then
  echo "$(date +"%Y-%m-%d %H:%M:%S") $input_file exists. Running hash..."
  hash=$(sha256sum "$input_file" | awk '{print $1}')
  echo "$(date +"%Y-%m-%d %H:%M:%S") Initial hash: $hash"
else
  echo "$(date +"%Y-%m-%d %H:%M:%S") File not found: $input_file"
  exit 1
fi

file_missing=false

while true; do

  if [[ -f "$input_file" ]]; then

    hash2=$(sha256sum "$input_file" | awk '{print $1}')

    if [[ "$hash" != "$hash2" ]]; then

    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${RED}CRITICAL: File changed! ${RESET}"
      echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${RED}Old hash: $hash ${RESET}"
      echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${RED}New hash: $hash2 ${RESET}"
      
      hash="$hash2"
      
    fi
    
    file_missing=false

  else
    if [[ "$file_missing" == false ]]; then
      echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${YELLOW}WARNING: File missing: $input_file ${RESET}"
      echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${YELLOW}Searching directory for matching hash...${RESET}"

      for file in *; do
        [[ -f "$file" ]] || continue

        hash3=$(sha256sum "$file" | awk '{print $1}')
        
        if [[ $hash3 == $hash ]]; then
          echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${GREEN}Found renamed/moved file: $file ${RESET}"
          input_file="$file"
          break
        fi
      done
      file_missing=true
    fi
  fi

  sleep 5
done
