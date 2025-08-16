#!/usr/bin/env vmd
# TCR-pMHC Salt Bridge Analysis Script
# Author: [Your Name]
# Version: 1.0
# Usage: source salt_bridge_analysis.tcl

# =============================================================================
# CONFIGURATION
# =============================================================================

# Default analysis parameters
set distance_threshold 4.0  # Salt bridge distance threshold in Angstroms
set interface_cutoff 5.0    # Interface definition cutoff in Angstroms

# Chain assignments will be set through user input or command line arguments

# =============================================================================
# FUNCTIONS
# =============================================================================

proc print_header {} {
    global distance_threshold
    puts "======================================================"
    puts "       TCR-pMHC Salt Bridge Analysis Tool"
    puts "======================================================"
    puts "Distance threshold: $distance_threshold Å"
    puts "Interface cutoff: 5.0 Å"
    puts ""
}

proc cleanup_selections {} {
    # Clean up any existing selections
    global tcr pmhc tcr_interface pmhc_interface
    global pos_tcr_res pos_pmhc_res neg_tcr_res neg_pmhc_res
    
    foreach sel_var {tcr pmhc tcr_interface pmhc_interface pos_tcr_res pos_pmhc_res neg_tcr_res neg_pmhc_res} {
        if {[info exists $sel_var]} {
            catch {[set $sel_var] delete}
        }
    }
}

proc check_salt_bridge {chain1 resid1 resname1 chain2 resid2 resname2} {
    global distance_threshold
    
    # Define charged atoms based on residue type
    switch $resname1 {
        "ARG" {set atoms1 "NH1 NH2"}
        "LYS" {set atoms1 "NZ"}
        "ASP" {set atoms1 "OD1 OD2"}
        "GLU" {set atoms1 "OE1 OE2"}
        default {return 0}
    }
    
    switch $resname2 {
        "ARG" {set atoms2 "NH1 NH2"}
        "LYS" {set atoms2 "NZ"}
        "ASP" {set atoms2 "OD1 OD2"}
        "GLU" {set atoms2 "OE1 OE2"}
        default {return 0}
    }
    
    # Create atom selections
    set sel1 [atomselect top "chain $chain1 and resid $resid1 and name $atoms1"]
    set sel2 [atomselect top "chain $chain2 and resid $resid2 and name $atoms2"]
    
    # Check if selections are valid
    if {[$sel1 num] == 0 || [$sel2 num] == 0} {
        $sel1 delete
        $sel2 delete
        return 0
    }
    
    # Measure contacts
    set contacts [measure contacts $distance_threshold $sel1 $sel2]
    set num_contacts [llength [lindex $contacts 0]]
    
    # Clean up selections
    $sel1 delete
    $sel2 delete
    
    # Return result
    if {$num_contacts > 0} {
        puts "  $chain1:$resid1:$resname1 - $chain2:$resid2:$resname2"
        return 1
    }
    return 0
}

proc get_unique_residues {selection} {
    set residue_list {}
    set chains [$selection get chain]
    set resids [$selection get resid]
    set resnames [$selection get resname]
    
    foreach chain $chains resid $resids resname $resnames {
        set residue_id "$chain:$resid:$resname"
        if {[lsearch $residue_list $residue_id] == -1} {
            lappend residue_list $residue_id
        }
    }
    return $residue_list
}

proc get_chain_input {} {
    global tcr_chains pmhc_chains
    
    # Check if chains are already defined (e.g., from command line)
    if {[info exists tcr_chains] && [info exists pmhc_chains]} {
        return
    }
    
    # Get available chains
    if {[molinfo num] == 0} {
        puts "ERROR: No molecule loaded. Please load a PDB structure first."
        puts "Usage: mol new your_structure.pdb"
        return 0
    }
    
    set all_chains [lsort -unique [[atomselect top "all"] get chain]]
    puts "Available chains in structure: $all_chains"
    puts ""
    
    # Interactive input for TCR chains
    puts "Please specify the chain IDs:"
    puts -nonewline "TCR chains (e.g., 'D E' for alpha and beta chains): "
    flush stdout
    gets stdin tcr_chains
    
    # Interactive input for pMHC chains  
    puts -nonewline "pMHC chains (e.g., 'A B C' for MHC, b2m, peptide): "
    flush stdout
    gets stdin pmhc_chains
    
    puts ""
    puts "Configuration set:"
    puts "  TCR chains: $tcr_chains"
    puts "  pMHC chains: $pmhc_chains"
    puts ""
    
    return 1
}

proc validate_structure {} {
    global tcr_chains pmhc_chains
    
    # Check chain existence
    set all_chains [lsort -unique [[atomselect top "all"] get chain]]
    
    foreach chain $tcr_chains {
        if {[lsearch $all_chains $chain] == -1} {
            puts "WARNING: TCR chain '$chain' not found in structure"
        }
    }
    
    foreach chain $pmhc_chains {
        if {[lsearch $all_chains $chain] == -1} {
            puts "WARNING: pMHC chain '$chain' not found in structure"
        }
    }
    
    return 1
}

proc parse_command_line_args {} {
    global argc argv tcr_chains pmhc_chains
    
    # Parse command line arguments if available
    if {[info exists argc] && $argc >= 2} {
        for {set i 0} {$i < $argc} {incr i} {
            set arg [lindex $argv $i]
            if {$arg == "-tcr" && $i < [expr $argc - 1]} {
                set tcr_chains [lindex $argv [expr $i + 1]]
                incr i
            } elseif {$arg == "-pmhc" && $i < [expr $argc - 1]} {
                set pmhc_chains [lindex $argv [expr $i + 1]]
                incr i
            }
        }
    }
}

