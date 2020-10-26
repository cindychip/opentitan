// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// alert_handler_env_pkg__params.sv is auto-generated by `topgen.py` tool

parameter string LIST_OF_ALERTS[] = {
  "aes_ctrl_err_update",
  "aes_ctrl_err_storage",
  "otbn_imem_uncorrectable",
  "otbn_dmem_uncorrectable",
  "otbn_reg_uncorrectable",
  "sensor_ctrl_ast_alerts",
  "keymgr_fault_err",
  "keymgr_operation_err",
  "otp_ctrl_otp_macro_failure",
  "otp_ctrl_otp_check_failure"
};

parameter uint NUM_ALERTS = 10;
