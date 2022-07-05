`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/22 23:04:32
// Design Name: 
// Module Name: memorio_tb
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


module memorio_tb(

    );
    
    reg mRead,mWrite,ioRead,ioWrite;
    reg[31:0] addr_in,m_rdata,r_rdata;
    reg[15:0] io_rdata_sw;
    reg[15:0] io_rdata_b;
    wire LEDCtrlHigh,LEDCtrlLow,SwitchCtrlHigh,SwitchCtrlLow;
    wire [31:0] addr_out,r_wdata,write_data;
    wire SegCtrl;
    wire BoardCtrl;
    
    
    MemOrIO m(mRead,mWrite,ioRead,ioWrite,addr_in,addr_out,m_rdata,io_rdata_sw,io_rdata_b,
    r_wdata,r_rdata,write_data,LEDCtrlLow,LEDCtrlHigh,SwitchCtrlLow,SwitchCtrlHigh,SegCtrl,BoardCtrl);
    
    
    
    initial begin // r_rdata -> m_wdata(write_data)
   m_rdata = 32'h0xffff_0001; io_rdata_sw = 32'h0xffff; r_rdata = 32'h0x0f0f_0f0f; addr_in = 32'h4;{mRead,mWrite,ioRead,ioWrite}=4'b01_00;#10 addr_in = 32'hffff_fc60; {mRead,mWrite,ioRead,ioWrite}= 4'b00_01; // r_rdata -> io_wdata(write_data)
    #10 addr_in = 32'h0000_0004; {mRead,mWrite,ioRead,ioWrite}= 4'b10_00; // m_rdata -> r_wdata
    #10 addr_in = 32'hffff_fc70; {mRead,mWrite,ioRead,ioWrite}= 4'b00_10; // io_rdata -> r_wdata(write_data)
    #10 $finish;
    end
    
    
endmodule
