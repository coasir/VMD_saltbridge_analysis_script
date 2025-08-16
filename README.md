# TCR-pMHC Salt Bridge Analysis

A VMD script for analyzing salt bridges at the TCR-pMHC interface in protein complex structures.

## Overview

This tool identifies and quantifies salt bridges between T-cell receptor (TCR) and peptide-MHC (pMHC) complex interfaces using Visual Molecular Dynamics (VMD). Salt bridges are important electrostatic interactions that contribute to the stability and specificity of TCR-pMHC recognition.

## Features

- Automated identification of interface residues within 5Å
- Detection of salt bridges between charged residues (Arg, Lys, Asp, Glu)
- Customizable distance threshold (default: 4.0Å)
- Interactive chain assignment (no script modification needed)
- Detailed output with residue-pair information
- Support for different chain configurations

## Requirements

- VMD (Visual Molecular Dynamics) software
- PDB structure file of TCR-pMHC complex

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/tcr-pmhc-saltbridge-analysis.git
cd tcr-pmhc-saltbridge-analysis
```

2. Ensure VMD is installed and accessible from command line

## Usage

### Method 1: Interactive Mode (Recommended)
1. Open VMD
2. Load your PDB structure:
   ```tcl
   mol new your_structure.pdb
   ```
3. Run the script:
   ```tcl
   source salt_bridge_analysis.tcl
   ```
4. When prompted, enter the chain IDs:
   ```
   Available chains in structure: A B C D E
   
   Please specify the chain IDs:
   TCR chains (e.g., 'D E' for alpha and beta chains): D E
   pMHC chains (e.g., 'A B C' for MHC, b2m, peptide): A B C
   ```

### Method 2: Command Line Arguments
```bash
# Using VMD command line with chain specification
vmd -dispdev text -e salt_bridge_analysis.tcl -args -tcr "D E" -pmhc "A B C" your_structure.pdb
```

### Method 3: Pre-define in VMD
```tcl
# Load structure
mol new your_structure.pdb

# Pre-define chains
set tcr_chains "D E"
set pmhc_chains "A B C"

# Run analysis
source salt_bridge_analysis.tcl
```

## Configuration

The script will automatically prompt you for chain assignments when run. No script modification needed!

### Common Chain Configurations:
- **1FYT structure**: TCR chains "D E", pMHC chains "A B C"
- **Most TCR-pMHC complexes**: TCR α and β chains, MHC heavy chain + β2m + peptide
- **Variable naming**: The script adapts to any chain naming scheme

### Advanced Configuration
You can also set parameters in VMD before running:
```tcl
# Optional: Modify distance threshold (default 4.0Å)
set distance_threshold 3.5

# Optional: Modify interface cutoff (default 5.0Å)  
set interface_cutoff 6.0

# Run analysis
source salt_bridge_analysis.tcl
```

## Output

The script provides:
- List of salt bridges between TCR positive charges and pMHC negative charges
- List of salt bridges between TCR negative charges and pMHC positive charges
- Total count of salt bridges
- Chain:ResID:ResName format for easy identification

### Example Session
```
vmd > mol new 1fyt.pdb
vmd > source salt_bridge_analysis.tcl

======================================================
       TCR-pMHC Salt Bridge Analysis Tool
======================================================
Distance threshold: 4.0 Å
Interface cutoff: 5.0 Å

Available chains in structure: A B C D E

Please specify the chain IDs:
TCR chains (e.g., 'D E' for alpha and beta chains): D E
pMHC chains (e.g., 'A B C' for MHC, b2m, peptide): A B C

Configuration set:
  TCR chains: D E
  pMHC chains: A B C

Analyzing interface between TCR (chains: D E) and pMHC (chains: A B C)...
```

## Parameters

You can modify these parameters before running the script:

```tcl
# Set custom distance threshold (default 4.0Å)
set distance_threshold 3.5

# Set custom interface cutoff (default 5.0Å)  
set interface_cutoff 6.0

# Then run the script
source salt_bridge_analysis.tcl
```

## Troubleshooting

### Common Issues

1. **"invalid command name atomselect"**: 
   - Clear VMD memory before running:
   ```tcl
   mol delete all
   mol new your_structure.pdb
   source salt_bridge_analysis.tcl
   ```

2. **"invalid command name atomselect"**: 
   - Clear VMD memory before running:
   ```tcl
   mol delete all
   mol new your_structure.pdb
   source salt_bridge_analysis.tcl
   ```

3. **"vector dimension mismatch"**:
   - This has been fixed in the current version

4. **No salt bridges found**:
   - Verify chain assignments are correct (script will show available chains)
   - Check that the structure contains charged residues at the interface
   - Try increasing the distance threshold:
   ```tcl
   set distance_threshold 4.5
   source salt_bridge_analysis.tcl
   ```

### Chain ID Determination

The script automatically shows available chains, but you can also check manually:
```tcl
# Load structure and check chains
mol new your_structure.pdb
set all [atomselect top "all"]
puts "Available chains: [lsort -unique [$all get chain]]"
$all delete
```

## Background

### Salt Bridge Criteria
- **Distance**: 2.5-4.0Å between charged atoms
- **Residues**: Arg(NH1,NH2), Lys(NZ) vs Asp(OD1,OD2), Glu(OE1,OE2)
- **Interface**: Residues within 5Å of the other protein component

### Typical TCR-pMHC Salt Bridge Counts
- **Range**: 0-4 salt bridges (most commonly 2-3)
- **Distribution**: Can vary significantly based on peptide sequence and TCR specificity
- **Zero salt bridges**: Completely normal, many complexes rely on hydrogen bonds and hydrophobic interactions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

If you use this script in your research, please cite:

```
[Your Name]. (2024). TCR-pMHC Salt Bridge Analysis Tool. 
GitHub repository: https://github.com/yourusername/tcr-pmhc-saltbridge-analysis
```

## References

1. Rudolph, M. G., Stanfield, R. L., & Wilson, I. A. (2006). How TCRs bind MHCs, peptides, and coreceptors. *Annual review of immunology*, 24, 419-466.

2. Garcia, K. C., & Adams, E. J. (2005). How the T cell receptor sees antigen—a structural view. *Cell*, 122(3), 333-346.

## Contact

For questions or suggestions, please open an issue on GitHub or contact [your-email@domain.com].
