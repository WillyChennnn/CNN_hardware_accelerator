//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Truncate.v
//Description:	Truncate Operation
//Version:		0.1
//=====================================
`include "def.v"

module Truncate(
	Data_in,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in;
	output reg [`DATA_BITS-1:0] Data_out;

//complete your design here
always@(*)begin
Data_out=Data_in[23:8];
end
endmodule
