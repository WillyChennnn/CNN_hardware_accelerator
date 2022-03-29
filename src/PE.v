//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		PE.v
//Description:	MAC Operation
//Version:		0.1
//=====================================
`include "def.v"

module PE( 
	clk,
	rst,
	IF_w,
	W_w,
	IF_in,
	W_in,
	Result
);

	input clk;
	input rst;
	input IF_w,W_w;
	input [`DATA_BITS-1:0] IF_in,W_in; 
	output reg [`INTERNAL_BITS-1:0] Result;
	reg signed [`DATA_BITS-1:0] weight [2:0];
	reg signed [`DATA_BITS-1:0] feature [2:0];
//complete your design here
always@(posedge clk or posedge rst) begin

if(rst) begin
weight[0] <= 16'd0;
weight[1] <= 16'd0;
weight[2] <= 16'd0;
feature[0] <= 16'd0;
feature[1] <= 16'd0;
feature[2] <= 16'd0;
end
/*when two input signal is enable, shift the value*/
else if(W_w==1'b1 && IF_w==1'b1) begin
weight[2] <= W_in;
feature[2] <=IF_in;
weight[1]<=weight[2];
feature[1] <= feature[2];
weight[0]<=weight[1];
feature[0] <= feature[1];
end
/*shift weight value */
else if(W_w==1'b1 && IF_w==1'b0) begin
weight[2]<= W_in;
weight[1] <= weight[2];
weight[0] <= weight[1];
end
// shift feature value
else if(IF_w==1'b1 && W_w==1'b0) begin
feature[2]<=IF_in;
feature[1] <= feature[2];
feature[0] <= feature[1];
end
// use last value to compute
else begin
//out <= weight[2]*feature[2] + weight[1]*feature[1] + weight[0]*feature[0];
end
end //end always block

always@(*)begin
Result = weight[2]*feature[2] + weight[1]*feature[1] + weight[0]*feature[0];
end

	
	
endmodule
