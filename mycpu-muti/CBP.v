`include "define.v"
`define ST 2'b11
`define WT 2'b10
`define WNT 2'b01
`define SNT 2'b00

module CBP(
	//input
	input wire rst,
	input wire clk_i,
	input wire MD_train_taken_i,
	input wire MD_train_vaild_i,

	output wire F_train_predict_o
);
	//两位饱和计数器分支预测
    reg [1:0] state,next_state;
    always @(*) begin
        case(state)
            `SNT : next_state = MD_train_vaild_i ? (MD_train_taken_i ? `WNT : `SNT) : `SNT;
            `WNT : next_state = MD_train_vaild_i ? (MD_train_taken_i ? `WT : `SNT) : `WNT;
            `WT : next_state = MD_train_vaild_i ? (MD_train_taken_i ? `ST : `WNT) : `WT;
            `ST : next_state = MD_train_vaild_i ? (MD_train_taken_i ? `ST : `WT) : `ST;
        endcase
    end

    always @(posedge clk_i) begin
        if(rst)
            state <= `WNT;
        else 
            state <= next_state;
    end
	assign F_train_predict_o = state[1];
endmodule	

