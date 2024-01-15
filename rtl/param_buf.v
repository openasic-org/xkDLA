/*
    Top Module:  param_buf.v
    Author:      Hao Zhang
    Time:        202308
*/

module param_buf#(
    parameter   BIAS_DATA_WIDTH = 16                                                             ,
    parameter   HBM_DATA_WIDTH  = 16                                                             ,
    parameter   LBM_DATA_WIDTH  = 16                                                             ,
    parameter   OC_NUM          = 4                                                              ,
    parameter   P_ADDR_WIDTH    = 5                                                              ,
    parameter   P_BUF0_DEPTH    = 17                                                             , //DNDM
    parameter   P_BUF1_DEPTH    = 20                                                             , //SR
    parameter   P_BUF_WIDTH     = (BIAS_DATA_WIDTH + HBM_DATA_WIDTH + LBM_DATA_WIDTH) * OC_NUM   ,
    parameter   P2PU_RD_WIDTH   = BIAS_DATA_WIDTH + HBM_DATA_WIDTH + LBM_DATA_WIDTH              
)
(
    input   wire                                  clk               ,
    input   wire                                  rst_n             ,
    // control                                                      
    input   wire                                  buf_pp_flag       ,
    // axi                                                          
    input   wire    [    P_ADDR_WIDTH - 1 : 0]    axi2p_waddr       ,
    input   wire                                  axi2p_wen         ,
    input   wire    [     P_BUF_WIDTH - 1 : 0]    axi2p_wdata       ,
    input   wire    [    P_ADDR_WIDTH - 1 : 0]    axi2p_raddr       ,
    input   wire                                  axi2p_ren         ,
    output  wire    [     P_BUF_WIDTH - 1 : 0]    axi2p_rdata       ,
    // buf_rd                                                       
    input   wire                                  pu2p_ren          ,
    input   wire    [    P_ADDR_WIDTH - 1 : 0]    pu2p_raddr        ,
    output  wire    [   P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_0      , //c 0/4...
    output  wire    [   P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_1      , //c 1/5...
    output  wire    [   P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_2      , //c 2/6...
    output  wire    [   P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_3        //c 3/7...
);

    wire    [ P_ADDR_WIDTH - 1 : 0]      b0_waddr   ;
    wire                                 b0_wen     ;
    wire    [  P_BUF_WIDTH - 1 : 0]      b0_wdata   ;
    wire    [ P_ADDR_WIDTH - 1 : 0]      b0_raddr   ;
    wire                                 b0_ren     ;
    wire    [  P_BUF_WIDTH - 1 : 0]      b0_rdata   ;
    wire    [ P_ADDR_WIDTH - 1 : 0]      b1_waddr   ;
    wire                                 b1_wen     ;
    wire    [  P_BUF_WIDTH - 1 : 0]      b1_wdata   ;
    wire    [ P_ADDR_WIDTH - 1 : 0]      b1_raddr   ;
    wire                                 b1_ren     ;
    wire    [  P_BUF_WIDTH - 1 : 0]      b1_rdata   ;

// buffer_wr & buffer_rd
assign b0_waddr     = axi2p_waddr;
assign b0_wen       = (buf_pp_flag == 0) ? axi2p_wen   : 0;
assign b0_wdata     = axi2p_wdata;
assign b0_raddr     = (buf_pp_flag == 0) ? axi2p_raddr : pu2p_raddr;
assign b0_ren       = (buf_pp_flag == 0) ? axi2p_ren   : pu2p_ren;
assign b1_waddr     = axi2p_waddr;
assign b1_wen       = (buf_pp_flag == 1) ? axi2p_wen   : 0;
assign b1_wdata     = axi2p_wdata;
assign b1_raddr     = (buf_pp_flag == 1) ? axi2p_raddr : pu2p_raddr;
assign b1_ren       = (buf_pp_flag == 1) ? axi2p_ren   : pu2p_ren;
assign axi2p_rdata  = (buf_pp_flag == 0) ? b0_rdata    : b1_rdata;
assign p2pu_rdata_0 = (buf_pp_flag == 0) ? b1_rdata[1*P2PU_RD_WIDTH - 1 : 0*P2PU_RD_WIDTH] : b0_rdata[1*P2PU_RD_WIDTH - 1 : 0*P2PU_RD_WIDTH];
assign p2pu_rdata_1 = (buf_pp_flag == 0) ? b1_rdata[2*P2PU_RD_WIDTH - 1 : 1*P2PU_RD_WIDTH] : b0_rdata[2*P2PU_RD_WIDTH - 1 : 1*P2PU_RD_WIDTH];
assign p2pu_rdata_2 = (buf_pp_flag == 0) ? b1_rdata[3*P2PU_RD_WIDTH - 1 : 2*P2PU_RD_WIDTH] : b0_rdata[3*P2PU_RD_WIDTH - 1 : 2*P2PU_RD_WIDTH];
assign p2pu_rdata_3 = (buf_pp_flag == 0) ? b1_rdata[4*P2PU_RD_WIDTH - 1 : 3*P2PU_RD_WIDTH] : b0_rdata[4*P2PU_RD_WIDTH - 1 : 3*P2PU_RD_WIDTH];

// bias ping-pong buffer instantiation
dp_ram #(
    .ADDR_WIDTH                     (P_ADDR_WIDTH   ),
    .DATA_WIDTH                     (P_BUF_WIDTH    ),
    .DATA_DEPTH                     (P_BUF0_DEPTH   )
)
u_b0_buf( //DNDM
    .clk                            (clk            ),
    .wr_addr                        (b0_waddr       ),
    .wr_en                          (b0_wen         ),
    .wr_data                        (b0_wdata       ),
    .rd_addr                        (b0_raddr       ),
    .rd_en                          (b0_ren         ),
    .rd_data                        (b0_rdata       )
);
dp_ram #( //SR
    .ADDR_WIDTH                     (P_ADDR_WIDTH   ),
    .DATA_WIDTH                     (P_BUF_WIDTH    ),
    .DATA_DEPTH                     (P_BUF1_DEPTH   )
)
u_b1_buf(
    .clk                            (clk            ),
    .wr_addr                        (b1_waddr       ),
    .wr_en                          (b1_wen         ),
    .wr_data                        (b1_wdata       ),
    .rd_addr                        (b1_raddr       ),
    .rd_en                          (b1_ren         ),
    .rd_data                        (b1_rdata       )
);

endmodule