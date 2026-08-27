#!/bin/bash

# ============================================================
# Input configuration
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


# ============================================================
# Run setup
# ============================================================

RUN_ID=$(date +"%Y%m%d_%H%M%S")

RUN_DIR="../runs/${RUN_ID}"

mkdir -p "$RUN_DIR"

mkdir -p "$RUN_DIR/results/elastic_constants"

# Save exact configuration used
cp "$CONFIG" "$RUN_DIR/"

# Log file for this run
LOG_PATH="${RUN_DIR}/elastic_constants.log"


echo "==========================================" >> "$LOG_PATH"
echo "Run ID: $RUN_ID" >> "$LOG_PATH"
echo "Initiating MD simulation to compute elastic constants of Si" >> "$LOG_PATH"
echo "==========================================" >> "$LOG_PATH"


# ============================================================
# Generate structure
# ============================================================

python ../structures/structure_generation.py "$CONFIG"

if [ $? -ne 0 ]; then
    echo "ERROR: Structure generation failed." >> "$LOG_PATH"
    exit 1
fi

echo "Structure generated. Initiating MD simulation." >> "$LOG_PATH"


# ============================================================
# Convert JSON → LAMMPS arguments
# ============================================================

lmp_args=()

while IFS='=' read -r key value; do
    lmp_args+=(-var "$key" "$value")
done < <(
    jq -r 'to_entries[] | "\(.key)=\(.value)"' "$CONFIG"
)

echo "LAMMPS arguments:" >> "$LOG_PATH"
echo "${lmp_args[@]}" >> "$LOG_PATH"


# ============================================================
# Run LAMMPS
# ============================================================

lmp "${lmp_args[@]}" \
    -var run_dir "$RUN_DIR" \
    -log "$LOG_PATH" \
    -in ../inputs/elastic_constants.in


# ============================================================
# Check simulation status
# ============================================================

if [ $? -ne 0 ]; then
    echo "ERROR: LAMMPS simulation failed." >> "$LOG_PATH"
    exit 1
fi


# ============================================================
# Completion
# ============================================================

echo "==========================================" >> "$LOG_PATH"
echo "Elastic constants calculation completed." >> "$LOG_PATH"
echo "Run ID: $RUN_ID" >> "$LOG_PATH"
echo "Results: ${RUN_DIR}/results/elastic_constants" >> "$LOG_PATH"
echo "==========================================" >> "$LOG_PATH"
