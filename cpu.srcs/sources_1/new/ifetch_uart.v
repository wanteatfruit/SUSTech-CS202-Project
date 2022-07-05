`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/24 21:22:15
// Design Name: 
// Module Name: ifetch_uart
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


module ifetch_uart(
        output[31:0] Instruction,			// ����PC��ֵ�Ӵ��ָ���prgrom��ȡ����ָ��
output[31:0] branch_base_addr,      // ������������ת���ָ����ԣ���ֵΪ(pc+4)����ALU
input[31:0]  Addr_result,            // ����ALU,ΪALU���������ת��ַ
input[31:0]  Read_data_1,           // ����Decoder��jrָ���õĵ�ַ
input        Branch,                // ���Կ��Ƶ�Ԫ
input        nBranch,               // ���Կ��Ƶ�Ԫ
input        Jmp,                   // ���Կ��Ƶ�Ԫ
input        Jal,                   // ���Կ��Ƶ�Ԫ
input        Jr,                   // ���Կ��Ƶ�Ԫ
input        Zero,                  //����ALU��ZeroΪ1��ʾ����ֵ��ȣ���֮��ʾ�����
input        clock,reset,           //ʱ���븴λ,��λ�ź����ڸ�PC����ʼֵ����λ�źŸߵ�ƽ��Ч
output[31:0] link_addr,             // JALָ��ר�õ�PC+4   
// UART Programmer Pinouts
input upg_rst_i, // UPG reset (Active High)
input upg_clk_i, // UPG clock (10MHz)
input upg_wen_i, // UPG write enable
input[13:0] upg_adr_i, // UPG write address
input[31:0] upg_dat_i, // UPG write data
input upg_done_i // 1 if program finished
    );
    wire kickOff = upg_rst_i | (~upg_rst_i &upg_done_i);
    
    reg[31:0] pc,next_pc,link;
    
    prgrom instmem (
    .clka (kickOff ? clock : upg_clk_i ),
    .wea (kickOff ? 1'b0 : upg_wen_i ),
    .addra (kickOff ? rom_adr_i : upg_adr_i ),
    .dina (kickOff ? 32'h00000000 : upg_dat_i ),.douta (Instruction_o)
    );
    
//     prgrom instmem(
//       .clka(clock),
//       .addra(pc[15:2]),
//       .douta(Instruction)
//       );
       
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
            pc <= {4'b0000,Instruction[25:0],2'b00}; 
          end
        else
             pc <= next_pc;
     end
     
     assign branch_base_addr = pc+4;
     assign link_addr=link;

endmodule
