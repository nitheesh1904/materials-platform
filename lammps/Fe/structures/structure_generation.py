import json
import sys
from func import create_structure_si

config_file = sys.argv[1]

with open(config_file) as f:
    config = json.load(f)


x_dim = int(config["xdim"])
y_dim = int(config["ydim"])
z_dim = int(config["zdim"])
mass = float(config["mass"])
lattice_constant = float(config["lattice_constant"])

print(f"Creating super cell of size: {x_dim} x {y_dim} x {z_dim}")

print(f"Mass of Atom: {mass}")

print(f"Lattice constant: {lattice_constant}")
create_structure_si(x_dim, y_dim, z_dim, mass, lattice_constant)
