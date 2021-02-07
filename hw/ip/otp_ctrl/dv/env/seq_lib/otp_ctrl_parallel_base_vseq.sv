// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This sequence will randomly issue key otbn, sram, flash key requests during or after partition
// is locked.
// This sequence will check if nonce, seed_valid, and output keys are correct via scb.

class otp_ctrl_parallel_base_vseq extends otp_ctrl_dai_errs_vseq;
  `uvm_object_utils(otp_ctrl_parallel_base_vseq)

  `uvm_object_new

  constraint num_iterations_c {
    num_trans  inside {[1:5]};
    num_dai_op inside {[1:500]};
  }

  virtual task body();
    bit base_vseq_done;

    fork
      begin
        run_parallel_seq(base_vseq_done);
      end
      begin
        super.body();
        base_vseq_done = 1;
      end
    join
  endtask

  virtual task run_parallel_seq(ref bit base_vseq_done);
    // Override with real parallel sequence
  endtask

  virtual task wait_clk_or_reset(int wait_clks);
    repeat(wait_clks) begin
      @(posedge cfg.clk_rst_vif.clk);
      if (cfg.under_reset) break;
    end
  endtask

endclass
