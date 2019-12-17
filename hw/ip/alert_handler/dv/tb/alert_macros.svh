// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// ---------------------------------------------
// Alert interface connection macros
// ---------------------------------------------

`define DECLARE_ASSIGN_ALERT(alert_name, index) \
  alert_if ``alert_name``(.clk(clk), .rst_n(rst_n)); \
  assign alert_tx[``index``].alert_p = ``alert_name``.alert_tx.alert_p; \
  assign alert_tx[``index``].alert_n = ``alert_name``.alert_tx.alert_n; \
  assign ``alert_name``.alert_rx.ack_p = alert_rx[``index``].ack_p; \
  assign ``alert_name``.alert_rx.ack_n = alert_rx[``index``].ack_n; \
  assign ``alert_name``.alert_rx.ping_p = alert_rx[``index``].ping_p; \
  assign ``alert_name``.alert_rx.ping_n = alert_rx[``index``].ping_n;

`define SET_ALERT_IF(alert_name) \
  uvm_config_db#(virtual alert_if)::set(null, "*.env.``alert_name``_agent", "vif", ``alert_name``);
