#!/bin/bash


CONFIG=$1



echo "Initating MD simulation to compute elastic constants of Si"


python ../structures/structure_generation.py "$CONFIG"


temperature=$(jq -r '.temperature' "$CONFIG")

while IFS='=' read -r key value; do
    lmp_args+=(-var "$key" "$value")
done < <(
    jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG"
)

echo "${lmp_args[@]}"

lmp "${lmp_args[@]}" -log "../logs/elastic_constants/elastic_constants.log" -in ../inputs/elastic_constants.in
