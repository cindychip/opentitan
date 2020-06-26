// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ---------------------------------------------
// Alert interface
// ---------------------------------------------
interface alert_esc_if(input clk, input rst_n);
  wire prim_alert_pkg::alert_tx_t alert_tx;
  wire prim_alert_pkg::alert_rx_t alert_rx;
  wire prim_esc_pkg::esc_tx_t esc_tx;
  wire prim_esc_pkg::esc_rx_t esc_rx;

  clocking sender_cb @(posedge clk);
    input  rst_n;
    output alert_tx;
    input  alert_rx;
    output esc_tx;
    input  esc_rx;
  endclocking

  clocking receiver_cb @(posedge clk);
    input  rst_n;
    input  alert_tx;
    output alert_rx;
    input  esc_tx;
    output esc_rx;
  endclocking

  clocking monitor_cb @(posedge clk);
    input rst_n;
    input alert_tx;
    input alert_rx;
    input esc_tx;
    input esc_rx;
  endclocking

  task automatic wait_ack_complete();
    while (alert_rx.ack_p !== 1'b0) @(monitor_cb);
  endtask : wait_ack_complete

  task automatic wait_esc_complete();
    while (esc_tx.esc_p === 1'b1 && esc_tx.esc_n === 1'b0) @(monitor_cb);
  endtask : wait_esc_complete

  task automatic wait_alert_ping();
    logic ping_p = alert_rx.ping_p;
    while (alert_rx.ping_p === ping_p) @(monitor_cb);
  endtask : wait_alert_ping

  task automatic wait_esc_ping();
    int cycle_cnt;
    do begin
      cycle_cnt = 0;
      while (esc_tx.esc_p === 1'b0 || (esc_tx.esc_p === esc_tx.esc_n)) @(monitor_cb);
      @(monitor_cb);
      cycle_cnt ++;
      while (esc_tx.esc_p === 1'b1 && esc_tx.esc_n === 1'b0) begin
        @(monitor_cb);
        cycle_cnt ++;
      end
    end while (cycle_cnt > 1);
  endtask : wait_esc_ping

endinterface: alert_esc_if
