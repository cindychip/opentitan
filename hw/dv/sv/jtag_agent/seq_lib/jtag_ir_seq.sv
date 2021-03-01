// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class jtag_ir_seq extends dv_base_seq #(
    .REQ         (jtag_item),
    .CFG_T       (jtag_agent_cfg),
    .SEQUENCER_T (jtag_sequencer)
  );

  rand logic [JTAG_IRW-1:0] ir;
  rand logic [JTAG_DRW-1:0] dr;
  rand uint ir_len;
  rand uint dr_len;

  `uvm_object_utils(jtag_ir_seq)
  `uvm_object_new

  virtual task body();
    req = jtag_item::type_id::create("req");
    start_item(req);
    randomize_req(req);
    finish_item(req);
    get_response(rsp);
    `uvm_info(`gfn, $sformatf("rcvd response:\n%0s", rsp.sprint()), UVM_HIGH)
  endtask

  virtual function void randomize_req(jtag_item req);
    `DV_CHECK_RANDOMIZE_WITH_FATAL(req,
        ir_len    == local::ir_len;
        dr_len    == local::dr_len;
        ir        == local::ir;
        select_ir == 1;
    )
  endfunction
endclass
