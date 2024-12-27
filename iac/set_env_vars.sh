#!/bin/bash

outputs_json=$(terraform output -json)

access_key_id=$(echo $outputs_json | jq -r '.["access_key_id"].value')
secret_access_key=$(echo $outputs_json | jq -r '.["secret_access_key"].value')

# Read existing .env file into an array
mapfile -t existing_lines < ../.env

# Update or add AWS credentials to the array
updated_lines=()

for line in "${existing_lines[@]}"; do
  if [[ ! "$line" =~ ^AWS_ACCESS_KEY_ID= ]]; then
    updated_lines+=("$line")
  elif [[ ! "$line" =~ ^AWS_SECRET_ACCESS_KEY= ]]; then
    updated_lines+=("$line")
  fi
done

updated_lines+=("AWS_ACCESS_KEY_ID=$access_key_id")
updated_lines+=("AWS_SECRET_ACCESS_KEY=$secret_access_key")

printf "%s\n" "${updated_lines[@]}" > ../.env