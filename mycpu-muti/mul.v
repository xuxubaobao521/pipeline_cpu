`include "define.v"
`define idle 0
`define busy 1 
module mul(
    input wire 						rst,
    input wire 						clk_i,
    input wire 						need,
    input wire[`XLEN:0] 			x,
    input wire[`XLEN:0] 			y,

    output wire[`XLEN * 2 + 1:0] 	z,
    output reg 						state_o,
    output reg 						cnt_o
);
    wire [`XLEN * 2 + 1:0] X = {{33{x[`XLEN]}},x};
    wire [`XLEN * 2 + 1:0] add_x = X;
    wire [`XLEN * 2 + 1:0] sub_x = ~X + {65'b0,1'b1};
    wire [`XLEN * 2 + 1:0] tmp[16:0];
    reg  [`XLEN * 2 + 1:0] tmp_1[16:0];
    wire [`XLEN * 2 + 1:0] S_1[4:0];
    wire [`XLEN * 2 + 1:0] C_1[4:0];

    wire [`XLEN * 2 + 1:0] S_2[3:0];
    wire [`XLEN * 2 + 1:0] C_2[3:0];

    wire [`XLEN * 2 + 1:0] S_3[1:0];
    wire [`XLEN * 2 + 1:0] C_3[1:0];
    
    wire [`XLEN * 2 + 1:0] S_4[1:0];
    wire [`XLEN * 2 + 1:0] C_4[1:0];

    wire [`XLEN * 2 + 1:0] S_5;
    wire [`XLEN * 2 + 1:0] C_5;

    wire [`XLEN * 2 + 1:0] S_6;
    wire [`XLEN * 2 + 1:0] C_6;
    genvar i;
    generate
        for(i = 0; i < 17; i = i + 1) begin:BLOCK1
            booth booth(
                .y_u(i == 16 ? y[i * 2] : y[i * 2 + 1]), 
                .y_i(y[i * 2]), 
                .y_d(i == 0 ? 1'b0 : y[i * 2 - 1]),
                .add_x(add_x << (i * 2)),
                .sub_x(sub_x << (i * 2)),

                .value(tmp[i]));
        end
    endgenerate
    //第一层 16 -> 11
    full_add full_add_0(tmp_1[0], tmp_1[1], tmp_1[2], C_1[0], S_1[0]);
    full_add full_add_1(tmp_1[3], tmp_1[4], tmp_1[5], C_1[1], S_1[1]);
    full_add full_add_2(tmp_1[6], tmp_1[7], tmp_1[8], C_1[2], S_1[2]);
    full_add full_add_3(tmp_1[9], tmp_1[10], tmp_1[11], C_1[3], S_1[3]);
    full_add full_add_4(tmp_1[12], tmp_1[13], tmp_1[14], C_1[4], S_1[4]);
    //第二层 11 -> 8
    full_add full_add_5(tmp_1[15], C_1[0], C_1[1], C_2[0], S_2[0]);
    full_add full_add_6(C_1[2], C_1[3],  C_1[4], C_2[1], S_2[1]);
    full_add full_add_7(S_1[0], S_1[1],  S_1[2], C_2[2], S_2[2]);
    full_add full_add_8(tmp_1[16], S_1[3], S_1[4], C_2[3], S_2[3]);
    //第三层 8 -> 6
    full_add full_add_9(C_2[3], S_2[3],  C_2[0], C_3[0], S_3[0]);
    full_add full_add_10(C_2[1], C_2[2],  S_2[0], C_3[1], S_3[1]);
    //第四层6 -> 4
    full_add full_add_11(S_2[1], S_2[2],  C_3[0], C_4[0], S_4[0]);
    full_add full_add_12(C_3[1], S_3[0],  S_3[1], C_4[1], S_4[1]);
    //第五层4->3
    full_add full_add_13(C_4[0], C_4[1],  S_4[0], C_5, S_5);
    //第六层3->2
    full_add full_add_14(S_4[1], C_5,  S_5, C_6, S_6);
	assign z = C_6 + S_6;
    always @(posedge clk_i) begin
        if(rst) begin
            state_o <= `idle;
        end
        else if(need) begin
            if(state_o == `idle) begin
                state_o <= `busy;
                cnt_o   <= 1;
            end
            else if(|cnt_o) begin
                cnt_o   <= cnt_o - 1;
                tmp_1   <= tmp;
            end
            else state_o <= `idle;
        end
    end
endmodule

module booth(
    input wire 				y_u,
    input wire 				y_i,
    input wire 				y_d,
    input [`XLEN * 2 + 1:0] add_x,
    input [`XLEN * 2 + 1:0] sub_x,

    output reg [`XLEN * 2 + 1:0] value
);
    reg [2:0] op;
    always@(*)begin
        case({y_u,y_i,y_d})
            3'b000: op = 3'b000;
            3'b001: op = 3'b001;
            3'b010: op = 3'b001;
            3'b011: op = 3'b010;
            3'b100: op = 3'b011;
            3'b101: op = 3'b100;
            3'b110: op = 3'b100;
            3'b111: op = 3'b000;
        endcase
    end
    always @(*)begin
        case(op)
            3'b000:value = {(`XLEN*2+2){1'b0}};
            3'b001:value = add_x;
            3'b010:value = add_x << 1;
            3'b011:value = sub_x << 1;
            3'b100:value = sub_x;
            default: value = {(`XLEN*2+2){1'b0}};
        endcase
    end
endmodule

module full_add(
    input  wire [`XLEN * 2 + 1:0] x,
    input  wire [`XLEN * 2 + 1:0] y,
    input  wire [`XLEN * 2 + 1:0] z,

    output wire [`XLEN * 2 + 1:0] c,
    output wire [`XLEN * 2 + 1:0] s
);
	reg [`XLEN * 2 + 1:0] cout;
	reg [`XLEN * 2 + 1:0] sum;
    always @(*)begin:full_add
		integer i;
		for(i = 0; i < `XLEN * 2 + 2; i = i + 1) begin
			sum[i] = x[i] ^ y[i] ^ z[i];
			cout[i] = (x[i] & y[i]) | (x[i] & z[i]) | (z[i] & y[i]);
		end
	end
	assign s = sum;
	assign c = cout << 1;
endmodule