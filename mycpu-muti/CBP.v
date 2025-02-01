`include "define.v"

module CBP(
    input wire 		clk_i,
    input wire 		rst,

    input wire	[`history_WIDTH - 1:0]	ED_train_history_i,
    input wire 				ED_train_valid_i,
    input wire				ED_train_predict_i,
    input wire				ED_train_taken_i,
    

    input wire [`history_WIDTH - 1:0] 	MD_PC_i,
    input wire [`history_WIDTH - 1:0]	MD_train_history_i,
    input wire 				MD_train_valid_i,
    input wire				MD_train_predict_i,
    input wire				MD_train_taken_i,
    
    input wire	[`history_WIDTH - 1:0]	F_PC_i,
    input wire				mini_op_branch_i,
    output wire				F_train_predict_o,
    output reg [`history_WIDTH - 1:0] 	F_train_history_o
);
	reg [`history_WIDTH - 1:0] predict_history;
	reg [1:0] PHT [`PHT_WIDTH - 1:0];
    	wire [`history_WIDTH - 1:0] F_sum = F_train_history_o^F_PC_i;
    	wire [`history_WIDTH - 1:0] MD_sum = MD_PC_i^MD_train_history_i;
	always @(posedge clk_i) begin
        if(rst) begin
            predict_history <= 7'b0;
            for(int i = 0; i <= 127; i ++) begin
                PHT[i] = 2'b01;
            end
        end
        else begin
        //利用预测失败，要更新history
        //如果不需要修复的话，正常更新
            	if(ED_train_valid_i & ~ED_train_taken_i)
              	 	 predict_history <= {ED_train_history_i[5:0], ~ED_train_predict_i};
           	 else if(mini_op_branch_i)
            		predict_history <= {predict_history[5:0], F_train_predict_o};
        //写回阶段提交，更新PHT
        	if(MD_train_valid_i) begin
            		if(MD_train_taken_i) begin
                		if(MD_train_predict_i) PHT[MD_sum]<=(PHT[MD_sum]==2'b11)?2'b11:PHT[MD_sum]+1;
                		else PHT[MD_sum]<=(PHT[MD_sum]==2'b00)?2'b00:PHT[MD_sum]-1;
            		end
            		else begin
            			if(MD_train_predict_i) PHT[MD_sum]<=(PHT[MD_sum]==2'b00)?2'b00:PHT[MD_sum]-1;
                		else PHT[MD_sum]<=(PHT[MD_sum]==2'b11)?2'b11:PHT[MD_sum]+1;
            		end
        	end
        	F_train_history_o <= predict_history;
        end
    end
    assign F_train_predict_o = PHT[F_sum][1];
endmodule

