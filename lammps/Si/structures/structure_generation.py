
import numpy as np
import os

def create_structure_si(dimx, dimy, dimz, mass,lp):
    input_file = os.path.join(os.getcwd()+ "/sample.dat")
    xs_list = []
    ys_list = []
    zs_list = []

    # Read the data from the file
    with open(input_file, 'r') as infile:
        lines = infile.readlines()

    start_processing = False
    for line in lines:
        if line.startswith('ITEM: ATOMS'):
            start_processing = True
            continue
        
        if start_processing:
            parts = line.split()

            
            xs = float(parts[2])
            ys = float(parts[3])
            zs = float(parts[4])
            
            xs_list.append(xs)
            ys_list.append(ys)
            zs_list.append(zs)
                
    coordinates = np.array([xs_list, ys_list, zs_list]).T
    sorted_coordinates = coordinates[coordinates[:, 2].argsort()]
    initial_vector = np.array([lp,lp,lp])
    translated_arrays = []
    count=0
    for i in range(dimx):
        for j in range(dimy):
            for k in range(dimz):
                translation_vector = np.array([i, j, k])
                
                translated_array = sorted_coordinates + translation_vector
                translated_arrays.append(translated_array)
                count+=1

    translated_arrays = np.array(translated_arrays)
    translated_arrays = translated_arrays.reshape(-1, 3)
    print(translated_arrays)
    data = translated_arrays * initial_vector
    # Since one 1x1x1 unit cell contains 8 Si atoms (Diamond structure)

    num_atoms = 8*dimx*dimy*dimz
    num_atom_types = 1
    num_atoms_type1 = int(num_atoms)*num_atom_types
    num_atoms_type2 = num_atoms - num_atoms_type1
    atom_types=[]
    l=[]

    for i in range(dimz):
        temp = np.array([1] * num_atoms_type1 + [2] * num_atoms_type2)
        np.random.shuffle(temp)
        l.append(temp)
        atom_types.append(temp) 
    atom_types=np.array(atom_types)
    atom_types=atom_types.astype(int) 
    atom_types=atom_types.flatten()

    sorted_indices = np.lexsort((data[:, 0], data[:, 1], data[:, 2]))
    sorted_data = data[sorted_indices]
    total_atoms=num_atoms
    
    with open(os.path.join(os.getcwd()+ "/si_structure.txt"), 'w') as file:
        file.write('LAMMPS data file via write_data, version 27 Jun 2024, timestep = 1, units = metal\n\n')
        file.write(f'{total_atoms} atoms\n')
        file.write(f'{num_atom_types} atom types\n\n')

        xlo = 0
        xhi = dimx * initial_vector[0]
        ylo = 0
        yhi = dimy * initial_vector[1]
        zlo = 0
        zhi = dimz * initial_vector[2]
        file.write(f'{xlo} {xhi} xlo xhi\n')
        file.write(f'{ylo} {yhi} ylo yhi\n')
        file.write(f'{zlo} {zhi} zlo zhi\n\n')

        # Write masses
        file.write('Masses\n\n')
        file.write(f'1 {mass}\n')

        # Write atom data header
        file.write('\nAtoms # atomic\n\n')

        for idx, (atom_type, row) in enumerate(zip(atom_types, sorted_data), start=1):

            row_str = f'{idx} {atom_type} ' + ' '.join(f'{value:.6f}' for value in row)
            file.write(row_str + '\n')

    return translated_arrays




