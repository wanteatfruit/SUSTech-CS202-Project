`timescale 1ns / 1ps

module MemOrIO( mRead, mWrite, ioRead, ioWrite,addr_in, addr_out, m_rdata, io_rdata_switch,io_rdata_board, 
r_wdata, r_rdata, write_data,LEDCtrlLow,LEDCtrlHigh,SwitchCtrlLow,SwitchCtrlHigh,SegCtrl,BoardCtrl);
//Controller
input mRead; // read memory, from Controller
input mWrite; // write memory, from Controller
input ioRead; // read IO, from Controller
input ioWrite; // write IO, from Controller

input[31:0] addr_in; // from alu_result in ALU
output[31:0] addr_out; // address to Data-Memory

input[31:0] m_rdata; // data read from Data-Memory
input[15:0] io_rdata_switch; // data read from switch,16 bits
input[15:0] io_rdata_board; // data read from board,16 bits
output[31:0] r_wdata; // data to Decoder(register file)
input[31:0] r_rdata; // data read from Decoder(register file)
output [31:0] write_data; // data to memory or I/O（m_wdata, io_wdata）
output LEDCtrlLow; // LED Chip Select
output LEDCtrlHigh; // LED Chip Select
output SwitchCtrlLow;//拨码开关
output SwitchCtrlHigh;//拨码开关
output SegCtrl;//七段数码显示管
output BoardCtrl;//小键盘

wire[15:0] io_rdata;
wire[1:0] low_addr;
assign low_addr = addr_in[1:0];
assign io_rdata=(low_addr==2'b11)?io_rdata_board:io_rdata_switch;

assign addr_out = addr_in;

assign r_wdata = (mRead==1'b1)?m_rdata:{16'b0,io_rdata};

assign LEDCtrlLow = (ioWrite==1&&low_addr==2'b00)?1'b1:1'b0;
assign LEDCtrlHigh = (ioWrite==1&&low_addr==2'b10)?1'b1:1'b0;
assign SwitchCtrlLow = (ioRead==1&&low_addr==2'b00)?1'b1:1'b0;
assign SwitchCtrlHigh = (ioRead==1&&low_addr==2'b10)?1'b1:1'b0;
assign SegCtrl=(ioWrite==1&&low_addr==2'b11)?1'b1:1'b0;
assign BoardCtrl=(ioRead==1&&low_addr==2'b11)?1'b1:1'b0;
reg[31:0] write_data_reg;
always @* begin
    if ((mWrite == 1) || (ioWrite == 1)) begin
        write_data_reg = r_rdata;
    end
    else begin
        write_data_reg = 32'hZZZZZZZZ;
    end
end
assign write_data=write_data_reg;

endmodule
