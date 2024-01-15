/*
    Top Module:  wt_buf.v
    Author:      Hao Zhang
    Time:        202307
*/

module wt_buf#(
    parameter   WT_WIDTH         = 8                        ,
    parameter   WT_ADDR_WIDTH    = 7                        ,
    parameter   WT_BUF0_DEPTH    = 73                       ,//DNDM
    parameter   WT_BUF1_DEPTH    = 108                      ,//SR
    parameter   IC_NUM           = 4                        ,
    parameter   OC_NUM           = 4                        ,
    parameter   WT_BUF_WIDTH     = WT_WIDTH*IC_NUM*OC_NUM   ,
    parameter   WT_GRP_NUM       = 8                        ,
    parameter   AXI2W_WIDTH      = WT_BUF_WIDTH*WT_GRP_NUM  ,
    parameter   KNOB_REGOUT      = 0
)
(
    input   wire                                           clk              ,
    input   wire                                           rst_n            ,
    // control                                                              
    input   wire                                           buf_pp_flag      ,
    // axi                                                                  
    input   wire     [      WT_ADDR_WIDTH - 1 : 0]         axi2w_waddr      ,
    input   wire                                           axi2w_wen        ,
    input   wire     [        AXI2W_WIDTH - 1 : 0]         axi2w_wdata      ,
    input   wire     [      WT_ADDR_WIDTH - 1 : 0]         axi2w_raddr      ,
    input   wire                                           axi2w_ren        ,
    output  wire     [        AXI2W_WIDTH - 1 : 0]         axi2w_rdata      ,
    // buf_rd                                                               
    input   wire     [         WT_GRP_NUM - 1 : 0]         sch2w_ren        ,
    input   wire     [      WT_ADDR_WIDTH - 1 : 0]         sch2w_raddr      ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_0_0  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_0_1  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_0_2  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_0_3  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_1_0  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_1_1  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_1_2  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_1_3  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_2_0  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_2_1  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_2_2  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_2_3  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_3_0  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_3_1  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_3_2  ,
    output  reg      [           WT_WIDTH - 1 : 0]         w2sch_rdata_3_3  
);

    wire   [            WT_ADDR_WIDTH - 1 : 0]    wt0_waddr ;
    wire                                          wt0_wen   ;
    wire   [              AXI2W_WIDTH - 1 : 0]    wt0_wdata ;
    wire   [            WT_ADDR_WIDTH - 1 : 0]    wt0_raddr ;
    wire   [               WT_GRP_NUM - 1 : 0]    wt0_ren   ;
    wire   [  WT_BUF_WIDTH*WT_GRP_NUM - 1 : 0]    wt0_rdata ;
    wire   [            WT_ADDR_WIDTH - 1 : 0]    wt1_waddr ;
    wire                                          wt1_wen   ;
    wire   [              AXI2W_WIDTH - 1 : 0]    wt1_wdata ;
    wire   [            WT_ADDR_WIDTH - 1 : 0]    wt1_raddr ;
    wire   [               WT_GRP_NUM - 1 : 0]    wt1_ren   ;
    wire   [  WT_BUF_WIDTH*WT_GRP_NUM - 1 : 0]    wt1_rdata ;
    wire   [  WT_BUF_WIDTH*WT_GRP_NUM - 1 : 0]    w2sch_rdata_w;

    reg    [                        8 - 1 : 0]    sch2w_ren_d;

    genvar                             idx_inst;
    genvar                             idx_buf;

// buffer_wr & buffer_rd
generate
    for(idx_buf = 0; idx_buf < WT_GRP_NUM; idx_buf = idx_buf + 1)begin: wt_pp
        assign wt0_wdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH]     = axi2w_wdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH];
        assign wt0_ren[idx_buf]                                                   = (buf_pp_flag == 0) ? axi2w_ren : sch2w_ren[idx_buf];
        assign axi2w_rdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH]   = (buf_pp_flag == 0) ? wt0_rdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH] : wt1_rdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH];
        assign wt1_wdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH]     = axi2w_wdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH];
        assign wt1_ren[idx_buf]                                                   = (buf_pp_flag == 1) ? axi2w_ren : sch2w_ren[idx_buf];
        assign w2sch_rdata_w[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH] = (buf_pp_flag == 1) ? wt0_rdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH] : wt1_rdata[(idx_buf+1)*WT_BUF_WIDTH - 1 : idx_buf*WT_BUF_WIDTH];
    end
