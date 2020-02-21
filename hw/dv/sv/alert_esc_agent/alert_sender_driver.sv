// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

// ---------------------------------------------
// Alert_handler sender driver
// ---------------------------------------------
class alert_sender_driver extends alert_esc_base_driver;

  `uvm_component_utils(alert_sender_driver)

  `uvm_component_new

  virtual task reset_signals();
    cfg.vif.reset_alert();
  endtask

  // alert_sender drive responses by sending the alert_p and alert_n
  // one alert sent by sequence driving the alert_send signal
  // another alert sent by responding to the ping signal
  virtual task drive_req();
    fork
      send_alert();
      rsp_ping();
    join_none
  endtask : drive_req

  virtual task send_alert();
    forever begin
      alert_esc_seq_item req, rsp;
      wait(s_alert_send_q.size() > 0);
      req = s_alert_send_q.pop_front();
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      `uvm_info(`gfn,
          $sformatf("starting to send sender item, alert_send=%0b, ping_rsp=%0b, int_err=%0b",
          req.s_alert_send, req.s_alert_ping_rsp, req.int_err), UVM_HIGH)

      set_alert_pins(req);

      `uvm_info(`gfn,
          $sformatf("finished sending sender item, alert_send=%0b, ping_rsp=%0b, int_err=%0b",
          req.s_alert_send, req.s_alert_ping_rsp, req.int_err), UVM_HIGH)
      seq_item_port.put_response(rsp);
    end // end forever
  endtask : send_alert

  virtual task rsp_ping();
    forever begin
      alert_esc_seq_item req, rsp;
      wait(s_alert_ping_rsp_q.size() > 0);
      req = s_alert_ping_rsp_q.pop_front();
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      `uvm_info(`gfn,
          $sformatf("starting to send sender item, alert_send=%0b, ping_rsp=%0b, int_err=%0b",
          req.s_alert_send, req.s_alert_ping_rsp, req.int_err), UVM_HIGH)

      cfg.vif.wait_ping();
      set_alert_pins(req);

      `uvm_info(`gfn,
          $sformatf("finished sending sender item, alert_send=%0b, ping_rsp=%0b, int_err=%0b",
          req.s_alert_send, req.s_alert_ping_rsp, req.int_err), UVM_HIGH)
      seq_item_port.put_response(rsp);
    end
  endtask : rsp_ping

  virtual task set_alert_pins(alert_esc_seq_item req);
    int unsigned alert_delay, ack_delay;
    if (!req.int_err) begin
      alert_delay = (cfg.use_seq_item_alert_delay) ? req.alert_delay :
          $urandom_range(cfg.alert_delay_max, cfg.alert_delay_min);
      ack_delay = (cfg.use_seq_item_ack_delay) ? req.ack_delay :
          $urandom_range(cfg.ack_delay_max, cfg.ack_delay_min);

      repeat (alert_delay) @(cfg.vif.sender_cb);
      @(cfg.vif.sender_cb);
      repeat (alert_delay) @(cfg.vif.sender_cb);
      cfg.vif.set_alert();
      fork
        begin : alert_timeout
          repeat (cfg.ping_timeout_cycle) @(cfg.vif.sender_cb);
        end
        begin : wait_alert_handshake
          cfg.vif.wait_ack();
          @(cfg.vif.sender_cb);
          repeat (ack_delay) @(cfg.vif.sender_cb);
          cfg.vif.reset_alert();
        end
      join_any
      disable fork;
    end else begin
      @(cfg.vif.sender_cb);
      case (req.int_err_scenario)
        BothHigh: cfg.vif.set_alert_p();
        BothLow:  cfg.vif.reset_alert_n();
        default: begin
          `uvm_fatal(`gfn, $sformatf("int_err_scenario unknown: %s", req.int_err_scenario.name));
        end
      endcase
      @(cfg.vif.sender_cb);
      repeat (req.int_err_cyc) @(cfg.vif.sender_cb);
      cfg.vif.reset_alert();
    end
  endtask : set_alert_pins

endclass : alert_sender_driver
