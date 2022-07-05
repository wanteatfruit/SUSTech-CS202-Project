`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/22 00:52:14
// Design Name: 
// Module Name: Switch
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


module Switch(clk, rst, SwitchCtrlLow,SwitchCtrlHigh,switch_wdata, switch_rdata);
    input clk;			       //  时钟信号
    input rst;			       //  复位信号
    input SwitchCtrlLow;
    input SwitchCtrlHigh;
    output [15:0] switch_wdata;	     //  传入给memorio的data
    input [23:0] switch_rdata;		    //  从板上读的24位开关数据
    reg [15:0] switch_wdata;
    always@(negedge clk or posedge rst) begin
        if(rst) begin
            switch_wdata <= 0;
        end
		else	if(SwitchCtrlLow==1'b1)begin
				switch_wdata[15:0] <= switch_rdata[15:0];   // data output,lower 16 bits non-extended
				end
		else if(SwitchCtrlHigh==1'b1)begin
				switch_wdata[15:0] <= { 8'h00, switch_rdata[23:16] }; //data output, upper 8 bits extended with zero
				end
		else begin
            switch_wdata <= switch_wdata;
        end
    end
endmodule
