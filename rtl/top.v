module top #(
    parameter    REG_IFMH_WIDTH       = 10                                                             ,
    parameter    REG_IFMW_WIDTH       = 10                                                             ,
    parameter    REG_TILEH_WIDTH      = 6                                                              ,
    parameter    REG_TNY_WIDTH        = 6                                                              ,
    parameter    REG_TNX_WIDTH        = 6                                                              ,
    parameter    REG_TLW_WIDTH        = 6                                                              ,
    parameter    REG_TLH_WIDTH        = 6                                                              ,
    parameter    TILE_BASE_W          = 32                                                             ,
    parameter    REG_IH_WIDTH         = 6                                                              ,
    parameter    REG_OH_WIDTH         = 6                                                              ,
    parameter    REG_IW_WIDTH         = 6                                                              ,
    parameter    REG_OW_WIDTH         = 6                                                              ,
    parameter    REG_IC_WIDTH         = 6                                                              ,
    parameter    REG_OC_WIDTH         = 6                                                              ,
    parameter    REG_AF_WIDTH         = 1                                                              ,
    parameter    REG_HBM_SFT_WIDTH    = 6                                                              ,
    parameter    REG_LBM_SFT_WIDTH    = 6                                                              ,
    parameter    WT_WIDTH             = 8                                                              ,
    parameter    WT_ADDR_WIDTH        = 7                                                              ,
    parameter    WT_BUF0_DEPTH        = 73                                                             ,//DNDM
    parameter    WT_BUF1_DEPTH        = 108                                                            ,//SR
    parameter    IC_NUM               = 4                                                              ,
    parameter    OC_NUM               = 4                                                              ,
    parameter    WT_BUF_WIDTH         = WT_WIDTH*IC_NUM*OC_NUM                                         ,
    parameter    WT_GRP_NUM           = 8                                                              ,
    parameter    AXI2W_WIDTH          = WT_BUF_WIDTH*WT_GRP_NUM                                        ,
    parameter    RESX_ADDR_WIDTH      = 6                                                              ,
    parameter    RESX_BUF_DEPTH       = 32                                                             ,
    parameter    RESX_LBUF_WIDTH      = 232                                                            ,
    parameter    RESX_SBUF_WIDTH      = 24                                                             ,
    parameter    RESY_ADDR_WIDTH      = 8                                                              ,
    parameter    RESY_BUF_DEPTH       = 128                                                            ,
    parameter    RESY_BUF_WIDTH       = 232                                                            ,
    parameter    RESXY_ADDR_WIDTH     = 8                                                              ,
    parameter    RESXY_BUF_DEPTH      = 132                                                            ,
    parameter    RESXY_BUF_WIDTH      = 24                                                             ,
    parameter    BIAS_DATA_WIDTH      = 16                                                             ,
    parameter    HBM_DATA_WIDTH       = 16                                                             ,
    parameter    LBM_DATA_WIDTH       = 16                                                             ,
    parameter    P_ADDR_WIDTH         = 5                                                              ,
    parameter    P_BUF0_DEPTH         = 17                                                             , //DNDM
    parameter    P_BUF1_DEPTH         = 20                                                             , //SR
    parameter    P_BUF_WIDTH          = (BIAS_DATA_WIDTH + HBM_DATA_WIDTH + LBM_DATA_WIDTH) * OC_NUM   ,
    parameter    P2PU_RD_WIDTH        = BIAS_DATA_WIDTH + HBM_DATA_WIDTH + LBM_DATA_WIDTH              ,
    parameter    OLPX_L1_ADDR_WIDTH   = 4                                                              ,
    parameter    OLPX_L1_BUF_DEPTH    = 8                                                              ,
    parameter    OLPX_BUF_NUM         = 4                                                              ,
    parameter    OLPX_BUF_WIDTH       = 32                                                             ,
    parameter    OLPX_ADDR_WIDTH      = 8                                                              ,
    parameter    OLPX_BUF_DEPTH       = 128                                                            ,
    parameter    OLPY_L1_ADDR_WIDTH   = 6                                                              ,
    parameter    OLPY_L1_BUF_DEPTH    = 32                                                             ,
    parameter    OLPY_BUF_NUM         = 28                                                             ,
    parameter    OLPY_BUF_WIDTH       = 224                                                            ,
    parameter    OLPY_ADDR_WIDTH      = 9                                                              ,
    parameter    OLPY_BUF_DEPTH       = 320                                                            ,
    parameter    OLPXY_L1_ADDR_WIDTH  = 5                                                              ,
    parameter    OLPXY_L1_BUF_DEPTH   = 17                                                             ,
    parameter    OLPXY_BUF_NUM        = 4                                                              ,
    parameter    OLPXY_BUF_WIDTH      = 32                                                             ,
    parameter    OLPXY_ADDR_WIDTH     = 8                                                              ,
    parameter    OLPXY_BUF_DEPTH      = 170                                                            ,
    parameter    FE_ADDR_WIDTH        = 6                                                              ,
    parameter    FE_BUF_DEPTH         = 32                                                             ,
    parameter    FE_BUF_WIDTH         = 32*8                                                           ,
    parameter    AXI2F_DATA_WIDTH     = 1024                                                           ,
    parameter    AXI2F_ADDR_WIDTH     = FE_ADDR_WIDTH + 2                                              ,// 2 bit MSB for buf-grouping: 00:_0_x/01:_1_x/10:_2_x/11:_3_x grp
    parameter    IFM_WIDTH            = 8                                                              ,
    parameter    SCH_COL_NUM          = 36                                                             ,
    parameter    PE_COL_NUM           = 32                                                             ,
    parameter    PE_H_NUM             = 4                                                              ,
    parameter    PE_IC_NUM            = IC_NUM                                                         ,
    parameter    PE_OC_NUM            = OC_NUM                                                         ,
    parameter    WIDTH_KSIZE          = 3                                                              ,
    parameter    WIDTH_FEA_X          = 6                                                              ,
    parameter    WIDTH_FEA_Y          = 6                                                              ,
    parameter    OLPY_L234_DEPTH      = 64                                                             ,
    parameter    OLPX_L234_DEPTH      = 32                                                             ,
    parameter    OLPXY_L234_DEPTH     = 34                                                             ,
    parameter    PE_OUTPUT_WD         = 18                                                             ,
    parameter    PU_RF_ACCU_WD        = 32 * 18                                                        ,
    parameter    KNOB_REGOUT          = 0
)
(
    input     wire                                     clk            ,
    input     wire                                     rst_n          ,
    input     wire    [                     32-1:0]    ctrl_reg       ,
    output    wire    [                     32-1:0]    state_reg      ,
    input     wire    [                     32-1:0]    reg0           ,
    input     wire    [                     32-1:0]    reg1           ,
    input     wire    [      WT_ADDR_WIDTH - 1 : 0]    axi2w_waddr    ,
    input     wire                                     axi2w_wen      ,
    input     wire    [        AXI2W_WIDTH - 1 : 0]    axi2w_wdata    ,
    input     wire    [      WT_ADDR_WIDTH - 1 : 0]    axi2w_raddr    ,
    input     wire                                     axi2w_ren      ,
    output    wire    [        AXI2W_WIDTH - 1 : 0]    axi2w_rdata    ,
    input     wire    [       P_ADDR_WIDTH - 1 : 0]    axi2p_waddr    ,
    input     wire                                     axi2p_wen      ,
    input     wire    [        P_BUF_WIDTH - 1 : 0]    axi2p_wdata    ,
    input     wire    [       P_ADDR_WIDTH - 1 : 0]    axi2p_raddr    ,
    input     wire                                     axi2p_ren      ,
    output    wire    [        P_BUF_WIDTH - 1 : 0]    axi2p_rdata    ,
    input     wire    [   AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_waddr    ,
    input     wire                                     axi2f_wen      ,
    input     wire    [   AXI2F_DATA_WIDTH - 1 : 0]    axi2f_wdata    ,
    input     wire    [   AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_raddr    ,
    input     wire                                     axi2f_ren      ,
    output    wire    [   AXI2F_DATA_WIDTH - 1 : 0]    axi2f_rdata    
);

    wire                                                     layer_done               ;
    wire                                                     layer_start              ;
    wire    [                                      1 : 0]    stat_ctrl                ;
    wire    [                                      2 : 0]    cnt_layer                ;
    wire                                                     tile_switch_r            ;
    wire                                                     model_switch_r           ;
    wire                                                     tile_switch              ;
    wire                                                     model_switch             ;
    wire                                                     model_switch_layer       ;
    wire                                                     nn_proc                  ;
    wire    [                      REG_TNX_WIDTH - 1 : 0]    tile_tot_num_x           ;
    wire    [                       REG_IH_WIDTH - 1 : 0]    tile_in_h                ;
    wire    [                       REG_OH_WIDTH - 1 : 0]    tile_out_h               ;
    wire    [                       REG_OH_WIDTH     : 0]    tile_out_h_w             ;
    wire    [                       REG_IW_WIDTH - 1 : 0]    tile_in_w                ;
    wire    [                       REG_OW_WIDTH - 1 : 0]    tile_out_w               ;
    wire    [                       REG_IC_WIDTH - 1 : 0]    tile_in_c                ;
    wire    [                       REG_OC_WIDTH - 1 : 0]    tile_out_c               ;
    wire    [                                      2 : 0]    ksize                    ;
    wire    [                                      2 : 0]    ksize_nxt                ;
    wire    [                                      3 : 0]    tile_loc                 ;
    wire                                                     x4_shuffle_vld           ;
    wire    [                       REG_AF_WIDTH - 1 : 0]    prl_vld                  ;
    wire    [                                      1 : 0]    res_proc_type            ;
    wire    [                  REG_HBM_SFT_WIDTH - 1 : 0]    pu_hbm_shift             ;
    wire    [                  REG_LBM_SFT_WIDTH - 1 : 0]    pu_lbm_shift             ;
    wire                                                     buf_pp_flag              ;

    wire    [                         WT_GRP_NUM - 1 : 0]    sch2w_ren                ;
    wire    [                      WT_ADDR_WIDTH - 1 : 0]    sch2w_raddr              ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_0_0          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_0_1          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_0_2          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_0_3          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_1_0          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_1_1          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_1_2          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_1_3          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_2_0          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_2_1          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_2_2          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_2_3          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_3_0          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_3_1          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_3_2          ;
    wire    [                           WT_WIDTH - 1 : 0]    w2sch_rdata_3_3          ;

    wire    [  16                                - 1 : 0]    pu2rx_ren                ;
    wire    [  RESX_ADDR_WIDTH                   - 1 : 0]    pu2rx_raddr              ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_0_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_0_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_0_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_0_3          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_1_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_1_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_1_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_1_3          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_2_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_2_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_2_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_2_3          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_3_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_3_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_3_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    rx2pu_rdata_3_3          ;
    wire    [  16                                - 1 : 0]    pu2rx_wen                ;
    wire    [  RESX_ADDR_WIDTH                   - 1 : 0]    pu2rx_waddr_0            ;
    wire    [  RESX_ADDR_WIDTH                   - 1 : 0]    pu2rx_waddr_1            ;
    wire    [  RESX_ADDR_WIDTH                   - 1 : 0]    pu2rx_waddr_2            ;
    wire    [  RESX_ADDR_WIDTH                   - 1 : 0]    pu2rx_waddr_3            ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_0_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_0_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_0_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_0_3          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_1_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_1_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_1_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_1_3          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_2_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_2_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_2_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_2_3          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_3_0          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_3_1          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_3_2          ;
    wire    [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : 0]    pu2rx_wdata_3_3          ;
    wire    [  12                                - 1 : 0]    pu2ry_ren                ;
    wire    [  RESY_ADDR_WIDTH                   - 1 : 0]    pu2ry_raddr              ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_0_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_0_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_0_2          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_1_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_1_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_1_2          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_2_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_2_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_2_2          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_3_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_3_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    ry2pu_rdata_3_2          ;
    wire    [  12                                - 1 : 0]    pu2ry_wen                ;
    wire    [  RESY_ADDR_WIDTH                   - 1 : 0]    pu2ry_waddr              ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_0_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_0_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_0_2          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_1_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_1_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_1_2          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_2_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_2_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_2_2          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_3_0          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_3_1          ;
    wire    [  RESY_BUF_WIDTH                    - 1 : 0]    pu2ry_wdata_3_2          ;
    wire    [  12                                - 1 : 0]    pu2rxy_ren               ;
    wire    [  RESXY_ADDR_WIDTH                  - 1 : 0]    pu2rxy_raddr             ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_0_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_0_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_0_2         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_1_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_1_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_1_2         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_2_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_2_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_2_2         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_3_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_3_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    rxy2pu_rdata_3_2         ;
    wire    [  12                                - 1 : 0]    pu2rxy_wen               ;
    wire    [  RESXY_ADDR_WIDTH                  - 1 : 0]    pu2rxy_waddr             ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_0_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_0_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_0_2         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_1_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_1_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_1_2         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_2_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_2_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_2_2         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_3_0         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_3_1         ;
    wire    [  RESXY_BUF_WIDTH                   - 1 : 0]    pu2rxy_wdata_3_2         ;

    wire                                                     pu2p_ren                 ;
    wire    [                       P_ADDR_WIDTH - 1 : 0]    pu2p_raddr               ;
    wire    [                      P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_0             ;
    wire    [                      P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_1             ;
    wire    [                      P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_2             ;
    wire    [                      P2PU_RD_WIDTH - 1 : 0]    p2pu_rdata_3             ;

    wire    [                                  4 - 1 : 0]    sch2x_ren                ;
    wire    [                    OLPX_ADDR_WIDTH - 1 : 0]    sch2x_raddr_0            ;
    wire    [                    OLPX_ADDR_WIDTH - 1 : 0]    sch2x_raddr_1            ;
    wire    [                    OLPX_ADDR_WIDTH - 1 : 0]    sch2x_raddr_2            ;
    wire    [                    OLPX_ADDR_WIDTH - 1 : 0]    sch2x_raddr_3            ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_0          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_1          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_2          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_3          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_0          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_1          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_2          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_3          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_0          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_1          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_2          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_3          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_0          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_1          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_2          ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_3          ;
    wire    [                                  4 - 1 : 0]    sch2y_ren                ;
    wire    [                    OLPY_ADDR_WIDTH - 1 : 0]    sch2y_raddr              ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_0          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_1          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_2          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_3          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_0          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_1          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_2          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_3          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_0          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_1          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_2          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_3          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_0          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_1          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_2          ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_3          ;
    wire    [                                  4 - 1 : 0]    sch2xy_evn_ren           ;
    wire    [                                  4 - 1 : 0]    sch2xy_odd_ren           ;
    wire    [                   OLPXY_ADDR_WIDTH - 1 : 0]    sch2xy_raddr_evn         ;
    wire    [                   OLPXY_ADDR_WIDTH - 1 : 0]    sch2xy_raddr_odd         ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_3     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_0     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_1     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_2     ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_3     ;
    wire    [                                 16 - 1 : 0]    pu2x_wen                 ;
    wire    [                    OLPX_ADDR_WIDTH - 1 : 0]    pu2x_waddr               ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_0           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_1           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_2           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_3           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_0           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_1           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_2           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_3           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_0           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_1           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_2           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_3           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_0           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_1           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_2           ;
    wire    [                     OLPX_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_3           ;
    wire    [                                 16 - 1 : 0]    pu2y_wen                 ;
    wire    [                    OLPY_ADDR_WIDTH - 1 : 0]    pu2y_waddr               ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_0           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_1           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_2           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_3           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_0           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_1           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_2           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_3           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_0           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_1           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_2           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_3           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_0           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_1           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_2           ;
    wire    [                     OLPY_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_3           ;
    wire    [                                 16 - 1 : 0]    pu2xy_evn_wen            ;
    wire    [                   OLPXY_ADDR_WIDTH - 1 : 0]    pu2xy_evn_waddr          ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_3      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_3      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_3      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_3      ;
    wire    [                                 16 - 1 : 0]    pu2xy_odd_wen            ;
    wire    [                   OLPXY_ADDR_WIDTH - 1 : 0]    pu2xy_odd_waddr          ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_3      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_3      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_3      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_0      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_1      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_2      ;
    wire    [                    OLPXY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_3      ;

    wire    [                                  4 - 1 : 0]    sch2fe_ren               ;
    wire    [                      FE_ADDR_WIDTH - 1 : 0]    sch2fe_raddr_0           ;
    wire    [                      FE_ADDR_WIDTH - 1 : 0]    sch2fe_raddr_1           ;
    wire    [                      FE_ADDR_WIDTH - 1 : 0]    sch2fe_raddr_2           ;
    wire    [                      FE_ADDR_WIDTH - 1 : 0]    sch2fe_raddr_3           ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_0_0         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_0_1         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_0_2         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_0_3         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_1_0         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_1_1         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_1_2         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_1_3         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_2_0         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_2_1         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_2_2         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_2_3         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_3_0         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_3_1         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_3_2         ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    fe2sch_rdata_3_3         ;
    wire    [                                 16 - 1 : 0]    pu2fe_wen                ;
    wire    [                      FE_ADDR_WIDTH - 1 : 0]    pu2fe_waddr              ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_0_0          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_0_1          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_0_2          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_0_3          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_1_0          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_1_1          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_1_2          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_1_3          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_2_0          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_2_1          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_2_2          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_2_3          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_3_0          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_3_1          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_3_2          ;
    wire    [                       FE_BUF_WIDTH - 1 : 0]    pu2fe_wdata_3_3          ;

    wire                                                     pe2sch_rdy               ;
    wire                                                     sch2pe_row_start         ;
    wire                                                     sch2pe_row_done          ;
    wire                                                     sch2pe_vld               ;
    wire    [PE_COL_NUM                          - 1 : 0]    mux_col_vld              ;
    wire    [PE_H_NUM                            - 1 : 0]    mux_row_vld              ;
    wire    [PE_IC_NUM                           - 1 : 0]    mux_array_vld            ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_0_0          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_0_1          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_0_2          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_0_3          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_1_0          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_1_1          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_1_2          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_1_3          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_2_0          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_2_1          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_2_2          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_2_3          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_3_0          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_3_1          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_3_2          ;
    wire    [PE_COL_NUM * IFM_WIDTH              - 1 : 0]    sch2pe_data_3_3          ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_0_0        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_0_1        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_0_2        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_0_3        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_1_0        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_1_1        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_1_2        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_1_3        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_2_0        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_2_1        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_2_2        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_2_3        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_3_0        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_3_1        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_3_2        ;
    wire    [WT_WIDTH                            - 1 : 0]    sch2pe_weight_3_3        ;

    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_0_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_0_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_0_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_0_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_1_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_1_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_1_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_1_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_2_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_2_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_2_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_2_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_3_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_3_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_3_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_0_3_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_0_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_0_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_0_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_0_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_1_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_1_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_1_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_1_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_2_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_2_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_2_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_2_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_3_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_3_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_3_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_1_3_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_0_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_0_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_0_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_0_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_1_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_1_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_1_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_1_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_2_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_2_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_2_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_2_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_3_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_3_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_3_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_2_3_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_0_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_0_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_0_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_0_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_1_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_1_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_1_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_1_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_2_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_2_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_2_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_2_3      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_3_0      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_3_1      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_3_2      ;
    wire    [PE_OUTPUT_WD * PE_COL_NUM           - 1 : 0]    pe_row_output_3_3_3      ;
    wire                                                     pe2pu_vld                ;
    wire                                                     pu2pe_rdy                ;

    wire    [AXI2F_DATA_WIDTH - 1                    : 0]    axi2f_wdata_w            ;
    wire    [AXI2F_DATA_WIDTH - 1                    : 0]    axi2f_rdata_w            ;

ctrl_engine #(
    .REG_IFMH_WIDTH                (REG_IFMH_WIDTH                         ),
    .REG_IFMW_WIDTH                (REG_IFMW_WIDTH                         ),
    .REG_TILEH_WIDTH               (REG_TILEH_WIDTH                        ),
    .REG_TNY_WIDTH                 (REG_TNY_WIDTH                          ),
    .REG_TNX_WIDTH                 (REG_TNX_WIDTH                          ),
    .REG_TLW_WIDTH                 (REG_TLW_WIDTH                          ),
    .REG_TLH_WIDTH                 (REG_TLH_WIDTH                          ),
    .TILE_BASE_W                   (TILE_BASE_W                            ),
    .REG_IH_WIDTH                  (REG_IH_WIDTH                           ),
    .REG_OH_WIDTH                  (REG_OH_WIDTH                           ),
    .REG_IW_WIDTH                  (REG_IW_WIDTH                           ),
    .REG_OW_WIDTH                  (REG_OW_WIDTH                           ),
    .REG_IC_WIDTH                  (REG_IC_WIDTH                           ),
    .REG_OC_WIDTH                  (REG_OC_WIDTH                           ),
    .REG_AF_WIDTH                  (REG_AF_WIDTH                           ),
    .REG_HBM_SFT_WIDTH             (REG_HBM_SFT_WIDTH                      ),
    .REG_LBM_SFT_WIDTH             (REG_LBM_SFT_WIDTH                      )
)
u_ctrl_engine (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .ctrl_reg                      (ctrl_reg                               ),
    .state_reg                     (state_reg                              ),
    .reg0                          (reg0                                   ),
    .reg1                          (reg1                                   ),
    .layer_done                    (layer_done                             ),
    .layer_start                   (layer_start                            ),
    .stat_ctrl                     (stat_ctrl                              ),
    .cnt_layer                     (cnt_layer                              ),
    .tile_switch_r                 (tile_switch_r                          ),
    .model_switch_r                (model_switch_r                         ),
    .tile_switch                   (tile_switch                            ),
    .model_switch                  (model_switch                           ),
    .model_switch_layer            (model_switch_layer                     ),
    .nn_proc                       (nn_proc                                ),
    .tile_tot_num_x                (tile_tot_num_x                         ),
    .tile_in_h                     (tile_in_h                              ),
    .tile_out_h                    (tile_out_h                             ),
    .tile_in_w                     (tile_in_w                              ),
    .tile_out_w                    (tile_out_w                             ),
    .tile_in_c                     (tile_in_c                              ),
    .tile_out_c                    (tile_out_c                             ),
    .ksize                         (ksize                                  ),
    .ksize_nxt                     (ksize_nxt                              ),
    .tile_loc                      (tile_loc                               ),
    .x4_shuffle_vld                (x4_shuffle_vld                         ),
    .prl_vld                       (prl_vld                                ),
    .res_proc_type                 (res_proc_type                          ),
    .pu_hbm_shift                  (pu_hbm_shift                           ),
    .pu_lbm_shift                  (pu_lbm_shift                           ),
    .buf_pp_flag                   (buf_pp_flag                            )
);

scheduler #(
    .REG_IH_WIDTH                  (REG_IH_WIDTH                           ),
    .REG_IW_WIDTH                  (REG_IW_WIDTH                           ),
    .REG_IC_WIDTH                  (REG_IC_WIDTH                           ),
    .REG_OH_WIDTH                  (REG_OH_WIDTH                           ),
    .REG_OW_WIDTH                  (REG_OW_WIDTH                           ),
    .REG_OC_WIDTH                  (REG_OC_WIDTH                           ),
    .IFM_WIDTH                     (IFM_WIDTH                              ),
    .SCH_COL_NUM                   (SCH_COL_NUM                            ),
    .WT_WIDTH                      (WT_WIDTH                               ),
    .PE_COL_NUM                    (PE_COL_NUM                             ),
    .PE_H_NUM                      (PE_H_NUM                               ),
    .PE_IC_NUM                     (PE_IC_NUM                              ),
    .PE_OC_NUM                     (PE_OC_NUM                              ),
    .FE_BUF_WIDTH                  (FE_BUF_WIDTH                           ),
    .X_BUF_WIDTH                   (OLPX_BUF_NUM                           ),
    .Y_BUF_WIDTH                   (OLPY_BUF_NUM                           ),
    .XY_BUF_WIDTH                  (OLPXY_BUF_NUM                          ),
    .FE_ADDR_WIDTH                 (FE_ADDR_WIDTH                          ),
    .WT_ADDR_WIDTH                 (WT_ADDR_WIDTH                          ),
    .X_ADDR_WIDTH                  (OLPX_ADDR_WIDTH                        ),
    .Y_ADDR_WIDTH                  (OLPY_ADDR_WIDTH                        ),
    .XY_ADDR_WIDTH                 (OLPXY_ADDR_WIDTH                       ),
    .WIDTH_KSIZE                   (WIDTH_KSIZE                            ),
    .WIDTH_FEA_X                   (WIDTH_FEA_X                            ),
    .WIDTH_FEA_Y                   (WIDTH_FEA_Y                            ),
    .Y_L234_DEPTH                  (OLPY_L234_DEPTH                        ),
    .X_L234_DEPTH                  (OLPX_L234_DEPTH                        ),
    .XY_L234_DEPTH                 (OLPXY_L234_DEPTH                       ),
    .KNOB_REGOUT                   (KNOB_REGOUT                            )
)
u_scheduler (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .tile_switch                   (tile_switch                            ),
    .ctrl2sch_layer_start          (layer_start                            ),
    .cnt_layer                     (cnt_layer                              ),
    .tile_loc                      (tile_loc                               ),
    .ksize                         (ksize                                  ),
    .pe2sch_rdy                    (pe2sch_rdy                             ),
    .tile_in_h                     (tile_in_h                              ),
    .tile_out_h                    (tile_out_h                             ),
    .tile_in_w                     (tile_in_w                              ),
    .tile_out_w                    (tile_out_w                             ),
    .tile_in_c                     (tile_in_c                              ),
    .tile_out_c                    (tile_out_c                             ),
    .model_switch                  (model_switch                           ),
    .nn_proc                       (nn_proc                                ),
    .tile_tot_num_x                (tile_tot_num_x                         ),
    .sch2fe_ren                    (sch2fe_ren                             ),
    .sch2fe_raddr_0                (sch2fe_raddr_0                         ),
    .sch2fe_raddr_1                (sch2fe_raddr_1                         ),
    .sch2fe_raddr_2                (sch2fe_raddr_2                         ),
    .sch2fe_raddr_3                (sch2fe_raddr_3                         ),
    .sch2x_ren                     (sch2x_ren                              ),
    .sch2x_raddr_0                 (sch2x_raddr_0                          ),
    .sch2x_raddr_1                 (sch2x_raddr_1                          ),
    .sch2x_raddr_2                 (sch2x_raddr_2                          ),
    .sch2x_raddr_3                 (sch2x_raddr_3                          ),
    .wt_buf_rd_en                  (sch2w_ren                              ),
    .wt_buf_rd_addr                (sch2w_raddr                            ),
    .sch2y_ren                     (sch2y_ren                              ),
    .sch2y_raddr                   (sch2y_raddr                            ),
    .sch2xy_evn_ren                (sch2xy_evn_ren                         ),
    .sch2xy_odd_ren                (sch2xy_odd_ren                         ),
    .sch2xy_raddr_evn              (sch2xy_raddr_evn                       ),
    .sch2xy_raddr_odd              (sch2xy_raddr_odd                       ),
    .sch2pe_row_start              (sch2pe_row_start                       ),
    .sch2pe_row_done               (sch2pe_row_done                        ),
    .sch2pe_vld_o                  (sch2pe_vld                             ),
    .mux_col_vld_o                 (mux_col_vld                            ),
    .mux_row_vld_o                 (mux_row_vld                            ),
    .mux_array_vld_o               (mux_array_vld                          ),
    .fe2sch_rdata_0_0              (fe2sch_rdata_0_0                       ),
    .fe2sch_rdata_0_1              (fe2sch_rdata_0_1                       ),
    .fe2sch_rdata_0_2              (fe2sch_rdata_0_2                       ),
    .fe2sch_rdata_0_3              (fe2sch_rdata_0_3                       ),
    .fe2sch_rdata_1_0              (fe2sch_rdata_1_0                       ),
    .fe2sch_rdata_1_1              (fe2sch_rdata_1_1                       ),
    .fe2sch_rdata_1_2              (fe2sch_rdata_1_2                       ),
    .fe2sch_rdata_1_3              (fe2sch_rdata_1_3                       ),
    .fe2sch_rdata_2_0              (fe2sch_rdata_2_0                       ),
    .fe2sch_rdata_2_1              (fe2sch_rdata_2_1                       ),
    .fe2sch_rdata_2_2              (fe2sch_rdata_2_2                       ),
    .fe2sch_rdata_2_3              (fe2sch_rdata_2_3                       ),
    .fe2sch_rdata_3_0              (fe2sch_rdata_3_0                       ),
    .fe2sch_rdata_3_1              (fe2sch_rdata_3_1                       ),
    .fe2sch_rdata_3_2              (fe2sch_rdata_3_2                       ),
    .fe2sch_rdata_3_3              (fe2sch_rdata_3_3                       ),
    .x2sch_rdata_0_0               (x2sch_rdata_0_0                        ),
    .x2sch_rdata_0_1               (x2sch_rdata_0_1                        ),
    .x2sch_rdata_0_2               (x2sch_rdata_0_2                        ),
    .x2sch_rdata_0_3               (x2sch_rdata_0_3                        ),
    .x2sch_rdata_1_0               (x2sch_rdata_1_0                        ),
    .x2sch_rdata_1_1               (x2sch_rdata_1_1                        ),
    .x2sch_rdata_1_2               (x2sch_rdata_1_2                        ),
    .x2sch_rdata_1_3               (x2sch_rdata_1_3                        ),
    .x2sch_rdata_2_0               (x2sch_rdata_2_0                        ),
    .x2sch_rdata_2_1               (x2sch_rdata_2_1                        ),
    .x2sch_rdata_2_2               (x2sch_rdata_2_2                        ),
    .x2sch_rdata_2_3               (x2sch_rdata_2_3                        ),
    .x2sch_rdata_3_0               (x2sch_rdata_3_0                        ),
    .x2sch_rdata_3_1               (x2sch_rdata_3_1                        ),
    .x2sch_rdata_3_2               (x2sch_rdata_3_2                        ),
    .x2sch_rdata_3_3               (x2sch_rdata_3_3                        ),
    .y2sch_rdata_0_0               (y2sch_rdata_0_0                        ),
    .y2sch_rdata_0_1               (y2sch_rdata_0_1                        ),
    .y2sch_rdata_0_2               (y2sch_rdata_0_2                        ),
    .y2sch_rdata_0_3               (y2sch_rdata_0_3                        ),
    .y2sch_rdata_1_0               (y2sch_rdata_1_0                        ),
    .y2sch_rdata_1_1               (y2sch_rdata_1_1                        ),
    .y2sch_rdata_1_2               (y2sch_rdata_1_2                        ),
    .y2sch_rdata_1_3               (y2sch_rdata_1_3                        ),
    .y2sch_rdata_2_0               (y2sch_rdata_2_0                        ),
    .y2sch_rdata_2_1               (y2sch_rdata_2_1                        ),
    .y2sch_rdata_2_2               (y2sch_rdata_2_2                        ),
    .y2sch_rdata_2_3               (y2sch_rdata_2_3                        ),
    .y2sch_rdata_3_0               (y2sch_rdata_3_0                        ),
    .y2sch_rdata_3_1               (y2sch_rdata_3_1                        ),
    .y2sch_rdata_3_2               (y2sch_rdata_3_2                        ),
    .y2sch_rdata_3_3               (y2sch_rdata_3_3                        ),
    .xy2sch_evn_rdata_0_0          (xy2sch_evn_rdata_0_0                   ),
    .xy2sch_evn_rdata_0_1          (xy2sch_evn_rdata_0_1                   ),
    .xy2sch_evn_rdata_0_2          (xy2sch_evn_rdata_0_2                   ),
    .xy2sch_evn_rdata_0_3          (xy2sch_evn_rdata_0_3                   ),
    .xy2sch_evn_rdata_1_0          (xy2sch_evn_rdata_1_0                   ),
    .xy2sch_evn_rdata_1_1          (xy2sch_evn_rdata_1_1                   ),
    .xy2sch_evn_rdata_1_2          (xy2sch_evn_rdata_1_2                   ),
    .xy2sch_evn_rdata_1_3          (xy2sch_evn_rdata_1_3                   ),
    .xy2sch_evn_rdata_2_0          (xy2sch_evn_rdata_2_0                   ),
    .xy2sch_evn_rdata_2_1          (xy2sch_evn_rdata_2_1                   ),
    .xy2sch_evn_rdata_2_2          (xy2sch_evn_rdata_2_2                   ),
    .xy2sch_evn_rdata_2_3          (xy2sch_evn_rdata_2_3                   ),
    .xy2sch_evn_rdata_3_0          (xy2sch_evn_rdata_3_0                   ),
    .xy2sch_evn_rdata_3_1          (xy2sch_evn_rdata_3_1                   ),
    .xy2sch_evn_rdata_3_2          (xy2sch_evn_rdata_3_2                   ),
    .xy2sch_evn_rdata_3_3          (xy2sch_evn_rdata_3_3                   ),
    .xy2sch_odd_rdata_0_0          (xy2sch_odd_rdata_0_0                   ),
    .xy2sch_odd_rdata_0_1          (xy2sch_odd_rdata_0_1                   ),
    .xy2sch_odd_rdata_0_2          (xy2sch_odd_rdata_0_2                   ),
    .xy2sch_odd_rdata_0_3          (xy2sch_odd_rdata_0_3                   ),
    .xy2sch_odd_rdata_1_0          (xy2sch_odd_rdata_1_0                   ),
    .xy2sch_odd_rdata_1_1          (xy2sch_odd_rdata_1_1                   ),
    .xy2sch_odd_rdata_1_2          (xy2sch_odd_rdata_1_2                   ),
    .xy2sch_odd_rdata_1_3          (xy2sch_odd_rdata_1_3                   ),
    .xy2sch_odd_rdata_2_0          (xy2sch_odd_rdata_2_0                   ),
    .xy2sch_odd_rdata_2_1          (xy2sch_odd_rdata_2_1                   ),
    .xy2sch_odd_rdata_2_2          (xy2sch_odd_rdata_2_2                   ),
    .xy2sch_odd_rdata_2_3          (xy2sch_odd_rdata_2_3                   ),
    .xy2sch_odd_rdata_3_0          (xy2sch_odd_rdata_3_0                   ),
    .xy2sch_odd_rdata_3_1          (xy2sch_odd_rdata_3_1                   ),
    .xy2sch_odd_rdata_3_2          (xy2sch_odd_rdata_3_2                   ),
    .xy2sch_odd_rdata_3_3          (xy2sch_odd_rdata_3_3                   ),
    .sch_weight_input_0_0          (w2sch_rdata_0_0                        ),
    .sch_weight_input_0_1          (w2sch_rdata_0_1                        ),
    .sch_weight_input_0_2          (w2sch_rdata_0_2                        ),
    .sch_weight_input_0_3          (w2sch_rdata_0_3                        ),
    .sch_weight_input_1_0          (w2sch_rdata_1_0                        ),
    .sch_weight_input_1_1          (w2sch_rdata_1_1                        ),
    .sch_weight_input_1_2          (w2sch_rdata_1_2                        ),
    .sch_weight_input_1_3          (w2sch_rdata_1_3                        ),
    .sch_weight_input_2_0          (w2sch_rdata_2_0                        ),
    .sch_weight_input_2_1          (w2sch_rdata_2_1                        ),
    .sch_weight_input_2_2          (w2sch_rdata_2_2                        ),
    .sch_weight_input_2_3          (w2sch_rdata_2_3                        ),
    .sch_weight_input_3_0          (w2sch_rdata_3_0                        ),
    .sch_weight_input_3_1          (w2sch_rdata_3_1                        ),
    .sch_weight_input_3_2          (w2sch_rdata_3_2                        ),
    .sch_weight_input_3_3          (w2sch_rdata_3_3                        ),
    .sch_data_output_0_0           (sch2pe_data_0_0                        ),
    .sch_data_output_0_1           (sch2pe_data_0_1                        ),
    .sch_data_output_0_2           (sch2pe_data_0_2                        ),
    .sch_data_output_0_3           (sch2pe_data_0_3                        ),
    .sch_data_output_1_0           (sch2pe_data_1_0                        ),
    .sch_data_output_1_1           (sch2pe_data_1_1                        ),
    .sch_data_output_1_2           (sch2pe_data_1_2                        ),
    .sch_data_output_1_3           (sch2pe_data_1_3                        ),
    .sch_data_output_2_0           (sch2pe_data_2_0                        ),
    .sch_data_output_2_1           (sch2pe_data_2_1                        ),
    .sch_data_output_2_2           (sch2pe_data_2_2                        ),
    .sch_data_output_2_3           (sch2pe_data_2_3                        ),
    .sch_data_output_3_0           (sch2pe_data_3_0                        ),
    .sch_data_output_3_1           (sch2pe_data_3_1                        ),
    .sch_data_output_3_2           (sch2pe_data_3_2                        ),
    .sch_data_output_3_3           (sch2pe_data_3_3                        ),
    .sch_weight_output_0_0         (sch2pe_weight_0_0                      ),
    .sch_weight_output_0_1         (sch2pe_weight_0_1                      ),
    .sch_weight_output_0_2         (sch2pe_weight_0_2                      ),
    .sch_weight_output_0_3         (sch2pe_weight_0_3                      ),
    .sch_weight_output_1_0         (sch2pe_weight_1_0                      ),
    .sch_weight_output_1_1         (sch2pe_weight_1_1                      ),
    .sch_weight_output_1_2         (sch2pe_weight_1_2                      ),
    .sch_weight_output_1_3         (sch2pe_weight_1_3                      ),
    .sch_weight_output_2_0         (sch2pe_weight_2_0                      ),
    .sch_weight_output_2_1         (sch2pe_weight_2_1                      ),
    .sch_weight_output_2_2         (sch2pe_weight_2_2                      ),
    .sch_weight_output_2_3         (sch2pe_weight_2_3                      ),
    .sch_weight_output_3_0         (sch2pe_weight_3_0                      ),
    .sch_weight_output_3_1         (sch2pe_weight_3_1                      ),
    .sch_weight_output_3_2         (sch2pe_weight_3_2                      ),
    .sch_weight_output_3_3         (sch2pe_weight_3_3                      )
);

pe_array #(
    .FEATURE_WD                    (IFM_WIDTH                              ),
    .WEIGHT_WD                     (WT_WIDTH                               ),
    .PE_COL_NUM                    (PE_COL_NUM                             ),
    .PE_OUTPUT_WD                  (PE_OUTPUT_WD                           ),
    .PE_ROW_INPUT_WD               (IFM_WIDTH*PE_COL_NUM                   ),
    .PE_ROW_OUTPUT_WD              (PE_OUTPUT_WD*PE_COL_NUM                ),
    .PE_GRP_NUM                    (PE_IC_NUM                              ),
    .PE_ROW_NUM                    (PE_H_NUM*PE_OC_NUM                     )
)
u_pe_array (
    .clk                           (clk                                    ),
    .rstn                          (rst_n                                  ),
    .sch2pe_row_start              (sch2pe_row_start                       ),
    .pe_row_input_ic_0_h_0               (sch2pe_data_0_0                        ),
    .pe_row_input_ic_0_h_1               (sch2pe_data_0_1                        ),
    .pe_row_input_ic_0_h_2               (sch2pe_data_0_2                        ),
    .pe_row_input_ic_0_h_3               (sch2pe_data_0_3                        ),
    .pe_row_input_ic_1_h_0               (sch2pe_data_1_0                        ),
    .pe_row_input_ic_1_h_1               (sch2pe_data_1_1                        ),
    .pe_row_input_ic_1_h_2               (sch2pe_data_1_2                        ),
    .pe_row_input_ic_1_h_3               (sch2pe_data_1_3                        ),
    .pe_row_input_ic_2_h_0               (sch2pe_data_2_0                        ),
    .pe_row_input_ic_2_h_1               (sch2pe_data_2_1                        ),
    .pe_row_input_ic_2_h_2               (sch2pe_data_2_2                        ),
    .pe_row_input_ic_2_h_3               (sch2pe_data_2_3                        ),
    .pe_row_input_ic_3_h_0               (sch2pe_data_3_0                        ),
    .pe_row_input_ic_3_h_1               (sch2pe_data_3_1                        ),
    .pe_row_input_ic_3_h_2               (sch2pe_data_3_2                        ),
    .pe_row_input_ic_3_h_3               (sch2pe_data_3_3                        ),
    .pe_row_weight_ic_0_oc_0             (sch2pe_weight_0_0                      ),
    .pe_row_weight_ic_0_oc_1             (sch2pe_weight_0_1                      ),
    .pe_row_weight_ic_0_oc_2             (sch2pe_weight_0_2                      ),
    .pe_row_weight_ic_0_oc_3             (sch2pe_weight_0_3                      ),
    .pe_row_weight_ic_1_oc_0             (sch2pe_weight_1_0                      ),
    .pe_row_weight_ic_1_oc_1             (sch2pe_weight_1_1                      ),
    .pe_row_weight_ic_1_oc_2             (sch2pe_weight_1_2                      ),
    .pe_row_weight_ic_1_oc_3             (sch2pe_weight_1_3                      ),
    .pe_row_weight_ic_2_oc_0             (sch2pe_weight_2_0                      ),
    .pe_row_weight_ic_2_oc_1             (sch2pe_weight_2_1                      ),
    .pe_row_weight_ic_2_oc_2             (sch2pe_weight_2_2                      ),
    .pe_row_weight_ic_2_oc_3             (sch2pe_weight_2_3                      ),
    .pe_row_weight_ic_3_oc_0             (sch2pe_weight_3_0                      ),
    .pe_row_weight_ic_3_oc_1             (sch2pe_weight_3_1                      ),
    .pe_row_weight_ic_3_oc_2             (sch2pe_weight_3_2                      ),
    .pe_row_weight_ic_3_oc_3             (sch2pe_weight_3_3                      ),
    .pe_row_output_ic_0_oc_0_h_0           (pe_row_output_0_0_0                    ),
    .pe_row_output_ic_0_oc_0_h_1           (pe_row_output_0_0_1                    ),
    .pe_row_output_ic_0_oc_0_h_2           (pe_row_output_0_0_2                    ),
    .pe_row_output_ic_0_oc_0_h_3           (pe_row_output_0_0_3                    ),
    .pe_row_output_ic_0_oc_1_h_0           (pe_row_output_0_1_0                    ),
    .pe_row_output_ic_0_oc_1_h_1           (pe_row_output_0_1_1                    ),
    .pe_row_output_ic_0_oc_1_h_2           (pe_row_output_0_1_2                    ),
    .pe_row_output_ic_0_oc_1_h_3           (pe_row_output_0_1_3                    ),
    .pe_row_output_ic_0_oc_2_h_0           (pe_row_output_0_2_0                    ),
    .pe_row_output_ic_0_oc_2_h_1           (pe_row_output_0_2_1                    ),
    .pe_row_output_ic_0_oc_2_h_2           (pe_row_output_0_2_2                    ),
    .pe_row_output_ic_0_oc_2_h_3           (pe_row_output_0_2_3                    ),
    .pe_row_output_ic_0_oc_3_h_0           (pe_row_output_0_3_0                    ),
    .pe_row_output_ic_0_oc_3_h_1           (pe_row_output_0_3_1                    ),
    .pe_row_output_ic_0_oc_3_h_2           (pe_row_output_0_3_2                    ),
    .pe_row_output_ic_0_oc_3_h_3           (pe_row_output_0_3_3                    ),
    .pe_row_output_ic_1_oc_0_h_0           (pe_row_output_1_0_0                    ),
    .pe_row_output_ic_1_oc_0_h_1           (pe_row_output_1_0_1                    ),
    .pe_row_output_ic_1_oc_0_h_2           (pe_row_output_1_0_2                    ),
    .pe_row_output_ic_1_oc_0_h_3           (pe_row_output_1_0_3                    ),
    .pe_row_output_ic_1_oc_1_h_0           (pe_row_output_1_1_0                    ),
    .pe_row_output_ic_1_oc_1_h_1           (pe_row_output_1_1_1                    ),
    .pe_row_output_ic_1_oc_1_h_2           (pe_row_output_1_1_2                    ),
    .pe_row_output_ic_1_oc_1_h_3           (pe_row_output_1_1_3                    ),
    .pe_row_output_ic_1_oc_2_h_0           (pe_row_output_1_2_0                    ),
    .pe_row_output_ic_1_oc_2_h_1           (pe_row_output_1_2_1                    ),
    .pe_row_output_ic_1_oc_2_h_2           (pe_row_output_1_2_2                    ),
    .pe_row_output_ic_1_oc_2_h_3           (pe_row_output_1_2_3                    ),
    .pe_row_output_ic_1_oc_3_h_0           (pe_row_output_1_3_0                    ),
    .pe_row_output_ic_1_oc_3_h_1           (pe_row_output_1_3_1                    ),
    .pe_row_output_ic_1_oc_3_h_2           (pe_row_output_1_3_2                    ),
    .pe_row_output_ic_1_oc_3_h_3           (pe_row_output_1_3_3                    ),
    .pe_row_output_ic_2_oc_0_h_0           (pe_row_output_2_0_0                    ),
    .pe_row_output_ic_2_oc_0_h_1           (pe_row_output_2_0_1                    ),
    .pe_row_output_ic_2_oc_0_h_2           (pe_row_output_2_0_2                    ),
    .pe_row_output_ic_2_oc_0_h_3           (pe_row_output_2_0_3                    ),
    .pe_row_output_ic_2_oc_1_h_0           (pe_row_output_2_1_0                    ),
    .pe_row_output_ic_2_oc_1_h_1           (pe_row_output_2_1_1                    ),
    .pe_row_output_ic_2_oc_1_h_2           (pe_row_output_2_1_2                    ),
    .pe_row_output_ic_2_oc_1_h_3           (pe_row_output_2_1_3                    ),
    .pe_row_output_ic_2_oc_2_h_0           (pe_row_output_2_2_0                    ),
    .pe_row_output_ic_2_oc_2_h_1           (pe_row_output_2_2_1                    ),
    .pe_row_output_ic_2_oc_2_h_2           (pe_row_output_2_2_2                    ),
    .pe_row_output_ic_2_oc_2_h_3           (pe_row_output_2_2_3                    ),
    .pe_row_output_ic_2_oc_3_h_0           (pe_row_output_2_3_0                    ),
    .pe_row_output_ic_2_oc_3_h_1           (pe_row_output_2_3_1                    ),
    .pe_row_output_ic_2_oc_3_h_2           (pe_row_output_2_3_2                    ),
    .pe_row_output_ic_2_oc_3_h_3           (pe_row_output_2_3_3                    ),
    .pe_row_output_ic_3_oc_0_h_0           (pe_row_output_3_0_0                    ),
    .pe_row_output_ic_3_oc_0_h_1           (pe_row_output_3_0_1                    ),
    .pe_row_output_ic_3_oc_0_h_2           (pe_row_output_3_0_2                    ),
    .pe_row_output_ic_3_oc_0_h_3           (pe_row_output_3_0_3                    ),
    .pe_row_output_ic_3_oc_1_h_0           (pe_row_output_3_1_0                    ),
    .pe_row_output_ic_3_oc_1_h_1           (pe_row_output_3_1_1                    ),
    .pe_row_output_ic_3_oc_1_h_2           (pe_row_output_3_1_2                    ),
    .pe_row_output_ic_3_oc_1_h_3           (pe_row_output_3_1_3                    ),
    .pe_row_output_ic_3_oc_2_h_0           (pe_row_output_3_2_0                    ),
    .pe_row_output_ic_3_oc_2_h_1           (pe_row_output_3_2_1                    ),
    .pe_row_output_ic_3_oc_2_h_2           (pe_row_output_3_2_2                    ),
    .pe_row_output_ic_3_oc_2_h_3           (pe_row_output_3_2_3                    ),
    .pe_row_output_ic_3_oc_3_h_0           (pe_row_output_3_3_0                    ),
    .pe_row_output_ic_3_oc_3_h_1           (pe_row_output_3_3_1                    ),
    .pe_row_output_ic_3_oc_3_h_2           (pe_row_output_3_3_2                    ),
    .pe_row_output_ic_3_oc_3_h_3           (pe_row_output_3_3_3                    ),
    .pe_col_vld                            (mux_col_vld                            ),
    .pe_array_vld                          ({mux_array_vld[0],mux_array_vld[1],mux_array_vld[2],mux_array_vld[3]}),
    .pe_row_vld                            ({4{mux_row_vld[0],mux_row_vld[1],mux_row_vld[2],mux_row_vld[3]}}),
    .sch2pe_vld                            (sch2pe_vld                             ),
    .pe2sch_rdy                            (pe2sch_rdy                             ),
    .pe2pu_vld                             (pe2pu_vld                              ),
    .pu2pe_rdy                             (pu2pe_rdy                              ),
    .sch2pe_row_done                       (sch2pe_row_done                        )
);
pu_top #(
    .REG_OC_WIDTH                  (REG_OC_WIDTH                           ),
    .REG_OH_WIDTH                  (REG_OH_WIDTH + 1                       ),
    .PE_OUTPUT_WD                  (PE_OUTPUT_WD                           ),
    .PE_COL_NUM                    (PE_COL_NUM                             ),
    .BIAS_ADDR_WD                  (P_ADDR_WIDTH                           ),
    .RES_ADDR_WD                   (/*UNUSED*/                             ),
    .FEATURE_ADDR_WD               (FE_ADDR_WIDTH                          ),
    .OVERLAP_ADDR_WD               (/*UNUSED*/                             ),
    .PU_RF_BIAS_IN_WD              (P2PU_RD_WIDTH                          ),
    .PU_RF_RES_IN_WD               (/*UNUSED*/                             ),
    .PU_RF_RES_OUT_WD              (/*UNUSED*/                             ),
    .PU_RF_FE_OUT_WD               (FE_BUF_WIDTH                           ),
    .PU_RF_OLP_OUT_WD              (/*UNUSED*/                             ),
    .PU_RF_ACCU_WD                 (PU_RF_ACCU_WD                          ),
    .BIAS_RF_WD                    (BIAS_DATA_WIDTH                        ),
    .RES_WD                        (/*UNUSED*/                             ),
    .PU_RF_WD                      (/*UNUSED*/                             ),
    .X_OLP_ADR_WD                  (OLPX_ADDR_WIDTH                        ),
    .X_OLP_DAT_WD                  (OLPX_BUF_WIDTH                         ),
    .Y_OLP_ADR_WD                  (OLPY_ADDR_WIDTH                        ),
    .Y_OLP_DAT_WD                  (OLPY_BUF_WIDTH                         ),
    .XY_OLP_ADR_WD                 (OLPXY_ADDR_WIDTH                       ),
    .XY_OLP_DAT_WD                 (OLPXY_BUF_WIDTH                        ),
    .X_RESI_ADR_WD                 (RESX_ADDR_WIDTH                        ),
    .X_RESI_DAT_WD                 (RESX_LBUF_WIDTH+RESX_SBUF_WIDTH        ),
    .Y_RESI_ADR_WD                 (RESY_ADDR_WIDTH                        ),
    .Y_RESI_DAT_WD                 (RESY_BUF_WIDTH                         ),
    .XY_RESI_ADR_WD                (RESXY_ADDR_WIDTH                       ),
    .XY_RESI_DAT_WD                (RESXY_BUF_WIDTH                        ),
    .Y_L234_DEPTH                  (OLPY_L234_DEPTH                        ),
    .X_L234_DEPTH                  (OLPX_L234_DEPTH                        ),
    .XY_L234_DEPTH                 (OLPXY_L234_DEPTH                       ),
    .REG_TNX_WIDTH                 (REG_TNX_WIDTH                          )
)
u_pu_top (
    .clk                           (clk                                    ),
    .rstn                          (rst_n                                  ),
    .layer_start_i                 (layer_start                            ),
    .tile_switch_i                 (tile_switch                            ),
    .strip_switch_i                (/*UNUSED*/                             ),
    .pu2ctrl_tile_done_o           (layer_done                             ),
    //.tile_h_i                      (tile_in_h                              ),
    //.tile_c_i                      (tile_in_c                              ),
    //.tile_h_i                      (tile_out_h                             ),
    .tile_h_i                      (tile_out_h_w                           ),
    .tile_c_i                      (tile_out_c                             ),
    .tile_num_x_i                  (tile_tot_num_x                         ),
    .knl_size_i                    (ksize                                  ),
    .ksize_nxt                     (ksize_nxt                              ),
    .res_proc_type_i               (res_proc_type                          ),
    .res_shift_i                   (/*UNSED*/                              ),
    .x4_shuffle_vld_i              (x4_shuffle_vld                         ),
    .pu_if_dnsamp_i                (/*UNUSED*/                             ),
    .model_switch_i                (model_switch                           ),
    .nn_proc_i                     (nn_proc                                ),
    .pu_hbm_shift_i                (pu_hbm_shift                           ),
    .pu_lbm_shift_i                (pu_lbm_shift                           ),
    .pu_prelu_en_i                 (prl_vld                                ),
    .tile_loc                      (tile_loc                               ),
    .tile_tot_num_x                (tile_tot_num_x                         ),
    .pu2sch_olp_addr_o             (/*UNUSED*/                             ),
    .pe2pu_vld_i                   (pe2pu_vld                              ),
    .pu2pe_rdy_o                   (pu2pe_rdy                              ),
    .pe_row_0_0_0_i                (pe_row_output_0_0_0                    ),
    .pe_row_0_0_1_i                (pe_row_output_0_0_1                    ),
    .pe_row_0_0_2_i                (pe_row_output_0_0_2                    ),
    .pe_row_0_0_3_i                (pe_row_output_0_0_3                    ),
    .pe_row_0_1_0_i                (pe_row_output_0_1_0                    ),
    .pe_row_0_1_1_i                (pe_row_output_0_1_1                    ),
    .pe_row_0_1_2_i                (pe_row_output_0_1_2                    ),
    .pe_row_0_1_3_i                (pe_row_output_0_1_3                    ),
    .pe_row_0_2_0_i                (pe_row_output_0_2_0                    ),
    .pe_row_0_2_1_i                (pe_row_output_0_2_1                    ),
    .pe_row_0_2_2_i                (pe_row_output_0_2_2                    ),
    .pe_row_0_2_3_i                (pe_row_output_0_2_3                    ),
    .pe_row_0_3_0_i                (pe_row_output_0_3_0                    ),
    .pe_row_0_3_1_i                (pe_row_output_0_3_1                    ),
    .pe_row_0_3_2_i                (pe_row_output_0_3_2                    ),
    .pe_row_0_3_3_i                (pe_row_output_0_3_3                    ),
    .pe_row_1_0_0_i                (pe_row_output_1_0_0                    ),
    .pe_row_1_0_1_i                (pe_row_output_1_0_1                    ),
    .pe_row_1_0_2_i                (pe_row_output_1_0_2                    ),
    .pe_row_1_0_3_i                (pe_row_output_1_0_3                    ),
    .pe_row_1_1_0_i                (pe_row_output_1_1_0                    ),
    .pe_row_1_1_1_i                (pe_row_output_1_1_1                    ),
    .pe_row_1_1_2_i                (pe_row_output_1_1_2                    ),
    .pe_row_1_1_3_i                (pe_row_output_1_1_3                    ),
    .pe_row_1_2_0_i                (pe_row_output_1_2_0                    ),
    .pe_row_1_2_1_i                (pe_row_output_1_2_1                    ),
    .pe_row_1_2_2_i                (pe_row_output_1_2_2                    ),
    .pe_row_1_2_3_i                (pe_row_output_1_2_3                    ),
    .pe_row_1_3_0_i                (pe_row_output_1_3_0                    ),
    .pe_row_1_3_1_i                (pe_row_output_1_3_1                    ),
    .pe_row_1_3_2_i                (pe_row_output_1_3_2                    ),
    .pe_row_1_3_3_i                (pe_row_output_1_3_3                    ),
    .pe_row_2_0_0_i                (pe_row_output_2_0_0                    ),
    .pe_row_2_0_1_i                (pe_row_output_2_0_1                    ),
    .pe_row_2_0_2_i                (pe_row_output_2_0_2                    ),
    .pe_row_2_0_3_i                (pe_row_output_2_0_3                    ),
    .pe_row_2_1_0_i                (pe_row_output_2_1_0                    ),
    .pe_row_2_1_1_i                (pe_row_output_2_1_1                    ),
    .pe_row_2_1_2_i                (pe_row_output_2_1_2                    ),
    .pe_row_2_1_3_i                (pe_row_output_2_1_3                    ),
    .pe_row_2_2_0_i                (pe_row_output_2_2_0                    ),
    .pe_row_2_2_1_i                (pe_row_output_2_2_1                    ),
    .pe_row_2_2_2_i                (pe_row_output_2_2_2                    ),
    .pe_row_2_2_3_i                (pe_row_output_2_2_3                    ),
    .pe_row_2_3_0_i                (pe_row_output_2_3_0                    ),
    .pe_row_2_3_1_i                (pe_row_output_2_3_1                    ),
    .pe_row_2_3_2_i                (pe_row_output_2_3_2                    ),
    .pe_row_2_3_3_i                (pe_row_output_2_3_3                    ),
    .pe_row_3_0_0_i                (pe_row_output_3_0_0                    ),
    .pe_row_3_0_1_i                (pe_row_output_3_0_1                    ),
    .pe_row_3_0_2_i                (pe_row_output_3_0_2                    ),
    .pe_row_3_0_3_i                (pe_row_output_3_0_3                    ),
    .pe_row_3_1_0_i                (pe_row_output_3_1_0                    ),
    .pe_row_3_1_1_i                (pe_row_output_3_1_1                    ),
    .pe_row_3_1_2_i                (pe_row_output_3_1_2                    ),
    .pe_row_3_1_3_i                (pe_row_output_3_1_3                    ),
    .pe_row_3_2_0_i                (pe_row_output_3_2_0                    ),
    .pe_row_3_2_1_i                (pe_row_output_3_2_1                    ),
    .pe_row_3_2_2_i                (pe_row_output_3_2_2                    ),
    .pe_row_3_2_3_i                (pe_row_output_3_2_3                    ),
    .pe_row_3_3_0_i                (pe_row_output_3_3_0                    ),
    .pe_row_3_3_1_i                (pe_row_output_3_3_1                    ),
    .pe_row_3_3_2_i                (pe_row_output_3_3_2                    ),
    .pe_row_3_3_3_i                (pe_row_output_3_3_3                    ),
    .bias_buf_rd_en_o              (pu2p_ren                               ),
    .bias_buf_rd_addr_o            (pu2p_raddr                             ),
    .bias_buf_rd_dat_0_i           (p2pu_rdata_0                           ),
    .bias_buf_rd_dat_1_i           (p2pu_rdata_1                           ),
    .bias_buf_rd_dat_2_i           (p2pu_rdata_2                           ),
    .bias_buf_rd_dat_3_i           (p2pu_rdata_3                           ),
    .x_resi_rd_en_o                (pu2rx_ren                              ),
    .x_resi_rd_addr_o              (pu2rx_raddr                            ),
    .x_resi_rd_dat_c0_h0_i         (rx2pu_rdata_0_0                        ),
    .x_resi_rd_dat_c0_h1_i         (rx2pu_rdata_0_1                        ),
    .x_resi_rd_dat_c0_h2_i         (rx2pu_rdata_0_2                        ),
    .x_resi_rd_dat_c0_h3_i         (rx2pu_rdata_0_3                        ),
    .x_resi_rd_dat_c1_h0_i         (rx2pu_rdata_1_0                        ),
    .x_resi_rd_dat_c1_h1_i         (rx2pu_rdata_1_1                        ),
    .x_resi_rd_dat_c1_h2_i         (rx2pu_rdata_1_2                        ),
    .x_resi_rd_dat_c1_h3_i         (rx2pu_rdata_1_3                        ),
    .x_resi_rd_dat_c2_h0_i         (rx2pu_rdata_2_0                        ),
    .x_resi_rd_dat_c2_h1_i         (rx2pu_rdata_2_1                        ),
    .x_resi_rd_dat_c2_h2_i         (rx2pu_rdata_2_2                        ),
    .x_resi_rd_dat_c2_h3_i         (rx2pu_rdata_2_3                        ),
    .x_resi_rd_dat_c3_h0_i         (rx2pu_rdata_3_0                        ),
    .x_resi_rd_dat_c3_h1_i         (rx2pu_rdata_3_1                        ),
    .x_resi_rd_dat_c3_h2_i         (rx2pu_rdata_3_2                        ),
    .x_resi_rd_dat_c3_h3_i         (rx2pu_rdata_3_3                        ),
    .x_resi_wr_en_o                (pu2rx_wen                              ),
    .x_resi_wr_addr_h0_o           (pu2rx_waddr_0                          ),
    .x_resi_wr_addr_h1_o           (pu2rx_waddr_1                          ),
    .x_resi_wr_addr_h2_o           (pu2rx_waddr_2                          ),
    .x_resi_wr_addr_h3_o           (pu2rx_waddr_3                          ),
    .x_resi_wr_dat_c0_h0_o         (pu2rx_wdata_0_0                        ),
    .x_resi_wr_dat_c0_h1_o         (pu2rx_wdata_0_1                        ),
    .x_resi_wr_dat_c0_h2_o         (pu2rx_wdata_0_2                        ),
    .x_resi_wr_dat_c0_h3_o         (pu2rx_wdata_0_3                        ),
    .x_resi_wr_dat_c1_h0_o         (pu2rx_wdata_1_0                        ),
    .x_resi_wr_dat_c1_h1_o         (pu2rx_wdata_1_1                        ),
    .x_resi_wr_dat_c1_h2_o         (pu2rx_wdata_1_2                        ),
    .x_resi_wr_dat_c1_h3_o         (pu2rx_wdata_1_3                        ),
    .x_resi_wr_dat_c2_h0_o         (pu2rx_wdata_2_0                        ),
    .x_resi_wr_dat_c2_h1_o         (pu2rx_wdata_2_1                        ),
    .x_resi_wr_dat_c2_h2_o         (pu2rx_wdata_2_2                        ),
    .x_resi_wr_dat_c2_h3_o         (pu2rx_wdata_2_3                        ),
    .x_resi_wr_dat_c3_h0_o         (pu2rx_wdata_3_0                        ),
    .x_resi_wr_dat_c3_h1_o         (pu2rx_wdata_3_1                        ),
    .x_resi_wr_dat_c3_h2_o         (pu2rx_wdata_3_2                        ),
    .x_resi_wr_dat_c3_h3_o         (pu2rx_wdata_3_3                        ),
    .y_resi_rd_en_o                (pu2ry_ren                              ),
    .y_resi_rd_addr_o              (pu2ry_raddr                            ),
    .y_resi_rd_dat_c0_h0_i         (ry2pu_rdata_0_0                        ),
    .y_resi_rd_dat_c0_h1_i         (ry2pu_rdata_0_1                        ),
    .y_resi_rd_dat_c0_h2_i         (ry2pu_rdata_0_2                        ),
    .y_resi_rd_dat_c1_h0_i         (ry2pu_rdata_1_0                        ),
    .y_resi_rd_dat_c1_h1_i         (ry2pu_rdata_1_1                        ),
    .y_resi_rd_dat_c1_h2_i         (ry2pu_rdata_1_2                        ),
    .y_resi_rd_dat_c2_h0_i         (ry2pu_rdata_2_0                        ),
    .y_resi_rd_dat_c2_h1_i         (ry2pu_rdata_2_1                        ),
    .y_resi_rd_dat_c2_h2_i         (ry2pu_rdata_2_2                        ),
    .y_resi_rd_dat_c3_h0_i         (ry2pu_rdata_3_0                        ),
    .y_resi_rd_dat_c3_h1_i         (ry2pu_rdata_3_1                        ),
    .y_resi_rd_dat_c3_h2_i         (ry2pu_rdata_3_2                        ),
    .y_resi_wr_en_o                (pu2ry_wen                              ),
    .y_resi_wr_addr_o              (pu2ry_waddr                            ),
    .y_resi_wr_dat_c0_h0_o         (pu2ry_wdata_0_0                        ),
    .y_resi_wr_dat_c0_h1_o         (pu2ry_wdata_0_1                        ),
    .y_resi_wr_dat_c0_h2_o         (pu2ry_wdata_0_2                        ),
    .y_resi_wr_dat_c1_h0_o         (pu2ry_wdata_1_0                        ),
    .y_resi_wr_dat_c1_h1_o         (pu2ry_wdata_1_1                        ),
    .y_resi_wr_dat_c1_h2_o         (pu2ry_wdata_1_2                        ),
    .y_resi_wr_dat_c2_h0_o         (pu2ry_wdata_2_0                        ),
    .y_resi_wr_dat_c2_h1_o         (pu2ry_wdata_2_1                        ),
    .y_resi_wr_dat_c2_h2_o         (pu2ry_wdata_2_2                        ),
    .y_resi_wr_dat_c3_h0_o         (pu2ry_wdata_3_0                        ),
    .y_resi_wr_dat_c3_h1_o         (pu2ry_wdata_3_1                        ),
    .y_resi_wr_dat_c3_h2_o         (pu2ry_wdata_3_2                        ),
    .xy_resi_rd_en_o               (pu2rxy_ren                             ),
    .xy_resi_rd_addr_o             (pu2rxy_raddr                           ),
    .xy_resi_rd_dat_c0_h0_i        (rxy2pu_rdata_0_0                       ),
    .xy_resi_rd_dat_c0_h1_i        (rxy2pu_rdata_0_1                       ),
    .xy_resi_rd_dat_c0_h2_i        (rxy2pu_rdata_0_2                       ),
    .xy_resi_rd_dat_c1_h0_i        (rxy2pu_rdata_1_0                       ),
    .xy_resi_rd_dat_c1_h1_i        (rxy2pu_rdata_1_1                       ),
    .xy_resi_rd_dat_c1_h2_i        (rxy2pu_rdata_1_2                       ),
    .xy_resi_rd_dat_c2_h0_i        (rxy2pu_rdata_2_0                       ),
    .xy_resi_rd_dat_c2_h1_i        (rxy2pu_rdata_2_1                       ),
    .xy_resi_rd_dat_c2_h2_i        (rxy2pu_rdata_2_2                       ),
    .xy_resi_rd_dat_c3_h0_i        (rxy2pu_rdata_3_0                       ),
    .xy_resi_rd_dat_c3_h1_i        (rxy2pu_rdata_3_1                       ),
    .xy_resi_rd_dat_c3_h2_i        (rxy2pu_rdata_3_2                       ),
    .xy_resi_wr_en_o               (pu2rxy_wen                             ),
    .xy_resi_wr_addr_o             (pu2rxy_waddr                           ),
    .xy_resi_wr_dat_c0_h0_o        (pu2rxy_wdata_0_0                       ),
    .xy_resi_wr_dat_c0_h1_o        (pu2rxy_wdata_0_1                       ),
    .xy_resi_wr_dat_c0_h2_o        (pu2rxy_wdata_0_2                       ),
    .xy_resi_wr_dat_c1_h0_o        (pu2rxy_wdata_1_0                       ),
    .xy_resi_wr_dat_c1_h1_o        (pu2rxy_wdata_1_1                       ),
    .xy_resi_wr_dat_c1_h2_o        (pu2rxy_wdata_1_2                       ),
    .xy_resi_wr_dat_c2_h0_o        (pu2rxy_wdata_2_0                       ),
    .xy_resi_wr_dat_c2_h1_o        (pu2rxy_wdata_2_1                       ),
    .xy_resi_wr_dat_c2_h2_o        (pu2rxy_wdata_2_2                       ),
    .xy_resi_wr_dat_c3_h0_o        (pu2rxy_wdata_3_0                       ),
    .xy_resi_wr_dat_c3_h1_o        (pu2rxy_wdata_3_1                       ),
    .xy_resi_wr_dat_c3_h2_o        (pu2rxy_wdata_3_2                       ),
    .fe_buf_wr_en_o                (pu2fe_wen                              ),
    .fe_buf_wr_addr_o              (pu2fe_waddr                            ),
    .fe_buf_wr_dat_0_0_o           (pu2fe_wdata_0_0                        ),
    .fe_buf_wr_dat_0_1_o           (pu2fe_wdata_0_1                        ),
    .fe_buf_wr_dat_0_2_o           (pu2fe_wdata_0_2                        ),
    .fe_buf_wr_dat_0_3_o           (pu2fe_wdata_0_3                        ),
    .fe_buf_wr_dat_1_0_o           (pu2fe_wdata_1_0                        ),
    .fe_buf_wr_dat_1_1_o           (pu2fe_wdata_1_1                        ),
    .fe_buf_wr_dat_1_2_o           (pu2fe_wdata_1_2                        ),
    .fe_buf_wr_dat_1_3_o           (pu2fe_wdata_1_3                        ),
    .fe_buf_wr_dat_2_0_o           (pu2fe_wdata_2_0                        ),
    .fe_buf_wr_dat_2_1_o           (pu2fe_wdata_2_1                        ),
    .fe_buf_wr_dat_2_2_o           (pu2fe_wdata_2_2                        ),
    .fe_buf_wr_dat_2_3_o           (pu2fe_wdata_2_3                        ),
    .fe_buf_wr_dat_3_0_o           (pu2fe_wdata_3_0                        ),
    .fe_buf_wr_dat_3_1_o           (pu2fe_wdata_3_1                        ),
    .fe_buf_wr_dat_3_2_o           (pu2fe_wdata_3_2                        ),
    .fe_buf_wr_dat_3_3_o           (pu2fe_wdata_3_3                        ),
    .x_olp_buf_wr_en_o             (pu2x_wen                               ),
    .x_olp_buf_wr_addr_o           (pu2x_waddr                             ),
    .x_olp_buf_wr_dat_0_0_o        (pu2x_wdata_0_0                         ),
    .x_olp_buf_wr_dat_0_1_o        (pu2x_wdata_0_1                         ),
    .x_olp_buf_wr_dat_0_2_o        (pu2x_wdata_0_2                         ),
    .x_olp_buf_wr_dat_0_3_o        (pu2x_wdata_0_3                         ),
    .x_olp_buf_wr_dat_1_0_o        (pu2x_wdata_1_0                         ),
    .x_olp_buf_wr_dat_1_1_o        (pu2x_wdata_1_1                         ),
    .x_olp_buf_wr_dat_1_2_o        (pu2x_wdata_1_2                         ),
    .x_olp_buf_wr_dat_1_3_o        (pu2x_wdata_1_3                         ),
    .x_olp_buf_wr_dat_2_0_o        (pu2x_wdata_2_0                         ),
    .x_olp_buf_wr_dat_2_1_o        (pu2x_wdata_2_1                         ),
    .x_olp_buf_wr_dat_2_2_o        (pu2x_wdata_2_2                         ),
    .x_olp_buf_wr_dat_2_3_o        (pu2x_wdata_2_3                         ),
    .x_olp_buf_wr_dat_3_0_o        (pu2x_wdata_3_0                         ),
    .x_olp_buf_wr_dat_3_1_o        (pu2x_wdata_3_1                         ),
    .x_olp_buf_wr_dat_3_2_o        (pu2x_wdata_3_2                         ),
    .x_olp_buf_wr_dat_3_3_o        (pu2x_wdata_3_3                         ),
    .y_olp_buf_wr_en_o             (pu2y_wen                               ),
    .y_olp_buf_wr_addr_o           (pu2y_waddr                             ),
    .y_olp_buf_wr_dat_0_0_o        (pu2y_wdata_0_0                         ),
    .y_olp_buf_wr_dat_0_1_o        (pu2y_wdata_0_1                         ),
    .y_olp_buf_wr_dat_0_2_o        (pu2y_wdata_0_2                         ),
    .y_olp_buf_wr_dat_0_3_o        (pu2y_wdata_0_3                         ),
    .y_olp_buf_wr_dat_1_0_o        (pu2y_wdata_1_0                         ),
    .y_olp_buf_wr_dat_1_1_o        (pu2y_wdata_1_1                         ),
    .y_olp_buf_wr_dat_1_2_o        (pu2y_wdata_1_2                         ),
    .y_olp_buf_wr_dat_1_3_o        (pu2y_wdata_1_3                         ),
    .y_olp_buf_wr_dat_2_0_o        (pu2y_wdata_2_0                         ),
    .y_olp_buf_wr_dat_2_1_o        (pu2y_wdata_2_1                         ),
    .y_olp_buf_wr_dat_2_2_o        (pu2y_wdata_2_2                         ),
    .y_olp_buf_wr_dat_2_3_o        (pu2y_wdata_2_3                         ),
    .y_olp_buf_wr_dat_3_0_o        (pu2y_wdata_3_0                         ),
    .y_olp_buf_wr_dat_3_1_o        (pu2y_wdata_3_1                         ),
    .y_olp_buf_wr_dat_3_2_o        (pu2y_wdata_3_2                         ),
    .y_olp_buf_wr_dat_3_3_o        (pu2y_wdata_3_3                         ),
    .evn_xy_olp_buf_wr_en_o        (pu2xy_evn_wen                          ),
    .evn_xy_olp_buf_wr_addr_o      (pu2xy_evn_waddr                        ),
    .evn_xy_olp_buf_wr_dat_0_0_o   (pu2xy_evn_wdata_0_0                    ),
    .evn_xy_olp_buf_wr_dat_0_1_o   (pu2xy_evn_wdata_0_1                    ),
    .evn_xy_olp_buf_wr_dat_0_2_o   (pu2xy_evn_wdata_0_2                    ),
    .evn_xy_olp_buf_wr_dat_0_3_o   (pu2xy_evn_wdata_0_3                    ),
    .evn_xy_olp_buf_wr_dat_1_0_o   (pu2xy_evn_wdata_1_0                    ),
    .evn_xy_olp_buf_wr_dat_1_1_o   (pu2xy_evn_wdata_1_1                    ),
    .evn_xy_olp_buf_wr_dat_1_2_o   (pu2xy_evn_wdata_1_2                    ),
    .evn_xy_olp_buf_wr_dat_1_3_o   (pu2xy_evn_wdata_1_3                    ),
    .evn_xy_olp_buf_wr_dat_2_0_o   (pu2xy_evn_wdata_2_0                    ),
    .evn_xy_olp_buf_wr_dat_2_1_o   (pu2xy_evn_wdata_2_1                    ),
    .evn_xy_olp_buf_wr_dat_2_2_o   (pu2xy_evn_wdata_2_2                    ),
    .evn_xy_olp_buf_wr_dat_2_3_o   (pu2xy_evn_wdata_2_3                    ),
    .evn_xy_olp_buf_wr_dat_3_0_o   (pu2xy_evn_wdata_3_0                    ),
    .evn_xy_olp_buf_wr_dat_3_1_o   (pu2xy_evn_wdata_3_1                    ),
    .evn_xy_olp_buf_wr_dat_3_2_o   (pu2xy_evn_wdata_3_2                    ),
    .evn_xy_olp_buf_wr_dat_3_3_o   (pu2xy_evn_wdata_3_3                    ),
    .odd_xy_olp_buf_wr_en_o        (pu2xy_odd_wen                          ),
    .odd_xy_olp_buf_wr_addr_o      (pu2xy_odd_waddr                        ),
    .odd_xy_olp_buf_wr_dat_0_0_o   (pu2xy_odd_wdata_0_0                    ),
    .odd_xy_olp_buf_wr_dat_0_1_o   (pu2xy_odd_wdata_0_1                    ),
    .odd_xy_olp_buf_wr_dat_0_2_o   (pu2xy_odd_wdata_0_2                    ),
    .odd_xy_olp_buf_wr_dat_0_3_o   (pu2xy_odd_wdata_0_3                    ),
    .odd_xy_olp_buf_wr_dat_1_0_o   (pu2xy_odd_wdata_1_0                    ),
    .odd_xy_olp_buf_wr_dat_1_1_o   (pu2xy_odd_wdata_1_1                    ),
    .odd_xy_olp_buf_wr_dat_1_2_o   (pu2xy_odd_wdata_1_2                    ),
    .odd_xy_olp_buf_wr_dat_1_3_o   (pu2xy_odd_wdata_1_3                    ),
    .odd_xy_olp_buf_wr_dat_2_0_o   (pu2xy_odd_wdata_2_0                    ),
    .odd_xy_olp_buf_wr_dat_2_1_o   (pu2xy_odd_wdata_2_1                    ),
    .odd_xy_olp_buf_wr_dat_2_2_o   (pu2xy_odd_wdata_2_2                    ),
    .odd_xy_olp_buf_wr_dat_2_3_o   (pu2xy_odd_wdata_2_3                    ),
    .odd_xy_olp_buf_wr_dat_3_0_o   (pu2xy_odd_wdata_3_0                    ),
    .odd_xy_olp_buf_wr_dat_3_1_o   (pu2xy_odd_wdata_3_1                    ),
    .odd_xy_olp_buf_wr_dat_3_2_o   (pu2xy_odd_wdata_3_2                    ),
    .odd_xy_olp_buf_wr_dat_3_3_o   (pu2xy_odd_wdata_3_3                    )
);

wt_buf #(
    .WT_WIDTH                      (WT_WIDTH                               ),
    .WT_ADDR_WIDTH                 (WT_ADDR_WIDTH                          ),
    .WT_BUF0_DEPTH                 (WT_BUF0_DEPTH                          ),
    .WT_BUF1_DEPTH                 (WT_BUF1_DEPTH                          ),
    .IC_NUM                        (IC_NUM                                 ),
    .OC_NUM                        (OC_NUM                                 ),
    .WT_BUF_WIDTH                  (WT_BUF_WIDTH                           ),
    .WT_GRP_NUM                    (WT_GRP_NUM                             ),
    .AXI2W_WIDTH                   (AXI2W_WIDTH                            ),
    .KNOB_REGOUT                   (KNOB_REGOUT                            )
)
u_wt_buf (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .buf_pp_flag                   (buf_pp_flag                            ),
    .axi2w_waddr                   (axi2w_waddr                            ),
    .axi2w_wen                     (axi2w_wen                              ),
    .axi2w_wdata                   (axi2w_wdata                            ),
    .axi2w_raddr                   (axi2w_raddr                            ),
    .axi2w_ren                     (axi2w_ren                              ),
    .axi2w_rdata                   (axi2w_rdata                            ),
    .sch2w_ren                     (sch2w_ren                              ),
    .sch2w_raddr                   (sch2w_raddr                            ),
    .w2sch_rdata_0_0               (w2sch_rdata_0_0                        ),
    .w2sch_rdata_0_1               (w2sch_rdata_0_1                        ),
    .w2sch_rdata_0_2               (w2sch_rdata_0_2                        ),
    .w2sch_rdata_0_3               (w2sch_rdata_0_3                        ),
    .w2sch_rdata_1_0               (w2sch_rdata_1_0                        ),
    .w2sch_rdata_1_1               (w2sch_rdata_1_1                        ),
    .w2sch_rdata_1_2               (w2sch_rdata_1_2                        ),
    .w2sch_rdata_1_3               (w2sch_rdata_1_3                        ),
    .w2sch_rdata_2_0               (w2sch_rdata_2_0                        ),
    .w2sch_rdata_2_1               (w2sch_rdata_2_1                        ),
    .w2sch_rdata_2_2               (w2sch_rdata_2_2                        ),
    .w2sch_rdata_2_3               (w2sch_rdata_2_3                        ),
    .w2sch_rdata_3_0               (w2sch_rdata_3_0                        ),
    .w2sch_rdata_3_1               (w2sch_rdata_3_1                        ),
    .w2sch_rdata_3_2               (w2sch_rdata_3_2                        ),
    .w2sch_rdata_3_3               (w2sch_rdata_3_3                        )
);

fe_buf #(
    .FE_ADDR_WIDTH                 (FE_ADDR_WIDTH                          ),
    .FE_BUF_DEPTH                  (FE_BUF_DEPTH                           ),
    .FE_BUF_WIDTH                  (FE_BUF_WIDTH                           ),
    .AXI2F_DATA_WIDTH              (AXI2F_DATA_WIDTH                       ),
    .AXI2F_ADDR_WIDTH              (AXI2F_ADDR_WIDTH                       ),
    .KNOB_REGOUT                   (KNOB_REGOUT                            )
)
u_fe_buf (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .layer_done                    (layer_done                             ),
    .tile_switch_r                 (tile_switch_r                          ),
    .stat_ctrl                     (stat_ctrl                              ),
    .axi2f_waddr                   (axi2f_waddr                            ),
    .axi2f_wen                     (axi2f_wen                              ),
    .axi2f_wdata                   (axi2f_wdata_w                          ),
    .axi2f_raddr                   (axi2f_raddr                            ),
    .axi2f_ren                     (axi2f_ren                              ),
    .axi2f_rdata                   (axi2f_rdata_w                            ),
    .sch2fe_ren                    ({sch2fe_ren[0],sch2fe_ren[1],sch2fe_ren[2],sch2fe_ren[3]}),
    .sch2fe_raddr_0                (sch2fe_raddr_0                         ),
    .sch2fe_raddr_1                (sch2fe_raddr_1                         ),
    .sch2fe_raddr_2                (sch2fe_raddr_2                         ),
    .sch2fe_raddr_3                (sch2fe_raddr_3                         ),
    .fe2sch_rdata_0_0              (fe2sch_rdata_0_0                       ),
    .fe2sch_rdata_0_1              (fe2sch_rdata_0_1                       ),
    .fe2sch_rdata_0_2              (fe2sch_rdata_0_2                       ),
    .fe2sch_rdata_0_3              (fe2sch_rdata_0_3                       ),
    .fe2sch_rdata_1_0              (fe2sch_rdata_1_0                       ),
    .fe2sch_rdata_1_1              (fe2sch_rdata_1_1                       ),
    .fe2sch_rdata_1_2              (fe2sch_rdata_1_2                       ),
    .fe2sch_rdata_1_3              (fe2sch_rdata_1_3                       ),
    .fe2sch_rdata_2_0              (fe2sch_rdata_2_0                       ),
    .fe2sch_rdata_2_1              (fe2sch_rdata_2_1                       ),
    .fe2sch_rdata_2_2              (fe2sch_rdata_2_2                       ),
    .fe2sch_rdata_2_3              (fe2sch_rdata_2_3                       ),
    .fe2sch_rdata_3_0              (fe2sch_rdata_3_0                       ),
    .fe2sch_rdata_3_1              (fe2sch_rdata_3_1                       ),
    .fe2sch_rdata_3_2              (fe2sch_rdata_3_2                       ),
    .fe2sch_rdata_3_3              (fe2sch_rdata_3_3                       ),
    .pu2fe_wen                     (pu2fe_wen                              ),
    .pu2fe_waddr                   (pu2fe_waddr                            ),
    .pu2fe_wdata_0_0               (pu2fe_wdata_0_0                        ),
    .pu2fe_wdata_0_1               (pu2fe_wdata_0_1                        ),
    .pu2fe_wdata_0_2               (pu2fe_wdata_0_2                        ),
    .pu2fe_wdata_0_3               (pu2fe_wdata_0_3                        ),
    .pu2fe_wdata_1_0               (pu2fe_wdata_1_0                        ),
    .pu2fe_wdata_1_1               (pu2fe_wdata_1_1                        ),
    .pu2fe_wdata_1_2               (pu2fe_wdata_1_2                        ),
    .pu2fe_wdata_1_3               (pu2fe_wdata_1_3                        ),
    .pu2fe_wdata_2_0               (pu2fe_wdata_2_0                        ),
    .pu2fe_wdata_2_1               (pu2fe_wdata_2_1                        ),
    .pu2fe_wdata_2_2               (pu2fe_wdata_2_2                        ),
    .pu2fe_wdata_2_3               (pu2fe_wdata_2_3                        ),
    .pu2fe_wdata_3_0               (pu2fe_wdata_3_0                        ),
    .pu2fe_wdata_3_1               (pu2fe_wdata_3_1                        ),
    .pu2fe_wdata_3_2               (pu2fe_wdata_3_2                        ),
    .pu2fe_wdata_3_3               (pu2fe_wdata_3_3                        )
);

olp_buf #(
    .X_L1_ADDR_WIDTH               (OLPX_L1_ADDR_WIDTH                     ),
    .X_L1_BUF_DEPTH                (OLPX_L1_BUF_DEPTH                      ),
    .X_BUF_WIDTH                   (OLPX_BUF_WIDTH                         ),
    .X_ADDR_WIDTH                  (OLPX_ADDR_WIDTH                        ),
    .X_BUF_DEPTH                   (OLPX_BUF_DEPTH                         ),
    .Y_L1_ADDR_WIDTH               (OLPY_L1_ADDR_WIDTH                     ),
    .Y_L1_BUF_DEPTH                (OLPY_L1_BUF_DEPTH                      ),
    .Y_BUF_WIDTH                   (OLPY_BUF_WIDTH                         ),
    .Y_ADDR_WIDTH                  (OLPY_ADDR_WIDTH                        ),
    .Y_BUF_DEPTH                   (OLPY_BUF_DEPTH                         ),
    .XY_L1_ADDR_WIDTH              (OLPXY_L1_ADDR_WIDTH                    ),
    .XY_L1_BUF_DEPTH               (OLPXY_L1_BUF_DEPTH                     ),
    .XY_BUF_WIDTH                  (OLPXY_BUF_WIDTH                        ),
    .XY_ADDR_WIDTH                 (OLPXY_ADDR_WIDTH                       ),
    .XY_BUF_DEPTH                  (OLPXY_BUF_DEPTH                        ),
    .FE_ADDR_WIDTH                 (FE_ADDR_WIDTH                          ),
    .AXI2F_DATA_WIDTH              (AXI2F_DATA_WIDTH                       ),
    .AXI2F_ADDR_WIDTH              (AXI2F_ADDR_WIDTH                       ),
    .REG_TNX_WIDTH                 (REG_TNX_WIDTH                          ),
    .KNOB_REGOUT                   (KNOB_REGOUT                            )
)
u_olp_buf (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .stat_ctrl                     (stat_ctrl                              ),
    .layer_done                    (layer_done                             ),
    .tile_tot_num_x                (tile_tot_num_x                         ),
    .tile_switch_r                 (tile_switch_r                          ),
    .tile_switch                   (tile_switch                            ),
    .model_switch_r                (model_switch_r                         ),
    .model_switch                  (model_switch                           ),
    .cnt_layer                     (cnt_layer                              ),
    .nn_proc                       (nn_proc                                ),
    .axi2f_waddr                   (axi2f_waddr                            ),
    .axi2f_wen                     (axi2f_wen                              ),
    .axi2f_wdata                   (axi2f_wdata                            ),
    .sch2x_ren                     (sch2x_ren                              ),
    .sch2x_raddr_0                 (sch2x_raddr_0                          ),
    .sch2x_raddr_1                 (sch2x_raddr_1                          ),
    .sch2x_raddr_2                 (sch2x_raddr_2                          ),
    .sch2x_raddr_3                 (sch2x_raddr_3                          ),
    .x2sch_rdata_0_0               (x2sch_rdata_0_0                        ),
    .x2sch_rdata_0_1               (x2sch_rdata_0_1                        ),
    .x2sch_rdata_0_2               (x2sch_rdata_0_2                        ),
    .x2sch_rdata_0_3               (x2sch_rdata_0_3                        ),
    .x2sch_rdata_1_0               (x2sch_rdata_1_0                        ),
    .x2sch_rdata_1_1               (x2sch_rdata_1_1                        ),
    .x2sch_rdata_1_2               (x2sch_rdata_1_2                        ),
    .x2sch_rdata_1_3               (x2sch_rdata_1_3                        ),
    .x2sch_rdata_2_0               (x2sch_rdata_2_0                        ),
    .x2sch_rdata_2_1               (x2sch_rdata_2_1                        ),
    .x2sch_rdata_2_2               (x2sch_rdata_2_2                        ),
    .x2sch_rdata_2_3               (x2sch_rdata_2_3                        ),
    .x2sch_rdata_3_0               (x2sch_rdata_3_0                        ),
    .x2sch_rdata_3_1               (x2sch_rdata_3_1                        ),
    .x2sch_rdata_3_2               (x2sch_rdata_3_2                        ),
    .x2sch_rdata_3_3               (x2sch_rdata_3_3                        ),
    .sch2y_ren                     (sch2y_ren                              ),
    .sch2y_raddr                   (sch2y_raddr                            ),
    .y2sch_rdata_0_0               (y2sch_rdata_0_0                        ),
    .y2sch_rdata_0_1               (y2sch_rdata_0_1                        ),
    .y2sch_rdata_0_2               (y2sch_rdata_0_2                        ),
    .y2sch_rdata_0_3               (y2sch_rdata_0_3                        ),
    .y2sch_rdata_1_0               (y2sch_rdata_1_0                        ),
    .y2sch_rdata_1_1               (y2sch_rdata_1_1                        ),
    .y2sch_rdata_1_2               (y2sch_rdata_1_2                        ),
    .y2sch_rdata_1_3               (y2sch_rdata_1_3                        ),
    .y2sch_rdata_2_0               (y2sch_rdata_2_0                        ),
    .y2sch_rdata_2_1               (y2sch_rdata_2_1                        ),
    .y2sch_rdata_2_2               (y2sch_rdata_2_2                        ),
    .y2sch_rdata_2_3               (y2sch_rdata_2_3                        ),
    .y2sch_rdata_3_0               (y2sch_rdata_3_0                        ),
    .y2sch_rdata_3_1               (y2sch_rdata_3_1                        ),
    .y2sch_rdata_3_2               (y2sch_rdata_3_2                        ),
    .y2sch_rdata_3_3               (y2sch_rdata_3_3                        ),
    .sch2xy_evn_ren                ({sch2xy_evn_ren[0],sch2xy_evn_ren[1],sch2xy_evn_ren[2],sch2xy_evn_ren[3]}),
    .sch2xy_odd_ren                ({sch2xy_odd_ren[0],sch2xy_odd_ren[1],sch2xy_odd_ren[2],sch2xy_odd_ren[3]}),
    .sch2xy_raddr_evn              (sch2xy_raddr_evn                       ),
    .sch2xy_raddr_odd              (sch2xy_raddr_odd                       ),
    .xy2sch_evn_rdata_0_0          (xy2sch_evn_rdata_0_0                   ),
    .xy2sch_evn_rdata_0_1          (xy2sch_evn_rdata_0_1                   ),
    .xy2sch_evn_rdata_0_2          (xy2sch_evn_rdata_0_2                   ),
    .xy2sch_evn_rdata_0_3          (xy2sch_evn_rdata_0_3                   ),
    .xy2sch_evn_rdata_1_0          (xy2sch_evn_rdata_1_0                   ),
    .xy2sch_evn_rdata_1_1          (xy2sch_evn_rdata_1_1                   ),
    .xy2sch_evn_rdata_1_2          (xy2sch_evn_rdata_1_2                   ),
    .xy2sch_evn_rdata_1_3          (xy2sch_evn_rdata_1_3                   ),
    .xy2sch_evn_rdata_2_0          (xy2sch_evn_rdata_2_0                   ),
    .xy2sch_evn_rdata_2_1          (xy2sch_evn_rdata_2_1                   ),
    .xy2sch_evn_rdata_2_2          (xy2sch_evn_rdata_2_2                   ),
    .xy2sch_evn_rdata_2_3          (xy2sch_evn_rdata_2_3                   ),
    .xy2sch_evn_rdata_3_0          (xy2sch_evn_rdata_3_0                   ),
    .xy2sch_evn_rdata_3_1          (xy2sch_evn_rdata_3_1                   ),
    .xy2sch_evn_rdata_3_2          (xy2sch_evn_rdata_3_2                   ),
    .xy2sch_evn_rdata_3_3          (xy2sch_evn_rdata_3_3                   ),
    .xy2sch_odd_rdata_0_0          (xy2sch_odd_rdata_0_0                   ),
    .xy2sch_odd_rdata_0_1          (xy2sch_odd_rdata_0_1                   ),
    .xy2sch_odd_rdata_0_2          (xy2sch_odd_rdata_0_2                   ),
    .xy2sch_odd_rdata_0_3          (xy2sch_odd_rdata_0_3                   ),
    .xy2sch_odd_rdata_1_0          (xy2sch_odd_rdata_1_0                   ),
    .xy2sch_odd_rdata_1_1          (xy2sch_odd_rdata_1_1                   ),
    .xy2sch_odd_rdata_1_2          (xy2sch_odd_rdata_1_2                   ),
    .xy2sch_odd_rdata_1_3          (xy2sch_odd_rdata_1_3                   ),
    .xy2sch_odd_rdata_2_0          (xy2sch_odd_rdata_2_0                   ),
    .xy2sch_odd_rdata_2_1          (xy2sch_odd_rdata_2_1                   ),
    .xy2sch_odd_rdata_2_2          (xy2sch_odd_rdata_2_2                   ),
    .xy2sch_odd_rdata_2_3          (xy2sch_odd_rdata_2_3                   ),
    .xy2sch_odd_rdata_3_0          (xy2sch_odd_rdata_3_0                   ),
    .xy2sch_odd_rdata_3_1          (xy2sch_odd_rdata_3_1                   ),
    .xy2sch_odd_rdata_3_2          (xy2sch_odd_rdata_3_2                   ),
    .xy2sch_odd_rdata_3_3          (xy2sch_odd_rdata_3_3                   ),
    .pu2x_wen                      (pu2x_wen                               ),
    .pu2x_waddr                    (pu2x_waddr                             ),
    .pu2x_wdata_0_0                (pu2x_wdata_0_0                         ),
    .pu2x_wdata_0_1                (pu2x_wdata_0_1                         ),
    .pu2x_wdata_0_2                (pu2x_wdata_0_2                         ),
    .pu2x_wdata_0_3                (pu2x_wdata_0_3                         ),
    .pu2x_wdata_1_0                (pu2x_wdata_1_0                         ),
    .pu2x_wdata_1_1                (pu2x_wdata_1_1                         ),
    .pu2x_wdata_1_2                (pu2x_wdata_1_2                         ),
    .pu2x_wdata_1_3                (pu2x_wdata_1_3                         ),
    .pu2x_wdata_2_0                (pu2x_wdata_2_0                         ),
    .pu2x_wdata_2_1                (pu2x_wdata_2_1                         ),
    .pu2x_wdata_2_2                (pu2x_wdata_2_2                         ),
    .pu2x_wdata_2_3                (pu2x_wdata_2_3                         ),
    .pu2x_wdata_3_0                (pu2x_wdata_3_0                         ),
    .pu2x_wdata_3_1                (pu2x_wdata_3_1                         ),
    .pu2x_wdata_3_2                (pu2x_wdata_3_2                         ),
    .pu2x_wdata_3_3                (pu2x_wdata_3_3                         ),
    .pu2y_wen                      (pu2y_wen                               ),
    .pu2y_waddr                    (pu2y_waddr                             ),
    .pu2y_wdata_0_0                (pu2y_wdata_0_0                         ),
    .pu2y_wdata_0_1                (pu2y_wdata_0_1                         ),
    .pu2y_wdata_0_2                (pu2y_wdata_0_2                         ),
    .pu2y_wdata_0_3                (pu2y_wdata_0_3                         ),
    .pu2y_wdata_1_0                (pu2y_wdata_1_0                         ),
    .pu2y_wdata_1_1                (pu2y_wdata_1_1                         ),
    .pu2y_wdata_1_2                (pu2y_wdata_1_2                         ),
    .pu2y_wdata_1_3                (pu2y_wdata_1_3                         ),
    .pu2y_wdata_2_0                (pu2y_wdata_2_0                         ),
    .pu2y_wdata_2_1                (pu2y_wdata_2_1                         ),
    .pu2y_wdata_2_2                (pu2y_wdata_2_2                         ),
    .pu2y_wdata_2_3                (pu2y_wdata_2_3                         ),
    .pu2y_wdata_3_0                (pu2y_wdata_3_0                         ),
    .pu2y_wdata_3_1                (pu2y_wdata_3_1                         ),
    .pu2y_wdata_3_2                (pu2y_wdata_3_2                         ),
    .pu2y_wdata_3_3                (pu2y_wdata_3_3                         ),
    .pu2xy_evn_wen                 (pu2xy_evn_wen                          ),
    .pu2xy_evn_waddr               (pu2xy_evn_waddr                        ),
    .pu2xy_evn_wdata_0_0           (pu2xy_evn_wdata_0_0                    ),
    .pu2xy_evn_wdata_0_1           (pu2xy_evn_wdata_0_1                    ),
    .pu2xy_evn_wdata_0_2           (pu2xy_evn_wdata_0_2                    ),
    .pu2xy_evn_wdata_0_3           (pu2xy_evn_wdata_0_3                    ),
    .pu2xy_evn_wdata_1_0           (pu2xy_evn_wdata_1_0                    ),
    .pu2xy_evn_wdata_1_1           (pu2xy_evn_wdata_1_1                    ),
    .pu2xy_evn_wdata_1_2           (pu2xy_evn_wdata_1_2                    ),
    .pu2xy_evn_wdata_1_3           (pu2xy_evn_wdata_1_3                    ),
    .pu2xy_evn_wdata_2_0           (pu2xy_evn_wdata_2_0                    ),
    .pu2xy_evn_wdata_2_1           (pu2xy_evn_wdata_2_1                    ),
    .pu2xy_evn_wdata_2_2           (pu2xy_evn_wdata_2_2                    ),
    .pu2xy_evn_wdata_2_3           (pu2xy_evn_wdata_2_3                    ),
    .pu2xy_evn_wdata_3_0           (pu2xy_evn_wdata_3_0                    ),
    .pu2xy_evn_wdata_3_1           (pu2xy_evn_wdata_3_1                    ),
    .pu2xy_evn_wdata_3_2           (pu2xy_evn_wdata_3_2                    ),
    .pu2xy_evn_wdata_3_3           (pu2xy_evn_wdata_3_3                    ),
    .pu2xy_odd_wen                 (pu2xy_odd_wen                          ),
    .pu2xy_odd_waddr               (pu2xy_odd_waddr                        ),
    .pu2xy_odd_wdata_0_0           (pu2xy_odd_wdata_0_0                    ),
    .pu2xy_odd_wdata_0_1           (pu2xy_odd_wdata_0_1                    ),
    .pu2xy_odd_wdata_0_2           (pu2xy_odd_wdata_0_2                    ),
    .pu2xy_odd_wdata_0_3           (pu2xy_odd_wdata_0_3                    ),
    .pu2xy_odd_wdata_1_0           (pu2xy_odd_wdata_1_0                    ),
    .pu2xy_odd_wdata_1_1           (pu2xy_odd_wdata_1_1                    ),
    .pu2xy_odd_wdata_1_2           (pu2xy_odd_wdata_1_2                    ),
    .pu2xy_odd_wdata_1_3           (pu2xy_odd_wdata_1_3                    ),
    .pu2xy_odd_wdata_2_0           (pu2xy_odd_wdata_2_0                    ),
    .pu2xy_odd_wdata_2_1           (pu2xy_odd_wdata_2_1                    ),
    .pu2xy_odd_wdata_2_2           (pu2xy_odd_wdata_2_2                    ),
    .pu2xy_odd_wdata_2_3           (pu2xy_odd_wdata_2_3                    ),
    .pu2xy_odd_wdata_3_0           (pu2xy_odd_wdata_3_0                    ),
    .pu2xy_odd_wdata_3_1           (pu2xy_odd_wdata_3_1                    ),
    .pu2xy_odd_wdata_3_2           (pu2xy_odd_wdata_3_2                    ),
    .pu2xy_odd_wdata_3_3           (pu2xy_odd_wdata_3_3                    )
);

param_buf #(
    .BIAS_DATA_WIDTH               (BIAS_DATA_WIDTH                        ),
    .HBM_DATA_WIDTH                (HBM_DATA_WIDTH                         ),
    .LBM_DATA_WIDTH                (LBM_DATA_WIDTH                         ),
    .OC_NUM                        (OC_NUM                                 ),
    .P_ADDR_WIDTH                  (P_ADDR_WIDTH                           ),
    .P_BUF0_DEPTH                  (P_BUF0_DEPTH                           ),
    .P_BUF1_DEPTH                  (P_BUF1_DEPTH                           ),
    .P_BUF_WIDTH                   (P_BUF_WIDTH                            ),
    .P2PU_RD_WIDTH                 (P2PU_RD_WIDTH                          )
)
u_param_buf (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .buf_pp_flag                   (buf_pp_flag                            ),
    .axi2p_waddr                   (axi2p_waddr                            ),
    .axi2p_wen                     (axi2p_wen                              ),
    .axi2p_wdata                   (axi2p_wdata                            ),
    .axi2p_raddr                   (axi2p_raddr                            ),
    .axi2p_ren                     (axi2p_ren                              ),
    .axi2p_rdata                   (axi2p_rdata                            ),
    .pu2p_ren                      (pu2p_ren                               ),
    .pu2p_raddr                    (pu2p_raddr                             ),
    .p2pu_rdata_0                  (p2pu_rdata_0                           ),
    .p2pu_rdata_1                  (p2pu_rdata_1                           ),
    .p2pu_rdata_2                  (p2pu_rdata_2                           ),
    .p2pu_rdata_3                  (p2pu_rdata_3                           )
);

