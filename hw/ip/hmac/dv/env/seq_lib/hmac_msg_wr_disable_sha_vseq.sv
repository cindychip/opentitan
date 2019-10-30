// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This sequence will disable sha_en in the middle of the message stream in process.
// This sequence intends to check after sha_en is disabled, prim_packer and hmac are
// able to recover and dicard the rest of the message

class hmac_msg_wr_disable_sha_vseq extends hmac_long_msg_vseq;
  `uvm_object_utils(hmac_msg_wr_disable_sha_vseq)
  `uvm_object_new

  constraint sha_en_c {
    sha_en == 1'b1;
  }

  task body();
    for (int i = 1; i <= num_trans; i++) begin
      bit [7:0] msg_q[$];
      `DV_CHECK_RANDOMIZE_FATAL(this)
      `uvm_info(`gfn, $sformatf("starting seq %0d/%0d, message size %0d, hmac=%0d, sha=%0d",
                                i, num_trans, msg.size(), hmac_en, sha_en), UVM_LOW)
      `uvm_info(`gfn, $sformatf("intr_fifo_full/hmac_done/hmac_err_en=%b, endian/digest_swap=%b",
                                {intr_fifo_full_en, intr_hmac_done_en, intr_hmac_err_en},
                                {endian_swap, digest_swap}), UVM_HIGH)
      // initialize hmac configs
      hmac_init(.sha_en(sha_en), .hmac_en(hmac_en), .endian_swap(endian_swap),
                .digest_swap(digest_swap), .intr_fifo_full_en(intr_fifo_full_en),
                .intr_hmac_done_en(intr_hmac_done_en), .intr_hmac_err_en(intr_hmac_err_en));

      // write key
      wr_key(key);

      // start stream in msg
      trigger_hash();

      wr_msg(msg);

      if ($urandom_range(0, 1)) begin
        sha_enable(1'b0);

     end else begin
      // msg stream in finished, start hash
       trigger_process();

        // fifo_full intr can be triggered at the latest two cycle after process
        // example: current fifo_depth=(14 words + 2 bytes), then wr last 4 bytes, design will
        // process the 15th word then trigger intr_fifo_full
        cfg.clk_rst_vif.wait_clks(2);
        clear_intr_fifo_full();

        // wait for interrupt to assert, check status and clear it
        if (intr_hmac_done_en) begin
          wait(cfg.intr_vif.pins[HmacDone] === 1'b1);
          check_interrupts(.interrupts((1 << HmacDone)), .check_set(1'b1));
        end else begin
          csr_spinwait(.ptr(ral.intr_state.hmac_done), .exp_data(1'b1));
          csr_wr(.csr(ral.intr_state), .value(1 << HmacDone));
        end
        rd_msg_length();
      end

      // read digest from DUT
      rd_digest();
    end
  endtask : body

endclass : hmac_msg_wr_disable_sha_vseq
