#!/bin/bash

RUN_ID=$(python ../utils/generate_run_id.py)

echo "Job ID: $RUN_ID"

RUN_DIR="../runs/${RUN_ID}"

mkdir -p "$RUN_DIR"

cat > "$RUN_DIR/run.json" <<EOF
{
  "run_id": "$RUN_ID"
}
EOF


echo "Running Lattice Parameter Simulation."

sh lattice_parameter.sh config/lattice_parameter.json "$RUN_DIR"

echo "Running Bulk Modulus Simulation."

sh bulk_modulus.sh config/bulk_modulus.json "$RUN_DIR"

echo "Running Elastic Constants Simulation."

sh elastic_constants.sh config/elastic_constants.json "$RUN_DIR"
