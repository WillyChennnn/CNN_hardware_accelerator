//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Relu.v
//Description:	Relu Operation
//Version:		0.1
//=====================================
`include "def.v"

module Relu(
	Data_in,
	Data_out
);
	
	input [`INTERNAL_BITS-1:0] Data_in;
	output reg [`INTERNAL_BITS-1:0] Data_out;

//complete your design here
always@(*)
begin
if(Data_in[`INTERNAL_BITS-1]==1'b1)
Data_out = 32'b0;
else
Data_out = Data_in;
end


endmodule	
