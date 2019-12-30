// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ---------------------------------------------
// Escalator interface
// ---------------------------------------------
interface esc_if(input clk, input rst_n);
  wire prim_pkg::esc_tx_t esc_tx;
  wire prim_pkg::esc_rx_t esc_rx;

  clocking sender_cb @(posedge clk);
    input  rst_n;
    output esc_tx;
    input  esc_rx;
  endclocking

  clocking receiver_cb @(posedge clk);
    input  rst_n;
    input  esc_tx;
    output esc_rx;
  endclocking

  clocking monitor_cb @(posedge clk);
    input  rst_n;
    input  esc_tx;
    input esc_rx;
  endclocking

  function automatic bit get_esc_p();
    return monitor_cb.esc_tx.esc_p;
  endfunction

  function automatic bit get_resp_p();
    return monitor_cb.esc_rx.resp_p;
  endfunction

endinterface : esc_if