res_buf #(
    .RESX_ADDR_WIDTH               (RESX_ADDR_WIDTH                        ),
    .RESX_BUF_DEPTH                (RESX_BUF_DEPTH                         ),
    .RESX_LBUF_WIDTH               (RESX_LBUF_WIDTH                        ),
    .RESX_SBUF_WIDTH               (RESX_SBUF_WIDTH                        ),
    .RESY_ADDR_WIDTH               (RESY_ADDR_WIDTH                        ),
    .RESY_BUF_DEPTH                (RESY_BUF_DEPTH                         ),
    .RESY_BUF_WIDTH                (RESY_BUF_WIDTH                         ),
    .RESXY_ADDR_WIDTH              (RESXY_ADDR_WIDTH                       ),
    .RESXY_BUF_DEPTH               (RESXY_BUF_DEPTH                        ),
    .RESXY_BUF_WIDTH               (RESXY_BUF_WIDTH                        )
)
u_res_buf (
    .clk                           (clk                                    ),
    .rst_n                         (rst_n                                  ),
    .layer_done                    (layer_done                             ),
    .res_proc_type                 (res_proc_type                          ),
    .nn_proc                       (nn_proc                                ),
    .tile_loc                      (tile_loc                               ),
    .pu2rx_ren                     (pu2rx_ren                              ),
    .pu2rx_raddr                   (pu2rx_raddr                            ),
    .rx2pu_rdata_0_0               (rx2pu_rdata_0_0                        ),
    .rx2pu_rdata_0_1               (rx2pu_rdata_0_1                        ),
    .rx2pu_rdata_0_2               (rx2pu_rdata_0_2                        ),
    .rx2pu_rdata_0_3               (rx2pu_rdata_0_3                        ),
    .rx2pu_rdata_1_0               (rx2pu_rdata_1_0                        ),
    .rx2pu_rdata_1_1               (rx2pu_rdata_1_1                        ),
    .rx2pu_rdata_1_2               (rx2pu_rdata_1_2                        ),
    .rx2pu_rdata_1_3               (rx2pu_rdata_1_3                        ),
    .rx2pu_rdata_2_0               (rx2pu_rdata_2_0                        ),
    .rx2pu_rdata_2_1               (rx2pu_rdata_2_1                        ),
    .rx2pu_rdata_2_2               (rx2pu_rdata_2_2                        ),
    .rx2pu_rdata_2_3               (rx2pu_rdata_2_3                        ),
    .rx2pu_rdata_3_0               (rx2pu_rdata_3_0                        ),
    .rx2pu_rdata_3_1               (rx2pu_rdata_3_1                        ),
    .rx2pu_rdata_3_2               (rx2pu_rdata_3_2                        ),
    .rx2pu_rdata_3_3               (rx2pu_rdata_3_3                        ),
    .pu2rx_wen                     (pu2rx_wen                              ),
    .pu2rx_waddr_0                 (pu2rx_waddr_0                          ),
    .pu2rx_waddr_1                 (pu2rx_waddr_1                          ),
    .pu2rx_waddr_2                 (pu2rx_waddr_2                          ),
    .pu2rx_waddr_3                 (pu2rx_waddr_3                          ),
    .pu2rx_wdata_0_0               (pu2rx_wdata_0_0                        ),
    .pu2rx_wdata_0_1               (pu2rx_wdata_0_1                        ),
    .pu2rx_wdata_0_2               (pu2rx_wdata_0_2                        ),
    .pu2rx_wdata_0_3               (pu2rx_wdata_0_3                        ),
    .pu2rx_wdata_1_0               (pu2rx_wdata_1_0                        ),
    .pu2rx_wdata_1_1               (pu2rx_wdata_1_1                        ),
    .pu2rx_wdata_1_2               (pu2rx_wdata_1_2                        ),
    .pu2rx_wdata_1_3               (pu2rx_wdata_1_3                        ),
    .pu2rx_wdata_2_0               (pu2rx_wdata_2_0                        ),
    .pu2rx_wdata_2_1               (pu2rx_wdata_2_1                        ),
    .pu2rx_wdata_2_2               (pu2rx_wdata_2_2                        ),
    .pu2rx_wdata_2_3               (pu2rx_wdata_2_3                        ),
    .pu2rx_wdata_3_0               (pu2rx_wdata_3_0                        ),
    .pu2rx_wdata_3_1               (pu2rx_wdata_3_1                        ),
    .pu2rx_wdata_3_2               (pu2rx_wdata_3_2                        ),
    .pu2rx_wdata_3_3               (pu2rx_wdata_3_3                        ),
    .pu2ry_ren                     (pu2ry_ren                              ),
    .pu2ry_raddr                   (pu2ry_raddr                            ),
    .ry2pu_rdata_0_0               (ry2pu_rdata_0_0                        ),
    .ry2pu_rdata_0_1               (ry2pu_rdata_0_1                        ),
    .ry2pu_rdata_0_2               (ry2pu_rdata_0_2                        ),
    .ry2pu_rdata_1_0               (ry2pu_rdata_1_0                        ),
    .ry2pu_rdata_1_1               (ry2pu_rdata_1_1                        ),
    .ry2pu_rdata_1_2               (ry2pu_rdata_1_2                        ),
    .ry2pu_rdata_2_0               (ry2pu_rdata_2_0                        ),
    .ry2pu_rdata_2_1               (ry2pu_rdata_2_1                        ),
    .ry2pu_rdata_2_2               (ry2pu_rdata_2_2                        ),
    .ry2pu_rdata_3_0               (ry2pu_rdata_3_0                        ),
    .ry2pu_rdata_3_1               (ry2pu_rdata_3_1                        ),
    .ry2pu_rdata_3_2               (ry2pu_rdata_3_2                        ),
    .pu2ry_wen                     (pu2ry_wen                              ),
    .pu2ry_waddr                   (pu2ry_waddr                            ),
    .pu2ry_wdata_0_0               (pu2ry_wdata_0_0                        ),
    .pu2ry_wdata_0_1               (pu2ry_wdata_0_1                        ),
    .pu2ry_wdata_0_2               (pu2ry_wdata_0_2                        ),
    .pu2ry_wdata_1_0               (pu2ry_wdata_1_0                        ),
    .pu2ry_wdata_1_1               (pu2ry_wdata_1_1                        ),
    .pu2ry_wdata_1_2               (pu2ry_wdata_1_2                        ),
    .pu2ry_wdata_2_0               (pu2ry_wdata_2_0                        ),
    .pu2ry_wdata_2_1               (pu2ry_wdata_2_1                        ),
    .pu2ry_wdata_2_2               (pu2ry_wdata_2_2                        ),
    .pu2ry_wdata_3_0               (pu2ry_wdata_3_0                        ),
    .pu2ry_wdata_3_1               (pu2ry_wdata_3_1                        ),
    .pu2ry_wdata_3_2               (pu2ry_wdata_3_2                        ),
    .pu2rxy_ren                    (pu2rxy_ren                             ),
    .pu2rxy_raddr                  (pu2rxy_raddr                           ),
    .rxy2pu_rdata_0_0              (rxy2pu_rdata_0_0                       ),
    .rxy2pu_rdata_0_1              (rxy2pu_rdata_0_1                       ),
    .rxy2pu_rdata_0_2              (rxy2pu_rdata_0_2                       ),
    .rxy2pu_rdata_1_0              (rxy2pu_rdata_1_0                       ),
    .rxy2pu_rdata_1_1              (rxy2pu_rdata_1_1                       ),
    .rxy2pu_rdata_1_2              (rxy2pu_rdata_1_2                       ),
    .rxy2pu_rdata_2_0              (rxy2pu_rdata_2_0                       ),
    .rxy2pu_rdata_2_1              (rxy2pu_rdata_2_1                       ),
    .rxy2pu_rdata_2_2              (rxy2pu_rdata_2_2                       ),
    .rxy2pu_rdata_3_0              (rxy2pu_rdata_3_0                       ),
    .rxy2pu_rdata_3_1              (rxy2pu_rdata_3_1                       ),
    .rxy2pu_rdata_3_2              (rxy2pu_rdata_3_2                       ),
    .pu2rxy_wen                    (pu2rxy_wen                             ),
    .pu2rxy_waddr                  (pu2rxy_waddr                           ),
    .pu2rxy_wdata_0_0              (pu2rxy_wdata_0_0                       ),
    .pu2rxy_wdata_0_1              (pu2rxy_wdata_0_1                       ),
    .pu2rxy_wdata_0_2              (pu2rxy_wdata_0_2                       ),
    .pu2rxy_wdata_1_0              (pu2rxy_wdata_1_0                       ),
    .pu2rxy_wdata_1_1              (pu2rxy_wdata_1_1                       ),
    .pu2rxy_wdata_1_2              (pu2rxy_wdata_1_2                       ),
    .pu2rxy_wdata_2_0              (pu2rxy_wdata_2_0                       ),
    .pu2rxy_wdata_2_1              (pu2rxy_wdata_2_1                       ),
    .pu2rxy_wdata_2_2              (pu2rxy_wdata_2_2                       ),
    .pu2rxy_wdata_3_0              (pu2rxy_wdata_3_0                       ),
    .pu2rxy_wdata_3_1              (pu2rxy_wdata_3_1                       ),
    .pu2rxy_wdata_3_2              (pu2rxy_wdata_3_2                       )
);

assign tile_out_h_w = tile_out_h;

assign axi2f_wdata_w  = {{axi2f_wdata[0 +: (AXI2F_DATA_WIDTH >> 2)],axi2f_wdata[(AXI2F_DATA_WIDTH >> 2) +: (AXI2F_DATA_WIDTH >> 2)],axi2f_wdata[(AXI2F_DATA_WIDTH >> 2)*2 +: (AXI2F_DATA_WIDTH >> 2)],
                        axi2f_wdata[(AXI2F_DATA_WIDTH >> 2)*3 +: (AXI2F_DATA_WIDTH >> 2)]}};
assign axi2f_rdata    = {{axi2f_rdata_w[0 +: (AXI2F_DATA_WIDTH >> 2)],axi2f_rdata_w[(AXI2F_DATA_WIDTH >> 2) +: (AXI2F_DATA_WIDTH >> 2)],axi2f_rdata_w[(AXI2F_DATA_WIDTH >> 2)*2 +: (AXI2F_DATA_WIDTH >> 2)],
                        axi2f_rdata_w[(AXI2F_DATA_WIDTH >> 2)*3 +: (AXI2F_DATA_WIDTH >> 2)]}};
endmodule
