#!/bin/bash

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

# Save exact configuration used
cp "$CONFIG" "$RUN_DIR/"

LOG_PATH="${RUN_DIR}/bulk_modulus.log"

echo "==========================================" >> "$LOG_PATH"
echo "Run ID: $RUN_ID" >> "$LOG_PATH"
echo "Starting Bulk Modulus calculation" >> "$LOG_PATH"
echo "==========================================" >> "$LOG_PATH"


# ============================================================
# Read lattice constant range
# ============================================================

values=$(jq -r \
    '.lattice_constant_start,
     .lattice_constant_end,
     .lattice_constant_step' \
    "$CONFIG" | tr '\n' ' ')

read -r start end step <<< "$values"


# ============================================================
# Generate result directory
# ============================================================

RESULT_DIR="${RUN_DIR}/results/bulk_modulus"

mkdir -p "$RESULT_DIR"


# ============================================================
# Initialize result file
# ============================================================

echo "Lattice_constant Volume Total_energy Pressure" \
    > "${RESULT_DIR}/E_vs_V.txt"


# ============================================================
# Run simulations
# ============================================================

echo "Generating configurations for lattice constants..." \
    >> "$LOG_PATH"


for a in $(seq "$start" "$step" "$end"); do

    a=$(printf "%.2f" "$a")

    echo "Running simulation for lattice constant: $a" \
        >> "$LOG_PATH"


    # --------------------------------------------------------
    # Create temporary config for this lattice constant
    # --------------------------------------------------------

    updated_config=$(mktemp)

    jq --argjson val "$a" \
       '. + {lattice_constant: $val}' \
       "$CONFIG" > "$updated_config"


    # --------------------------------------------------------
    # Generate structure
    # --------------------------------------------------------

    python ../structures/structure_generation.py "$updated_config"

    if [ $? -ne 0 ]; then
        echo "ERROR: Structure generation failed for a=$a" \
            >> "$LOG_PATH"
        rm "$updated_config"
        exit 1
    fi


    echo "Structure generated for a=$a" >> "$LOG_PATH"


    # --------------------------------------------------------
    # Convert JSON → LAMMPS arguments
    # --------------------------------------------------------

    lmp_args=()

    while IFS='=' read -r key value; do
        lmp_args+=(-var "$key" "$value")
    done < <(
        jq -r 'to_entries[] | "\(.key)=\(.value)"' \
        "$updated_config"
    )


    # --------------------------------------------------------
    # Run LAMMPS
    # --------------------------------------------------------

    lmp "${lmp_args[@]}" \
        -var run_dir "$RUN_DIR" \
        -log "$LOG_PATH" \
        -in ../inputs/bulk_modulus.in


    if [ $? -ne 0 ]; then
        echo "ERROR: LAMMPS failed for a=$a" \
            >> "$LOG_PATH"
        rm "$updated_config"
        exit 1
    fi


    rm "$updated_config"

done


# ============================================================
# Completion
# ============================================================

echo "==========================================" >> "$LOG_PATH"
echo "Bulk Modulus calculation completed" >> "$LOG_PATH"
echo "Run ID: $RUN_ID" >> "$LOG_PATH"
echo "Results: $RESULT_DIR" >> "$LOG_PATH"
echo "==========================================" >> "$LOG_PATH"
