`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/10 22:52:38
// Design Name: 
// Module Name: Decoder
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


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output[31:0] read_data_1;               // è¾åºçç¬¬ä¸?æä½æ?
     output[31:0] read_data_2;               // è¾åºçç¬¬äºæä½æ°
     input[31:0]  Instruction;               // åæååæ¥çæä»¤
     input[31:0]  mem_data;                   //  ä»DATA RAM or I/O portååºçæ°æ?
     input[31:0]  ALU_result;                   // ä»æ§è¡ååæ¥çè¿ç®çç»æ
     input        Jal;                       //  æ¥èªæ§å¶ååï¼è¯´ææ¯JALæä»¤ 
     input        RegWrite;                  // æ¥èªæ§å¶åå
     input        MemtoReg;              // æ¥èªæ§å¶åå
     input        RegDst;             
     output[31:0] Sign_extend;               // æ©å±åç32ä½ç«å³æ°
     input         clock,reset;                // æ¶éåå¤ä½?
     input[31:0]  opcplus4;                 // æ¥èªåæååï¼JALä¸­ç¨
     
     reg[31:0] register[0:31]; //å¯å­å?
     
     wire[5:0] opcode; 
     wire[4:0] rs;//rsçå°å?
     wire[4:0] rt;//rtçå°å?
     reg[4:0] write_adr;
     reg[31:0] write_data;
     wire[4:0] rd;//
 
     wire[15:0] immediate_value;
     wire sign;
     reg[31:0] imme_extend;
     
     assign opcode = Instruction[31:26];
     assign rs = Instruction[25:21];//è·årså°å
     assign rt = Instruction[20:16];//è·årtå°å
     assign rd = Instruction[15:11];//è·årdå°å r-format
 
     assign immediate_value = Instruction[15:0];
 //    assign sign = Instruction[15];
     
     assign Sign_extend = imme_extend;
     
     assign read_data_1 = register[rs];
     assign read_data_2 = register[rt];
     
     always@* begin
         if(opcode==6'b001101||opcode==6'b001100||opcode==6'b001110||opcode==6'b001011)begin
             imme_extend={{16{1'b0}},immediate_value};
         end
         else begin
             imme_extend={{16{Instruction[15]}},immediate_value};
         end
     end
     
     always@* begin
         if(MemtoReg==1'b0&&Jal==1'b0) begin
             write_data = ALU_result;
         end
         else if(Jal==1'b1)begin
             write_data =opcplus4 ;
         end
         else begin
             write_data = mem_data;
         end
     end
     
     always@* begin
         if(RegWrite==1'b1)begin
             if(opcode==6'b000011)begin
                 if(Jal==1'b1)begin
                     write_adr = 5'b11111;//jal
                 end
             end
             else if(RegDst==1'b1)begin
                 write_adr = rd;
             end
             else begin
                 write_adr = rt;
             end
         end
     end
 
 always@(posedge clock) begin
     if(reset==1'b1) begin
     register[0]<=32'd0;
     register[1]<=32'd0;
     register[2]<=32'd0;
     register[3]<=32'd0;
     register[4]<=32'd0;
     register[5]<=32'd0;
     register[6]<=32'd0;
     register[7]<=32'd0;
     register[8]<=32'd0;
     register[9]<=32'd0;
     register[10]<=32'd0;
     register[11]<=32'd0;
     register[12]<=32'd0;
     register[13]<=32'd0;
     register[14]<=32'd0;
     register[15]<=32'd0;
     register[16]<=32'd0;
     register[17]<=32'd0;
     register[18]<=32'd0;
     register[19]<=32'd0;
     register[20]<=32'd0;
     register[21]<=32'd0;
     register[22]<=32'd0;
     register[23]<=32'd0;
     register[24]<=32'd0;
     register[25]<=32'd0;
     register[26]<=32'd0;
     register[27]<=32'd0;
     register[28]<=32'd0;
     register[29]<=32'd0;
     register[30]<=32'd0;
     register[31]<=32'd0;
     end
     else if(RegWrite==1'b1)begin
         if(write_adr!=5'd0)begin
             register[write_adr]<=write_data;
         end
     end
 end
 
 endmodule
