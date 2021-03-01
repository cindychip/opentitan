// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// A dmi access sequence to drive a single CSR read or write
class jtag_dr_seq extends jtag_ir_seq;

  `uvm_object_utils(jtag_dr_seq)
  `uvm_object_new

  virtual function void randomize_req(jtag_item req);
    `DV_CHECK_RANDOMIZE_WITH_FATAL(req,
        ir_len    == local::ir_len;
        dr_len    == local::dr_len;
        dr        == local::dr;
        select_ir == 0;
    )
  endfunction
endclass
