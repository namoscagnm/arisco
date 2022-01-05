/*
 * sysmgr.v
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module sysmgr (
	input  wire clk_in,
	output wire clk_24Mhz,
	output wire rst
);

	wire pll_lock;

	SB_PLL40_2F_PAD #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),
		.DIVF(7'b1000010),
		.DIVQ(3'b101),
		.FILTER_RANGE(3'b001),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("DYNAMIC"),
		.FDA_RELATIVE(15),
		.SHIFTREG_DIV_MODE(0),
		.PLLOUT_SELECT_PORTA("GENCLK"),
		.PLLOUT_SELECT_PORTB("GENCLK")
	) pll_I (
		.PACKAGEPIN    (clk_in),
		.DYNAMICDELAY  (8'h0),
		.PLLOUTGLOBALA (),
		.PLLOUTGLOBALB (clk_24Mhz),
		.RESETB        (1'b1),
		.LOCK          (pll_lock)
	);

endmodule