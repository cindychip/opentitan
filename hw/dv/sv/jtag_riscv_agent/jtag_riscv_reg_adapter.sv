// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

typedef class jtag_dmi_access_seq;

class jtag_riscv_reg_adapter #(type ITEM_T = jtag_riscv_item) extends uvm_reg_adapter;

  `uvm_object_param_utils(jtag_riscv_reg_adapter#(ITEM_T))

  function new(string name = "jtag_riscv_reg_adapter");
    super.new(name);
    parent_sequence = jtag_dmi_access_seq::type_id::create("m_jtag_dmi_access_seq");
    supports_byte_enable = 1;
    provides_responses = 1;
  endfunction : new

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    ITEM_T reg_item;
    reg_item = ITEM_T::type_id::create("reg_item");
    `DV_CHECK_RANDOMIZE_FATAL(reg_item)
    reg_item.addr = rw.addr;
    reg_item.data = rw.data;
    reg_item.op   = (rw.kind == UVM_WRITE) ? DmiWrite : DmiRead;
    `uvm_info(`gtn, $sformatf("jtag_riscv reg req item: addr 0x%0h, data=0x%0h, op=0x%0h",
              reg_item.addr, reg_item.data, reg_item.op), UVM_LOW)
              $display("parent seq %0s", parent_sequence.get_name());
    return reg_item;
  endfunction

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    ITEM_T reg_item;
    if (!$cast(reg_item, bus_item)) begin
      `uvm_fatal(`gtn, "Incorrect bus item type, expecting jtag_riscv_seq_item")
    end
    rw.kind = (reg_item.op == DmiWrite) ? UVM_WRITE : UVM_READ;
    rw.addr = reg_item.addr;
    rw.data = reg_item.data;
    `uvm_info(`gtn, $sformatf("jtag_riscv reg rsp item: addr 0x%0h, data=0x%0h, op=0x%0h",
              reg_item.addr, reg_item.data, reg_item.op), UVM_LOW)
  endfunction
endclass
