`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 20:05:22
// Design Name: 
// Module Name: cpu_top
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


module cpu_top(
input fpga_clk,
input[23:0] sw_in,  //sw15...sw0, 测试场景1, sw7...sw0测试场景1/2，sw3...sw0测试场景2/2
input fpga_rst,
output[23:0] led_out, //17个led输出（测试场景1）
input[3:0] row,
output[3:0] col,
output[7:0] seg_out,
output[7:0] seg_en,
//output wen,
input start_pg, //active high
input rx, //receive data by UART
output tx //send data by UART


    );
    
    //UART
    wire upg_clk, upg_clk_o;
    wire upg_wen_o; //Uart write out enable
    wire upg_done_o; //Uart rx data have done
        //assign led_out[23]=upg_wen_o; //!!!!test

    //data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    //data to program_rom or dmemory32
    wire [31:0] upg_dat_o;
        //wire clk_uart;
    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter// Generate UART Programmer reset signal
    reg upg_rst;
    always @ (posedge fpga_clk) begin
    if (spg_bufg) upg_rst = 0;
    if (fpga_rst) upg_rst = 1;
    end
    //used for other modules which don't relatetoUART
    wire rst;
    assign rst = fpga_rst | !upg_rst;
    
    uart_bmpg_0 uart  (.upg_adr_o(upg_adr_o),
           .upg_clk_i(upg_clk),
           .upg_clk_o(upg_clk_o),
           .upg_dat_o(upg_dat_o),
           .upg_done_o(upg_done_o),
           .upg_rst_i(upg_rst),
           .upg_rx_i(rx),
           .upg_tx_o(tx),
           .upg_wen_o(upg_wen_o));
    assign wen=upg_wen_o;
    //ALU  outputs
    wire[31:0] ALU_Result;
    wire[31:0] Addr_Result;
    wire Zero;
    
    //MemOrIO outputs
    wire[31:0] addr_out; //addr to memory
    wire[31:0] r_wdata; //data to decoder
    wire[31:0] write_data; //data to mem or IO (m_wdata, io_wdata)
    wire LEDCtrlHigh;
    wire LEDCtrlLow;
    wire SwitchCtrlLow;
    wire SwitchCtrlHigh;
    wire SegCtrl;
    wire BoardCtrl;
    wire  lowAddr;
    //wire [15:0] ledlowData
    
    //switch outputs
    wire[15:0] switch_wdata;
    //led outputs
    wire[23:0] led_rout;
    //keyboard outputs
    wire[15:0] key_wdata;
    //seg outputs
    
    //IFetch outputs
    wire[31:0] link_addr; //JAL指令专用的PC+4   
    wire[31:0] Instruction_o_if;
    wire[31:0] branch_base_addr; //对于有条件跳转类的指令而言，该值为(pc+4)送往ALU
    
    //d_memory  outputs
    wire[31:0] readData;
    
    //decoder outputs
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    wire [31:0] Sign_extend;
    
     //controller outputs
    wire Jr;
    wire RegDST;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemWrite;
    wire Branch;
    wire nBranch;
    wire Jmp;
    wire Jal;
    wire I_format;
    wire Sftmd;
    wire[1:0] ALUOp;
    wire MemorIOtoReg;
    wire MemRead;
    wire IORead;
    wire IOWrite;
   
    
     //instruction related
    wire [5:0]Opcode;
    wire[5:0] Function_opcode;
    wire[4:0] Shamt;
    
    assign Shamt=Instruction_o_if[10:6];
    assign Opcode=Instruction_o_if[31:26]; 
    assign Function_opcode=Instruction_o_if[5:0];
    
    //cpuclk
    wire clk_out;
    cpuclk clk(.clk_in1(fpga_clk),.clk_out1(clk_out),.clk_out2(upg_clk));
    
    assign cpuclk_out=clk_out;
    
    wire [21:0] Alu_resultHigh; //to controller
     assign Alu_resultHigh=ALU_Result[31:10];
     
    control32 controller(Opcode,Function_opcode,Jr,RegDST,ALUSrc,MemtoReg,
       RegWrite, MemWrite,Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp, 
       Alu_resultHigh,MemRead,IORead,IOWrite);
       assign IOWriteTest=IOWrite;
       assign IOReadTest=IORead;
       assign RegWriteTest=RegWrite;
       assign InstructionTest=Instruction_o_if;
       //!!!!!!!TODO: CONNECT DATA RAM OR IO PORT RELATED!!!!!
       //opcplus4:来自取指单元，JAL中用, should be link_addr
      decode32 decoder(read_data_1,read_data_2,Instruction_o_if,r_wdata,ALU_Result,
                        Jal,RegWrite,MemtoReg,RegDST,Sign_extend,clk_out,rst,link_addr);
        
        //address, writedata, readdata
//        dmemory32 data_memory(clk_out,MemWrite,addr_out,write_data,readData);
        wire upg_wen= upg_wen_o & upg_adr_o[14];
        dmemory32_Uart data_memory(clk_out,MemWrite,addr_out,write_data,readData,
        upg_rst,upg_clk_o,upg_wen,upg_adr_o[13:0],upg_dat_o,upg_done_o);
        
   
   //pc plus 4 from ifetch (link_addr or branchbase?) should be branchbase
   executs32 alu(read_data_1,read_data_2,Sign_extend,Function_opcode,Opcode,ALUOp,
                         Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,branch_base_addr);
       
       wire upg_wen_pr= upg_wen_o & (!upg_adr_o[14]) ;    
       wire[13:0] rom_adr_o;   
       wire[31:0] upg_Instruction_o;
     programrom pro(clk_out,rom_adr_o,upg_Instruction_o,upg_rst,upg_clk_o,upg_wen_pr,upg_adr_o[13:0],upg_dat_o,upg_done_o);
      Ifetc32 ifetch(branch_base_addr,Addr_Result,read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clk_out,rst,link_addr,
      rom_adr_o,Instruction_o_if,upg_Instruction_o);
      
     MemOrIO memio(MemRead,MemWrite,IORead,IOWrite,ALU_Result,addr_out,readData,
                                   switch_wdata ,key_wdata ,r_wdata,read_data_2,write_data,LEDCtrlLow,LEDCtrlHigh,
                                   SwitchCtrlLow,SwitchCtrlHigh,SegCtrl,BoardCtrl);
                                   
                                   
                                   wire[15:0] led_wdata;
                                   assign led_wdata=write_data[15:0];
                                   
   Switch switch(clk_out,rst,SwitchCtrlLow,SwitchCtrlHigh,switch_wdata,sw_in);
   LED led(clk_out,rst,LEDCtrlLow,LEDCtrlHigh,led_wdata,led_out);
   Keyboard key(fpga_clk,rst,row,col,key_wdata);
   Segtube seg(fpga_clk,rst,led_wdata,SegCtrl,seg_en,seg_out);


    
endmodule
