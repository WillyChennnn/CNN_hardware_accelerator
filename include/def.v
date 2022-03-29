//=====================================
//Author:		Chen Yun-Ru (May)
//Filename:		def.v
//Description:	Parameters definition
//Version:		0.1
//=====================================

`ifndef DEF_V
`define DEF_V

//Global
`define DATA_BITS 16
`define INTERNAL_BITS 32

//ROM(Image)
`define ROM_IM_SIZE 1024 
`define ROM_IM_ADDR_BITS 10

//ROM(Weight)
`define ROM_W_SIZE 131072 
`define ROM_W_ADDR_BITS 17

//ROM(Bias)
`define ROM_B_SIZE 256 
`define ROM_B_ADDR_BITS 8

//Two port SRAM
`define SRAM_SIZE 8192  
`define SRAM_ADDR_BITS 13

`endif
