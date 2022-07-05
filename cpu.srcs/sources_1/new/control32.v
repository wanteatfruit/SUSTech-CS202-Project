`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/18 20:51:07
// Design Name: 
// Module Name: control32
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


module control32(Opcode, Function_opcode, Jr, RegDST, ALUSrc, MemorIOtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp, Alu_resultHigh,MemRead,IORead,IOWrite);
    input[5:0]   Opcode;            // 来自IFetch模块的指令高6bit, instruction[31..26]
input[5:0]   Function_opcode;      // 来自IFetch模块的指令低6bit, 用于区分r-类型中的指令, instructions[5..0]
output       Jr;              // 为1表明当前指令是jr, 为0表示当前指令不是jr
output       RegDST;          // 为1表明目的寄存器是rd, 否则目的寄存器是rt
output       ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）是立即数（beq, bne除外）, 为0时表示第二个操作数来自寄存器
output       MemorIOtoReg;     // 为1表明需要从存储器或I/O读数据到寄存器
output       RegWrite;         // 为1表明该指令需要写寄存器
output       MemWrite;       // 为1表明该指令需要写存储器
output       Branch;        // 为1表明是beq指令, 为0时表示不是beq指令
output       nBranch;       // 为1表明是Bne指令, 为0时表示不是bne指令
output       Jmp;            // 为1表明是J指令, 为0时表示不是J指令
output       Jal;            // 为1表明是Jal指令, 为0时表示不是Jal指令
output       I_format;      // 为1表明该指令是除beq, bne, LW, SW之外的其他I-类型指令
output       Sftmd;         // 为1表明是移位指令, 为0表明不是移位指令
output[1:0]  ALUOp;        // 是R-类型或I_format=1时位1（高bit位）为1,  beq、bne指令则位0（低bit位）为1
//IO
input [21:0] Alu_resultHigh;
output MemRead;
output IORead;
output IOWrite;
//output lwTest;
/* if the instruction is R-type or I_format, ALUOp is 2'b10
if the instruction is"beq" or "bne", ALUOp is 2'b01
if the instruction is"lw" or "sw", ALUOp is 2'b00*/


wire R_format = (Opcode==6'B000000) ? 1'B1 : 1'B0;
wire lw,sw;
assign Jr = (Opcode==6'B000000 && Function_opcode==6'B001000)?1'B1:1'B0;
assign Jmp = (Opcode==6'B000010)?1'B1:1'B0;
assign Jal = (Opcode==6'B000011)?1'B1:1'B0;
wire I_format0 = (R_format==1'B1 || Jr==1'B1 || Jmp==1'B1 || Jal==1'B1)?1'B0:1'B1;//immediate type
assign sw = (Opcode==6'b101011)?1'b1:1'b0;//sw
assign lw = (Opcode==6'b100011)?1'b1:1'b0;//lw
assign RegDST = R_format;
assign Branch = (I_format0==1'B1 && Opcode==6'B000100)?1'B1:1'B0;
assign nBranch = (I_format0==1'B1 && Opcode==6'B00101)?1'B1:1'B0;
assign ALUSrc = (I_format0==1'B1 && Opcode!=6'B000100 && Opcode!=6'B00101)?1'B1:1'B0;
assign Sftmd = (R_format==1'B1 && (Function_opcode==6'B000000 || Function_opcode==6'B000100 || 
Function_opcode==6'B000010 || Function_opcode==6'B000110 || Function_opcode==6'B000011 || 
Function_opcode==6'B000111))?1'B1:1'B0;//if shift,set 1

assign I_format = I_format0 && ~Branch && ~nBranch && ~lw && ~sw;
assign ALUOp = {(R_format||I_format),(Branch||nBranch)};

//I/O
assign RegWrite = (R_format || lw || Jal || I_format) && !(Jr) ; // Write memory or write IO 
assign MemWrite = ((sw==1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1:1'b0; 
assign MemRead = ((lw==1)&&(Alu_resultHigh[21:0]!=22'h3FFFFF))?1'b1:1'b0;
assign IORead = ((lw==1)&&(Alu_resultHigh[21:0]==22'h3FFFFF))?1'b1:1'b0;
assign IOWrite = ((sw==1)&&(Alu_resultHigh[21:0]==22'h3FFFFF))?1'b1:1'b0;

assign MemorIOtoReg = IORead || MemRead;

endmodule
