# Example Usage

## Example 1: Basic Usage with 1FYT Structure

```tcl
# Load the structure
mol new 1fyt.pdb

# Run the analysis with default settings
source salt_bridge_analysis.tcl
```

Expected output:
```
======================================================
       TCR-pMHC Salt Bridge Analysis Tool
======================================================
Distance threshold: 4.0 Å
Interface cutoff: 5.0 Å

Available chains in structure: A B C D E
Analyzing interface between TCR (chains: D E) and pMHC (chains: A B C)...

Interface residues found:
  TCR positive: 3 residues
  TCR negative: 2 residues
  pMHC positive: 4 residues
  pMHC negative: 3 residues

TCR positive charges - pMHC negative charges:
  None found

TCR negative charges - pMHC positive charges:
  E:30:ASP - A:155:ARG
  D:95:GLU - B:12:LYS

======================================================
                    SUMMARY
======================================================
TCR+ to pMHC- salt bridges: 0
TCR- to pMHC+ salt bridges: 2
Total salt bridges: 2

INTERPRETATION:
Salt bridge count (2) is within normal range (0-4 typical).
======================================================
```

## Example 2: Custom Chain Assignment

For structures with different chain naming:

```tcl
# Load structure
mol new my_structure.pdb

# Check available chains
set all [atomselect top "all"]
puts "Available chains: [lsort -unique [$all get chain]]"
$all delete

# Modify the script for your chains
# Edit the configuration section in salt_bridge_analysis.tcl:
# set tcr_chains "A B"      # Your TCR chains
# set pmhc_chains "H L P"   # Your pMHC chains

source salt_bridge_analysis.tcl
```

## Example 3: Different Distance Threshold

```tcl
# Load structure
mol new structure.pdb

# Edit the script to change distance threshold:
# set distance_threshold 3.5  # More stringent
# or
# set distance_threshold 4.5  # More permissive

source salt_bridge_analysis.tcl
```

## Example 4: Command Line Usage

```bash
# Create a batch script
echo "mol new 1fyt.pdb; source salt_bridge_analysis.tcl; quit" > analysis.vmd

# Run VMD in text mode
vmd -dispdev text -e analysis.vmd
```

## Troubleshooting Examples

### Problem: No salt bridges found when expected

```tcl
# Debug: Check interface residues manually
mol new your_structure.pdb

# Check what residues are at the interface
set interface [atomselect top "chain D E and same residue as (within 5 of chain A B C)"]
puts "Interface residues: [$interface get {chain resid resname}]"

# Check for charged residues specifically
set charged [atomselect top "chain D E and same residue as (within 5 of chain A B C) and (resname ARG LYS ASP GLU)"]
puts "Charged interface residues: [$charged get {chain resid resname}]"

$interface delete
$charged delete
```

### Problem: Too many salt bridges found

```tcl
# Check if you're including crystal contacts
# Verify chain assignments are correct
set all_chains [lsort -unique [[atomselect top "all"] get chain]]
puts "All chains: $all_chains"

# Make sure you're only analyzing biological interface
# You might need to exclude certain chains
```

## Real Structure Examples

### Human TCR-HLA Complex
- Chains typically: A (HLA-A), B (β2m), C (peptide), D (TCR-α), E (TCR-β)
- Expected salt bridges: 1-3

### Mouse TCR-H2 Complex  
- Similar chain organization
- May have different salt bridge patterns

### Viral Peptide Complexes
- Often fewer salt bridges
- More hydrophobic interactions
