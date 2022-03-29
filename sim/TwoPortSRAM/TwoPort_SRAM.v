//=========================================
//Author:		Chen Yun-Ru (May)
//Filename:		TwoPort_SRAM.v
//Description:	Two-Port SRAM
//Version:		0.1
//=========================================
`include "def.v"

module TwoPort_SRAM(
	CLKA,
	CENA,
	AA,
	QA,
	CLKB,
	CENB,
	WENB,
	AB,
	DB
);

	//parameters
	parameter ADDR_BITS = 13;
	parameter MEM_SIZE = 8192;

	input CLKA,CLKB;
	input CENA,CENB;
	input WENB;
	input [ADDR_BITS-1:0] AA,AB;
	input [`INTERNAL_BITS-1:0] DB;
	output [`INTERNAL_BITS-1:0] QA;

	reg [`INTERNAL_BITS-1:0] Memory [0:MEM_SIZE-1];
	reg [`INTERNAL_BITS-1:0] QA;

	//Port A read only
	always@(posedge CLKA)
	begin
		if(CENA)
			QA <= Memory[AA];
		else;
	end

	//Port B write only
	always@(posedge CLKB)
	begin
		if(CENB)
		begin
			if(WENB)
				Memory[AB] <= DB;
			else;
		end
		else;
	end

endmodule
