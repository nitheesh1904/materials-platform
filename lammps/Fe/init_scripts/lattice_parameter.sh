#!/bin/bash


CONFIG=$1



echo "Initating MD simulation to compute lattice parameter of Si"

python ../structures/structure_generation.py "$CONFIG"


echo "Structure generated.Initiating MD simualtion."

temperature=$(jq -r '.temperature' "$CONFIG")

while IFS='=' read -r key value; do
    lmp_args+=(-var "$key" "$value")
done < <(
    jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG"
)

echo "${lmp_args[@]}"

lmp "${lmp_args[@]}" -log "../logs/lattice_parameter_${temperature}.log" -in ../inputs/lattice_parameter.in
