// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <assert.h>
#include <stdbool.h>

#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_lc_ctrl.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/check.h"
#include "sw/device/lib/testing/test_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

static dif_lc_ctrl_t lc;

const test_config_t kTestConfig;

/**
 * Tests that the OTP sends correct HW_CFG partition data to the receiving IPs.
 */
bool test_main(void) {
  LOG_INFO("Start LC_CTRL transition test.");
  mmio_region_t lc_reg = mmio_region_from_addr(TOP_EARLGREY_LC_CTRL_BASE_ADDR);
  CHECK(dif_lc_ctrl_init((dif_lc_ctrl_params_t){.base_addr = lc_reg}, &lc) ==
        kDifLcCtrlOk);

  dif_lc_ctrl_state_t curr_state;
  dif_lc_ctrl_state_t req_lc_ctrl_state = kDifLcCtrlStateDev;
  dif_lc_ctrl_token_t token;
  uint8_t exp_count;

  LOG_INFO("Read and check LC state.");
  CHECK(dif_lc_ctrl_get_state(&lc, &curr_state) == kDifLcCtrlOk);
  if (curr_state == kDifLcCtrlStateTestUnlocked2) {
    for (int i = 0; i < ARRAYSIZE(token.data); i++) {
      token.data[i] = i;
    }
    exp_count = 8;
  } else {
    CHECK(curr_state == req_lc_ctrl_state, "Error: state transition failed!");
    exp_count = 9;
  }

  // Read and check lc_cnt.
  LOG_INFO("Read and check LC count.");
  uint8_t count;
  CHECK(dif_lc_ctrl_get_attempts(&lc, &count) == kDifLcCtrlMutexOk,
        "Get lc_count failed!");
  CHECK(count == exp_count,
        "LC_count error, expected %0d but actual count is %0d", exp_count,
        count);

  if (exp_count == 9)
    return true;

  // Claim exclusive access to the lc transition interface.
  LOG_INFO("LC state transition request.");
  CHECK(dif_lc_ctrl_mutex_try_acquire(&lc) == kDifLcCtrlMutexOk);

  CHECK(dif_lc_ctrl_transition(&lc, req_lc_ctrl_state, &token) ==
            kDifLcCtrlMutexOk,
        "LC_transition failed!");

  // Wait for lc transition finished and hard reset.
  LOG_INFO("Waiting for LC transtition done and reboot.");
  wait_for_interrupt();

  return false;
}
