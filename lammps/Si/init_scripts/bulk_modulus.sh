#!/bin/bash

LOG_PATH="../logs/bulk_modulus/bulk_modulus.log"
CONFIG=$1


if [ ! -f $LOG_PATH ]; then
    touch $LOG_PATH
fi
echo "Initating MD simulation to compute bulk modulus of Si" >> ${LOG_PATH}


echo "Generating config files to compute energy of Si structure at various lattice parameters" >> ${LOG_PATH}

# 1. Read values and convert the newlines into a space-separated string

values=$(jq -r '.lattice_constant_start, .lattice_constant_end, .lattice_constant_step' "$CONFIG" | tr '\n' ' ')

# 2. Safely parse the space-separated string into variables
read -r start end step <<< "$values"

# 2. Run the loop using seq for decimal stepping


for a in $(seq "$start" "$step" "$end"); do

    a=$(printf "%.2f" "$a")

    echo "Running simulation with lattice constant: $a" >> "$LOG_PATH"

    # Create updated config with current lattice constant
    updated_config=$(mktemp)

    jq --argjson val "$a" '. + {lattice_constant: $val}' "$CONFIG" > "$updated_config"
    
    # Generate structure
    python ../structures/structure_generation.py "$updated_config"

    echo "Structure generated. Initiating MD simulation."

    lmp_args=()

    while IFS='=' read -r key value; do
        lmp_args+=(-var "$key" "$value")
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$updated_config")

    lmp "${lmp_args[@]}" \
        -log "$LOG_PATH" \
        -in ../inputs/bulk_modulus.in

    rm "$updated_config"

done

