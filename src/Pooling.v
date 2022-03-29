//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Pooling.v
//Description:	Max Pooling Operation
//Version:		0.1
//=====================================
`include "def.v"

module Pooling(
	clk,
	rst,
	en,
	Data_in,
	Data_out
);

	input clk;
	input rst;
	input en;
	input [`INTERNAL_BITS-1:0] Data_in;
	output reg [`INTERNAL_BITS-1:0] Data_out;
	reg  [`INTERNAL_BITS-1:0] temp;
	reg [2:0]counter;

//complete your design here
always@(posedge clk or posedge rst)begin
if(rst)begin
//Data_out<=32'd0;
temp<=32'd0;
end

else if(en)begin
counter<=counter+3'd1;

case(counter)
3'd0:begin
//Data_out<=32'd0;
temp<=32'd0;
end
3'd1:begin
//Data_out<=Data_in;
temp<=Data_in;
end
3'd2:begin
//Data_out<=(Data_in>Data_out)?Data_in:Data_out;
temp<=(Data_in>temp)?Data_in:temp;
end
3'd3:begin
//Data_out<=(Data_in>Data_out)?Data_in:Data_out;
temp<=(Data_in>temp)?Data_in:temp;
end
3'd4:begin
//Data_out<=(Data_in>Data_out)?Data_in:Data_out;
temp<=(Data_in>temp)?Data_in:temp;
end
3'd5:begin
//Data_out<=Data_out;
temp<=temp;
counter<=3'd0;
end
default:begin
//Data_out<=Data_out;
counter<=3'd0;
temp<=temp;
end
endcase

end

else begin
counter<=3'd0;
end
end

always@(*)begin
if(counter==3'd5)begin
Data_out=temp;
end
else begin
Data_out=32'd0;
end
end

endmodule
