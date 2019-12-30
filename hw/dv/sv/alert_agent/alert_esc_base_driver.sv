// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

// ---------------------------------------------
// Alert_esc_base driver
// ---------------------------------------------
class alert_esc_base_driver extends dv_base_driver#(alert_seq_item, alert_agent_cfg);
  alert_seq_item ping_send_q[$], ping_rsp_q[$], alert_send_q[$], alert_rsp_q[$], esc_rsp_q[$];

  `uvm_component_utils(alert_esc_base_driver)

  `uvm_component_new

  virtual task reset_signals();
  endtask

  // drive trans received from sequencer
  virtual task get_and_drive();
    fork
      get_req();
      drive_req();
    join_none
  endtask

  virtual task drive_req();
  endtask

  virtual task get_req();
    forever begin
      alert_seq_item req_clone;
      seq_item_port.get(req);
      $cast(req_clone, req.clone());
      req_clone.set_id_info(req);
      // TODO: if any of the queue size is larger than 2, need additional support
      if (req.ping_send)  ping_send_q.push_back(req_clone);
      if (req.alert_rsp)  alert_rsp_q.push_back(req_clone);
      if (req.esc_rsp)    esc_rsp_q.push_back(req_clone);
      // sender mode
      if (req.alert_send) alert_send_q.push_back(req_clone);
      if (req.ping_rsp)   ping_rsp_q.push_back(req_clone);
    end
  endtask : get_req

endclass
