`timescale 1ns/10ps

`define CYCLE 10 //Cycle time
`define MAX 48000000 //Max cycle number
`ifdef SYN
`include "top_syn.v"
`include "tsmc13_neg.v"
`else
`include "top.v"
`endif
`include "ROM/ROM.v"
`include "TwoPortSRAM/TwoPort_SRAM.v"
`include "def.v"

module top_tb;

	//top inputs
	reg clk;
	reg rst;
	reg START;
	
	wire [`DATA_BITS-1:0] ROM_IM_out;
	wire [`DATA_BITS-1:0] ROM_W_out;
	wire [`DATA_BITS-1:0] ROM_B_out;
	
	wire [`INTERNAL_BITS-1:0] SRAM_QA;	
	
	//top outputs	
	wire DONE;
	
	wire ROM_IM_OE,ROM_W_OE,ROM_B_OE;
	wire ROM_IM_CS,ROM_W_CS,ROM_B_CS;
	wire [`ROM_IM_ADDR_BITS-1:0] ROM_IM_A;
	wire [`ROM_W_ADDR_BITS-1:0] ROM_W_A;
	wire [`ROM_B_ADDR_BITS-1:0] ROM_B_A;
	
	wire [`SRAM_ADDR_BITS-1:0] SRAM_AA,SRAM_AB;
	wire SRAM_CENA,SRAM_CENB;
	wire SRAM_WENB;
	wire [`INTERNAL_BITS-1:0] SRAM_DB;	
	
	parameter GOLDEN_SIZE = 4704; 
	`ifdef SYN
	parameter RUN_TIMES = 10;
	`else
	parameter RUN_TIMES = 200;
	`endif
	
	reg [`INTERNAL_BITS-1:0] GOLDEN [0:(GOLDEN_SIZE-1)];
	reg [`INTERNAL_BITS-1:0] TRUE_LABEL [0:199];	

	integer i,gf,tf,count,exe_count,dff_count,golden_count,err;
	
	ROM ROM_IM(
		.CK(clk),
		.CS(ROM_IM_CS),
		.OE(ROM_IM_OE),
		.A(ROM_IM_A),
		.DO(ROM_IM_out)
	);
	defparam ROM_IM.ADDR_BITS = 10;
	defparam ROM_IM.MEM_SIZE = 1024;

	ROM ROM_W(
		.CK(clk),
		.CS(ROM_W_CS),
		.OE(ROM_W_OE),
		.A(ROM_W_A),
		.DO(ROM_W_out)
	);
	defparam ROM_W.ADDR_BITS = 17;
	defparam ROM_W.MEM_SIZE = 131072;

	ROM ROM_B(
		.CK(clk),
		.CS(ROM_B_CS),
		.OE(ROM_B_OE),
		.A(ROM_B_A),
		.DO(ROM_B_out)
	);
	defparam ROM_B.ADDR_BITS = 8;
	defparam ROM_B.MEM_SIZE = 256;

	TwoPort_SRAM TS(
		.CLKA(clk),
		.CLKB(clk),
		.CENA(SRAM_CENA),
		.CENB(SRAM_CENB),
		.WENB(SRAM_WENB),
		.AA(SRAM_AA),
		.AB(SRAM_AB),
		.DB(SRAM_DB),
		.QA(SRAM_QA)
	);
	
	top top(
		.clk(clk),
		.rst(rst),
		.START(START),
		.ROM_IM_out(ROM_IM_out),
		.ROM_W_out(ROM_W_out),
		.ROM_B_out(ROM_B_out),
		.SRAM_QA(SRAM_QA),
		.DONE(DONE),
		.ROM_IM_OE(ROM_IM_OE),
		.ROM_W_OE(ROM_W_OE),
		.ROM_B_OE(ROM_B_OE),
		.ROM_IM_CS(ROM_IM_CS),
		.ROM_W_CS(ROM_W_CS),
		.ROM_B_CS(ROM_B_CS),
		.ROM_IM_A(ROM_IM_A),
		.ROM_W_A(ROM_W_A),
		.ROM_B_A(ROM_B_A),
		.SRAM_AA(SRAM_AA),
		.SRAM_AB(SRAM_AB),
		.SRAM_CENA(SRAM_CENA),
		.SRAM_CENB(SRAM_CENB),
		.SRAM_WENB(SRAM_WENB),
		.SRAM_DB(SRAM_DB)
	);

	`ifdef SYN
	initial $sdf_annotate("../syn/top_syn.sdf",top); 
	`endif
	
	initial clk = 0;
	always #(`CYCLE/2) clk = ~clk;
	
	initial
	begin
		`ifdef conv0
		gf = $fopen("../golden/conv0.txt","r");
		golden_count = 0;
		while(!$feof(gf))
		begin
			count = $fscanf(gf,"%h\n",GOLDEN[golden_count]);
			golden_count = golden_count+1; 
		end
		`elsif pool1
		gf = $fopen("../golden/pool1.txt","r");
		golden_count = 0;
		while(!$feof(gf))
		begin
			count = $fscanf(gf,"%h\n",GOLDEN[golden_count]);
			golden_count = golden_count+1; 
		end		
		`else
		gf = $fopen("../golden/prediction.txt","r");
		golden_count = 0;
		while(!$feof(gf))
		begin
			count = $fscanf(gf,"%h\n",GOLDEN[golden_count]);
			golden_count = golden_count+1; 
		end
		$readmemh("../golden/true_labels.txt",TRUE_LABEL);		
		`endif
		$fclose(gf);
		
		//Read parameters
		$readmemh("../parameters/layer0_w.txt",ROM_W.Memory,0); 
		$readmemh("../parameters/layer2_w.txt",ROM_W.Memory,54); 
		$readmemh("../parameters/layer5_w.txt",ROM_W.Memory,864); 
		$readmemh("../parameters/layer6_w.txt",ROM_W.Memory,98064);		
		$readmemh("../parameters/layer0_b.txt",ROM_B.Memory,0); 
		$readmemh("../parameters/layer2_b.txt",ROM_B.Memory,6); 
		$readmemh("../parameters/layer5_b.txt",ROM_B.Memory,21); 
		$readmemh("../parameters/layer6_b.txt",ROM_B.Memory,201); 		
		
		//Execute the accelerator
		err = 0;
		dff_count = 0;
		
		`ifdef conv0
		//read image 0
		$readmemh("../data/test_im0.txt",ROM_IM.Memory,0);
		rst = 1; START=0;
		#(`CYCLE) rst=0; START=1;
		#(`CYCLE) START=0;

		while(!DONE)
			#(`CYCLE);

		for(i=0;i<golden_count;i=i+1)
		begin
			if(TS.Memory[i]!==GOLDEN[i])
			begin
				$display("SRAM[%4d] = %h, expect = %h",i,TS.Memory[i],GOLDEN[i]);
				err = err+1;
			end
			else
				$display("SRAM[%4d] = %h, pass",i,TS.Memory[i]);
		end
		show_result(err);
		`elsif pool1
		//read image 0
		$readmemh("../data/test_im0.txt",ROM_IM.Memory,0);
		rst = 1; START=0;
		#(`CYCLE) rst=0; START=1;
		#(`CYCLE) START=0;

		while(!DONE)
			#(`CYCLE);

		for(i=0;i<golden_count;i=i+1)
		begin
			if(TS.Memory[i+4704]!==GOLDEN[i])
			begin
				$display("SRAM[%4d] = %h, expect = %h",i+4704,TS.Memory[i+4704],GOLDEN[i]);
				err = err+1;
			end
			else
				$display("SRAM[%4d] = %h, pass",i+4704,TS.Memory[i+4704]);
		end
		show_result(err);		
		`else
		exe_count = 0;	
		while(exe_count<RUN_TIMES)
		begin
			//Read image
			$readmemh($sformatf("../data/test_im%0d.txt",exe_count),ROM_IM.Memory,0); 
			rst = 1; START = 0;
			#(`CYCLE) rst = 0; START = 1;
			#(`CYCLE) START = 0;		

			while(!DONE)
				#(`CYCLE);	

			if(TS.Memory[0]!==GOLDEN[exe_count])
			begin
				$display("Image %3d:",exe_count);
				$display("Predict = %0d, expect %0d", TS.Memory[0], GOLDEN[exe_count]);
				err = err+1;
			end
			else
			begin
				$display("Image %3d:",exe_count);
				$display("Predict = %0d, pass", TS.Memory[0]);	
				$display("True label = %0d", TRUE_LABEL[exe_count]);
				if(GOLDEN[exe_count]!=TRUE_LABEL[exe_count])
					dff_count = dff_count+1;
				else;
			end
			
			exe_count = exe_count+1;				
		end
		show_result(err,dff_count,RUN_TIMES);
		`endif	
		$finish;
	end
	
	task show_result;
		`ifdef full
		input integer err;
		input integer dff_count;
		input integer golden_count;
		
		if (err == 0)
		begin
			$display("\n");
			$display("\n");
			$display("        ****************************               ");
			$display("        **                        **               ");
			$display("        **  Congratulations !!    **       		 ");
			$display("        **                        **     			 ");
			$display("        **  Simulation PASS!!     **   			 ");
			$display("        **                        **   			 ");
			$display("        ****************************   			 ");
			$display("\n");
			$display("Accuracy = %4f %",(1-$bitstoreal(dff_count)/$bitstoreal(golden_count))*100);
		end
		else
		begin
			$display("\n");
			$display("\n");
			$display("        ****************************               ");
			$display("        **                        **        		 ");
			$display("        **  OOPS!!                **       		 ");
			$display("        **                        **     			 ");
			$display("        **  Simulation Failed!!   **   			 ");
			$display("        **                        **   			 ");
			$display("        ****************************  			 ");
			$display("         Totally has %d errors                     ", err); 
			$display("\n");
		end			
		`else
		input integer err;
		
		if (err == 0)
		begin
			$display("\n");
			$display("\n");
			$display("        ****************************               ");
			$display("        **                        **               ");
			$display("        **  Congratulations !!    **       		 ");
			$display("        **                        **     			 ");
			$display("        **  Simulation PASS!!     **   			 ");
			$display("        **                        **   			 ");
			$display("        ****************************   			 ");
			$display("\n");
		end
		else
		begin
			$display("\n");
			$display("\n");
			$display("        ****************************               ");
			$display("        **                        **        		 ");
			$display("        **  OOPS!!                **       		 ");
			$display("        **                        **     			 ");
			$display("        **  Simulation Failed!!   **   			 ");
			$display("        **                        **   			 ");
			$display("        ****************************  			 ");
			$display("         Totally has %d errors                     ", err); 
			$display("\n");
		end			
		`endif
	endtask
	
	initial
	begin
		#(`CYCLE*`MAX);
		$display("\n");
		$display("\n");
		$display("        ****************************               ");
		$display("        **                        **        		 ");
		$display("        **  OOPS!!                **       		 ");
		$display("        **                        **     			 ");
		$display("        **  Simulation Time Out!! **   			 ");
		$display("        **                        **   			 ");
		$display("        ****************************  			 ");
		$display("         Please check your code                    "); 
		$display("\n");
		$finish;
	end
	
	//Dump fsdb file
	initial
	begin
		`ifdef FSDB
			$fsdbDumpfile("top.fsdb");
			$fsdbDumpvars(0,top,"+struct");  
		`endif
	end

endmodule