endgenerate

assign wt0_waddr = axi2w_waddr                                      ;
assign wt0_wen   = (buf_pp_flag == 0) ? axi2w_wen : 0               ;
assign wt0_raddr = (buf_pp_flag == 0) ? axi2w_raddr : sch2w_raddr   ;
assign wt1_waddr = axi2w_waddr                                      ;
assign wt1_wen   = (buf_pp_flag == 1) ? axi2w_wen : 0               ;
assign wt1_raddr = (buf_pp_flag == 1) ? axi2w_raddr : sch2w_raddr   ;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        sch2w_ren_d <= 0;
    else
        sch2w_ren_d <= sch2w_ren;
end

always@(*)begin
    case(sch2w_ren_d)
        8'b00000001:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(0*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(0*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(0*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(0*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(0*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(0*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(0*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(0*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(0*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 0*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(0*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(0*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(0*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(0*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(0*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(0*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(0*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 0*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b00000010:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(1*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(1*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(1*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(1*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(1*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(1*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(1*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(1*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(1*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 1*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(1*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(1*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(1*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(1*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(1*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(1*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(1*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 1*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b00000100:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(2*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(2*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(2*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(2*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(2*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(2*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(2*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(2*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(2*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 2*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(2*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(2*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(2*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(2*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(2*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(2*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(2*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 2*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b00001000:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(3*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(3*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(3*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(3*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(3*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(3*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(3*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(3*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(3*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 3*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(3*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(3*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(3*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(3*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(3*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(3*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(3*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 3*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b00010000:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(4*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(4*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(4*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(4*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(4*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(4*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(4*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(4*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(4*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 4*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(4*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(4*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(4*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(4*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(4*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(4*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(4*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 4*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b00100000:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(5*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(5*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(5*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(5*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(5*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(5*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(5*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(5*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(5*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 5*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(5*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(5*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(5*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(5*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(5*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(5*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(5*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 5*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b01000000:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(6*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(6*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(6*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(6*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(6*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(6*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(6*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(6*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(6*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 6*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(6*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(6*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(6*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(6*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(6*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(6*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(6*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 6*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        8'b10000000:begin
            w2sch_rdata_0_0 = w2sch_rdata_w[(7*WT_BUF_WIDTH+1*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+0*WT_WIDTH];
            w2sch_rdata_0_1 = w2sch_rdata_w[(7*WT_BUF_WIDTH+2*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+1*WT_WIDTH];
            w2sch_rdata_0_2 = w2sch_rdata_w[(7*WT_BUF_WIDTH+3*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+2*WT_WIDTH];
            w2sch_rdata_0_3 = w2sch_rdata_w[(7*WT_BUF_WIDTH+4*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+3*WT_WIDTH];
            w2sch_rdata_1_0 = w2sch_rdata_w[(7*WT_BUF_WIDTH+5*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+4*WT_WIDTH];
            w2sch_rdata_1_1 = w2sch_rdata_w[(7*WT_BUF_WIDTH+6*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+5*WT_WIDTH];
            w2sch_rdata_1_2 = w2sch_rdata_w[(7*WT_BUF_WIDTH+7*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+6*WT_WIDTH];
            w2sch_rdata_1_3 = w2sch_rdata_w[(7*WT_BUF_WIDTH+8*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+7*WT_WIDTH];
            w2sch_rdata_2_0 = w2sch_rdata_w[(7*WT_BUF_WIDTH+9*WT_WIDTH) - 1  : 7*WT_BUF_WIDTH+8*WT_WIDTH];
            w2sch_rdata_2_1 = w2sch_rdata_w[(7*WT_BUF_WIDTH+10*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+9*WT_WIDTH];
            w2sch_rdata_2_2 = w2sch_rdata_w[(7*WT_BUF_WIDTH+11*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+10*WT_WIDTH];
            w2sch_rdata_2_3 = w2sch_rdata_w[(7*WT_BUF_WIDTH+12*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+11*WT_WIDTH];
            w2sch_rdata_3_0 = w2sch_rdata_w[(7*WT_BUF_WIDTH+13*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+12*WT_WIDTH];
            w2sch_rdata_3_1 = w2sch_rdata_w[(7*WT_BUF_WIDTH+14*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+13*WT_WIDTH];
            w2sch_rdata_3_2 = w2sch_rdata_w[(7*WT_BUF_WIDTH+15*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+14*WT_WIDTH];
            w2sch_rdata_3_3 = w2sch_rdata_w[(7*WT_BUF_WIDTH+16*WT_WIDTH) - 1 : 7*WT_BUF_WIDTH+15*WT_WIDTH];
        end
        default:begin
            w2sch_rdata_0_0 = 0;
            w2sch_rdata_0_1 = 0;
            w2sch_rdata_0_2 = 0;
            w2sch_rdata_0_3 = 0;
            w2sch_rdata_1_0 = 0;
            w2sch_rdata_1_1 = 0;
            w2sch_rdata_1_2 = 0;
            w2sch_rdata_1_3 = 0;
            w2sch_rdata_2_0 = 0;
            w2sch_rdata_2_1 = 0;
            w2sch_rdata_2_2 = 0;
            w2sch_rdata_2_3 = 0;
            w2sch_rdata_3_0 = 0;
            w2sch_rdata_3_1 = 0;
            w2sch_rdata_3_2 = 0;
            w2sch_rdata_3_3 = 0;
        end 
    endcase
end

// weight ping-pong buffer instantiation
generate
    for(idx_inst = 0; idx_inst < WT_GRP_NUM; idx_inst = idx_inst + 1)begin: buf_inst
        dp_ram_regout #(
            .KNOB_REGOUT                    (KNOB_REGOUT),
            .ADDR_WIDTH                     (WT_ADDR_WIDTH),
            .DATA_WIDTH                     (WT_BUF_WIDTH),
            .DATA_DEPTH                     (WT_BUF0_DEPTH)
        )
        u_wt0_buf( //DNDM
            .clk                            (clk),
            .wr_addr                        (wt0_waddr),
            .wr_en                          (wt0_wen),
            .wr_data                        (wt0_wdata[(idx_inst+1)*WT_BUF_WIDTH - 1 : idx_inst*WT_BUF_WIDTH]),
            .rd_addr                        (wt0_raddr),
            .rd_en                          (wt0_ren[idx_inst]),
            .rd_data                        (wt0_rdata[(idx_inst+1)*WT_BUF_WIDTH - 1 : idx_inst*WT_BUF_WIDTH])
        );
        dp_ram_regout #( //SR
            .KNOB_REGOUT                    (KNOB_REGOUT),
            .ADDR_WIDTH                     (WT_ADDR_WIDTH),
            .DATA_WIDTH                     (WT_BUF_WIDTH),
            .DATA_DEPTH                     (WT_BUF1_DEPTH)
        )
        u_wt1_buf(
            .clk                            (clk),
            .wr_addr                        (wt1_waddr),
            .wr_en                          (wt1_wen),
            .wr_data                        (wt1_wdata[(idx_inst+1)*WT_BUF_WIDTH - 1 : idx_inst*WT_BUF_WIDTH]),
            .rd_addr                        (wt1_raddr),
            .rd_en                          (wt1_ren[idx_inst]),
            .rd_data                        (wt1_rdata[(idx_inst+1)*WT_BUF_WIDTH - 1 : idx_inst*WT_BUF_WIDTH])
        );
    end
endgenerate

endmodule