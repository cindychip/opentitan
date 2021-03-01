// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class jtag_riscv_agent_cfg extends dv_base_agent_cfg;
  `uvm_object_utils_begin(jtag_riscv_agent_cfg)
  `uvm_object_utils_end

  function new (string name="");
    super.new(name);
    // This agent is always passive.
    this.has_driver = 1'b0;
  endfunction : new

endclass
