`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/22 22:42:00
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb(

    );
    
    reg fpga_clk=1;
    
        reg fpga_rst = 1;
        
            reg [23:0]switch;
            
            wire [23:0]led;
            wire IOWriteTest;
            wire regWrite;
            wire memToReg;
            wire IORead;
            wire clk_out;
            wire lwTest;
            wire[31:0] ins;
            wire[31:0] res;
            wire[31:0] rd1;
            wire [31:0] rd2;
            wire[31:0] sign_ext;
                        wire[31:0] addr;
            wire[31:0] branch_base_addr;
            wire[15:0] sw_wdata;
            wire Branch;
            wire Zero;
            wire[13:0] rom;
            
            reg uart_start=0;
            wire uart_wen;
            wire tx;
            reg rx;
            wire[23:0] led_out;//17¸öledÊä³ö£¨²âÊÔ³¡¾°1£©
            reg[3:0] row;
            wire[3:0] col;
            wire[7:0] seg_out;
            wire[7:0] seg_en;
                        cpu_top t(fpga_clk,switch,fpga_rst,led_out,row,col,seg_out,seg_en,uart_start,rx,tx);
            

                always #5 begin
                    fpga_clk = ~fpga_clk;
                end
                
                initial begin
                #100 fpga_rst=1;
                #100 fpga_rst=0;
//                #20  uart_start=1;
//                      rx=1;     
                #200 switch=24'b0000_0000_0000_1111_1111_0000;
                end
                
                
endmodule
