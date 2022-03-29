//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Decoder.v
//Description:	Index Decode
//Version:		0.1
//=====================================
`include "def.v"

module Decoder(
	clk,
	rst,
	en,
	Data_in,
	Index
);

	input clk;
	input rst;
	input en;
	input signed [31:0] Data_in;
	output reg [31:0] Index;
	reg [4:0]counter;
	reg signed [31:0] temp;
	reg [31:0] temp_Index;
//complete your design here
always@(posedge clk or posedge rst)begin
if(rst)begin
	counter<=5'd0;
	temp <= 32'd0;
	temp_Index <= 32'd0; 
end
else begin

if(en)begin
counter<=counter+5'd1;

case(counter)
5'd0:begin
temp<=32'd0;
end
5'd1:begin
temp<=32'd0;
end
5'd2:begin
temp<=Data_in;
end
5'd3:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd1;
end
else begin
temp<=temp;
temp_Index<=32'd0;
end
end
5'd4:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd2;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd5:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd3;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd6:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd4;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd7:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd5;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd8:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd6;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd9:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd7;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd10:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd8;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd11:begin
if(Data_in>temp)begin
temp<=Data_in;
temp_Index<=32'd9;
end
else begin
temp<=temp;
temp_Index<=temp_Index;
end
end
5'd12:begin
temp<=temp;
temp_Index<=temp_Index;
counter<=5'd0;
end
default:begin
temp<=32'd0;
end
endcase

end

else begin
counter<=5'd0;
end
end
end

always@(*)begin
if(counter==5'd12)begin
Index=temp_Index;
end
else
Index=32'd0;
end

endmodule
