//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		Controller.v
//Description:	Controller
//Version:		0.1
//=====================================
`include "def.v"

module Controller(
	clk,
	rst,
	START,
	DONE,
	//ROM
	ROM_IM_CS,ROM_W_CS,ROM_B_CS,
	ROM_IM_OE,ROM_W_OE,ROM_B_OE,
	ROM_IM_A,ROM_W_A,ROM_B_A,
	//SRAM
	SRAM_CENA,SRAM_CENB,
	SRAM_WENB,
	SRAM_AA,SRAM_AB,
	//PE
	PE1_IF_w,PE2_IF_w,PE3_IF_w,
	PE1_W_w,PE2_W_w,PE3_W_w,
	//Pooling
	Pool_en,
	//Decoder
	Decode_en,
	//Adder
	Adder_mode,
	//MUX
	MUX1_sel,MUX2_sel,MUX3_sel     
);
	//layer
	parameter   
	//CONV0		
				CONV0_INIT    = 5'd0,
				CONV0_READ_W = 5'd1,
				CONV0_READ_C = 5'd2,
				CONV0_READ_9 = 5'd3,
				CONV0_WRITE = 5'd4,
				CONV0_DONE = 5'd5,
	//POOLING1
				POOLING1_READ =5'd6,
				POOLING1_WRITE=5'd7,
	//CONV2
				CONV2_INIT   = 5'd8,
				CONV2_READ_W = 5'd9,
				CONV2_READ_C = 5'd10,
				CONV2_READ_9 = 5'd11,
				CONV2_WRITE = 5'd12,
				CONV2_DONE = 5'd13,
	//POOLING2
				POOLING2_READ=5'd14,
				POOLING2_WRITE=5'd15,
	//FC4
				FC4_INIT=5'd16,
				FC4_READ_W=5'd17,
				FC4_WRITE=5'd18,
				FC4_DONE=5'd19,
	//FC5
				FC5_INIT=5'd20,
				FC5_READ_W=5'd21,
				FC5_WRITE=5'd22,
				FC5_DONE=5'd23,
	//Decode
				DECODE_INIT=5'd24,
				DECODE_READ_W=5'd25,
				DECODE_WRITE=5'd26,
				DECODE_DONE=5'd27;
	
	
	
	input clk;
	input rst;
	input START;
	output reg DONE;
	output reg ROM_IM_CS,ROM_W_CS,ROM_B_CS;
	output reg ROM_IM_OE,ROM_W_OE,ROM_B_OE;
	output reg [`ROM_IM_ADDR_BITS-1:0] ROM_IM_A;
	output reg [`ROM_W_ADDR_BITS-1:0] ROM_W_A;
	output reg [`ROM_B_ADDR_BITS-1:0] ROM_B_A;
	output reg SRAM_CENA,SRAM_CENB;
	output reg SRAM_WENB;
	output reg [`SRAM_ADDR_BITS-1:0] SRAM_AA,SRAM_AB;
	output reg PE1_IF_w,PE2_IF_w,PE3_IF_w;
	output reg PE1_W_w,PE2_W_w,PE3_W_w;
	output reg Pool_en; 
	output reg Decode_en;
	output reg [1:0] Adder_mode;
	output reg [1:0] MUX2_sel;
	output reg MUX1_sel,MUX3_sel;
//------------------------------------------------------------------------
reg [2:0]filter_counter;
reg [3:0]counter;	
reg [10:0] column;
reg [9:0] row;
reg [11:0]CONV2_W_counter;
reg[12:0] pooling1_READ_column,pooling1_READ_row,pooling1_WRITE_counter,
		  pooling2_READ_column,pooling2_READ_row,pooling2_WRITE_counter;
reg [4:0]ADDER_counter,BIAS_counter,channel;
reg [4:0]state,n_state;
reg [16:0]FC4_W_counter,FC5_W_counter;
reg[12:0]FC4_SRAM_A_counter,FC5_SRAM_A_counter,start_address;
reg [12:0]FC5_SRAM_B_counter,FC4_SRAM_B_counter;
reg [7:0]BIAS_counter2,FC4_ADD_counter,BIAS_counter3,FC5_ADD_counter;
//complete your design here
always@(posedge clk or posedge rst)begin
//CONV0_INITialize and change state
	if(rst)begin
		state<=CONV0_INIT;
		counter<=4'd0;
		column<=11'd0;
		row<=10'd0;
		filter_counter<=3'd0;
		ADDER_counter<=5'd0;
		BIAS_counter<=5'd1;
		pooling1_WRITE_counter<=13'd4704;
		pooling2_WRITE_counter<=13'd4704;
		pooling1_READ_column<=13'd0;
		pooling1_READ_row<=13'd0;
		channel<=5'd0;
		CONV2_W_counter<=12'd54;
		
		pooling2_READ_column<=13'd0;
		pooling2_READ_row<=13'd0;
		
		FC4_SRAM_A_counter<=13'd4703;
		FC4_W_counter<=17'd864;
		
		FC5_SRAM_A_counter<=17'd0;
		FC5_W_counter<=17'd98064;
		
		BIAS_counter2<=8'd0;
		FC4_SRAM_B_counter<=13'd0;
		FC4_ADD_counter<=8'd0;
		
		BIAS_counter3<=8'd0;
		FC5_SRAM_B_counter<=13'd4704;
		FC5_ADD_counter<=8'd0;
	end

	else begin
		state<=n_state;
//calculate conv0 counter
		if(state==CONV0_READ_W || state==CONV0_READ_C || state==CONV0_READ_9||state==POOLING1_READ||state==CONV2_READ_W||state==CONV2_READ_C||state==CONV2_READ_9||state==POOLING2_READ||state==FC4_READ_W||state==FC5_READ_W||state==DECODE_READ_W)
			counter<=counter+4'd1;
		else 
			counter<=4'd0;
//calculate row and col
		if(state==CONV0_WRITE && n_state==CONV0_READ_9/*column==11'd256 && row!=10'd256*/)begin
			row<=row+10'd1;
			column<=11'd0;
		end
		else if(state==CONV0_WRITE && n_state==CONV0_READ_C/*column!=11'd256 && row!=10'd257*/)begin
			column<=column+11'd1;
			row<=row;
		end
		else if(n_state==CONV0_INIT)begin
			row<=10'd0;
			column<=11'd0;
		end
		else begin
		end
//calculate filter counter
		if(state==CONV0_INIT)
			filter_counter<=filter_counter+3'd1;
		else
			filter_counter<=filter_counter;
//calculate pooling1 SRAM address
		/*if(state==POOLING1_READ)
			pooling1_READ_column<=pooling1_READ_column+12'd1;
		else
			pooling1_READ_column<=pooling1_READ_column;
		*/
		if(state==POOLING1_WRITE)begin
			row<=10'd0;
			column<=11'd0;
			pooling1_WRITE_counter<=pooling1_WRITE_counter+13'd1;
			pooling1_READ_column<=pooling1_READ_column+13'd2;
			if(pooling1_READ_column==13'd26)begin
			pooling1_READ_row<=pooling1_READ_row+13'd1;
			pooling1_READ_column<=13'd0;
			end
		end
		else begin
			pooling1_WRITE_counter<=pooling1_WRITE_counter;
			pooling1_READ_column<=pooling1_READ_column;
		end
//CONV2
		if(state==CONV2_INIT)begin
		
			if(channel==5'd6)begin
			BIAS_counter<=BIAS_counter+5'd1;
			CONV2_W_counter<=12'd54*(BIAS_counter+5'd1);
			channel<=5'd1;
			end
			else begin
			channel<=channel+5'd1;
			BIAS_counter<=BIAS_counter;
			CONV2_W_counter<=CONV2_W_counter;
			start_address<=17'd4704+17'd196*channel;
			end
			
			row<=10'd0;
			column<=11'd0;
			
		end
		else begin
			BIAS_counter<=BIAS_counter;
			channel<=channel;
		end
//calculate address
        if(n_state==CONV2_READ_W)begin
			row<=10'd0;
			column<=11'd0;
		end
		
	else begin
			start_address<=start_address;
			if(state==CONV2_WRITE && n_state==CONV2_READ_9)begin
				row<=row+10'd1;
				column<=11'd0;
			end
			else if(state==CONV2_WRITE && n_state==CONV2_READ_C)begin
				column<=column+11'd1;
				row<=row;
			end
			
			else begin
			end
			
		end
//calculate conv2 weight address
		if(state==CONV2_READ_W)begin
				CONV2_W_counter<=CONV2_W_counter+12'd1;
					if(counter>=4'd9)begin
						CONV2_W_counter<=CONV2_W_counter;
					end
		end
//calculate row and col
		/*if(state==CONV2_CH_COL)begin
			CONV2_W_counter<=12'd54*(BIAS_counter)-12'd1;
			column<=column+11'd1;
		end
		else if(state==CONV2_CH_ROW)begin
			CONV2_W_counter<=12'd54*(BIAS_counter)-12'd1;
			row<=row+10'd1;
			column<=11'd0;
		end
		else begin
		end*/
//CONV2_WRITE  control adder_counter
		/*if(state==CONV2_WRITE)begin
		  if(n_state==CONV2_READ_W)
		     ADDER_counter<=ADDER_counter+5'd1;
		  else
			 ADDER_counter<=5'd0;
		end*/
//calculate pooling2 SRAM address
		if(state==POOLING2_WRITE)begin
			row<=10'd0;
			column<=11'd0;
			pooling2_WRITE_counter<=pooling2_WRITE_counter+13'd1;
			pooling2_READ_column<=pooling2_READ_column+13'd2;
			BIAS_counter2<=8'd0;
			if(pooling2_READ_column==13'd10)begin
			pooling2_READ_row<=pooling2_READ_row+13'd1;
			pooling2_READ_column<=13'd0;
			end
		end
		else begin
			pooling2_WRITE_counter<=pooling2_WRITE_counter;
			pooling2_READ_column<=pooling2_READ_column;
		end
//FC4
		if(state==FC4_INIT)begin
			BIAS_counter2<=BIAS_counter2+8'd1;
			FC4_SRAM_A_counter<=13'd4704;
		end
		if(state==FC4_READ_W)begin
			FC4_SRAM_A_counter<=FC4_SRAM_A_counter+13'd1;
			FC4_W_counter<=FC4_W_counter+17'd1;
				if(counter>=4'd10||counter==4'd0)begin
				FC4_SRAM_A_counter<=FC4_SRAM_A_counter;
				FC4_W_counter<=FC4_W_counter;
				end
		end
		if(state==FC4_WRITE)begin
			if(FC4_ADD_counter==8'd59)begin
				FC4_SRAM_B_counter<=FC4_SRAM_B_counter+13'd1;
				FC4_ADD_counter<=8'd0;
			end
			else begin
			  if(n_state==FC4_READ_W)
				FC4_ADD_counter<=FC4_ADD_counter+8'd1;
			  else
				FC4_ADD_counter<=8'd0;
			end
		end
//FC5
		if(state==FC5_INIT)begin
			BIAS_counter3<=BIAS_counter3+8'd1;
			FC5_SRAM_A_counter<=13'd0;
		end
		if(state==FC5_READ_W)begin
			FC5_SRAM_A_counter<=FC5_SRAM_A_counter+13'd1;
			FC5_W_counter<=FC5_W_counter+17'd1;
				if(counter>=4'd10||counter==4'd0)begin
				FC5_SRAM_A_counter<=FC5_SRAM_A_counter;
				FC5_W_counter<=FC5_W_counter;
				end
			end
		if(state==FC5_WRITE)begin
			if(FC5_ADD_counter==8'd19)begin
				FC5_SRAM_B_counter<=FC5_SRAM_B_counter+13'd1;
				FC5_ADD_counter<=8'd0;
			end
			else begin
			  if(n_state==FC5_READ_W)
				FC5_ADD_counter<=FC5_ADD_counter+8'd1;
			  else
				FC5_ADD_counter<=8'd0;
			end
		end
//DECODE	
		
	end
		
		
end



/*conv0 begin*///----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
always@(*)begin
	if(state==CONV0_INIT)begin
		n_state=CONV0_READ_W;	ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ SRAM_AB=13'd0; Adder_mode=2'd3;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	end

	else if(state==CONV0_READ_W)begin
		SRAM_AA=13'd0;
		case(counter)
		4'd0:begin	ROM_IM_A=10'd0;  ROM_W_A=17'd0+(filter_counter-1)*17'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd1:begin	ROM_IM_A=10'd1;  ROM_W_A=17'd1+(filter_counter-1)*17'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd2:begin	ROM_IM_A=10'd2;  ROM_W_A=17'd2+(filter_counter-1)*20'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd3:begin	ROM_IM_A=10'd30;  ROM_W_A=17'd3+(filter_counter-1)*20'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd4:begin	ROM_IM_A=10'd31;  ROM_W_A=17'd4+(filter_counter-1)*20'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd5:begin	ROM_IM_A=10'd32; ROM_W_A=17'd5+(filter_counter-1)*20'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd6:begin	ROM_IM_A=10'd60; ROM_W_A=17'd6+(filter_counter-1)*20'd9; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd7:begin	ROM_IM_A=10'd61; ROM_W_A=17'd7+(filter_counter-1)*20'd9; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd8:begin	ROM_IM_A=10'd62; ROM_W_A=17'd8+(filter_counter-1)*20'd9; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=CONV0_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd9:begin	ROM_IM_A=10'd0;  ROM_W_A=17'd0; 						 PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=CONV0_WRITE ; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd2;end
		default:begin ROM_IM_A=10'd0;ROM_W_A=17'd0; 						 PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV0_READ_W ;SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		endcase
	end
	
	else if(state==CONV0_WRITE)begin
		PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/
		ROM_IM_A=10'd0;   ROM_W_A=17'd0; Adder_mode=2'd2;SRAM_AA=13'd0;ROM_B_A=8'd0;
		if((column==11'd27)&&(row==10'd27))begin//finish all
			n_state=CONV0_DONE;
			SRAM_AB={2'd0,column}+13'd28*row+(filter_counter-1)*13'd784;
		end

		else if(column==11'd27)begin//finish a row
			n_state=CONV0_READ_9;
			SRAM_AB={2'd0,column}+13'd28*row+(filter_counter-1)*13'd784;
		end

		else begin//change col
			n_state=CONV0_READ_C;
			SRAM_AB={2'd0,column}+13'd28*row+(filter_counter-1)*13'd784;
		end
	end
	
	else if(state==CONV0_READ_C)begin
		SRAM_AA=13'd0;
		case(counter)
		4'd0:begin	ROM_IM_A = {6'd0,(column+11'd2)}+17'd30*row        ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV0_READ_C; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd1:begin	ROM_IM_A = {6'd0,(column+11'd2)}+17'd30*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV0_READ_C; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd2:begin	ROM_IM_A = {6'd0,(column+11'd2)}+17'd30*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV0_READ_C; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd3:begin	ROM_IM_A = 17'd0				    			   ;ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV0_WRITE ; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd2;end
		default:begin   ROM_IM_A = 17'd0  					  	       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV0_READ_C; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		endcase
	end

	else if(state==CONV0_READ_9)begin
		SRAM_AA=13'd0;
		case(counter)
		//update conv1
		4'd0:begin	ROM_IM_A = {6'd0,column}        +17'd30*row       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd1:begin	ROM_IM_A = {6'd0,column+11'd1}  +17'd30*row       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd2:begin	ROM_IM_A = {6'd0,column+11'd2}  +17'd30*row       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		//update conv2
		4'd3:begin	ROM_IM_A = {6'd0,column      }  +17'd30*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd4:begin	ROM_IM_A = {6'd0,column+11'd1}  +17'd30*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd5:begin	ROM_IM_A = {6'd0,column+11'd2}  +17'd30*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		//update conv3
		4'd6:begin	ROM_IM_A = {6'd0,column      } +17'd30*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd7:begin	ROM_IM_A = {6'd0,column+11'd1}  +17'd30*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd8:begin	ROM_IM_A = {6'd0,column+11'd2}  +17'd30*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		4'd9:begin	ROM_IM_A = 17'd0									;ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV0_WRITE;  SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd2;end
		default:begin	ROM_IM_A = 17'd0								;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV0_READ_9; SRAM_AB=13'd0;ROM_B_A=(filter_counter-1);Adder_mode=2'd3;end
		endcase
	end
	
	else if(state==CONV0_DONE)begin
	ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ /*n_state=CONV0_READ_9;*/ SRAM_AB=13'd0; Adder_mode=2'd3;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	if(filter_counter==3'd6)begin
	n_state=POOLING1_READ;
	end
	else begin
	n_state=CONV0_INIT;
	end
	end
/*POOLOING*///-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//POOLING1_READ
	else if(state==POOLING1_READ)begin
	Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;ROM_W_A=17'd0; SRAM_AB=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	case(counter)
	4'd0:begin n_state=POOLING1_READ;SRAM_AA=13'd56*pooling1_READ_row+pooling1_READ_column;end
	4'd1:begin n_state=POOLING1_READ;SRAM_AA=13'd56*pooling1_READ_row+pooling1_READ_column+13'd1;end
	4'd2:begin n_state=POOLING1_READ;SRAM_AA=13'd56*pooling1_READ_row+pooling1_READ_column+13'd28;end
	4'd3:begin n_state=POOLING1_READ;SRAM_AA=13'd56*pooling1_READ_row+pooling1_READ_column+13'd29;end
	4'd4:begin n_state=POOLING1_WRITE;SRAM_AA=13'd0;end 
	default:begin n_state=POOLING1_READ;SRAM_AA=13'd0;end
	endcase
	end
//POOLING1_WRITE
	else if(state==POOLING1_WRITE)begin
		Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
		SRAM_AB=pooling1_WRITE_counter;ROM_W_A=17'd0;
		if(pooling1_WRITE_counter==13'd5879)begin
			n_state=CONV2_INIT;
		end
		else begin
			n_state=POOLING1_READ;
		end
	end
//CONV2 begin ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//CONV2_INIT
	else if(state==CONV2_INIT)begin
	n_state=CONV2_READ_W; ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ SRAM_AB=13'd0; Adder_mode=2'd3;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	end
//CONV2_READ_W
	else if(state==CONV2_READ_W)begin
	ROM_IM_A=10'd0;
	case(counter)
		4'd0:begin	SRAM_AA =start_address;  	    ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd1:begin	SRAM_AA =start_address+13'd1;   ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd2:begin	SRAM_AA =start_address+13'd2;   ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd3:begin	SRAM_AA =start_address+13'd14;  ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd4:begin	SRAM_AA =start_address+13'd15;  ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd5:begin	SRAM_AA =start_address+13'd16;  ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd6:begin	SRAM_AA =start_address+13'd28;  ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd7:begin	SRAM_AA =start_address+13'd29;  ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd8:begin	SRAM_AA =start_address+13'd30;  ROM_W_A=CONV2_W_counter; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=CONV2_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		4'd9:begin		SRAM_AA={2'd0,column}+13'd12*row+(BIAS_counter-1)*13'd144;                 								    ROM_W_A=17'd0;PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=CONV2_WRITE ; SRAM_AB=13'd0;ROM_B_A=(BIAS_counter-5'd1)+5'd6;Adder_mode=2'd3;end
		default:begin SRAM_AA =13'd0;ROM_W_A=17'd0;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV2_READ_W ;SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		endcase
	end
//CONV2_READ_C
	else if(state==CONV2_READ_C)begin
	ROM_IM_A=10'd0;ROM_B_A=8'd0;
		case(counter)
		4'd0:begin	SRAM_AA = start_address+{6'd0,(column+11'd2)}+13'd14*row        ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV2_READ_C; SRAM_AB=13'd0;Adder_mode=2'd3;end
		4'd1:begin	SRAM_AA = start_address+{6'd0,(column+11'd2)}+13'd14*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV2_READ_C; SRAM_AB=13'd0;Adder_mode=2'd3;end
		4'd2:begin	SRAM_AA = start_address+{6'd0,(column+11'd2)}+13'd14*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV2_READ_C; SRAM_AB=13'd0;Adder_mode=2'd3;end
		4'd3:begin	SRAM_AA = {2'd0,column}+13'd12*row+(BIAS_counter-1)*13'd144;ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV2_WRITE ; SRAM_AB=13'd0;Adder_mode=2'd3;end
		default:begin   SRAM_AA=13'd0;  					  	       ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV2_READ_C; SRAM_AB=13'd0;Adder_mode=2'd3;end
		endcase
	end
//CONV2_READ_9
	else if(state==CONV2_READ_9)begin
	ROM_IM_A=10'd0;ROM_B_A=8'd0;
		Adder_mode=2'd3;
		case(counter)
		//update conv1
		4'd0:begin	SRAM_AA = start_address+{6'd0,column}        +13'd14*row       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd1:begin	SRAM_AA = start_address+{6'd0,column+11'd1}  +13'd14*row       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd2:begin	SRAM_AA = start_address+{6'd0,column+11'd2}  +13'd14*row       ;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		//update conv2
		4'd3:begin	SRAM_AA = start_address+{6'd0,column      }  +13'd14*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*001;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd4:begin	SRAM_AA = start_address+{6'd0,column+11'd1}  +13'd14*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd5:begin	SRAM_AA = start_address+{6'd0,column+11'd2}  +13'd14*(row+10'd1);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		//update conv3
		4'd6:begin	SRAM_AA = start_address+{6'd0,column      }  +13'd14*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*010;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd7:begin	SRAM_AA = start_address+{6'd0,column+11'd1}  +13'd14*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd8:begin	SRAM_AA = start_address+{6'd0,column+11'd2}  +13'd14*(row+10'd2);ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		4'd9:begin	SRAM_AA = {2'd0,column}+13'd12*row+(BIAS_counter-1)*13'd144;ROM_W_A=17'd0; PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;000*/ n_state=CONV2_WRITE;  SRAM_AB=13'd0;end
		default:begin	SRAM_AA=13'd0;								ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=CONV2_READ_9; SRAM_AB=13'd0;end
		endcase
	end
//CONV2_WRITE	
	else if(state==CONV2_WRITE)begin
		ROM_W_A=17'd0;ROM_IM_A=10'd0;
		PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/SRAM_AA=13'd0;ROM_B_A=8'd0;
		
		if(channel==5'd1)begin
			Adder_mode=2'd0;
		end
		else if(channel==5'd6)begin
			Adder_mode=2'd2;
		end
		else begin //channel==2~5
			Adder_mode=2'd1;
		end
		
		if((column==11'd11)&&(row==10'd11))begin//finish all
			n_state=CONV2_DONE;
			SRAM_AB={2'd0,column}+13'd12*row+(BIAS_counter-1)*13'd144;
		end

		else if(column==11'd11)begin//finish a row
			n_state=CONV2_READ_9;
			SRAM_AB={2'd0,column}+13'd12*row+(BIAS_counter-1)*13'd144;
		end

		else begin//change col
			n_state=CONV2_READ_C;
			SRAM_AB={2'd0,column}+13'd12*row+(BIAS_counter-1)*13'd144;
		end
		
	end
//CONV2_DONE
	else if(state==CONV2_DONE)begin
	ROM_W_A=17'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;SRAM_AA=13'd0;SRAM_AB=13'd0;
	if(BIAS_counter==5'd15 && channel==5'd6)
		n_state=POOLING2_READ;
	else
		n_state=CONV2_INIT;
end
/*POOLING2*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//POOLING2_READ
	else if(state==POOLING2_READ)begin
	Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;ROM_W_A=17'd0;SRAM_AB=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	case(counter)
	4'd0:begin n_state=POOLING2_READ;SRAM_AA=13'd24*pooling2_READ_row+pooling2_READ_column;end
	4'd1:begin n_state=POOLING2_READ;SRAM_AA=13'd24*pooling2_READ_row+pooling2_READ_column+13'd1;end
	4'd2:begin n_state=POOLING2_READ;SRAM_AA=13'd24*pooling2_READ_row+pooling2_READ_column+13'd12;end
	4'd3:begin n_state=POOLING2_READ;SRAM_AA=13'd24*pooling2_READ_row+pooling2_READ_column+13'd13;end
	4'd4:begin n_state=POOLING2_WRITE;SRAM_AA=13'd0;end 
	default:begin n_state=POOLING2_READ;SRAM_AA=13'd0;end
	endcase
	end
//POOLING2_WRITE
else if(state==POOLING2_WRITE)begin
		Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;ROM_W_A=17'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
		SRAM_AB=pooling2_WRITE_counter;SRAM_AA=13'd0;
		if(pooling2_WRITE_counter==13'd5243)begin
			n_state=FC4_INIT;
		end
		else begin
			n_state=POOLING2_READ;
		end
	end

/*FC4*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FC4_INIT
else if(state==FC4_INIT)begin
	n_state=FC4_READ_W; ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ SRAM_AB=13'd0; Adder_mode=2'd0;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
end
//FC4_READ_W
else if(state==FC4_READ_W)begin
	ROM_W_A = FC4_W_counter;ROM_IM_A=10'd0;
	case(counter)
		4'd1:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd2:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd3:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd4:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd5:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd6:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd7:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd8:begin	PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd9:begin	PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=FC4_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC4_SRAM_A_counter;ROM_W_A = FC4_W_counter;end
		4'd10:begin	SRAM_AA =17'd0;ROM_W_A=17'd0;PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=FC4_WRITE ; SRAM_AB=13'd0;ROM_B_A=(BIAS_counter2-8'd1)+8'd21;Adder_mode=2'd0;
		if(FC4_ADD_counter==8'd0)begin
			SRAM_AA=13'd0;
		end
		else if(FC4_ADD_counter==8'd59)begin
			SRAM_AA=FC4_SRAM_B_counter;
		end
		else begin
			SRAM_AA=FC4_SRAM_B_counter;
		end
			end
		default:begin SRAM_AA =17'd0;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=FC4_READ_W ;SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		endcase
	end

else if(state==FC4_WRITE)begin
	SRAM_AA=13'd0;ROM_B_A=8'd0;
	if(FC4_ADD_counter==8'd0)begin
			Adder_mode=2'd0;
		end
		else if(FC4_ADD_counter==8'd59)begin
			Adder_mode=2'd2;
		end
		else begin
			Adder_mode=2'd1;
		end
	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/
	ROM_IM_A=10'd0;   ROM_W_A=17'd0;
	SRAM_AB=FC4_SRAM_B_counter; //SRAM position
	//control state
	if(FC4_ADD_counter==8'd59)
	n_state=FC4_DONE;
	else
	n_state=FC4_READ_W;
	end
else if(state==FC4_DONE)begin
	Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;SRAM_AA=13'd0;ROM_W_A=17'd0;SRAM_AB=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	if(BIAS_counter2==12'd180)
		n_state=FC5_INIT;
	else
		n_state=FC4_INIT;
	end
/*FC5*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	else if(state==FC5_INIT)begin
		n_state=FC5_READ_W; ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ SRAM_AB=13'd0; Adder_mode=2'd0;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	end
	
	else if(state==FC5_READ_W)begin
	ROM_W_A = FC5_W_counter;ROM_IM_A=10'd0;
	case(counter)
		4'd1:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd2:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd3:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd4:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b1;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b1;/*001;001*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd5:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd6:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd7:begin	PE1_IF_w=1'b0;PE2_IF_w=1'b1;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b1;PE3_W_w=1'b0;/*010;010*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd8:begin	PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd9:begin	PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=FC5_READ_W; SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd0;SRAM_AA = FC5_SRAM_A_counter;ROM_W_A = FC5_W_counter;end
		4'd10:begin	SRAM_AA =13'd0;ROM_W_A=17'd0;PE1_IF_w=1'b1;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b1;PE2_W_w=1'b0;PE3_W_w=1'b0;/*100;100*/ n_state=FC5_WRITE ; SRAM_AB=13'd0;ROM_B_A=(BIAS_counter3-8'd1)+8'd21; Adder_mode=2'd0;
		if(FC5_ADD_counter==8'd0)begin
			SRAM_AA=13'd0;
		end
		else if(FC5_ADD_counter==8'd19)begin
			SRAM_AA=FC5_SRAM_B_counter;
		end
		else begin
			SRAM_AA=FC5_SRAM_B_counter;
		end
			end
		default:begin SRAM_AA =13'd0;ROM_W_A=17'd0; PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/ n_state=FC5_READ_W ;SRAM_AB=13'd0;ROM_B_A=8'd0;Adder_mode=2'd3;end
		endcase
	end

	else if(state==FC5_WRITE)begin
	SRAM_AA=13'd0;ROM_B_A=8'd0;
	if(FC5_ADD_counter==8'd0)begin
		Adder_mode=2'd0;
	end
	else if(FC5_ADD_counter==8'd19)begin
		Adder_mode=2'd2;
	end
	else begin
		Adder_mode=2'd1;
	end
	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/
	ROM_IM_A=10'd0;   ROM_W_A=17'd0;
	SRAM_AB=FC5_SRAM_B_counter; //SRAM position
	//control state
	if(FC5_ADD_counter==8'd19)
	n_state=FC5_DONE;
	else
	n_state=FC5_READ_W;
	end
	
	else if(state==FC5_DONE)begin
	Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;SRAM_AA=13'd0;ROM_W_A=17'd0;SRAM_AB=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	if(BIAS_counter3==12'd10)
		n_state=DECODE_INIT;
	else
		n_state=FC5_INIT;
	end
/*DECODE*//////////////////////////////////////////////////////////////////////////////////////////////
	else if(state==DECODE_INIT)begin
	PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;/*000;000*/
	ROM_IM_A=10'd0;   ROM_W_A=17'd0; Adder_mode=2'd3;ROM_B_A=8'd0;
	n_state=DECODE_READ_W;SRAM_AA=13'd0;SRAM_AB=13'd0;
	end
	
	else if(state==DECODE_READ_W)begin
	Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;ROM_W_A=17'd0;SRAM_AB=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
	case(counter)
	4'd0:begin n_state=DECODE_READ_W;SRAM_AA=13'd4704;end
	4'd1:begin n_state=DECODE_READ_W;SRAM_AA=13'd4705;end
	4'd2:begin n_state=DECODE_READ_W;SRAM_AA=13'd4706;end
	4'd3:begin n_state=DECODE_READ_W;SRAM_AA=13'd4707;end
	4'd4:begin n_state=DECODE_READ_W;SRAM_AA=13'd4708;end
	4'd5:begin n_state=DECODE_READ_W;SRAM_AA=13'd4709;end
	4'd6:begin n_state=DECODE_READ_W;SRAM_AA=13'd4710;end
	4'd7:begin n_state=DECODE_READ_W;SRAM_AA=13'd4711;end
	4'd8:begin n_state=DECODE_READ_W;SRAM_AA=13'd4712;end
	4'd9:begin n_state=DECODE_READ_W;SRAM_AA=13'd4713;end
	4'd10:begin n_state=DECODE_WRITE;SRAM_AA=13'd0;end 
	default:begin n_state=DECODE_READ_W;SRAM_AA=13'd0;end
	endcase
	end
	
	else if(state==DECODE_WRITE)begin
		Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;ROM_W_A=17'd0;
		SRAM_AB=13'd0;SRAM_AA=13'd4704;ROM_IM_A=10'd0;ROM_B_A=8'd0;
		n_state=DECODE_DONE;
	end
	else begin
		Adder_mode=2'd3;PE1_IF_w=1'b0;PE2_IF_w=1'b0;PE3_IF_w=1'b0;PE1_W_w=1'b0;PE2_W_w=1'b0;PE3_W_w=1'b0;ROM_W_A=17'd0;
		SRAM_AB=13'd0;SRAM_AA=13'd0;ROM_IM_A=10'd0;ROM_B_A=8'd0;
		n_state=DECODE_DONE;
	end
end
//-------------------------------------------------------------------------
always@(*)begin
case(state)
CONV0_INIT:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b0;
	SRAM_WENB=1'b0;
	SRAM_CENB=1'b0;
	SRAM_CENA=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd0;
	MUX3_sel=1'd0;
	Decode_en=1'b0;
	Pool_en=1'd0;
	DONE=1'b0;
	end
	
//You should complete this part
CONV0_READ_W:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	Pool_en=1'b0;
	ROM_IM_OE=1'b1;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_WENB=1'b0;
	SRAM_CENB=1'b0;
	SRAM_CENA=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd0;
	MUX3_sel=1'd1;// psum==0
	//clear=1'b0;
	DONE=1'b0;
	Decode_en=1'b0;
	end
CONV0_WRITE:begin
	ROM_IM_CS=1'b0;
	ROM_W_CS=1'b0;
	ROM_B_CS=1'b1;
	Pool_en=1'b0;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	SRAM_CENA=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd0;// do passing relu
	MUX3_sel=1'd1;
	//clear=1'b0;
	DONE=1'b0;
	Decode_en=1'b0;
	end
CONV0_READ_C:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	Pool_en=1'b0;
	ROM_IM_OE=1'b1;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	SRAM_WENB=1'b0;
	SRAM_CENB=1'b0;
	SRAM_CENA=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd0;
	MUX3_sel=1'd1;// psum==0
	//clear=1'b0;
	DONE=1'b0;
	Decode_en=1'b0;
	end
CONV0_READ_9:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	Pool_en=1'b0;
	ROM_IM_OE=1'b1;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	SRAM_WENB=1'b0;
	SRAM_CENB=1'b0;
	SRAM_CENA=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd0;
	MUX3_sel=1'd1;// psum==0
	//clear=1'b0;
	DONE=1'b0;
	Decode_en=1'b0;
	end
CONV0_DONE:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	Pool_en=1'b0;
	SRAM_WENB=1'b0;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd2;
	MUX3_sel=1'd1;
	//clear=1'b0;
	DONE=1'b0;
	Decode_en=1'b0;
	end
//------------------------------------------------------------------------------------------	
POOLING1_READ:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	ROM_B_OE=1'b1;
	ROM_W_OE=1'b0;
	ROM_IM_OE=1'b0;
	Pool_en=1'b1;
	SRAM_CENA=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	MUX1_sel=1'b0;
	MUX2_sel=2'd2;
	MUX3_sel=1'd1;
	DONE=1'b0;
	Decode_en=1'b0;
	end
POOLING1_WRITE:begin
	ROM_IM_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_B_CS=1'b1;
	ROM_B_OE=1'b1;
	ROM_W_OE=1'b0;
	ROM_IM_OE=1'b0;
	Pool_en=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	MUX1_sel=1'b0;
	MUX2_sel=2'd2;
	MUX3_sel=1'd1;
	DONE=1'b0;
	Decode_en=1'b0;
	end
//------------------------------------------------------------------------------------------
CONV2_INIT:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_WENB=1'b0;
	SRAM_CENB=1'b0;
	SRAM_CENA=1'b1;
	MUX1_sel=1'd1;
	if(channel==5'd6)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'd0;
	DONE=1'b0;
	end
CONV2_READ_W:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_WENB=1'b0;
	SRAM_CENB=1'b0;
	SRAM_CENA=1'b1;
	MUX1_sel=1'd1;
	if(channel==5'd6)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'd1; 
	DONE=1'b0;
	end
CONV2_WRITE:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	SRAM_CENA=1'b0;
	MUX1_sel=1'd1;
	if(channel==5'd6)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'b0;
	DONE=1'b0;
	end
CONV2_READ_C:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	SRAM_CENA=1'b1;
	MUX1_sel=1'd1;
	if(channel==5'd6)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'b0;
	DONE=1'b0;
	end
CONV2_READ_9:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	SRAM_CENA=1'b1;
	MUX1_sel=1'd1;
	if(channel==5'd6)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'b0;
	DONE=1'b0;
	end
CONV2_DONE:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	SRAM_WENB=1'b0;
	SRAM_CENA=1'b0; //before pooling
	SRAM_CENB=1'b0;
	MUX1_sel=1'b1;
	MUX2_sel=2'd2;  //before pooling
	MUX3_sel=1'b1;
	DONE=1'b0;
	end
//----------------------------------------------------------------------------------------------------
POOLING2_READ:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b1;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	SRAM_CENA=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	MUX1_sel=1'd1;
	MUX2_sel=2'd2;
	MUX3_sel=1'd1;
	DONE=1'b0;
	end
POOLING2_WRITE:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	Decode_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	MUX1_sel=1'd1;
	MUX2_sel=2'd2;
	MUX3_sel=1'd1;
	DONE=1'b0;
	end
//-----------------------------------------------------------------------------------------------------
FC4_INIT:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	if(FC4_ADD_counter==8'd59)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'b0;
	Decode_en=1'b0;
	Pool_en=1'b0;
	DONE=1'b0;
	end
FC4_READ_W:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	if(FC4_ADD_counter==8'd59)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'd0; 
	Decode_en=1'b0;
	Pool_en=1'b0;
	DONE=1'b0;
	end
FC4_WRITE:begin
	ROM_IM_CS=1'b1;
	Pool_en=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	MUX1_sel=1'b1;
	if(FC4_ADD_counter==8'd59)
		MUX2_sel=2'd0;
	else
		MUX2_sel=2'd1;
	MUX3_sel=1'd0;
	Decode_en=1'b0;
	DONE=1'b0;
	end
FC4_DONE:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd1;
	MUX3_sel=1'b0;
	Decode_en=1'b0;
	DONE=1'b0;
	Pool_en=1'b0;
	end
//---------------------------------------------------------------------------------------------------
FC5_INIT:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd1;
	MUX3_sel=1'b0;
	Decode_en=1'b0;
	Pool_en=1'b0;
	DONE=1'b0;
	end
FC5_READ_W:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd1;
	MUX3_sel=1'd0; //add Psum
	Decode_en=1'b0;
	Pool_en=1'b0;
	DONE=1'b0;
	end
FC5_WRITE:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd1;
	MUX3_sel=1'd0; //add Psum
	Decode_en=1'b0;
	Pool_en=1'b0;
	DONE=1'b0;
	end
FC5_DONE:begin
	ROM_IM_CS=1'b1;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_B_CS=1'b1;
	ROM_W_CS=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd1;
	MUX3_sel=1'b1;
	Decode_en=1'b0;
	Pool_en=1'b0;
	DONE=1'b0;
	end
//-------------------------------------------------------------------
DECODE_INIT:begin
	ROM_IM_CS=1'b0;
	ROM_W_CS=1'b0;
	ROM_B_CS=1'b0;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd3;
	MUX3_sel=1'b1;
	Decode_en=1'b1;
	Pool_en=1'b0;
	DONE=1'b0;
	end
DECODE_READ_W:begin
	Pool_en=1'b0;
	ROM_IM_CS=1'b0;
	ROM_W_CS=1'b0;
	ROM_B_CS=1'b0;
	SRAM_CENA=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd3;
	MUX3_sel=1'b1;
	Decode_en=1'b1;
	DONE=1'b0;
	end
DECODE_WRITE:begin
	ROM_IM_CS=1'b0;
	ROM_W_CS=1'b0;
	ROM_B_CS=1'b0;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b1;
	SRAM_WENB=1'b1;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd3;
	MUX3_sel=1'b1;
	Decode_en=1'b1;
	Pool_en=1'b0;
	DONE=1'b0;
	end
DECODE_DONE:begin
	ROM_IM_CS=1'b0;
	ROM_W_CS=1'b0;
	ROM_B_CS=1'b0;
	SRAM_CENA=1'b0;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b1;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd3;
	MUX3_sel=1'b1;
	Decode_en=1'b1;
	Pool_en=1'b0;
	DONE=1'b1;
	end
default:begin
	Decode_en=1'b0;
	Pool_en=1'b0;
	ROM_IM_CS=1'b0;
	ROM_W_CS=1'b0;
	ROM_B_CS=1'b0;
	ROM_IM_OE=1'b0;
	ROM_W_OE=1'b0;
	ROM_B_OE=1'b1;
	MUX1_sel=1'b1;
	MUX2_sel=2'd3;
	MUX3_sel=1'b1;
	SRAM_CENB=1'b0;
	SRAM_WENB=1'b0;
	SRAM_CENA=1'b0;
	DONE=1'b0;
	end
endcase
end
/*conv0 end*/

	
endmodule
