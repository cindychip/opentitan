// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class alert_handler_env extends cip_base_env #(
    .CFG_T              (alert_handler_env_cfg),
    .COV_T              (alert_handler_env_cov),
    .VIRTUAL_SEQUENCER_T(alert_handler_virtual_sequencer),
    .SCOREBOARD_T       (alert_handler_scoreboard)
  );
  `uvm_component_utils(alert_handler_env)

  `uvm_component_new

  alert_agent host_agent[];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    host_agent                  = new[alert_pkg::NAlerts];
    virtual_sequencer.host_seqr = new[alert_pkg::NAlerts];
    foreach (host_agent[i]) begin
      host_agent[i] = alert_agent::type_id::create(
          $sformatf("%0s_agent", cfg.alert_hosts[i]), this);
      uvm_config_db#(alert_agent_cfg)::set(this,
          $sformatf("*%0s*", cfg.alert_hosts[i]),"cfg", cfg.alert_cfg[i]);
    end

    // get vifs
    if (!uvm_config_db#(esc_en_vif)::get(this, "", "esc_en_vif", cfg.esc_en_vif)) begin
      `uvm_fatal(get_full_name(), "failed to get esc_en_vif from uvm_config_db")
    end
    if (!uvm_config_db#(entropy_vif)::get(this, "", "entropy_vif", cfg.entropy_vif)) begin
      `uvm_fatal(get_full_name(), "failed to get entropy_vif from uvm_config_db")
    end

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active) begin
      foreach (host_agent[i]) begin
        virtual_sequencer.host_seqr[i] = host_agent[i].sequencer;
      end
    end
  endfunction

endclass
