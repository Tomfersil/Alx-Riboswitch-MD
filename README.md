# Alx-Riboswitch-MD
This repository stores input files and scripts used in MD simulations of the alx riboswitch.

In the input_files folder, scripts and input files (.mdp,.itp,.top) can be found to reproduce the CpHMD and MD simulations. Beware that to reproduce these simulations, it requires the XOL3pH.ff force field that can be found: https://github.com/Tomfersil/CpHMD_RNA .

In the structural_files, PDB structures for the deprotonated native and protonated wobble structures are available with the standard nomenclature. Beware that in these structures, the extra proton for the A114 (A92 in the pdb) is missing, since that is only compatible with the XOL3pH.ff. 

If the user intends to use these structures, use that or other available methods to add the extra proton.