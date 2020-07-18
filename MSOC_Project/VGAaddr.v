`timescale 1ns / 1ps
module VGAaddr(	input clk,
				input [8:0] row,
				input [9:0] col,
				output reg [18:0] vram_addr,
				
				input [15:0] vram_data,
				output reg [15:0] vga_data
    );

always @(posedge clk) begin
		vram_addr <= col + 640 * row;
		vga_data <= vram_data;
end
endmodule
