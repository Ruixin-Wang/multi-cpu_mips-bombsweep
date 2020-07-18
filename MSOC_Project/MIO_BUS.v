`timescale 1ns / 1ps
module MIO_BUS(input clk,
					input rst,
					input[3:0]BTN,
					input[15:0]SW,
					input mem_w,
					input mem_r,
					input[31:0]Cpu_data2bus,				//data from CPU
					input[31:0]addr_bus,
					input[31:0]ram_data_out,
					input[15:0]led_out,
					input[31:0]counter_out,
					input counter0_out,
					input counter1_out,
					input counter2_out,
					input ps2_ready,
					
					output reg[31:0]Cpu_data4bus,				//write to CPU
					output reg[31:0]ram_data_in,				//from CPU write to Memory
					output reg[18:0]ram_addr,					//Memory Address signals
					output reg data_ram_we,
					output reg GPIOf0000000_we,				//PIOÐ´/SW¶Á
					output reg GPIOe0000000_we,				//Æß¶ÎÐ´
					output reg counter_we,						//counterÐ´ËÍ³£Êý
					output reg[31:0]Peripheral_in,
					
					output reg vram_we,
					output reg [15:0] vram_data,
					output reg [18:0] vram_addr,
					output reg ps2kb_rd,
					input [9:0] ps2kb_key,
					
					output reg [31:0] Cpu_data4bus_kbd
					);	

	reg data_ram_rd, GPIOf0000000_rd, GPIOe0000000_rd, counter_rd;
	
	
	wire counter_over; 

	always@(posedge clk) begin
		data_ram_we = 0; 
		data_ram_rd = 0; 
		counter_we = 0; 
		counter_rd = 0; 
		GPIOf0000000_we = 0; 
		GPIOe0000000_we = 0;
		GPIOf0000000_rd = 0; 
		GPIOe0000000_rd = 0; 
		ram_addr = 19'h0; 
		ram_data_in = 32'h0;
		Peripheral_in=32'h0;
		ps2kb_rd = 0;
		vram_we = 0; 
		vram_data = 12'h0;
		vram_addr = 19'h0;
		casex(addr_bus[31:8])
		24'h0xxxxx:begin // data_ram (00000000 - 00000ffc, actually lower 4KB RAM)
				data_ram_we = mem_w;
				ram_addr = addr_bus[20:2];
				ram_data_in = Cpu_data2bus;
				data_ram_rd = ~mem_w;
		end
		24'hfffffe:begin // Æß¶ÎÏÔÊ¾Æ÷ (e0000000 - efffffff, SSeg7_Dev)
				GPIOe0000000_we = mem_w;
				Peripheral_in = Cpu_data2bus;
				GPIOe0000000_rd = ~mem_w;
		end
		24'hffffff:begin // PIO (f0000000 - ffffffff0, 8 LEDs & counter, f000004-fffffff4)
				if(addr_bus[2])begin    //counter 
					counter_we = mem_w;
					Peripheral_in = Cpu_data2bus; 
					counter_rd = ~mem_w;
				end
				else begin     //LED
					GPIOf0000000_we = mem_w;
					Peripheral_in = Cpu_data2bus; //write Counter set & Initialization and light LED
					GPIOf0000000_rd = ~mem_w;
				end
		end
		24'hcxxxxx:begin // vram
				vram_we = mem_w;
				vram_addr = addr_bus[19:1];
				vram_data = Cpu_data2bus[31:16];
		end
		24'hffffdx:begin // keyborad
				ps2kb_rd = ~mem_w;
				Peripheral_in = Cpu_data2bus;
				Cpu_data4bus_kbd = {{22{1'b0}}, ps2kb_key};
		end
		default:begin;end
		
		endcase
	end
	
always @* begin
	Cpu_data4bus = 32'h0;
		casex({data_ram_rd,GPIOe0000000_rd,counter_rd,GPIOf0000000_rd,ps2kb_rd})
			8'b1xxxx: begin
				if (addr_bus[1] == 0) Cpu_data4bus = ram_data_out;
					else Cpu_data4bus = {ram_data_out[15:0], 16'h0};
			end 
			8'bx1xxx:Cpu_data4bus = counter_out;  //read from Counter
			8'bxx1xx:Cpu_data4bus = counter_out;  //read from Counter
			8'bxxx1x:Cpu_data4bus = {counter0_out,counter1_out,counter2_out,led_out[12:0],SW}; //read from SW & BTN
			8'bxxxx1:Cpu_data4bus = {{22{1'b0}}, ps2kb_key}; //read from keyborad

		endcase
end

endmodule

