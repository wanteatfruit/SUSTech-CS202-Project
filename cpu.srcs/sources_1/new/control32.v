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
    input[5:0]   Opcode;            // ����IFetchģ���ָ���6bit, instruction[31..26]
input[5:0]   Function_opcode;      // ����IFetchģ���ָ���6bit, ��������r-�����е�ָ��, instructions[5..0]
output       Jr;              // Ϊ1������ǰָ����jr, Ϊ0��ʾ��ǰָ���jr
output       RegDST;          // Ϊ1����Ŀ�ļĴ�����rd, ����Ŀ�ļĴ�����rt
output       ALUSrc;          // Ϊ1�����ڶ�����������ALU�е�Binput������������beq, bne���⣩, Ϊ0ʱ��ʾ�ڶ������������ԼĴ���
output       MemorIOtoReg;     // Ϊ1������Ҫ�Ӵ洢����I/O�����ݵ��Ĵ���
output       RegWrite;         // Ϊ1������ָ����Ҫд�Ĵ���
output       MemWrite;       // Ϊ1������ָ����Ҫд�洢��
output       Branch;        // Ϊ1������beqָ��, Ϊ0ʱ��ʾ����beqָ��
output       nBranch;       // Ϊ1������Bneָ��, Ϊ0ʱ��ʾ����bneָ��
output       Jmp;            // Ϊ1������Jָ��, Ϊ0ʱ��ʾ����Jָ��
output       Jal;            // Ϊ1������Jalָ��, Ϊ0ʱ��ʾ����Jalָ��
output       I_format;      // Ϊ1������ָ���ǳ�beq, bne, LW, SW֮�������I-����ָ��
output       Sftmd;         // Ϊ1��������λָ��, Ϊ0����������λָ��
output[1:0]  ALUOp;        // ��R-���ͻ�I_format=1ʱλ1����bitλ��Ϊ1,  beq��bneָ����λ0����bitλ��Ϊ1
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
