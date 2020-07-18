`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:15:31 05/15/2020 
// Design Name: 
// Module Name:    MDPath 
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
module     MDPath(input clk,
					   input reset,
					   input MIO_ready,		
					   input IorD,
					   input IRWrite,
					   input [1:0] RegDst,
					   input RegWrite,
					   input [1:0]DatatoReg,
					   input [1:0]ALUSrcA,
					   input [1:0]ALUSrcB,
					   input [1:0]PCSource,
					   input PCWrite,
					   input PCWriteCond,	
					   input Branch,
						input Sign,
					   input [2:0] ALU_operation,
					  
					   output[31:0]PC_Current,
					   input [31:0]data2CPU,
					   output[31:0]Inst,
					   output[31:0]data_out,
					   output[31:0]M_addr,
					  
					   output zero,
					   output overflow
					  );	
					  
		// Instruction Fetch
		reg[31:0] PC, ALUOut;
		wire[31:0] Inst, Imm_32;			  
		assign M_addr = IorD ? ALUOut : PC;
		assign PC_Current = PC;
		reg[31:0] IR;
		always @(posedge clk or posedge reset) begin
			if (reset) IR <= 32'h00000000;
			else if (IRWrite) IR <= data2CPU;
				else IR <= IR;
		end 
		assign Inst = IR;
		wire[4:0] rs, rt, rd;
		wire[15:0] Imm_16;
		wire[25:0] Imm_26;
		wire[31:0] offset;
		assign rs = Inst[25:21];
		assign rt = Inst[20:16];
		assign rd = Inst[15:11];
		
		assign Imm_16 = Inst[15:0];
		assign Imm_26 = Inst[25:0];
		assign Imm_32 = Sign ? {{16{Inst[15]}},Inst[15:0]} : {16'b0,Inst[15:0]};
		assign offset = {Imm_32[29:0], 2'b00};
		
		
		// Register Write
		reg[4:0] Wt_addr;
		always @* begin	
			case (RegDst)
				2'b00: Wt_addr = rt;
				2'b01: Wt_addr = rd;
				2'b10: Wt_addr = 5'd31;
				2'b11: Wt_addr = 5'd31;
			endcase
		end 
		reg[31:0] Wt_data;
		reg[31:0] MDR;
		wire[31:0] lui = {Inst[15:0], 16'd0};
		always @* begin	
			case (DatatoReg)
				2'b00: Wt_data = ALUOut;
				2'b01: Wt_data = MDR;
				2'b10: Wt_data = lui;
				2'b11: Wt_data = PC_Current;
			endcase
		end 
		
		// Register Read
		wire[31:0] rdata_A, rdata_B;
		Regs U2 (
			.clk(clk), 
			.rst(reset), 
			.L_S(RegWrite), 
			.R_addr_A(rs), 
			.R_addr_B(rt), 
			.Wt_addr(Wt_addr), 
			.Wt_data(Wt_data), 
			.rdata_A(rdata_A), 
			.rdata_B(rdata_B)
		);
		
		// ALU Execution
		reg[31:0] ALU_A;
		reg[31:0] ALU_B;
		always @* begin
			case (ALUSrcA)
				2'b00: ALU_A = PC_Current;
				2'b01: ALU_A = rdata_A;
				2'b10: ALU_A = data_out;
				2'b11: ALU_A = 32'h0;
			endcase
			case (ALUSrcB)
				2'b00: ALU_B = rdata_B;
				2'b01: ALU_B = 32'h4;
				2'b10: ALU_B = Imm_32;
				2'b11: ALU_B = offset;
			endcase
		end
		wire[31:0] res;
		ALU U1 (
			.A(ALU_A), 
			.B(ALU_B), 
			.ALU_operation(ALU_operation), 
			.right(Imm_32[1]), 
			.sign(Imm_32[0]), 
			.res(res), 
			.Co( ), 
			.zero(zero), 
			.overflow(overflow)
		);
		always @(posedge clk) begin
			ALUOut <= res;
		end
		// Memory Access
		assign data_out = rdata_B;
		
		always @(posedge clk) begin
			MDR <= data2CPU;
		end
		
		// PC Stream
		wire[31:0] Jump_addr, PCBranch;
		assign PCPlus4 = res;
		assign Jump_addr = {PC_Current[31:28], Imm_26, 2'b00};
		assign PCBranch = ALUOut;
		reg[31:0] PC_next;
		always @* begin
			case (PCSource)
				2'b00: PC_next = res;
				2'b01: PC_next = ALUOut;
				2'b10: PC_next = Jump_addr;
				2'b11: PC_next = ALUOut;
			endcase
		end 
		wire CE;
		assign CE = MIO_ready & (PCWrite | (PCWriteCond & (Branch ^~ zero)));
		always @(posedge clk or posedge reset) begin
			if (reset) PC <= 32'h0;
			else if (CE) PC <= PC_next;
				else PC <= PC;
		end
		
endmodule
