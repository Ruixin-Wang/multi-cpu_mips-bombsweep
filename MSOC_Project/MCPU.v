`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:56:34 05/12/2020 
// Design Name: 
// Module Name:    MCPU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:  
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MCPU(
    input INT,
    input clk,
    input reset,
    input MIO_ready,
    input [31:0] Data_in,
    output mem_w,
    output [31:0] PC_out,
    output [31:0] inst_out,
    output [31:0] Data_out,
    output [31:0] Addr_out,
    output CPU_MIO,
    output [4:0] state
    );
	 
	 wire MemRead, MemWrite, IorD, Sign,
			IRWrite, RegWrite, PCWrite,
			PCWriteCond, Branch, zero, overflow;
	 wire [1:0] RegDst;
	 wire [1:0] DatatoReg;
	 wire [1:0] ALUSrcA, ALUSrcB;
	 wire [1:0] PCSource;
	 wire [2:0] ALU_operation;
	 
	 
	 MCtrl Control ( 
			.clk(clk),
			.reset(reset),
			.zero(zero),
			.overflow(overflow),
			.MIO_ready(MIO_ready),
			.Inst_in(inst_out),
			.mem_w(mem_w),
			.CPU_MIO(CPU_MIO),
			.IorD(IorD),
			.IRWrite(IRWrite),
			.RegWrite(RegWrite),
			.ALUSrcA(ALUSrcA),
			.PCWrite(PCWrite),
			.PCWriteCond(PCWriteCond),
			.Branch(Branch),
			.RegDst(RegDst),
			.DatatoReg(DatatoReg),
			.ALUSrcB(ALUSrcB),
			.PCSource(PCSource),
			.ALU_operation(ALU_operation),
			.state_out(state),
			.Sign(Sign)
			);

	 MDPath Datapath (
			.clk(clk),
			.reset(reset),
			.MIO_ready(MIO_ready),
			.IorD(IorD),
			.IRWrite(IRWrite),
			.RegWrite(RegWrite),
			.ALUSrcA(ALUSrcA),
			.PCWrite(PCWrite),
			.PCWriteCond(PCWriteCond),
			.Branch(Branch),
			.RegDst(RegDst),
			.DatatoReg(DatatoReg),
			.ALUSrcB(ALUSrcB),
			.PCSource(PCSource),
			.ALU_operation(ALU_operation),
			.data2CPU(Data_in),
			.zero(zero),
			.overflow(overflow),
			.PC_Current(PC_out),
			.Inst(inst_out),
			.data_out(Data_out),
			.M_addr(Addr_out),
			.Sign(Sign)
			);

endmodule
