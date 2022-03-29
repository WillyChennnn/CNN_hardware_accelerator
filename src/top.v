//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		top.v
//Description:	Top Connection
//Version:		0.1
//=====================================
`include "MUX2to1_16b.v"
`include "PE.v"
`include "Adder.v"
`include "Relu.v"
`include "MUX4to1_32b.v"
`include "MUX2to1_32b.v"
`include "Truncate.v"
`include "Pooling.v"
`include "Decoder.v"
`include "Controller.v"

module top(
	clk,
	rst,
	START,
	ROM_IM_out,ROM_W_out,ROM_B_out,
	SRAM_QA,
	DONE,
	ROM_IM_OE,ROM_W_OE,ROM_B_OE,
	ROM_IM_CS,ROM_W_CS,ROM_B_CS,
	ROM_IM_A,ROM_W_A,ROM_B_A,
	SRAM_AA,SRAM_AB,
	SRAM_CENA,SRAM_CENB,
	SRAM_WENB,
	SRAM_DB
);

	input clk;
	input rst;
	input START;
	
	input [`DATA_BITS-1:0] ROM_IM_out;
	input [`DATA_BITS-1:0] ROM_W_out;
	input [`DATA_BITS-1:0] ROM_B_out;
	
	input [`INTERNAL_BITS-1:0] SRAM_QA; 
	
	output DONE;
	
	output ROM_IM_OE,ROM_W_OE,ROM_B_OE;
	output ROM_IM_CS,ROM_W_CS,ROM_B_CS;
	output [`ROM_IM_ADDR_BITS-1:0] ROM_IM_A;
	output [`ROM_W_ADDR_BITS-1:0] ROM_W_A;
	output [`ROM_B_ADDR_BITS-1:0] ROM_B_A;
	
	output [`SRAM_ADDR_BITS-1:0] SRAM_AA,SRAM_AB;
	output SRAM_CENA,SRAM_CENB;
	output SRAM_WENB;
	output [`INTERNAL_BITS-1:0] SRAM_DB;
	
	wire [`INTERNAL_BITS-1:0] zero;
	assign zero = 0;
	
	wire [`DATA_BITS-1:0] MUX1_out;
	wire MUX1_sel;
	wire [1:0] MUX2_sel;
	wire MUX3_sel;
	
	wire PE1_IF_w,PE2_IF_w,PE3_IF_w;
	wire PE1_W_w,PE2_W_w,PE3_W_w;
	wire [`INTERNAL_BITS-1:0] PE1_result,PE2_result,PE3_result;
	
	wire [`INTERNAL_BITS-1:0] Adder_result;
	wire [`INTERNAL_BITS-1:0] Psum;
	wire [1:0] Adder_mode;
	
	wire [`INTERNAL_BITS-1:0] Relu_out;
	
	wire [`DATA_BITS-1:0] Truncate_out;
	
	wire [`INTERNAL_BITS-1:0] Pooling_out;
	wire Pooling_en;
	
	wire [`INTERNAL_BITS-1:0] Decoder_out;
	wire Decoder_en;

	MUX2to1_16b M16b2to1(
		.Data_in1(ROM_IM_out),
		.Data_in2(Truncate_out),
		.sel(MUX1_sel),
		.Data_out(MUX1_out)
	);

	PE PE1(
		.clk(clk),
		.rst(rst),
		.IF_w(PE1_IF_w),
		.W_w(PE1_W_w),
		.IF_in(MUX1_out),
		.W_in(ROM_W_out),
		.Result(PE1_result)
	);

	PE PE2(
		.clk(clk),
		.rst(rst),
		.IF_w(PE2_IF_w),
		.W_w(PE2_W_w),
		.IF_in(MUX1_out),
		.W_in(ROM_W_out),
		.Result(PE2_result)
	);

	PE PE3(
		.clk(clk),
		.rst(rst),
		.IF_w(PE3_IF_w),
		.W_w(PE3_W_w),
		.IF_in(MUX1_out),
		.W_in(ROM_W_out),
		.Result(PE3_result)
	);

	Adder AD(
		.Data_in1(PE1_result),
		.Data_in2(PE2_result),
		.Data_in3(PE3_result),
		.Psum(Psum),
		.Bias(ROM_B_out),
		.Mode(Adder_mode),
		.Result(Adder_result)
	);

	Relu RL(
		.Data_in(Adder_result),
		.Data_out(Relu_out)
	);

	MUX4to1_32b M32b4to1(
		.Data_in1(Relu_out),
		.Data_in2(Adder_result),
		.Data_in3(Pooling_out),
		.Data_in4(Decoder_out),
		.sel(MUX2_sel),
		.Data_out(SRAM_DB)
	);
	
	MUX2to1_32b M32b2to1(
		.Data_in1(SRAM_QA),
		.Data_in2(zero),
		.sel(MUX3_sel),
		.Data_out(Psum)
	);	

	Truncate TRC(
		.Data_in(SRAM_QA),
		.Data_out(Truncate_out)
	);

	Pooling PL(
		.clk(clk),
		.rst(rst),
		.en(Pooling_en),
		.Data_in(SRAM_QA),
		.Data_out(Pooling_out)
	);

	Decoder DC(
		.clk(clk),
		.rst(rst),
		.en(Decoder_en),
		.Data_in(SRAM_QA),
		.Index(Decoder_out)
	);

   Controller CTRL(
   	   .clk(clk),
   	   .rst(rst),
   	   .START(START),
   	   .DONE(DONE),
   	   .ROM_IM_CS(ROM_IM_CS),
   	   .ROM_W_CS(ROM_W_CS),
   	   .ROM_B_CS(ROM_B_CS),
   	   .ROM_IM_OE(ROM_IM_OE),
   	   .ROM_W_OE(ROM_W_OE),
   	   .ROM_B_OE(ROM_B_OE),
   	   .ROM_IM_A(ROM_IM_A),
   	   .ROM_W_A(ROM_W_A),
   	   .ROM_B_A(ROM_B_A),
   	   .SRAM_CENA(SRAM_CENA),
   	   .SRAM_CENB(SRAM_CENB),
   	   .SRAM_WENB(SRAM_WENB),
   	   .SRAM_AA(SRAM_AA),
   	   .SRAM_AB(SRAM_AB),
   	   .PE1_IF_w(PE1_IF_w),
   	   .PE2_IF_w(PE2_IF_w),
   	   .PE3_IF_w(PE3_IF_w),
   	   .PE1_W_w(PE1_W_w),
   	   .PE2_W_w(PE2_W_w),
   	   .PE3_W_w(PE3_W_w),
   	   .Pool_en(Pooling_en),
   	   .Decode_en(Decoder_en),
   	   .Adder_mode(Adder_mode),
   	   .MUX1_sel(MUX1_sel),
   	   .MUX2_sel(MUX2_sel),
	   .MUX3_sel(MUX3_sel)
   );
endmodule
