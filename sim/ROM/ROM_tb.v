`timescale 1ns/10ps

`define CYCLE 10 //Cycle time
`define MAX 100 //Max cycle number

`include "ROM.v"
`include "def.v"

module ROM_tb;

	//parameters
	parameter ADDR_BITS = 17;

	//inputs
	reg CK;
	reg CS;
	reg OE;
	reg [ADDR_BITS-1:0] A;

	//outputs
	wire [`DATA_BITS-1:0] DO;

	ROM ROM_W(
		.CK(CK),
		.CS(CS),
		.OE(OE),
		.A(A),
		.DO(DO)
	);
	defparam ROM_W.ADDR_BITS = 17;
	defparam ROM_W.MEM_SIZE = 131072;
	
	initial CK = 1'b0;
	always #(`CYCLE/2) CK = ~CK;

	integer i;

	initial
	begin
		for(i=0;i<100;i=i+1)
		begin
			ROM_W.Memory[i] = i;
		end
		CS = 1; OE = 0; A = 0;

		#(`CYCLE) OE = 1;
		for(i=0;i<100;i=i+1)
		begin
			#(`CYCLE) A = i;
		end

		#(`CYCLE) $finish;
	end
	
	initial
	begin
		`ifdef FSDB
			$fsdbDumpfile("ROM.fsdb");
			$fsdbDumpvars(0,ROM_W,"+struct");
		`endif
	end

endmodule
