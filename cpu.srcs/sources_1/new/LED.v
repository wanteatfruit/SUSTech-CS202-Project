`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/22 15:44:38
// Design Name: 
// Module Name: LED
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

module LED(led_clk, ledrst, LEDCtrlLow,LEDCtrlHigh,ledwdata, ledout);
    input led_clk;    		    // ʱ���ź�
    input ledrst; 		        // ��λ�ź�
    input LEDCtrlLow;		      // ��memorio���ģ��ɵ�����λ�γɵ�LEDƬѡ�ź�   
    input LEDCtrlHigh;		      // ��memorio���ģ��ɵ�����λ�γɵ�LEDƬѡ�ź�   
    input[15:0] ledwdata;	  //  д��LEDģ������ݣ�ע��������ֻ��16��
    output[23:0] ledout;	//  ������������24λLED�ź�
  
    reg [23:0] ledout;
    
   always@(posedge led_clk or posedge ledrst) begin
        if(ledrst) begin
            ledout <= 24'h000000;
        end
		else	if(LEDCtrlLow == 1'b1)begin
				ledout[23:0] <= { ledout[23:16], ledwdata[15:0] };
		end
		else if(LEDCtrlHigh ==1'b1 )begin
				ledout[23:0] <= { ledwdata[7:0], ledout[15:0] };
		end
        else begin
            ledout <= ledout;
        end
    end
endmodule
