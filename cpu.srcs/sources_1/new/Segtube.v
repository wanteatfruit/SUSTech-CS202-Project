`timescale 1ns / 1ps

module Segtube(
    input clk,
    input rst,
    input[15:0] segwdata,                  // 传进来16bit的要显示的数据
    input segCtrl,
    output  reg [7:0] seg_en,              // 控制哪个灯亮
    output  reg [7:0] seg_out              // 控制每个灯怎么亮（同时亮哪几个数码管）
    );

    reg [3:0] data_0;

    reg [19:0] cnt2;
    reg clk_seg;
    reg [2:0] scan_cnt;     // 基于分频后时钟clk_seg的计数子
       
    //parameter period = 200000;  // 500Hz （稳定）
    parameter period = 200000;  // 5000Hz （稳定）

    always @(posedge clk, negedge rst)    // 分频为clk_seg,tried change to nege,no use
        begin
            if (rst)    // 复位
                begin
                cnt2 <= 0;   //cnt归0
                clk_seg <= 0;   //clk归0
                end
            else begin
                if (cnt2 == (period >> 1) - 1)       // 右移除以2为半个周期，当半个周期结束
                    begin
                    clk_seg <= ~clk_seg;    // clk取反，两次取反为一个周期
                    cnt2 <= 0;       // cnt归0
                    end
                else
                    cnt2 <= cnt2 + 1; // cnt递增
            end
        end

    always@(posedge clk_seg, negedge rst)    // 根据clk_seg改变scan_cnt
        begin
            if (rst)    // 复位
                scan_cnt <= 0;  // scan_cnt归0
            else begin
                scan_cnt <= scan_cnt + 1;   // scan_cnt递增
                if (scan_cnt == 3'd7)   // scan_cnt一个周期完成
                    scan_cnt <= 0;      // scan_cnt归0
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

    wire[7:0] numDisplay [15:0];  // !开个numDisplay数组，下标从0到9，下标是几代表要表示哪一个数字
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
       default: seg_out = numDisplay[data_0];    // 不知道有没有用
       endcase
   end
    //  always @(data_0, scan_cnt) begin
    //      seg_out = numDisplay[data_0];
    //  end
endmodule