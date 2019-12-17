// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Testbench module for prim_packer.
// Intended to be used with a formal tool.

module prim_packer_fpv #(
  parameter  InW = 8,
  parameter  OutW = 8
) (
  input  clk_i,
  input  rst_ni,
  input  valid_i,
  input [InW-1:0] data_i,
  input [InW-1:0] mask_i,
  output  ready_o,
  output logic valid_o,
  output logic[OutW-1:0] data_o,
  output logic[OutW-1:0] mask_o,
  input  ready_i,
  input  flush_i,
  output logic flush_done_o
);


  prim_packer #(
    .InW(InW),
    .OutW(OutW)
  ) i_prim_packer (
    .clk_i,
    .rst_ni,
    .valid_i,
    .data_i,
    .mask_i,
    .ready_o,
    .valid_o,
    .data_o,
    .mask_o,
    .ready_i,
    .flush_i,
    .flush_done_o
  );


endmodule : prim_packer_fpv
