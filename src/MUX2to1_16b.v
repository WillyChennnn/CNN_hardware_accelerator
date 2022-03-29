//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		MUX2to1_16b.v
//Description:	16-bit 2to1 multiplexer
//Version:		0.1
//=====================================
`include "def.v"

module MUX2to1_16b(
	Data_in1,
	Data_in2,
	sel,
	Data_out
);

	input [`DATA_BITS-1:0] Data_in1,Data_in2;
	input sel;
	output reg [`DATA_BITS-1:0] Data_out;

//complete your design here
always@(*)begin
if(sel)
Data_out=Data_in2;
else
Data_out=Data_in1;
end
endmodule
