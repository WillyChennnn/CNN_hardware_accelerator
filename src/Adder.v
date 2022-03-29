//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Adder.v
//Description:	Add Operation
//Version:		0.1
//=====================================
`include "def.v"

module Adder(
	Data_in1,
	Data_in2,
	Data_in3,
	Psum,
	Bias,
	Mode,
	Result
);

	input signed [31:0] Data_in1,Data_in2,Data_in3;
	input signed [31:0] Psum;
	input signed [15:0] Bias;
	input [1:0] Mode;
	output reg [31:0] Result;

//complete your design here
always@(*)begin
case(Mode)
2'd0:begin
Result=Data_in1+Data_in2+Data_in3;
end	
2'd1:begin
Result=Data_in1+Data_in2+Data_in3+Psum;
end
2'd2:begin
Result=Data_in1+Data_in2+Data_in3+Psum+Bias;
end
default:begin
Result=32'd0;
end
endcase
end

endmodule
