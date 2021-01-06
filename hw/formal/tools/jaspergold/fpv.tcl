# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# clear previous settings
clear -all

# We use parameter instead of localparam in packages to allow redefinition
# at elaboration time.
# Disabling the warning
# "parameter declared inside package XXX shall be treated as localparam".
set_message -disable VERI-2418

if {$env(COV) == 1} {
  check_cov -init -model {branch statement functional} \
  -enable_prove_based_proof_core
}
set_task_compile_time_limit 1000s
set_property_compile_time_limit 1000s

#-------------------------------------------------------------------------
# read design
#-------------------------------------------------------------------------

# only one scr file exists in this folder
analyze -sv09                 \
  +define+FPV_ON              \
  -f [glob *.scr]

elaborate -bbox_a 3600 -top prim_arbiter_ppc_fpv -enable_sva_isunknown

#-------------------------------------------------------------------------
# specify clock(s) and reset(s)
#-------------------------------------------------------------------------

# select primary clock and reset condition (use ! for active-low reset)
# note: -both_edges is needed below because the TL-UL protocol checker
# tlul_assert.sv operates on the negedge clock
# TODO: create each FPV_TOP's individual config file

clock clk_i -both_edges
reset -expr {!rst_ni}

# use counter abstractions to reduce the run time:
# alert_handler ping_timer: timer to count until reaches ping threshold
# hmac sha2: does not check any calculation results, so 64 rounds of calculation can be abstracted

#-------------------------------------------------------------------------
# assume properties for inputs
#-------------------------------------------------------------------------

# Notes on above regular expressions: ^ indicates the beginning of the string;
# \w* includes all letters a-z, A-Z, and the underscore, but not the period.
# And \. is for period (with escape). These regular expressions make sure that
# the assume only applies to module_name.tlul_assert_*, but not to
# module_name.submodule.tlul_assert_*

# For sram2tlul, input tl_i.a_ready is constrained by below asssertion
assume -from_assert -remove_original {sram2tlul.validNotReady*}

# Input scanmode_i should not be X
assume -from_assert -remove_original -regexp {^\w*\.scanmodeKnown}

# TODO: If scanmode is set to 0, then JasperGold errors out complaining
# about combo loops, which should be debugged further. For now, below
# lines work around this issue


# run once to check if assumptions have any conflict
if {[info exists ::env(CHECK)]} {
  if {$env(CHECK)} {
    check_assumptions -conflict
    check_assumptions -live
    check_assumptions -dead_end
  }
}

#-------------------------------------------------------------------------
# configure proofgrid
#-------------------------------------------------------------------------

set_proofgrid_per_engine_max_local_jobs 2
set_proofgrid_mode local

# Uncomment below 2 lines when using LSF:
# set_proofgrid_mode lsf
# set_proofgrid_per_engine_max_jobs 16

#-------------------------------------------------------------------------
# prove all assertions & report
#-------------------------------------------------------------------------

# time limit set to 2 hours
get_reset_info -x_value -with_reset_pin
prove -all -time_limit 2h
report

#-------------------------------------------------------------------------
# check coverage and report
#-------------------------------------------------------------------------

if {$env(COV) == 1} {
  check_cov -measure -time_limit 2h
  check_cov -report -force -exclude { reset waived }
  check_cov -report -type all -no_return -report_file cover.html \
      -html -force -exclude { reset waived }
}
