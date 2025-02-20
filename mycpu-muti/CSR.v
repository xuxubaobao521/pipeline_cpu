`include "define.v"
module CSR(
	input wire								rst,
	input wire 								clk_i,
	input wire [`CSR_WIDTH - 1:0]			D_csr_op_i,
	input wire [`CSR_number_WIDTH - 1:0]	D_csr_read_addr_i,
	input wire 								MD_need_CSR_i,
	input wire [`CSR_number_WIDTH - 1:0]	MD_csr_addr_i,
	input wire [`XLEN - 1:0]				MD_csr_valE_i,
	//output
	output wire [`XLEN - 1:0]       D_csr_data_o
);
	//只需要支持ecall指令、mret指令、CSR指令
	reg [31:0] mstatus;
	reg [31:0] mtvec;
	reg [31:0] mcause;
	reg [31:0] mepc;
	wire [31:0] debug_mstatus = mstatus;
	wire [31:0] debug_mtvec = mtvec;
	wire [31:0] debug_mcause = mcause;
	wire [31:0] debug_mepc = mepc;
	wire D_ecall = D_csr_op_i[`ecall];
	wire D_mret = D_csr_op_i[`mret];
	//写回阶段
	wire W_mstatus = (MD_csr_addr_i == 12'h300);
	wire W_mtvec   = (MD_csr_addr_i == 12'h305);
	wire W_mepc    = (MD_csr_addr_i == 12'h341);
	wire W_mcause  = (MD_csr_addr_i == 12'h342);
	//译码阶段
	wire D_mstatus = (D_csr_read_addr_i == 12'h300);
	wire D_mtvec   = (D_csr_read_addr_i == 12'h305) | D_mret;
	wire D_mepc    = (D_csr_read_addr_i == 12'h341) | D_ecall;
	wire D_mcause  = (D_csr_read_addr_i == 12'h342);

	always @(posedge clk_i) begin
		if(rst) begin
			mtvec   <= 32'd0;
			mstatus <= 32'h1800;
			mepc    <= 32'd0;
			mcause  <= 32'hb; 
		end
		else if(MD_need_CSR_i)begin
			if(W_mstatus) mstatus <= MD_csr_valE_i;
			else if(W_mtvec) mtvec <= MD_csr_valE_i;
			else if(W_mepc) mepc <= MD_csr_valE_i;
			else if(W_mcause) mcause <= MD_csr_valE_i;
		end
	end
	assign D_csr_data_o = 	D_mstatus ? mstatus :
							D_mtvec ? mtvec : 
							D_mepc ? mepc : 
							D_mcause ? mcause : 0;
endmodule

//CSR mepc 保存返回地址 编号0x341
//CSR mtvec 指向trap处理函数入口 编号0x305
//CSR mcause 发生原因 编号 0x342
//CSR mstatus 机器状态 编号 0x341