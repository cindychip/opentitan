// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// A dmi access sequence to drive a single CSR read or write
class jtag_riscv_dmi_access_seq extends dv_base_seq #(
    .REQ                 (jtag_riscv_item),
    .CFG_T               (jtag_riscv_agent_cfg),
    .SEQUENCER_T         (jtag_riscv_sequencer)
  );
  rand bit [DMI_OPW-1:0]   op;
  rand bit [DMI_DATAW-1:0] data;
  rand bit [DMI_ADDRW-1:0] addr;

  `uvm_object_utils(jtag_riscv_dmi_access_seq)
  `uvm_object_new

  virtual task body();
    // Drive IR with DMI access
    jtag_ir_seq ir_seq;
    jtag_dr_seq dr_seq;
    `uvm_create_on(ir_seq, p_sequencer.jtag_sequencer_h);
    `DV_CHECK_RANDOMIZE_WITH_FATAL(ir_seq,
        ir_len == DMI_IRW;
        ir     == JtagDmiAccess;
    )
    `uvm_send(ir_seq)

    // Drive DR with operation type, address, and data
    //jtag_dr_seq dr_seq;
    `uvm_create_on(dr_seq, p_sequencer.jtag_sequencer_h);
    `DV_CHECK_RANDOMIZE_WITH_FATAL(dr_seq,
        dr_len == DMI_DRW;
        dr     == {local::addr, local::data, local::op};
    )
    `uvm_send(dr_seq)

    // TODO: return error if status fail
    while (1) begin
    jtag_dr_seq dr_seq;
    `uvm_create_on(dr_seq, p_sequencer.jtag_sequencer_h);
    `DV_CHECK_RANDOMIZE_WITH_FATAL(dr_seq,
        dr_len == 2;
        dr     == DmiStatus;
    )
    `uvm_send(dr_seq)
    if (dr_seq.rsp.dout != DmiInProgress) break;
    end

    // Drive DR to get output if operation is read
    if (op == DmiRead) begin
      jtag_dr_seq dr_seq;
      `uvm_create_on(dr_seq, p_sequencer.jtag_sequencer_h);
      `DV_CHECK_RANDOMIZE_WITH_FATAL(dr_seq,
          dr_len == DMI_DRW;
          dr     == {local::addr, local::data, DmiStatus};
      )
      `uvm_send(dr_seq)
      $display("output read data is %0h", dr_seq.rsp.dout);
    end
  endtask
endclass
