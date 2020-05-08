// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

// ---------------------------------------------
// Escalator sender receiver interface monitor
// ---------------------------------------------

class esc_monitor extends alert_esc_base_monitor;

  `uvm_component_utils(esc_monitor)

  `uvm_component_new

  bit under_esc_ping;
  bit under_reset;

  //TODO: currently only support sync mode
  virtual task run_phase(uvm_phase phase);
    fork
      esc_thread(phase);
      reset_thread();
      unexpected_resp_thread();
      sig_int_fail_thread();
      //esc_ping_detector();
    join_none
  endtask : run_phase

  virtual task reset_thread();
    forever begin
      @(negedge cfg.vif.rst_n);
      under_reset = 1;
      @(posedge cfg.vif.rst_n);
      under_reset = 0;
    end
  endtask : reset_thread

  // this task detects if esc_p/n signal is ping signal or real escalation signal
  // by counting the escalation length. If the signal lasts one clock cycle, it is ping signal;
  // if it lasts more than one clk cycle, then it is escalation signal
  virtual task esc_ping_detector();
    forever begin
      int cnt;
      cfg.vif.wait_esc();
      @(cfg.vif.monitor_cb);
      while (cfg.vif.get_esc() == 1) begin
        cnt++;
        if (cnt == 1) under_esc_ping = 1;
        if (cnt == 2) under_esc_ping = 0;
        @(cfg.vif.receiver_cb);
      end
      if (under_esc_ping == 1) begin
        repeat(2) @(cfg.vif.receiver_cb);
        under_esc_ping = 0;
      end
    end
  endtask : esc_ping_detector

  virtual task esc_thread(uvm_phase phase);
    alert_esc_seq_item req, req_clone;
    logic esc_p = cfg.vif.get_esc();
    forever @(cfg.vif.monitor_cb) begin
      if (!esc_p && cfg.vif.get_esc() === 1'b1) begin
        phase.raise_objection(this, $sformatf("%s objection raised", `gfn));
        req = alert_esc_seq_item::type_id::create("req");
        req.sig_cycle_cnt++;
        if (cfg.vif.get_resp_p() == cfg.vif.get_resp_n()) req.esc_handshake_sta = EscIntFail;
        else req.esc_handshake_sta = EscRespHi;
        @(cfg.vif.monitor_cb);
        if (cfg.vif.get_esc() === 1'b0) begin
          int ping_cnter = 1;
          under_esc_ping = 1;
          req.alert_esc_type = AlertEscPingTrans;
          check_ping_resp(req);
          do begin
            @(cfg.vif.monitor_cb);
            check_ping_resp(req);
            //$display("next expected state is %s", req.esc_handshake_sta.name());
            ping_cnter ++;
          end
          while (req.esc_handshake_sta != EscRespComplete && ping_cnter < cfg.ping_timeout_cycle && !cfg.vif.get_esc());

          if (!cfg.vif.get_esc()) begin
            if (ping_cnter == cfg.ping_timeout_cycle && req.esc_handshake_sta != EscRespComplete) begin
              alert_esc_seq_item req_clone;
              $cast(req_clone, req.clone());
              req_clone.timeout = 1;
              alert_esc_port.write(req_clone);
              //$display("%time here exit due to timeout", $realtime);
              @(cfg.vif.monitor_cb);
              check_ping_resp(req);
            end
          end
          under_esc_ping = 0;
        end
        if (cfg.vif.get_esc() === 1'b1) begin
          req.alert_esc_type = AlertEscSigTrans;
          req.sig_cycle_cnt++;
          check_esc_resp(req);
          while (cfg.vif.get_esc() === 1) check_esc_resp(req);
          check_esc_resp(req, 0);
          $cast(req_clone, req.clone());
          req_clone.esc_handshake_sta = EscRespComplete;
          alert_esc_port.write(req_clone);
        end
        `uvm_info("esc_monitor", $sformatf("[%s]: handshake status is %s, timeout=%0b",
            req.alert_esc_type.name(), req.esc_handshake_sta.name(), req.timeout), UVM_HIGH)
        phase.drop_objection(this, $sformatf("%s objection dropped", `gfn));
      end
      esc_p = cfg.vif.get_esc();
    end
  endtask : esc_thread

  virtual task unexpected_resp_thread();
    alert_esc_seq_item req;
    forever @(cfg.vif.monitor_cb) begin
      while (cfg.vif.get_esc() === 1'b0 && !under_esc_ping && !under_reset) begin
        @(cfg.vif.monitor_cb);
        if (cfg.vif.get_resp_p() === 1'b1 && cfg.vif.get_resp_n() == 1'b0) begin
          req = alert_esc_seq_item::type_id::create("req");
          req.alert_esc_type = AlertEscIntFail;
          alert_esc_port.write(req);
        end
      end
    end
  endtask : unexpected_resp_thread

  virtual task sig_int_fail_thread();
    alert_esc_seq_item req;
    forever @(cfg.vif.monitor_cb) begin
      if (cfg.vif.get_resp_p() === cfg.vif.get_resp_n() && !under_reset) begin
        req = alert_esc_seq_item::type_id::create("req");
        req.alert_esc_type = AlertEscIntFail;
        alert_esc_port.write(req);
      end
    end
  endtask : sig_int_fail_thread

  virtual task check_esc_resp(alert_esc_seq_item req, bit do_wait_clk = 1);
    if (req.esc_handshake_sta inside {EscIntFail, EscReceived}) begin
      if (cfg.vif.get_resp_p() !== 0) begin
        alert_esc_seq_item req_clone;
        $cast(req_clone, req.clone());
        req_clone.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req_clone);
      end
      if (!cfg.probe_vif.get_esc_en() && req.esc_handshake_sta == EscIntFail) begin
        req.esc_handshake_sta = EscReceived;
      end else begin
        req.esc_handshake_sta = EscRespHi;
      end
    end else if (req.esc_handshake_sta == EscRespHi) begin
      if (cfg.vif.get_resp_p() !== 1) begin
        req.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req);
      end else begin
        req.esc_handshake_sta = EscRespLo;
      end
    end else if (req.esc_handshake_sta == EscRespLo) begin
      if (cfg.vif.get_resp_p() !== 0) begin
        req.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req);
      end else begin
        req.esc_handshake_sta = EscRespHi;
      end
    end

    if (cfg.vif.get_resp_p() == cfg.vif.get_resp_n()) req.esc_handshake_sta = EscIntFail;

    if (do_wait_clk) begin
      @(cfg.vif.monitor_cb);
      if (cfg.vif.get_esc() === 1) req.sig_cycle_cnt++;
    end
  endtask : check_esc_resp

  virtual task check_ping_resp(alert_esc_seq_item req, bit do_wait_clk = 1);
    if (req.esc_handshake_sta inside {EscIntFail, EscReceived}) begin
      if (cfg.vif.get_resp_p() !== 0) begin
        alert_esc_seq_item req_clone;
        $cast(req_clone, req.clone());
        req_clone.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req_clone);
      end
      req.esc_handshake_sta = EscRespHi;
    end else if (req.esc_handshake_sta == EscRespHi) begin
      if (cfg.vif.get_resp_p() !== 1) begin
        req.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req);
        //$display("%time here write integrity fail", $realtime);
      end else begin
        req.esc_handshake_sta = EscRespLo;
      end
    end else if (req.esc_handshake_sta == EscRespLo) begin
      if (cfg.vif.get_resp_p() !== 0) begin
        req.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req);
      end else begin
        req.esc_handshake_sta = EscRespPing2;
      end
    end else if (req.esc_handshake_sta == EscRespPing2) begin
      if (cfg.vif.get_resp_p() !== 1) begin
        req.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req);
      end else begin
        req.esc_handshake_sta = EscRespPing3;
      end
    end else if (req.esc_handshake_sta == EscRespPing3) begin
      if (cfg.vif.get_resp_p() !== 0) begin
        req.esc_handshake_sta = EscIntFail;
        alert_esc_port.write(req);
      end else begin
        req.esc_handshake_sta = EscRespComplete;
      end
    end
    if (cfg.vif.get_resp_p() == cfg.vif.get_resp_n()) req.esc_handshake_sta = EscIntFail;
    //if (do_wait_clk) @(cfg.vif.monitor_cb);
  endtask
endclass : esc_monitor
