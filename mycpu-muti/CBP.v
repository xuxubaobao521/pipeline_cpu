`include "define.v"
`define YY 2'b11
`define NY 2'b10 
`define YN 2'b01 
`define NN 2'b00

module CBP(
    input wire 							clk_i,
    input wire 							rst,
	//ED input
    input wire 							ED_train_valid_i,
    input wire	[`history_WIDTH - 1:0]	ED_train_global_history_i,
    input wire							ED_train_global_predict_i,
    input wire							ED_train_global_taken_i,
    
	//MD input
    input wire [`history_WIDTH - 1:0] 	MD_PC_i,
    input wire [`history_WIDTH - 1:0]	MD_train_global_history_i,
    input wire 							MD_train_valid_i,
    input wire							MD_train_predict_i,
    input wire							MD_train_taken_i,
    input wire							MD_train_global_taken_i,
    input wire							MD_train_global_predict_i,
	input wire							MD_train_local_predict_i,
	input wire							MD_train_local_taken_i,
    
    
    //output
    input wire	[`history_WIDTH - 1:0]	F_PC_i,
    input wire							mini_op_branch_i,
    output wire							F_train_predict_o,
    output wire [`history_WIDTH - 1:0] 	F_train_global_history_o,
    output wire 						F_train_local_predict_o,
    output wire							F_train_global_predict_o
);
	reg [1:0] state, next_state;
	global_CBP global_CBP(
		//in
		.rst					(rst						),
		.clk_i					(clk_i						),
		//MD input
		.MD_PC_i				(MD_PC_i					),
    	.MD_train_valid_i		(MD_train_valid_i			),
    	.MD_train_history_i		(MD_train_global_history_i	),
    	.MD_train_predict_i		(MD_train_global_predict_i	),
    	.MD_train_taken_i		(MD_train_global_taken_i	),
		//ED input
   		.ED_train_valid_i		(ED_train_valid_i			),
		.ED_train_history_i		(ED_train_global_history_i	),
    	.ED_train_predict_i		(ED_train_global_predict_i	),
    	.ED_train_taken_i		(ED_train_global_taken_i	),
    		
    	.F_PC_i					(F_PC_i						),
    	.mini_op_branch_i		(mini_op_branch_i			),
		//output
		.F_train_predict_o		(F_train_global_predict_o	),
    	.F_train_history_o		(F_train_global_history_o	)
	);
	local_CBP local_CBP(
    	.clk_i					(clk_i						),
    	.rst					(rst						),
    
		//MD input
    	.MD_PC_i				(MD_PC_i					),
    	.MD_train_valid_i		(MD_train_valid_i			),
    	.MD_train_predict_i		(MD_train_local_predict_i	),
    	.MD_train_taken_i		(MD_train_local_taken_i		),
		//output
    	.F_PC_i					(F_PC_i						),
    	.F_train_predict_o		(F_train_local_predict_o	)
	);
	always @(*) begin
		case(state)
			`NN:next_state = MD_train_local_taken_i ^ MD_train_global_taken_i ? MD_train_local_taken_i ? `NN : `YN: `NN;
			`YN:next_state = MD_train_local_taken_i ^ MD_train_global_taken_i ? MD_train_local_taken_i ? `NN : `NY: `YN;
			`NY:next_state = MD_train_local_taken_i ^ MD_train_global_taken_i ? MD_train_local_taken_i ? `YN : `YY: `NY;
			`YY:next_state = MD_train_local_taken_i ^ MD_train_global_taken_i ? MD_train_local_taken_i ? `YN : `YY: `YY;
		endcase
	end
	always @(posedge clk_i)begin
		if(rst) state <= `YN;
		else if(MD_train_valid_i) state <= next_state;
	end
	assign F_train_predict_o = 1'b0;
endmodule

module global_CBP(
    input wire 							clk_i,
    input wire 							rst,

    input wire	[`history_WIDTH - 1:0]	ED_train_history_i,
    input wire 							ED_train_valid_i,
    input wire							ED_train_predict_i,
    input wire							ED_train_taken_i,
    

    input wire [`history_WIDTH - 1:0] 	MD_PC_i,
    input wire [`history_WIDTH - 1:0]	MD_train_history_i,
    input wire 							MD_train_valid_i,
    input wire							MD_train_predict_i,
    input wire							MD_train_taken_i,
    
    input wire	[`history_WIDTH - 1:0]	F_PC_i,
    input wire							mini_op_branch_i,
    output wire							F_train_predict_o,
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

module local_CBP(
    input wire 							clk_i,
    input wire 							rst,
    

    input wire [`history_WIDTH - 1:0] 	MD_PC_i,
    input wire 							MD_train_valid_i,
    input wire							MD_train_predict_i,
    input wire							MD_train_taken_i,
    
    input wire	[`history_WIDTH - 1:0]	F_PC_i,
    output wire							F_train_predict_o
);
	reg [1:0] PHT [`PHT_WIDTH - 1:0];
	reg [`history_WIDTH - 1:0] BHT[`PHT_WIDTH - 1:0];
	wire [`history_WIDTH - 1:0] F_sum = BHT[F_PC_i] ^ F_PC_i;
	wire [`history_WIDTH - 1:0] MD_sum = BHT[MD_PC_i] ^ MD_PC_i;
	always @(posedge clk_i) begin
        	if(rst) begin
            		for(int i = 0; i <= `PHT_WIDTH - 1; i ++) begin
               			PHT[i] = 2'b01;
            		end
            		for(int i = 0; i <= `PHT_WIDTH - 1; i ++) begin
            			BHT[i] = 7'b0;
            		end
        	end
        	else begin
        		if(MD_train_valid_i) begin
            			if(MD_train_taken_i) begin
            				BHT[MD_PC_i] <= {BHT[MD_PC_i][5:0], MD_train_predict_i};
                			if(MD_train_predict_i) PHT[MD_sum]<=(PHT[MD_sum]==2'b11)?2'b11:PHT[MD_sum]+1;
                			else PHT[MD_sum]<=(PHT[MD_sum]==2'b00)?2'b00:PHT[MD_sum]-1;
            			end
            			else begin
            				BHT[MD_PC_i] <= {BHT[MD_PC_i][5:0], ~MD_train_predict_i};
            				if(MD_train_predict_i) PHT[MD_sum]<=(PHT[MD_sum]==2'b00)?2'b00:PHT[MD_sum]-1;
                			else PHT[MD_sum]<=(PHT[MD_sum]==2'b11)?2'b11:PHT[MD_sum]+1;
            			end
				end
        	end
        end
		wire [`history_WIDTH - 1:0] debug = BHT[MD_PC_i];
        assign F_train_predict_o = PHT[F_sum][1];
endmodule

