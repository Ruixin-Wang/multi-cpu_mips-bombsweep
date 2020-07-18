`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:47:54 05/15/2020 
// Design Name: 
// Module Name:    ADC32 
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
module ADC32( input [31:0] a,
				  input [31:0] b,
				  input C0,
				  output [31:0] s,
				  output Co
    );
	 
	 wire [31:0] bo, res;
	 assign bo = b ^ {32{C0}};
	 assign res = a + bo + C0;
	 assign Co = ((~a[31])&(~b[31])&(~C0)&s[31])|((a[31])&(b[31])&(~C0)&(~s[31]))
					|((~a[31])&(b[31])&(C0)&s[31])|((a[31])&(~b[31])&(C0)&(~s[31]));
	 assign s = res;
	 
endmodule
