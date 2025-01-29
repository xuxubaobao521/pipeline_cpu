`include "define.v"
`include ST 2'b11
`include WT 2'b10
`include WNT 2'b01
`include SNT 2'b00

module CBP(
	//input
	input wire rst,
	input wire clk_i,
	input wire train_taken_i,
	input wire train_valid_i,

	output wire predict_o,
);
	//两位饱和计数器分支预测
    reg [1:0] next_state;
    always @(*) begin
        case(state)
            SNT : next_state = train_valid ? (train_taken ? WNT : SNT) : SNT;
            WNT : next_state = train_valid ? (train_taken ? WT : SNT) : WNT;
            WT : next_state = train_valid ? (train_taken ? ST : WNT) : WT;
            ST : next_state = train_valid ? (train_taken ? ST : WT) : ST;
        endcase
    end

    always @(posedge clk) begin
        if(rst)
            state <= WNT;
        else 
            state = next_state;
    end
	assign predict_o = state[1];
endmodule	