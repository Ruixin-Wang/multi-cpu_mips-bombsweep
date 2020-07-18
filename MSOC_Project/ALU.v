`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:08:05 11/17/2019 
// Design Name: 
// Module Name:    ALU 
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
module ALU( input [31:0] A,
				input [31:0] B,
				input [2:0]  ALU_operation,
				input right,
				input sign,
				output[31:0] res,
				output Co,
				output zero,
				output overflow
    );
	 
	wire [31:0] Sum, Dif, And, Or, Slt, Xor, Nor, Sl;
	wire sub = ALU_operation[2];

/*
	ADC32	ADC_32(.a(A),
					 .b(B),
					 .C0(sub),
					 .s(Sum),
					 .Co(Co)
					 );
*/
			 
	assign And = A & B;
	assign Or  = A | B;
	assign Xor = A ^ B;
	assign Nor = ~(A | B);
	assign Sl = right ? (B >> A[4:0]) : (B << A[4:0]);
	assign Slt = $signed(A) < $signed(B) ? 1 : 0;
	assign Sum = $signed(A) + $signed(B);
	assign Dif = $signed(A) - $signed(B);
	
	MUX8T1_32	MUX1(.I0(And),
						  .I1(Or),
						  .I2(Sum),
						  .I3(Xor),
						  .I4(Nor),
						  .I5(Sl),
						  .I6(Dif),
						  .I7(Slt),
						  .sel(ALU_operation),
						  .o(res)
						  );
	
//	assign overflow = Co && sign;
	assign zero = ($signed(A) == $signed(B)) ? 1 : 0;

endmodule
