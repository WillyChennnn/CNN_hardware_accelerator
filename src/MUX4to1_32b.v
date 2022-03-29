//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		MUX4to1_32b.v
//Description:	32-bit 4to1 multiplexer
//Version:		0.1
//=====================================
`include "def.v"

module MUX4to1_32b(
	Data_in1,
	Data_in2,
	Data_in3,
	Data_in4,
	sel,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2,Data_in3,Data_in4;
	input [1:0] sel;
	output reg [`INTERNAL_BITS-1:0] Data_out;

//complete your design here
always@(*)begin
case(sel)
4'd0:begin Data_out=Data_in1;end
4'd1:begin Data_out=Data_in2;end
4'd2:begin Data_out=Data_in3;end
4'd3:begin Data_out=Data_in4;end
//default:begin Data_out=32'd0;end
endcase
end
endmodule
