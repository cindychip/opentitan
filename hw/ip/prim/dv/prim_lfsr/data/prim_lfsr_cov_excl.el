// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//==================================================
// This file contains the Excluded objects
// Generated By User: udij
// Format Version: 2
// Date: Fri Oct 16 15:45:46 2020
// ExclMode: default
//==================================================
CHECKSUM: "2196990883"
INSTANCE: prim_lfsr_tb.gen_duts[24].i_prim_lfsr
ANNOTATION: "[EXTERNAL] seed/entropy inputs tied off in DV as they are covered in FPV."
Assert gen_lockup_mechanism_sva.LfsrLockupCheck_A "assertion"
ANNOTATION: "[EXTERNAL] seed/entropy inputs tied off in DV as they are covered in FPV."
Assert gen_ext_seed_sva.ExtDefaultSeedInputCheck_A "assertion"
CHECKSUM: "2196990883 1520894529"
INSTANCE: prim_lfsr_tb.gen_duts[24].i_prim_lfsr
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 2 "2655198170" "((lfsr_en_i && lockup) ? DefaultSeed : (lfsr_en_i ? next_lfsr_state : lfsr_q)) 1 -1" (2 "1")
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 3 "1026054222" "(lfsr_en_i && lockup) 1 -1" (3 "11")
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 3 "1026054222" "(lfsr_en_i && lockup) 1 -1" (1 "01")
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 5 "4214161107" "((lfsr_en_i && lockup) ? '0 : ((lfsr_en_i && (gen_max_len_sva.cnt_q == gen_max_len_sva.cmp_val)) ? '0 : (lfsr_en_i ? ((gen_max_len_sva.cnt_q + 1'b1)) : gen_max_len_sva.cnt_q))) 1 -1" (2 "1")
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 6 "3622507969" "(lfsr_en_i && lockup) 1 -1" (3 "11")
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 6 "3622507969" "(lfsr_en_i && lockup) 1 -1" (1 "01")
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Condition 8 "1510648413" "(lfsr_en_i && (gen_max_len_sva.cnt_q == gen_max_len_sva.cmp_val)) 1 -1" (1 "01")
CHECKSUM: "2196990883 2214500533"
INSTANCE: prim_lfsr_tb.gen_duts[24].i_prim_lfsr
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Branch 0 "780369097" "seed_en_i" (0) "seed_en_i 1,-,-"
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Branch 0 "780369097" "seed_en_i" (1) "seed_en_i 0,1,-"
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Branch 1 "864650299" "(lfsr_en_i && lockup)" (0) "(lfsr_en_i && lockup) 1,-,-"
CHECKSUM: "2196990883 528004685"
INSTANCE: prim_lfsr_tb.gen_duts[24].i_prim_lfsr
ANNOTATION: "[EXTERNAL] Covered in FPV testbench."
Block 33 "1545234335" "state = DefaultSeed;"
CHECKSUM: "2196990883 1321015592"
INSTANCE: prim_lfsr_tb.gen_duts[24].i_prim_lfsr
ANNOTATION: "[LOW_RISK] DV bench is meant to be extremely light-weight and already tests that prim_lfsr can come out of reset correctly"
Toggle rst_ni "net rst_ni"
