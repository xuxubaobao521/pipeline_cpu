`include "define.v"
module memory(
	//input
	input clk_i,
	input wire [`STORE_WIDTH - 1:0]  	ED_store_op_i,
	input wire [`LOAD_WIDTH - 1:0]	 	ED_load_op_i,
	input wire [`XLEN - 1:0]         	ED_valE_i,
	input wire [`XLEN - 1:0]			ED_rs2_data_i,
	input wire 							execute_vaild_i,
	//output
	output wire [`XLEN - 1:0]        	M_valM_o
);
	//load OP
	wire load_lb = ED_load_op_i[`load_lb];
	wire load_lh = ED_load_op_i[`load_lh];
	wire load_lw = ED_load_op_i[`load_lw];
	wire load_ld = ED_load_op_i[`load_ld];
	wire load_lbu = ED_load_op_i[`load_lbu];
	wire load_lhu = ED_load_op_i[`load_lhu];
	wire load_lwu = ED_load_op_i[`load_lwu];
	//store
	wire store_sb = ED_store_op_i[`store_sb];
	wire store_sh = ED_store_op_i[`store_sh];
	wire store_sw = ED_store_op_i[`store_sw];
	wire store_sd = ED_store_op_i[`store_sd];
	
	//load / store
	wire op_load = (load_lb | load_lh | load_lw | load_ld | load_lbu | load_lhu | load_lwu) & execute_vaild_i;
	wire op_store = (store_sb | store_sh | store_sw | store_sd) & execute_vaild_i;
	
	import "DPI-C" function void dpi_mem_write(input int addr, input int data, int len);
	import "DPI-C" function int  dpi_mem_read (input int addr  , input int len);
	reg [`XLEN - 1:0] data;
//读取内存，每次读取4个字节，然后根据需要，再对读出来的数据进行处理
always @(*) begin
    if(op_load) begin
	data = dpi_mem_read(ED_valE_i, 4);
    end
    else begin
		data = 32'B0;
    end
end

//写入
always @(posedge clk_i) begin
	if(store_sb) begin
		dpi_mem_write(ED_valE_i, ED_rs2_data_i, 1);
	end
	else if(store_sh) begin
		dpi_mem_write(ED_valE_i, ED_rs2_data_i, 2);	
	end
	else if(store_sw) begin
		dpi_mem_write(ED_valE_i, ED_rs2_data_i, 4);			
	end
end
	
	//data load
	assign M_valM_o = load_lb ? {{24{data[7]}},data[7:0]} :
					 load_lh ? {{16{data[15]}},data[15:0]} :
					 load_lw ? data :
					 load_lbu ? {{24{1'b0}},data[7:0]} :
					 {{16{1'b0}},data[15:0]};
endmodule

