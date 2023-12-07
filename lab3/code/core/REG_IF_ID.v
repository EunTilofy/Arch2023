`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    21:34:44 03/12/2012
// Design Name:
// Module Name:    REGS IF/ID Latch
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module    REG_IF_ID(input clk,                                      //IF/ID Latch
                    input rst,
                    input EN,                                       //流水寄存器使能
                    input Data_stall,                               //数据竞争等待
                    input flush,                                    //控制竞争清除并等待
                    input [31:0] PCOUT,                             //指令存储器指针
                    input [31:0] IR,                                //指令存储器输出

                    output reg[31:0] IR_ID,                         //取指锁存
                    output reg[31:0] PCurrent_ID,                   //当前存在指令地址
                    output reg isFlushed,
                    input bp_taken_IF,
                    output reg bp_taken_ID,
                    output reg is_stalled
                );

//reg[31:0]PCurrent_ID,IR_ID;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            IR_ID <= 32'h00000013;                            //复位清零
            PCurrent_ID <= 32'h00000000;                     //复位清零
            isFlushed <= 0;
            bp_taken_ID <= 0;
        end
        else if(EN)begin
            if(Data_stall)begin
                IR_ID <= IR_ID;                          //IR waiting for Data Hazards 并暂停取指
                PCurrent_ID <= PCurrent_ID;           //保存对应PC指针
                bp_taken_ID <= bp_taken_ID;
                isFlushed <= 0;
                is_stalled <= 1;
            end
            else if(flush)begin
                IR_ID <= 32'h00000013;              //IR waiting for Control Hazards i清s除指令并暂停
                PCurrent_ID <= PCurrent_ID;      //清除指令的指针(测试)
                bp_taken_ID <= 1'b0;
                isFlushed <= 1;
                is_stalled <= 0;
            end
            else begin
                IR_ID <= IR;                       //正常取指,传送下一流水级译码
                bp_taken_ID <= bp_taken_IF;
                PCurrent_ID <= PCOUT;           //当前取指PC地址，Branch/Junp指令计算目标地址用(非PC+4)
                isFlushed <= 0;
                is_stalled <= 0;
            end
        end
    end

endmodule