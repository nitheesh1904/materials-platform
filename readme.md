# Materials Platform

An end-to-end platform for running **LAMMPS molecular dynamics simulations**, ingesting simulation outputs, processing them using **Databricks/Spark**, and performing scientific analysis.

The goal of this project is to combine:

- Molecular Dynamics (LAMMPS)
- Data Engineering (Spark, Databricks, Delta Lake)
- Materials Science Research

---

## Architecture

```text
                   +----------------------+
                   |   LAMMPS Inputs      |
                   |  (input scripts)     |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |   LAMMPS Simulation  |
                   +----------+-----------+
                              |
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
       log.lammps        dump.atom        rdf/msd/etc.
             \                |                /
              \               |               /
               +--------------+--------------+
                              |
                              v
                   +----------------------+
                   |  Raw Data Storage    |
                   |    (Bronze Layer)    |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   | Spark / Databricks   |
                   | Parsing & Cleaning   |
                   |    (Silver Layer)    |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   | Delta Tables / DB    |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   | Scientific Analysis  |
                   | Visualization        |
                   | Gold Layer           |
                   +----------------------+
```

---

## Repository Structure

```text
materials-platform/
│
├── README.md
├── pyproject.toml
├── requirements.txt
├── .gitignore
│
├── configs/
│
├── lammps/
│   ├── inputs/
│   ├── potentials/
│   └── templates/
│
├── src/
│   ├── parser/
│   ├── runner/
│   ├── database/
│   ├── analytics/
│   └── utils/
│
├── databricks/
│   ├── notebooks/
│   ├── jobs/
│   └── workflows/
│
├── data/
│   ├── raw/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── tests/
│
└── docs/
```

---

## Workflow

1. Create a LAMMPS input script.
2. Run the simulation.
3. Store all generated outputs.
4. Ingest raw files into Databricks.
5. Parse and clean simulation data.
6. Store structured data as Delta tables.
7. Perform analysis using Spark and SQL.
8. Generate plots, reports, and scientific insights.

---

## Project Layers

### LAMMPS

Contains simulation input files, templates, and interatomic potentials.

Examples:

- Thermal Expansion
- Vacancy Migration
- RDF
- MSD

---

### Parser

Responsible for converting raw simulation outputs into structured tables.

Supported files:

- `log.lammps`
- `dump.atom`
- `rdf.dat`
- `msd.dat`

---

### Databricks

Processes simulation data using the Medallion Architecture.

- **Bronze** → Raw simulation files
- **Silver** → Parsed and cleaned datasets
- **Gold** → Aggregated results and analytics

---

### Analytics

Scientific analyses such as:

- Thermal Expansion
- Diffusion Coefficient
- Vacancy Migration
- Radial Distribution Function
- Energy Comparison
- Potential Benchmarking

---

## Technologies

- Python
- LAMMPS
- Apache Spark
- Databricks
- Delta Lake
- SQL
- Pandas
- NumPy

---

## Future Work

- Automated parameter sweeps
- Workflow orchestration
- Experiment tracking
- Interactive dashboards
- Machine learning on simulation data
- HPC integration
- Cloud deployment

---

## License

MIT License
