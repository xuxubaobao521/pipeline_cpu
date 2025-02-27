`include "define.v"
module target_buff(
    input wire                      rst,
    input wire                      clk_i,
    input wire                      jmp_vaild,
    input wire [2:0]                index,
    input wire [`PC_WIDTH - 1:0]   	tag,
    //如果未命中更新PC
    input wire [`PC_WIDTH - 1:0]    nex_PC,

    output wire                     hit,
    output wire [`BTA_WIDTH - 1:0]  addr
);
    //BTB 直接映射
    reg                    vaild   [`BTB_index_WIDTH - 1:0];
    reg [`BTA_WIDTH - 1:0] BTA     [`BTB_index_WIDTH - 1:0];
    reg [`PC_WIDTH - 1:0]  BIA     [`BTB_index_WIDTH - 1:0];
    //查看是否命中
    assign hit = jmp_vaild & vaild[index] & BIA[index] == tag;
    assign addr = hit ? BTA[index] : 32'b0;
    always @(posedge clk_i) begin
        if(rst) begin
            for(int i = 0; i < `BTB_index_WIDTH; i ++)
                vaild[i] = 1'b0;
            end
        else if(~hit & jmp_vaild) begin
            vaild[index] <= 1;
            BIA[index] <= tag;
            BTA[index] <= nex_PC;
        end
    end
endmodule