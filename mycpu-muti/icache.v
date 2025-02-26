`include "define.v"
`define idle 0
`define lookup 1
`define miss 2
`define refill 3
`define done 4
module icache(
		input wire					    rst,
		input wire					    clk_i,
		input wire [`PC_WIDTH-1:0] 	    instr_addr_i,
		
		output wire					    instr_data_ok_o,
		output reg [`INSTR_WIDTH-1:0]  	instr_data_o
	);
	//data tag vaild tag
	reg cache_vaild[`cache_line - 1:0];
	reg cache_dirty[`cache_line - 1:0];
	reg [`cache_tag - 1:0] cache_tag[`cache_line - 1:0];
	reg [`cache_data - 1:0] cache_data[`cache_line - 1:0];
	//分解地址
	wire [`cache_offset - 1:0]  offset = instr_addr_i[3:0];
	wire [`cache_index - 1:0]   index = instr_addr_i[12:4];
	wire [`cache_tag - 1:0]     tag = instr_addr_i[31:13];
	//直接映射 数据块为16B 128bit cache大小为8KB
	reg [2:0] state, nex_state;
	//判断命中否
	wire hit = (state == `lookup) & cache_vaild[index] & (cache_tag[index] == tag);
	//状态机 idle：空闲 lookup：接到一条内存访问 miss：未命中 refill:替换
		always @(*)begin
		case(state)
			`idle:nex_state = `lookup;
			`lookup:nex_state = hit ? `done : `miss;
			`miss:nex_state = `refill;
			`refill:nex_state = `done;
            `done:nex_state = `idle;
		endcase
	end
	integer i;
	always @(posedge clk_i) begin
		if(rst) begin
			state <= 0;
			for(i = 0; i < `cache_line; i = i + 1) begin
				cache_vaild[i] = 0;
			end
		end
		else begin
			state <= nex_state;
		end
	end
	//未命中读内存
	wire [`PC_WIDTH - 1:0] addr = instr_addr_i & {{28{1'b1}},{4{1'b0}}};
    import "DPI-C" function int  instr_dpi_mem_read 	(input int addr  , input int len);
    reg [`XLEN - 1:0] block_0;
    reg [`XLEN - 1:0] block_1;
    reg [`XLEN - 1:0] block_2;
    reg [`XLEN - 1:0] block_3;
	//命中后读数据
	always @(*) begin
		casez(offset)
			4'b00zz: instr_data_o = cache_data[index][31:0];
			4'b01zz: instr_data_o = cache_data[index][63:32];
			4'b10zz: instr_data_o = cache_data[index][95:64];
			4'b11zz: instr_data_o = cache_data[index][127:96];
		endcase
	end
	always @(posedge clk_i) begin
		if(state == `refill) begin
            cache_data[index] <= {block_3, block_2, block_1, block_0};
		    cache_tag[index] <= tag;
		    cache_vaild[index] <= 1;
		    cache_dirty[index] <= 1;
        end
		else if(state == `miss) begin
			block_0 <= instr_dpi_mem_read(addr + 0, 4);
    		block_1 <= instr_dpi_mem_read(addr + 4, 4);
   			block_2 <= instr_dpi_mem_read(addr + 8, 4);
    		block_3 <= instr_dpi_mem_read(addr + 12, 4);
		end
	end
    assign instr_data_ok_o = state == `done;
endmodule