# =============================================================================
# MAIN ANALYSIS
# =============================================================================

proc analyze_salt_bridges {} {
    global tcr_chains pmhc_chains interface_cutoff
    
    # Parse command line arguments first
    parse_command_line_args
    
    # Print header
    print_header
    
    # Get chain input if not already defined
    if {![get_chain_input]} {
        return
    }
    
    # Validate structure
    if {![validate_structure]} {
        return
    }
    
    # Clean up previous selections
    cleanup_selections
    
    puts "Analyzing interface between TCR (chains: $tcr_chains) and pMHC (chains: $pmhc_chains)..."
    puts ""
    
    # Define interface residues with charged amino acids
    set pos_tcr_res [atomselect top "chain $tcr_chains and same residue as (within $interface_cutoff of chain $pmhc_chains) and (resname ARG LYS)"]
    set pos_pmhc_res [atomselect top "chain $pmhc_chains and same residue as (within $interface_cutoff of chain $tcr_chains) and (resname ARG LYS)"]
    set neg_tcr_res [atomselect top "chain $tcr_chains and same residue as (within $interface_cutoff of chain $pmhc_chains) and (resname ASP GLU)"]
    set neg_pmhc_res [atomselect top "chain $pmhc_chains and same residue as (within $interface_cutoff of chain $tcr_chains) and (resname ASP GLU)"]
    
    # Get unique residue lists
    set pos_tcr_list [get_unique_residues $pos_tcr_res]
    set neg_pmhc_list [get_unique_residues $neg_pmhc_res]
    set neg_tcr_list [get_unique_residues $neg_tcr_res]
    set pos_pmhc_list [get_unique_residues $pos_pmhc_res]
    
    # Debug information
    puts "Interface residues found:"
    puts "  TCR positive: [llength $pos_tcr_list] residues"
    puts "  TCR negative: [llength $neg_tcr_list] residues"
    puts "  pMHC positive: [llength $pos_pmhc_list] residues"
    puts "  pMHC negative: [llength $neg_pmhc_list] residues"
    puts ""
    
    # Analyze TCR positive - pMHC negative salt bridges
    puts "TCR positive charges - pMHC negative charges:"
    set count1 0
    foreach tcr_res $pos_tcr_list {
        set tcr_parts [split $tcr_res ":"]
        set tcr_chain [lindex $tcr_parts 0]
        set tcr_resid [lindex $tcr_parts 1]
        set tcr_resname [lindex $tcr_parts 2]
        
        foreach pmhc_res $neg_pmhc_list {
            set pmhc_parts [split $pmhc_res ":"]
            set pmhc_chain [lindex $pmhc_parts 0]
            set pmhc_resid [lindex $pmhc_parts 1]
            set pmhc_resname [lindex $pmhc_parts 2]
            
            if {[check_salt_bridge $tcr_chain $tcr_resid $tcr_resname $pmhc_chain $pmhc_resid $pmhc_resname]} {
                incr count1
            }
        }
    }
    if {$count1 == 0} {puts "  None found"}
    puts ""
    
    # Analyze TCR negative - pMHC positive salt bridges
    puts "TCR negative charges - pMHC positive charges:"
    set count2 0
    foreach tcr_res $neg_tcr_list {
        set tcr_parts [split $tcr_res ":"]
        set tcr_chain [lindex $tcr_parts 0]
        set tcr_resid [lindex $tcr_parts 1]
        set tcr_resname [lindex $tcr_parts 2]
        
        foreach pmhc_res $pos_pmhc_list {
            set pmhc_parts [split $pmhc_res ":"]
            set pmhc_chain [lindex $pmhc_parts 0]
            set pmhc_resid [lindex $pmhc_parts 1]
            set pmhc_resname [lindex $pmhc_parts 2]
            
            if {[check_salt_bridge $tcr_chain $tcr_resid $tcr_resname $pmhc_chain $pmhc_resid $pmhc_resname]} {
                incr count2
            }
        }
    }
    if {$count2 == 0} {puts "  None found"}
    puts ""
    
    # Summary
    puts "======================================================"
    puts "                    SUMMARY"
    puts "======================================================"
    puts "TCR+ to pMHC- salt bridges: $count1"
    puts "TCR- to pMHC+ salt bridges: $count2"
    puts "Total salt bridges: [expr $count1 + $count2]"
    puts ""
    
    # Interpretation
    set total [expr $count1 + $count2]
    puts "INTERPRETATION:"
    if {$total == 0} {
        puts "No salt bridges found. This is normal - many TCR-pMHC complexes"
        puts "rely primarily on hydrogen bonds and hydrophobic interactions."
    } elseif {$total <= 4} {
        puts "Salt bridge count ($total) is within normal range (0-4 typical)."
    } else {
        puts "High salt bridge count ($total). Please verify:"
        puts "- Chain assignments are correct"
        puts "- Distance threshold is appropriate"
        puts "- No crystal contacts are included"
    }
    puts "======================================================"
    
    # Clean up
    cleanup_selections
}

# =============================================================================
# EXECUTE ANALYSIS
# =============================================================================

# Run the analysis
analyze_salt_bridges
