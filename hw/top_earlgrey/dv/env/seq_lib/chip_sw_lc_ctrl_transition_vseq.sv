// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class chip_sw_lc_ctrl_transition_vseq extends chip_sw_base_vseq;
  `uvm_object_utils(chip_sw_lc_ctrl_transition_vseq)

  `uvm_object_new

  virtual task dut_init(string reset_kind = "HARD");
    super.dut_init(reset_kind);
    cfg.mem_bkdr_util_h[Otp].otp_write_lc_partition(lc_ctrl_state_pkg::LcStTestUnlocked2);
    cfg.mem_bkdr_util_h[Otp].otp_write_secret0_partition('h547070d7503264af5b9a971b894ef3be,
            'h547070d7503264af5b9a971b894ef3be);
  endtask

  virtual task body();
    bit [TL_DW-1:0] status_val;
    super.body();
    cfg.tap_straps_vif.drive(2'b01); // Select LC jtag
    cfg.clk_rst_vif.wait_clks(21000);

    while(1) begin
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 10));
      jtag_read_csr(4, status_val);
      foreach (status_val[i]) begin
        if (status_val[i] && (i > 1)) begin
          `uvm_error(`gfn, $sformatf("Unexpected status error %0h", status_val));
        end
      end
      if (status_val[1]) break;
    end

    // Issue hard reset.
    apply_reset();
  endtask

  virtual task jtag_read_csr(bit [TL_AW-1:0] csr_addr, ref bit [TL_DW-1:0] csr_val);
    jtag_riscv_csr_seq jtag_csr_seq;
    `uvm_create_on(jtag_csr_seq, p_sequencer.jtag_sequencer_h);
    `DV_CHECK_RANDOMIZE_WITH_FATAL(jtag_csr_seq, addr == csr_addr; do_write == 0;)
    `uvm_send(jtag_csr_seq)
    csr_val = jtag_csr_seq.data;
  endtask
endclass
