#!/bin/bash

# ============================================================
# Simulation Run Setup
# ============================================================

CONFIG=$1

if [ -z "$CONFIG" ]; then
    echo "Usage: $0 <config.json>"
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: Config file not found: $CONFIG"
    exit 1
fi

RUN_ID=$(date +"%Y%m%d_%H%M%S")

RUN_DIR="../runs/${RUN_ID}"
RESULT_DIR="${RUN_DIR}/results"

mkdir -p "$RESULT_DIR"

# Save exact configuration used for this run
cp "$CONFIG" "${RUN_DIR}/"

echo "=========================================="
echo "Run ID      : $RUN_ID"
echo "Run directory: $RUN_DIR"
echo "Config      : $CONFIG"
echo "=========================================="


# ============================================================
# Structure Generation
# ============================================================

echo "Initiating MD simulation to compute lattice parameter of Si"

python ../structures/structure_generation.py "$CONFIG"

if [ $? -ne 0 ]; then
    echo "ERROR: Structure generation failed."
    exit 1
fi

echo "Structure generated. Initiating MD simulation."


# ============================================================
# Read configuration
# ============================================================

temperature=$(jq -r '.temperature' "$CONFIG")


# ============================================================
# Convert JSON configuration to LAMMPS arguments
# ============================================================

lmp_args=()

while IFS='=' read -r key value; do
    lmp_args+=(-var "$key" "$value")
done < <(
    jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG"
)

echo "LAMMPS arguments:"
echo "${lmp_args[@]}"


# ============================================================
# Run LAMMPS
# ============================================================

lmp "${lmp_args[@]}" \
    -var run_dir "$RUN_DIR" \
    -log "${RUN_DIR}/lammps.log" \
    -in ../inputs/lattice_parameter.in


# ============================================================
# Check simulation status
# ============================================================

if [ $? -ne 0 ]; then
    echo "ERROR: LAMMPS simulation failed."
    exit 1
fi

echo "=========================================="
echo "Simulation completed successfully."
echo "Run ID: $RUN_ID"
echo "Results: $RESULT_DIR"
echo "=========================================="
