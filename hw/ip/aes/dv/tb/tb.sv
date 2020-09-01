// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
module tb;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import aes_env_pkg::*;
  import aes_test_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  wire clk, rst_n;
  wire devmode;
  wire [NUM_MAX_INTERRUPTS-1:0] interrupts;
  alert_esc_if alert_if[aes_reg_pkg::NumAlerts](.clk(clk), .rst_n(rst_n));
  prim_alert_pkg::alert_rx_t [aes_reg_pkg::NumAlerts-1:0] alert_rx;
  prim_alert_pkg::alert_tx_t [aes_reg_pkg::NumAlerts-1:0] alert_tx;

  // interfaces
  clk_rst_if clk_rst_if(.clk(clk), .rst_n(rst_n));
  pins_if #(NUM_MAX_INTERRUPTS) intr_if(interrupts);

  pins_if #(1) devmode_if(devmode);
  tl_if tl_if(.clk(clk), .rst_n(rst_n));

  for (genvar k = 0; k < aes_reg_pkg::NumAlerts; k++) begin : connect_alerts_pins
    assign alert_rx[k] = alert_if[k].alert_rx;
    assign alert_if[k].alert_tx = alert_tx[k];
    initial begin
      uvm_config_db#(virtual alert_esc_if)::set(null, $sformatf("*.env.m_alert_agent_%0s",
          list_of_alerts[k]), "vif", alert_if[k]);
    end
  end
  // dut
  aes dut (
    .clk_i                (clk        ),
    .rst_ni               (rst_n      ),

    .idle_o               (           ),

    .tl_i                 (tl_if.h2d  ),
    .tl_o                 (tl_if.d2h  ),

    .alert_rx_i           ( alert_rx  ),
    .alert_tx_o           ( alert_tx  )
  );

  initial begin
    // drive clk and rst_n from clk_if
    clk_rst_if.set_active();
    uvm_config_db#(virtual clk_rst_if)::set(null, "*.env", "clk_rst_vif", clk_rst_if);
    uvm_config_db#(intr_vif)::set(null, "*.env", "intr_vif", intr_if);
    uvm_config_db#(devmode_vif)::set(null, "*.env", "devmode_vif", devmode_if);
    uvm_config_db#(virtual tl_if)::set(null, "*.env.m_tl_agent*", "vif", tl_if);
    $timeformat(-12, 0, " ps", 12);
    run_test();
  end

endmodule
