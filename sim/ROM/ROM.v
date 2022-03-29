//=========================================
//Author:		Chen Yun-Ru (May)
//Filename:		ROM.v
//Description:	Read-Only Memory
//Version:		0.1
//=========================================
`include "def.v"

module ROM(
	CK,
	CS,
	OE,
	A,
	DO
);

	//parameters
	parameter ADDR_BITS = 10;
	parameter MEM_SIZE = 1024;

	input CK;
	input CS;
	input OE;
	input [ADDR_BITS-1:0] A;
	output [`DATA_BITS-1:0] DO;

	reg [`DATA_BITS-1:0] Memory [0:MEM_SIZE-1];
	reg [`DATA_BITS-1:0] latched_DO;

	always@(posedge CK)
	begin
		if(CS)
			latched_DO <= Memory[A];
		else;
	end

	assign DO = OE? latched_DO:{(`DATA_BITS){1'bz}};

endmodule
