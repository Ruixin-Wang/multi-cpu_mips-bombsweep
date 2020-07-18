`timescale 1ns / 1ps
module Top(
	input [3:0] BTN_y,
   input clk_100mhz,
   input RSTN,
   input [15:0] SW,
	input PS2_clk,
	input PS2_data,
   output [3:0] AN,
   output [4:0] BTN_x,
   output Buzzer,
   output CR,
   output [7:0] LED,
   output led_clk,
   output led_clrn,
   output LED_PEN,
   output led_sout,
   output RDY,
   output readn,
   output [7:0] SEGMENT,
   output seg_clk,
   output seg_clrn,
   output SEG_PEN,
   output seg_sout,
	output [3:0] Blue, Red, Green,
	output HSYNC, VSYNC
	);
   
   wire [31:0] Addr_out;
   wire [31:0] Ai;
   wire [31:0] Bi;
   wire [7:0] blink;
   wire [3:0] BTN_OK;
   wire Clk_CPU;
   wire [31:0] Counter_out;
   wire [31:0] CPU2IO;
   wire [31:0] Data_in;
   wire [31:0] Data_out;
   wire [31:0] Disp_num;
   wire [31:0] Div;
   wire GPIOF0;
   wire [31:0] inst;
   wire IO_clk;
   wire [7:0] LE_out;
   wire [31:0] PC;
   wire [7:0] point_out;
   wire [3:0] Pulse;
   wire rst;
   wire [15:0] SW_OK;
   wire [4:0] Dinline;
   wire invClk_CPU;
   wire mem_w_line;
	wire mem_r_line;
   wire [31:0] Data_in_line;
   wire [31:0] Data_out_line;
   wire [31:0] dina4RAMline;
   wire [0:0] wealine;
   wire [17:0] ram;
   wire [31:0] douta4RAM;
   wire counter_weline;
   wire [1:0] counter_setline;
   wire GPIOf_weline;
   wire [15:0] led_outline;
   wire counter2_outline;
   wire counter1_outline;
   wire intline;
   wire [31:0] peripheral_inline;
   wire GPIOe_weline;
	wire [4:0] State;
	wire ps2_ready;
	wire vram_we;
	wire [15:0] vga_data, vram_data_out, vram_data_in;
	wire [8:0] row_addr;
	wire [9:0] col_addr;
	wire [18:0] vram_r_addr, vram_w_addr;
	wire [9:0] PS2_key;
	wire ps2_rdn;
	wire RDY_DUMMY;
   wire readn_DUMMY;
   assign RDY = RDY_DUMMY;
   assign readn = readn_DUMMY;
	assign invClk_CPU = ~Clk_CPU;
	assign IO_clk = ~Clk_CPU;
	wire [31:0] Cpu_data4bus_kbd;
	
					 
   SEnter_2_32  M4 (.BTN(BTN_OK[2:0]), 
                   .clk(clk_100mhz), 
                   .Ctrl({SW_OK[7:5], SW_OK[15], SW_OK[0]}), 
                   .Din(Dinline[4:0]), 
                   .D_ready(RDY_DUMMY), 
                   .Ai(Ai[31:0]), 
                   .Bi(Bi[31:0]), 
                   .blink(blink[7:0]), 
                   .readn(readn_DUMMY));
						 
   RAM_B  U3 (.addra(ram[17:0]), 
             .clka(invClk_CPU), 
             .dina(dina4RAMline[31:0]), 
             .wea(wealine[0]), 
             .douta(douta4RAM[31:0]));
				 
   MIO_BUS  U4 (.addr_bus(Addr_out[31:0]), 
               .BTN(BTN_OK[3:0]), 
               .clk(clk_100mhz), 
               .counter_out(Counter_out[31:0]), 
               .counter0_out(intline), 
               .counter1_out(counter1_outline), 
               .counter2_out(counter2_outline), 
					.ps2_ready(ps2_ready),
               .Cpu_data2bus(Data_out_line[31:0]),
               .led_out(led_outline[15:0]), 
               .mem_w(mem_w_line), 
					.mem_r(mem_r_line),
               .ram_data_out(douta4RAM[31:0]), 
               .rst(rst), 
               .SW(SW_OK[15:0]), 
               .counter_we(counter_weline), 
               .Cpu_data4bus(Data_in_line[31:0]), 
               .data_ram_we(wealine[0]), 
               .GPIOe0000000_we(GPIOe_weline), 
               .GPIOf0000000_we(GPIOf_weline), 
               .Peripheral_in(peripheral_inline[31:0]), 
               .ram_addr(ram[17:0]), 
               .ram_data_in(dina4RAMline[31:0]),
					.vram_we(vram_we), .vram_data(vram_data_in), .vram_addr(vram_w_addr),
					.ps2kb_rd(ps2_rdn),
					.ps2kb_key(PS2_key),
					.Cpu_data4bus_kbd(Cpu_data4bus_kbd));
					
   Multi_8CH32  U5 (.clk(IO_clk), 
                   .Data0(peripheral_inline[31:0]), 
                   .data1({{22{1'b0}}, ps2kb_key}), 
                   .data2(inst[31:0]), 
                   .data3(Counter_out[31:0]), 
                   .data4(Addr_out[31:0]), 
                   .data5(Data_out_line[31:0]), 
                   .data6(Data_in_line[31:0]), 
                   .data7(PC[31:0]), 
                   .EN(GPIOe_weline), 
                   .LES(64'b0), 
                   .point_in({Div[31:0], Div[31:0]}), 
                   .rst(rst), 
                   .Test(SW_OK[7:5]), 
                   .Disp_num(Disp_num[31:0]), 
                   .LE_out(LE_out[7:0]), 
                   .point_out(point_out[7:0]));
						 
   SSeg7_Dev  U6 (.clk(clk_100mhz), 
                  .flash(Div[25]), 
                  .Hexs(Disp_num[31:0]), 
                  .LES(LE_out[7:0]), 
                  .point(point_out[7:0]), 
                  .rst(rst), 
                  .Start(Div[20]), 
                  .SW0(SW_OK[0]), 
                  .seg_clk(seg_clk), 
                  .seg_clrn(seg_clrn), 
                  .SEG_PEN(SEG_PEN), 
                  .seg_sout(seg_sout));
									
   SPIO  U7 (.clk(IO_clk), 
            .EN(GPIOf_weline), 
            .P_Data(peripheral_inline[31:0]), 
            .rst(rst), 
            .Start(Div[20]), 
            .counter_set(counter_setline[1:0]), 
            .GPIOf0(), 
            .led_clk(led_clk), 
            .led_clrn(led_clrn), 
            .LED_out(led_outline[15:0]), 
            .LED_PEN(LED_PEN), 
            .led_sout(led_sout));
				
   clk_div  U8 (.clk(clk_100mhz), 
               .rst(rst), 
               .SW2(SW_OK[2]), 
               .clkdiv(Div[31:0]), 
               .Clk_CPU(Clk_CPU));
					
   SAnti_jitter  U9 (.clk(clk_100mhz), 
                    .Key_y(BTN_y[3:0]), 
                    .readn(readn_DUMMY), 
                    .RSTN(RSTN), 
                    .SW(SW[15:0]), 
                    .BTN_OK(BTN_OK[3:0]), 
                    .CR(CR), 
                    .Key_out(Dinline[4:0]), 
                    .Key_ready(RDY_DUMMY), 
                    .Key_x(BTN_x[4:0]), 
                    .pulse_out(Pulse[3:0]), 
                    .rst(rst), 
                    .SW_OK(SW_OK[15:0]));
						  
   Counter_x  U10 (.clk(IO_clk), 
                  .clk0(Div[6]), 
                  .clk1(Div[9]), 
                  .clk2(Div[11]), 
                  .counter_ch(counter_setline[1:0]), 
                  .counter_val(peripheral_inline[31:0]), 
                  .counter_we(counter_weline), 
                  .rst(rst), 
                  .counter_out(Counter_out[31:0]), 
                  .counter0_OUT(intline), 
                  .counter1_OUT(counter1_outline), 
                  .counter2_OUT(counter2_outline));
						
   Seg7_Dev  U61 (.flash(Div[25]), 
                  .Hexs(Disp_num[31:0]), 
                  .LES(LE_out[7:0]), 
                  .point(point_out[7:0]), 
                  .Scan({SW_OK[1], Div[19:18]}), 
                  .SW0(SW_OK[0]), 
                  .AN(AN[3:0]), 
                  .SEGMENT(SEGMENT[7:0]));
						
   PIO  U71 (.clk(IO_clk), 
            .EN(GPIOF0), 
            .PData_in(CPU2IO[31:0]), 
            .rst(rst), 
            .counter_set(), 
            .GPIOf0(), 
            .LED_out(LED[7:0]));
				
	MCPU  U1 (.clk(Clk_CPU), 
             .Data_in(Data_in_line[31:0]), 
             .inst_out(inst[31:0]), 
             .INT(intline), 
             .MIO_ready(1'b1), 
             .reset(rst), 
             .Addr_out(Addr_out[31:0]), 
             .CPU_MIO(), 
             .Data_out(Data_out_line[31:0]), 
             .mem_w(mem_w_line), 
             .PC_out(PC[31:0]),
				 .state(State[4:0]));
	
	VGA  U11(.clk(Div[1]),
				.rst(rst),
				.Din(vga_data),
				.row(row_addr),
				.col(col_addr),
				.rdn(),.R(Red),
				.G(Green),
				.B(Blue),
				.HS(HSYNC),
				.VS(VSYNC));
	
	VGAaddr  U12(.clk(Div[1]), 
					 .row(row_addr), 
					 .col(col_addr), 
					 .vram_addr(vram_r_addr), 
					 .vram_data(vram_data_out), 
					 .vga_data(vga_data));
	
	VRAM VRAM(.clka(clk_100mhz), 
				 .wea(vram_we), 
				 .addra(vram_w_addr), 
				 .dina(vram_data_in), 
				 .clkb(Div[1]), 
				 .addrb(vram_r_addr), 
				 .doutb(vram_data_out));
	
	PS2 U13(.clk(clk_100mhz), 
			  .rst(rst), 
			  .ps2_clk(PS2_clk), 
			  .ps2_data(PS2_data), 
			  .data_out(PS2_key), 
			  .ready());
	
endmodule
