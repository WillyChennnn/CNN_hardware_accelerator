`timescale 1ns/10ps

`define CYCLE 10 //Cycle time
`define MAX 100 //Max cycle number

`include "TwoPort_SRAM.v"
`include "def.v"

module TwoPort_SRAM_tb;

	//parameters
	parameter ADDR_BITS = 13;

	//inputs
	reg CLK;
	reg CENA,CENB;
	reg WENB;
	reg [ADDR_BITS-1:0] AA,AB;
	reg [`INTERNAL_BITS-1:0] DB;

	//outputs
	wire [`INTERNAL_BITS-1:0] QA;

	TwoPort_SRAM TS(
		.CLKA(CLK),
		.CLKB(CLK),
		.CENA(CENA),
		.CENB(CENB),
		.WENB(WENB),
		.AA(AA),
		.AB(AB),
		.DB(DB),
		.QA(QA)
	);

	initial CLK = 0;
	always #(`CYCLE/2) CLK = ~CLK;

	integer i;

	initial
	begin
		for(i=0;i<100;i=i+1)
			TS.Memory[i] = i;

		CENA = 1; CENB = 1;
		WENB = 0;
		AA = 0; AB = 0; DB = 0;

		//read test
		for(i=0;i<100;i=i+1)
			#(`CYCLE) AA = i;

		//write test
		for(i=0;i<100;i=i+1)
		begin
			#(`CYCLE) AB=i; DB=100-i; WENB=1;
		end
		//read test
		#(`CYCLE) WENB=0;
		for(i=0;i<100;i=i+1)
			#(`CYCLE) AA = i;
		#(`CYCLE) $finish;
	end

	initial
	begin
		`ifdef FSDB
			$fsdbDumpfile("TwoPort_SRAM.fsdb");
			$fsdbDumpvars(0,TS,"+struct");
		`endif
	end

endmodule
