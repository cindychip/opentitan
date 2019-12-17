// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

module prim_packer_bind_fpv;


  bind prim_packer prim_packer_assert_fpv #(
    .InW(InW),
    .OutW(OutW)
  ) i_prim_packer_assert_fpv (
    .clk_i,
    .rst_ni,
    .valid_i,
    .data_i,
    .mask_i,
    .ready_o,
    .valid_o,
    .data_o,
    .mask_o,
    .ready_i,
    .flush_i,
    .flush_done_o
  );


endmodule : prim_packer_bind_fpv
