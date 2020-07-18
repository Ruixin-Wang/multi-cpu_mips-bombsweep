`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:04:52 05/19/2020 
// Design Name: 
// Module Name:    MCtrl 
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
module MCtrl(
		input clk,
		input reset,
		input[31:0] Inst_in,
		input zero,
		input overflow,
		input MIO_ready,
		output reg[2:0]ALU_operation,
		output[4:0]state_out,
		output reg CPU_MIO,
		output reg Sign,
		output reg IorD,
		output reg IRWrite,
		output reg [1:0]RegDst,
		output reg RegWrite,
		output reg [1:0]DatatoReg,
		output reg [1:0]ALUSrcA,
		output reg [1:0]ALUSrcB,
		output reg [1:0]PCSource,
		output reg PCWrite,
		output reg PCWriteCond,
		output reg Branch,
		output reg mem_w
		);
		

		`define Datapath_signals {PCWrite, PCWriteCond, IorD, mem_w, IRWrite, DatatoReg, PCSource, ALUSrcA, ALUSrcB, RegWrite, RegDst, Branch, CPU_MIO, Sign}
		parameter 	  IF = 5'b00000,     ID = 5'b00001,    Ex_R = 5'b00010, Ex_Mem = 5'b00011,   Ex_I = 5'b00100,
					 WB_Lui = 5'b00101, Ex_beq = 5'b00110,  Ex_bne = 5'b00111,  Ex_jr = 5'b01000, Ex_jal = 5'b01001,
						Ex_j = 5'b01010, Mem_RD = 5'b01011,  Mem_WD = 5'b01100,   WB_R = 5'b01101,   WB_I = 5'b01110,
					  WB_LW = 5'b01111,  Error = 5'b11111, Ex_jalr = 5'b10000;
		parameter	AND = 3'b000, OR = 3'b001, ADD = 3'b010, SUB = 3'b110, NOR = 3'b100, XOR = 3'b011, SRL = 3'b101, SLT = 111;
		parameter   
			stateIF	 = 19'b1000100000001000011,
			stateID	 = 19'b0000000000011000001,
			stateR	 = 19'b0000000000100000001,	
			stateMem  = 19'b0000000000110000001,
			stateIs	 = 19'b0000000000110000001,
			stateIu	 = 19'b0000000000110000000,	
			stateLui  = 19'b0000010000111100001,
			stateBeq  = 19'b0100000010100000101,	
			stateBne  = 19'b0100000010100000001,
			stateJr	 = 19'b1000000000100000001,	
			stateJal  = 19'b1000011100011110001,
			stateJalr = 19'b1000011000100110001,
			stateJ	 = 19'b1000000100011000001,	
			stateRD   = 19'b0010000000000000011,
			stateWD	 = 19'b0011000000000000011,	
			stateWBR  = 19'b0000000000000101001,
			stateWBI  = 19'b0000000000110100001,	
			stateLW	 = 19'b0000001000000100001,
			stateSRL  = 19'b0000000001010000001;

					
		wire [5:0] Fun = Inst_in[5:0];
		wire [5:0] OP = Inst_in[31:26];
		reg [4:0] state;
		assign state_out = state;
		always @(posedge clk or posedge reset) begin
			if (reset) state <= IF;
			else 
				case (state)
					IF:		if (MIO_ready) state <= ID;
									else state <= IF;
					ID:		case (OP)
									6'b000000: begin
										case (Fun)
											6'h8: state <= Ex_jr;
											6'h9: state <= Ex_jalr;
											default: state <= Ex_R;
										endcase
									end
									6'b001000: state <= Ex_I;
									6'b001100: state <= Ex_I;
									6'b001101: state <= Ex_I;
									6'b001110: state <= Ex_I;
									6'b001010: state <= Ex_I;
									6'b001111: state <= WB_Lui;
									6'b100011: state <= Ex_Mem;
									6'b101011: state <= Ex_Mem;
									6'b000100: state <= Ex_beq;
									6'b000101: state <= Ex_bne;
									6'b000010: state <= Ex_j;
									6'b000011: state <= Ex_jal;
									default:   state <= Error;
								endcase 
					Ex_R: 	state <= WB_R;
					Ex_Mem:	case (OP)
									6'b100011: state <= Mem_RD;
									6'b101011: state <= Mem_WD;
									default:   state <= Error;
								endcase 
					Ex_I:		state <= WB_I;
					WB_Lui:	state <= IF;
					Ex_beq:	state <= IF;
					Ex_bne:	state <= IF;
					Ex_jr:	state <= IF;
					Ex_jal:	state <= IF;
					Ex_jalr:	state <= IF;
					Ex_j:		state <= IF;
					Mem_RD:	if (MIO_ready) state <= WB_LW;
									else state <= Mem_RD;
					Mem_WD:	if (MIO_ready) state <= IF;
									else state <= Mem_RD;
					WB_R:		state <= IF;
					WB_I:		state <= IF;
					WB_LW:	state <= IF;
					default: state <= Error;
				endcase 
		end 
		
		always @* begin
			case (state)
				IF:		begin `Datapath_signals = stateIF; ALU_operation = ADD; end
				ID:		begin `Datapath_signals = stateID; ALU_operation = ADD; end
				Ex_R:		begin 
								if ((Fun == 6'b000000) || (Fun == 6'b000010)) `Datapath_signals = stateSRL;
										else `Datapath_signals = stateR;
								case (Fun)
									6'b100000: ALU_operation = ADD;
									6'b100001: ALU_operation = ADD;
									6'b100010: ALU_operation = SUB;
									6'b100011: ALU_operation = SUB;
									6'b100100: ALU_operation = AND;
									6'b100101: ALU_operation = OR;
									6'b100110: ALU_operation = XOR;
									6'b100111: ALU_operation = NOR;
									6'b101010: ALU_operation = SLT;
									6'b000000: ALU_operation = SRL;
									6'b000010: ALU_operation = SRL;
									6'b000100: ALU_operation = SRL;
									6'b000110: ALU_operation = SRL;
									default  : ALU_operation = ADD;
								endcase 
							end
				Ex_Mem:	begin `Datapath_signals = stateMem; ALU_operation = ADD; end
				Ex_I:		begin 
								case (OP)
									6'b001000: begin ALU_operation = ADD; `Datapath_signals =stateIs; end 
									6'b001100: begin ALU_operation = AND; `Datapath_signals =stateIu; end 
									6'b001101: begin ALU_operation = OR;  `Datapath_signals =stateIu; end 
									6'b001110: begin ALU_operation = XOR; `Datapath_signals =stateIu; end 
									6'b001010: begin ALU_operation = SLT; `Datapath_signals =stateIs; end 
								endcase 
							end
				WB_Lui:	begin `Datapath_signals = stateLui; 	ALU_operation = ADD; end
				Ex_beq:	begin `Datapath_signals = stateBeq; 	ALU_operation = SUB; end
				Ex_bne:	begin `Datapath_signals = stateBne; 	ALU_operation = SUB; end
				Ex_jr:	begin `Datapath_signals = stateJr; 		ALU_operation = ADD; end
				Ex_jal:	begin `Datapath_signals = stateJal; 	ALU_operation = ADD; end
				Ex_jalr: begin `Datapath_signals = stateJalr; 	ALU_operation = ADD; end
				Ex_j:		begin `Datapath_signals = stateJ; 		ALU_operation = ADD; end
				Mem_RD:	begin `Datapath_signals = stateRD; 		ALU_operation = ADD; end
				Mem_WD:	begin `Datapath_signals = stateWD; 		ALU_operation = ADD; end
				WB_R:		begin `Datapath_signals = stateWBR; 	ALU_operation = ADD; end
				WB_I:		begin `Datapath_signals = stateWBI; 	ALU_operation = ADD; end
				WB_LW:	begin `Datapath_signals = stateLW; 		ALU_operation = ADD; end
			endcase 
		end
		
	
endmodule
