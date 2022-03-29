//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		MUX2to1_32b.v
//Description:	32-bit 2to1 multiplexer
//Version:		0.1
//=====================================
`include "def.v"

module MUX2to1_32b(
	Data_in1,
	Data_in2,//==0
	sel,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2;
	input sel;
	output reg [`INTERNAL_BITS-1:0] Data_out;

//complete your design here
always@(*)begin
if(sel)
Data_out=Data_in2;
else
Data_out=Data_in1;
end


endmodule
