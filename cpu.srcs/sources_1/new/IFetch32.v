`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/08 17:25:37
// Design Name: 
// Module Name: IFetch32
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


module Ifetc32(branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr,rom_adr_o
,Instruction_o,Instruction_i);
    output[31:0] branch_base_addr;      // ������������ת���ָ����ԣ���ֵΪ(pc+4)����ALU
    input[31:0]  Addr_result;            // ����ALU,ΪALU���������ת��ַ
    input[31:0]  Read_data_1;           // ����Decoder��jrָ���õĵ�ַ
    input        Branch;                // ���Կ��Ƶ�Ԫ
    input        nBranch;               // ���Կ��Ƶ�Ԫ
    input        Jmp;                   // ���Կ��Ƶ�Ԫ
    input        Jal;                   // ���Կ��Ƶ�Ԫ
    input        Jr;                   // ���Կ��Ƶ�Ԫ
    input        Zero;                  //����ALU��ZeroΪ1��ʾ����ֵ��ȣ���֮��ʾ�����
    input        clock,reset;           //ʱ���븴λ,��λ�ź����ڸ�PC����ʼֵ����λ�źŸߵ�ƽ��Ч
    output[31:0] link_addr;             // JALָ��ר�õ�PC+4   
    
    //Uart changes
    output [13:0] rom_adr_o; //to programmrom
    output[31:0] Instruction_o;
    input [31:0] Instruction_i;//from programmrom
    reg[31:0] pc,next_pc,link;
       
    always @* begin
        if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero==0))) //beq,bne
            next_pc=(Addr_result);
        else if (Jr==1)
            next_pc=(Read_data_1);
         else next_pc=pc+4;
     end
     
        always @(Jal)begin
          if(Jal ==1) begin
              link = (pc + 4);
          end
      end
     
     always @(negedge clock) begin
        if(reset == 1'b1)
            pc <= 32'h0000_0000;
        else if((Jal == 1 || Jmp==1)) begin 
            pc <= {pc[31:28],Instruction_i[25:0],2'b00}; 
          end
        else
             pc <= next_pc;
     end
     
     assign branch_base_addr = pc+4;
     assign link_addr=link;
     assign rom_adr_o=pc[15:2];
     assign Instruction_o=Instruction_i;


endmodule

