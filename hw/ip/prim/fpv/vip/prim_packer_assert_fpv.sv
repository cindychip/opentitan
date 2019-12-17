// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Assertions for prim_packer.
// Intended to be used with a formal tool.

module prim_packer_assert_fpv #(
  parameter  InW = 32,
  parameter  OutW = 32
) (
  input  clk_i,
  input  rst_ni,
  input  valid_i,
  input [InW-1:0] data_i,
  input [InW-1:0] mask_i,
  input  ready_o,
  input logic valid_o,
  input logic[OutW-1:0] data_o,
  input logic[OutW-1:0] mask_o,
  input  ready_i,
  input  flush_i,
  input logic flush_done_o
);

  ///////////////////////////////
  // Declarations & Parameters //
  ///////////////////////////////

  /////////////////
  // Assumptions //
  /////////////////
  // Assumption: mask_i should be contiguous ones
  // e.g: 0011100 --> OK
  //      0100011 --> Not OK
  `ASSUME(ContiguousOnesMask_M,
          valid_i |-> $countones(mask_i ^ {mask_i[InW-2:0],1'b0}) <= 2,
          clk_i, !rst_ni)

  // Flush and Write Enable cannot be asserted same time
  `ASSUME(ExFlushValid_M, flush_i |-> !valid_i, clk_i, !rst_ni)

  // While in flush state, new request shouldn't come
  `ASSUME(ValidIDeassertedOnFlush_M,
          i_prim_packer.flush_st == i_prim_packer.FlushWait |-> $stable(valid_i),
          clk_i, !rst_ni)

  // If not acked, input port keeps asserting valid and data
  `ASSUME(DataIStable_M,
          ##1 valid_i && $past(valid_i) && !$past(ready_o)
          |-> $stable(data_i) && $stable(mask_i),
          clk_i, !rst_ni)
  `ASSUME(ValidIPairedWithReadyO_M,
          valid_i && !ready_o |=> valid_i,
          clk_i, !rst_ni)

  /////////////////
  // Assertions //
  /////////////////

  // If not acked, valid_o should keep asserting

  `ASSERT(FlushFollowedByDone_A,
          ##1 $rose(flush_i) && !flush_done_o |-> !flush_done_o [*0:$] ##1 flush_done_o,
          clk_i, !rst_ni)

  `ASSERT(ValidOPairedWidthReadyI_A,
          valid_o && !ready_i |=> valid_o,
          clk_i, !rst_ni)

  // If input mask + stored data is greater than output width, valid should be asserted
  `ASSERT(ValidOAssertedForInputGTEOutW_A,
          valid_i && (($countones(mask_i) + $countones(i_prim_packer.stored_mask)) >= OutW) |-> valid_o,
          clk_i, !rst_ni)

  // If output port doesn't accept the data, the data should be stable
  `ASSERT(DataOStableWhenPending_A,
          ##1 valid_o && $past(valid_o)
          && !$past(ready_i) |-> $stable(data_o),
          clk_i, !rst_ni)

  `ASSERT(ExcessiveDataStored_A,
          i_prim_packer.ack_in &&
          (($countones(mask_i) + $countones(i_prim_packer.stored_mask)) > OutW) |=>
          (($past(data_i) &  $past(mask_i)) >>
          ($past(i_prim_packer.lod_idx)+OutW-$countones($past(i_prim_packer.stored_mask))))
          == i_prim_packer.stored_data,
          clk_i, !rst_ni)

  `ASSERT(ExcessiveMaskStored_A,
          i_prim_packer.ack_in &&
          (($countones(mask_i) + $countones(i_prim_packer.stored_mask)) > OutW) |=>
          ($past(mask_i) >>
          ($past(i_prim_packer.lod_idx)+OutW-$countones($past(i_prim_packer.stored_mask))))
            == i_prim_packer.stored_mask,
          clk_i, !rst_ni)

  `ASSERT(FlushIdle_A,
          ((i_prim_packer.flush_st == i_prim_packer.FlushIdle) && (!flush_i)) |->
          i_prim_packer.flush_st_next == i_prim_packer.FlushIdle,
          clk_i, !rst_ni)
endmodule : prim_packer_assert_fpv
