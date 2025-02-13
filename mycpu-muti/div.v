`include "define.v"
`define die 0
`define busy 1
module div(
	input wire rst,
	input wire clk_i,
	input wire need,
	input wire [`XLEN - 1:0] Dividend_i,
	input wire [`XLEN - 1:0] Divisor_i,
	
	output wire [`XLEN - 1:0] Q,
	output wire [`XLEN - 1:0] D,
    output wire state_o,
    output wire [5:0] cnt_o
);
	reg state;
	reg [5:0] cnt;
	reg [`XLEN * 2 - 1:0] 	Divisor;
	reg [`XLEN * 2 - 1:0] 	Dividend;
	reg [`XLEN - 1:0] 		Quotent;
	wire [`XLEN * 2 - 1:0] 	sum;
	wire select;
	control control(
		.Divisor(Divisor),
		.Dividend(Dividend),
		.sum(sum),
		.select(select)
	);
	always @(posedge clk_i) begin
		if(rst)
			state <= 0;
		else if(need) begin
			if(state == `die) begin
				state 	<= `busy;
				cnt		<=	33;	
				Divisor <= {Divisor_i, 32'b0};
				Dividend <= {32'b0, Dividend_i};
				Quotent	<= 32'b0;
			end
			else if(cnt == 0) begin
				state <= `die;
			end
			else begin
				cnt <= cnt - 1;
				Divisor <= Divisor >> 1; 
				Quotent <= {Quotent[30:0], select};
				if(select) begin
					Dividend <= sum;
				end
			end
		end
	end
	assign Q = Quotent;
	assign D = Dividend[`XLEN - 1:0];
    assign state_o = state;
    assign cnt_o = cnt;
endmodule

module control(
	input wire [`XLEN * 2 - 1:0] Divisor,
	input wire [`XLEN * 2 - 1:0] Dividend,
	
	output wire [`XLEN * 2 - 1:0] sum,
	output wire select
);
	wire [`XLEN * 2 - 1:0] OP1 = Dividend;
	wire [`XLEN * 2 - 1:0] OP2 = {64{1'b1}} ^ Divisor;
	assign sum = OP1 + OP2 + 64'b1;
	wire lt =  (Dividend[`XLEN * 2 - 1] & ~Divisor[`XLEN * 2 - 1]) | ((~(Divisor[`XLEN * 2 - 1] ^ Dividend[`XLEN * 2 - 1])) & sum[`XLEN * 2 - 1]);
	assign select = ~lt;
endmodule