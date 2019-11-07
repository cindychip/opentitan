// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Testbench module for rv_plic. Intended to use with a formal tool.

module rv_plic_csr_assert_fpv import rv_plic_reg_pkg::*; (
  input clk_i,
  input rst_ni,

  // tile link ports
  input tlul_pkg::tl_h2d_t h2d,
  input tlul_pkg::tl_d2h_t d2h
);

  import tlul_pkg::*;

  localparam int MAX_PRIO = 3;
  localparam int PRIOW    = $clog2(MAX_PRIO+1);

  logic [31:0] a_mask_bit;
  logic [PRIOW-1:0] prio [NumSrc];

  assign a_mask_bit[7:0]   = h2d.a_mask[0] ? '1 : '0;
  assign a_mask_bit[15:8]  = h2d.a_mask[1] ? '1 : '0;
  assign a_mask_bit[23:16] = h2d.a_mask[2] ? '1 : '0;
  assign a_mask_bit[31:24] = h2d.a_mask[3] ? '1 : '0;

  //initial begin
  //  prio = NumSrc{0};
  //end

  property prio0_wr_p;
    logic [31:0] id;
    (h2d.a_address == 'h10 && h2d.a_opcode inside {PutFullData, PutPartialData}, id = h2d.a_source, prio[0] = h2d.a_data & a_mask_bit)
        ##[0:$] (h2d.a_valid && h2d.a_source == id) ##[0:$] (h2d.d_ready && h2d.a_source == id)
        ##[0:$] (d2h.d_valid && d2h.d_source == id && !d2h.d_error) |->
        rv_plic.prio[0] == prio[0];
  endproperty

  property prio0_rd_p;
    logic [31:0] id;
    (h2d.a_address == 'h10 && h2d.a_valid && h2d.d_ready && d2h.a_ready &&
         h2d.a_opcode == Get, id = h2d.a_source) |=>
         ##1 (d2h.d_valid && d2h.d_source == id && !d2h.d_error) |->
         d2h.d_data == prio[0];
  endproperty

  `ASSERT(prio0_wr_A, prio0_wr_p ,clk_i, !rst_ni)
  //`ASSERT(prio0_rd_A, prio0_rd_p ,clk_i, !rst_ni)
  //assert property prio0_p;

endmodule
