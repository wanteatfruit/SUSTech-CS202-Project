`timescale 1ns / 1ps

module Segtube(
    input clk,
    input rst,
    input[15:0] segwdata,                  // ������16bit��Ҫ��ʾ������
    input segCtrl,
    output  reg [7:0] seg_en,              // �����ĸ�����
    output  reg [7:0] seg_out              // ����ÿ������ô����ͬʱ���ļ�������ܣ�
    );

    reg [3:0] data_0;

    reg [19:0] cnt2;
    reg clk_seg;
    reg [2:0] scan_cnt;     // ���ڷ�Ƶ��ʱ��clk_seg�ļ�����
       
    //parameter period = 200000;  // 500Hz ���ȶ���
    parameter period = 200000;  // 5000Hz ���ȶ���

    always @(posedge clk, negedge rst)    // ��ƵΪclk_seg,tried change to nege,no use
        begin
            if (rst)    // ��λ
                begin
                cnt2 <= 0;   //cnt��0
                clk_seg <= 0;   //clk��0
                end
            else begin
                if (cnt2 == (period >> 1) - 1)       // ���Ƴ���2Ϊ������ڣ���������ڽ���
                    begin
                    clk_seg <= ~clk_seg;    // clkȡ��������ȡ��Ϊһ������
                    cnt2 <= 0;       // cnt��0
                    end
                else
                    cnt2 <= cnt2 + 1; // cnt����
            end
        end

    always@(posedge clk_seg, negedge rst)    // ����clk_seg�ı�scan_cnt
        begin
            if (rst)    // ��λ
                scan_cnt <= 0;  // scan_cnt��0
            else begin
                scan_cnt <= scan_cnt + 1;   // scan_cnt����
                if (scan_cnt == 3'd7)   // scan_cntһ���������
                    scan_cnt <= 0;      // scan_cnt��0
            end
        end

    always @(scan_cnt, segCtrl) begin //original scan_cnt
        
        if (segCtrl)
            begin
                case(scan_cnt)
                        0: seg_en = 8'b0111_1111;
                        1: seg_en = 8'b0111_1111;
                        2: seg_en = 8'b0111_1111;
                        3: seg_en = 8'b0111_1111;
                        4: seg_en = 8'b0111_1111;
                        5: seg_en = 8'b0111_1111;
                        6: seg_en = 8'b0111_1111;
                        7: seg_en = 8'b0111_1111;
                        default: seg_en = 8'b0111_1111;
                endcase
            end
        else begin
           seg_en = 8'b1111_1111; 
        end
    end

    wire[7:0] numDisplay [15:0];  // !����numDisplay���飬�±��0��9���±��Ǽ�����Ҫ��ʾ��һ������
    begin
        assign numDisplay[0] = 8'b1100_0000; // 0
        assign numDisplay[1] = 8'b1111_1001; // 1
        assign numDisplay[2] = 8'b1010_0100; // 2
        assign numDisplay[3] = 8'b1011_0000; // 3
        assign numDisplay[4] = 8'b1001_1001; // 4
        assign numDisplay[5] = 8'b1001_0010; // 5
        assign numDisplay[6] = 8'b1000_0010; // 6
        assign numDisplay[7] = 8'b1111_1000; // 7
        assign numDisplay[8] = 8'b1000_0000; // 8
        assign numDisplay[9] = 8'b1001_0000; // 9
        assign numDisplay[10] = 8'b1000_1000; // A
        assign numDisplay[11] = 8'b1000_0011; // B
        assign numDisplay[12] = 8'b1100_0110; // C
        assign numDisplay[13] = 8'b1010_0001; // D
        assign numDisplay[14] = 8'b1000_0110; // E
        assign numDisplay[15] = 8'b1000_1110; // F
    end

    always @(scan_cnt, segCtrl) begin
        // case (scan_cnt)
        //     0: data_0 = segwdata[3:0];
        //     1: data_0 = segwdata[3:0];
        //     2: data_0 = segwdata[3:0];
        //     3: data_0 = segwdata[3:0];
        //     4: data_0 = segwdata[3:0];
        //     5: data_0 = segwdata[3:0];
        //     6: data_0 = segwdata[3:0];
        //     7: data_0 = segwdata[3:0];
        //     default: data_0 = data_0;
        // endcase

        if (segCtrl) begin
            data_0 = segwdata[3:0];
        end
        else begin
            data_0 = data_0;
        end
    end


   always @(scan_cnt, data_0) begin
       case(scan_cnt)
           0: seg_out = numDisplay[data_0];
           1: seg_out = numDisplay[data_0];
           2: seg_out = numDisplay[data_0];
           3: seg_out = numDisplay[data_0];
           4: seg_out = numDisplay[data_0];
           5: seg_out = numDisplay[data_0];
           6: seg_out = numDisplay[data_0];
           7: seg_out = numDisplay[data_0];
       default: seg_out = numDisplay[data_0];    // ��֪����û����
       endcase
   end
    //  always @(data_0, scan_cnt) begin
    //      seg_out = numDisplay[data_0];
    //  end
endmodule