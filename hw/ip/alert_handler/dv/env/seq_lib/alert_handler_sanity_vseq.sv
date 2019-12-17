// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// basic sanity test vseq
class alert_handler_sanity_vseq extends alert_handler_base_vseq;
  `uvm_object_utils(alert_handler_sanity_vseq)

  `uvm_object_new

  task body();
    for (int i = 1; i <= num_trans; i++) begin
      `uvm_info(`gfn, $sformatf("starting seq %0d/%0d", i, num_trans), UVM_LOW)
      alert_handler_init();
      drive_alert();
      wait(cfg.intr_vif.pins[ClassA] === 1'b1);
      check_interrupts(.interrupts((1 << ClassA)), .check_set(1'b1));
    end
  endtask : body

endclass : alert_handler_sanity_vseq
