/*
    Top Module:  olp_buf.v
    Author:      Hao Zhang
    Time:        202307
*/

module olp_buf#(
    parameter    X_L1_ADDR_WIDTH    = 4                 ,
    parameter    X_L1_BUF_DEPTH     = 8                 ,
    parameter    X_BUF_WIDTH        = 32                ,
    parameter    X_ADDR_WIDTH       = 8                 ,
    parameter    X_BUF_DEPTH        = 128               ,
    parameter    Y_L1_ADDR_WIDTH    = 6                 ,
    parameter    Y_L1_BUF_DEPTH     = 32                ,
    parameter    Y_BUF_WIDTH        = 224               ,
    parameter    Y_ADDR_WIDTH       = 9                 ,
    parameter    Y_BUF_DEPTH        = 320               ,
    parameter    XY_L1_ADDR_WIDTH   = 5                 ,
    parameter    XY_L1_BUF_DEPTH    = 17                ,
    parameter    XY_BUF_WIDTH       = 32                ,
    parameter    XY_ADDR_WIDTH      = 8                 ,
    parameter    XY_BUF_DEPTH       = 170               ,
    // parameter    X_L234_DEPTH       = 32                ,
    // parameter    Y_L234_DEPTH       = 64                ,
    // parameter    XY_L234_DEPTH      = 34                ,
    parameter    FE_ADDR_WIDTH      = 6                 ,
    parameter    AXI2F_DATA_WIDTH   = 1024              ,
    parameter    AXI2F_ADDR_WIDTH   = FE_ADDR_WIDTH + 2 ,// 2 bit MSB for buf-grouping
    parameter    REG_TNX_WIDTH      = 6                 ,
    parameter    KNOB_REGOUT        = 0
)
(
    input   wire                                      clk                   ,
    input   wire                                      rst_n                 ,
    // control
    input   wire    [                       1 : 0]    stat_ctrl             ,
    input   wire                                      layer_done            ,
    input   wire    [       REG_TNX_WIDTH - 1 : 0]    tile_tot_num_x        ,
    input   wire                                      tile_switch_r         ,
    input   wire                                      tile_switch           ,
    input   wire                                      model_switch_r        ,
    input   wire                                      model_switch          ,
    input   wire    [                       2 : 0]    cnt_layer             ,
    input   wire                                      nn_proc               , //0-dndm 1-sr
    // axi
    input   wire    [    AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_waddr           ,
    input   wire                                      axi2f_wen             ,
    input   wire    [    AXI2F_DATA_WIDTH - 1 : 0]    axi2f_wdata           ,
    // scheduler rd x_olp buf
    input   wire    [                   4 - 1 : 0]    sch2x_ren             ,
    input   wire    [        X_ADDR_WIDTH - 1 : 0]    sch2x_raddr_0         , //_x_0 grp
    input   wire    [        X_ADDR_WIDTH - 1 : 0]    sch2x_raddr_1         , //_x_1 grp
    input   wire    [        X_ADDR_WIDTH - 1 : 0]    sch2x_raddr_2         , //_x_2 grp
    input   wire    [        X_ADDR_WIDTH - 1 : 0]    sch2x_raddr_3         , //_x_3 grp
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_0       , //_c_row
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_1       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_2       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_0_3       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_0       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_1       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_2       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_1_3       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_0       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_1       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_2       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_2_3       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_0       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_1       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_2       ,
    output  wire    [         X_BUF_WIDTH - 1 : 0]    x2sch_rdata_3_3       ,
    // scheduler rd y_olp buf
    input   wire    [                   4 - 1 : 0]    sch2y_ren             ,
    input   wire    [        Y_ADDR_WIDTH - 1 : 0]    sch2y_raddr           ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_0       , //_c_row
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_1       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_2       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_0_3       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_0       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_1       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_2       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_1_3       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_0       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_1       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_2       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_2_3       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_0       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_1       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_2       ,
    output  wire    [         Y_BUF_WIDTH - 1 : 0]    y2sch_rdata_3_3       ,
    // scheduler rd xy_olp_evn & xy_olp_odd buf
    input   wire    [                   4 - 1 : 0]    sch2xy_evn_ren        ,
    input   wire    [                   4 - 1 : 0]    sch2xy_odd_ren        ,
    input   wire    [       XY_ADDR_WIDTH - 1 : 0]    sch2xy_raddr_evn      ,
    input   wire    [       XY_ADDR_WIDTH - 1 : 0]    sch2xy_raddr_odd      ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_0  , //_c_row
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_0_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_0  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_1_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_0  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_2_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_0  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_evn_rdata_3_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_0  , //_c_row
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_0_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_0  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_1_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_0  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_2_3  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_0  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_1  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_2  ,
    output  wire    [        XY_BUF_WIDTH - 1 : 0]    xy2sch_odd_rdata_3_3  ,
    // pu wr x_olp buf
    input   wire    [                  16 - 1 : 0]    pu2x_wen              ,
    input   wire    [        X_ADDR_WIDTH - 1 : 0]    pu2x_waddr            ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_0        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_1        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_2        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_0_3        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_0        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_1        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_2        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_1_3        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_0        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_1        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_2        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_2_3        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_0        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_1        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_2        ,
    input   wire    [         X_BUF_WIDTH - 1 : 0]    pu2x_wdata_3_3        ,
    // pu wr y_olp buf
    input   wire    [                  16 - 1 : 0]    pu2y_wen              ,
    input   wire    [        Y_ADDR_WIDTH - 1 : 0]    pu2y_waddr            ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_0        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_1        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_2        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_0_3        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_0        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_1        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_2        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_1_3        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_0        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_1        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_2        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_2_3        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_0        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_1        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_2        ,
    input   wire    [         Y_BUF_WIDTH - 1 : 0]    pu2y_wdata_3_3        ,
    // pu wr xy_olp_evn buf
    input   wire    [                  16 - 1 : 0]    pu2xy_evn_wen         ,
    input   wire    [       XY_ADDR_WIDTH - 1 : 0]    pu2xy_evn_waddr       ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_0_3   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_1_3   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_2_3   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_evn_wdata_3_3   ,
    // pu wr xy_olp_odd buf
    input   wire    [                  16 - 1 : 0]    pu2xy_odd_wen         ,
    input   wire    [       XY_ADDR_WIDTH - 1 : 0]    pu2xy_odd_waddr       ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_0_3   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_1_3   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_2_3   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_0   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_1   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_2   ,
    input   wire    [        XY_BUF_WIDTH - 1 : 0]    pu2xy_odd_wdata_3_3   
);

    localparam  ROW_GRP_NUM  = 4    ;
    localparam  CH_GRP_NUM   = 4    ;
    localparam  DNDM_L1_CH   = 3    ;
    localparam  SR_L1_CH     = 1    ;

    // x_l1_olp ping-pong buf, dndm & sr shared
    wire    [    X_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_0_waddr        ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_0_wen          ;
    wire    [        X_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_0_wdata        ;
    wire    [    X_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_0_raddr        ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_0_ren          ;
    wire    [        X_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_0_rdata        ;
    wire    [    X_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_1_waddr        ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_1_wen          ;
    wire    [        X_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_1_wdata        ;
    wire    [    X_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_1_raddr        ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_1_ren          ;
    wire    [        X_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    x_l1_1_rdata        ;
    // x_olp ping-pong buf, dndm & sr shared
    wire    [       X_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_0_waddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_0_wen             ;
    wire    [        X_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_0_wdata           ;
    wire    [       X_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_0_raddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_0_ren             ;
    wire    [        X_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_0_rdata           ;
    wire    [       X_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_1_waddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_1_wen             ;
    wire    [        X_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_1_wdata           ;
    wire    [       X_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_1_raddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_1_ren             ;
    wire    [        X_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x_1_rdata           ;
    // y_l1_olp buf for dndm
    wire    [    Y_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_0_waddr        ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_0_wen          ;
    wire    [        Y_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_0_wdata        ;
    wire    [    Y_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_0_raddr        ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_0_ren          ;
    wire    [        Y_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_0_rdata        ;
    // y_l1_olp buf for sr
    wire    [      Y_L1_ADDR_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_1_waddr        ;
    wire    [                      SR_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_1_wen          ;
    wire    [          Y_BUF_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_1_wdata        ;
    wire    [      Y_L1_ADDR_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_1_raddr        ;
    wire    [                      SR_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_1_ren          ;
    wire    [          Y_BUF_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    y_l1_1_rdata        ;
    // y_olp buf for dndm
    wire    [       Y_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_0_waddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_0_wen             ;
    wire    [        Y_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_0_wdata           ;
    wire    [       Y_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_0_raddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_0_ren             ;
    wire    [        Y_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_0_rdata           ;
    // y_olp buf for sr
    wire    [       Y_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_1_waddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_1_wen             ;
    wire    [        Y_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_1_wdata           ;
    wire    [       Y_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_1_raddr           ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_1_ren             ;
    wire    [        Y_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y_1_rdata           ;
    // xy_l1_olp buf for dndm
    wire    [   XY_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_evn_waddr   ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_evn_wen     ;
    wire    [       XY_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_evn_wdata   ;
    wire    [   XY_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_evn_raddr   ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_evn_ren     ;
    wire    [       XY_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_evn_rdata   ;
    wire    [   XY_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_odd_waddr   ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_odd_wen     ;
    wire    [       XY_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_odd_wdata   ;
    wire    [   XY_L1_ADDR_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_odd_raddr   ;
    wire    [                    DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_odd_ren     ;
    wire    [       XY_BUF_WIDTH*DNDM_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_0_odd_rdata   ;
    // xy_l1_olp buf for sr
    wire    [     XY_L1_ADDR_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_evn_waddr   ;
    wire    [                      SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_evn_wen     ;
    wire    [         XY_BUF_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_evn_wdata   ;
    wire    [     XY_L1_ADDR_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_evn_raddr   ;
    wire    [                      SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_evn_ren     ;
    wire    [         XY_BUF_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_evn_rdata   ;
    wire    [     XY_L1_ADDR_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_odd_waddr   ;
    wire    [                      SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_odd_wen     ;
    wire    [         XY_BUF_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_odd_wdata   ;
    wire    [     XY_L1_ADDR_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_odd_raddr   ;
    wire    [                      SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_odd_ren     ;
    wire    [         XY_BUF_WIDTH*SR_L1_CH*ROW_GRP_NUM - 1 : 0]    xy_l1_1_odd_rdata   ;
    // xy_olp buf for dndm
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_evn_waddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_evn_wen        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_evn_wdata      ;
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_evn_raddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_evn_ren        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_evn_rdata      ;
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_odd_waddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_odd_wen        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_odd_wdata      ;
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_odd_raddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_odd_ren        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_0_odd_rdata      ;
    // xy_olp buf for sr
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_evn_waddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_evn_wen        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_evn_wdata      ;
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_evn_raddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_evn_ren        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_evn_rdata      ;
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_odd_waddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_odd_wen        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_odd_wdata      ;
    wire    [      XY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_odd_raddr      ;
    wire    [                    CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_odd_ren        ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy_1_odd_rdata      ;

    wire    [        X_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    x2sch_rdata_w       ;
    wire    [        Y_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    y2sch_rdata_w       ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy2sch_evn_rdata_w  ;
    wire    [       XY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    xy2sch_odd_rdata_w  ;
    wire                                                            is_axi_wr_lst_4row  ;

// xolp fsm
localparam    A0         = 2'b00;
localparam    P0_AS1     = 2'b01;
localparam    AS0_P1     = 2'b11;

reg    [1:0]    cur_state_xolp;
reg    [1:0]    next_state_xolp;
reg             x_mode_flag;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cur_state_xolp <= A0;
    else
        cur_state_xolp <= next_state_xolp;
end

always@(*)begin
    case(cur_state_xolp)
        A0:begin
            if(stat_ctrl == 2'b11)
                next_state_xolp = P0_AS1;
            else 
                next_state_xolp = A0;
        end
        P0_AS1:begin
            if(layer_done && tile_switch_r) 
                next_state_xolp = AS0_P1;
            else
                next_state_xolp = P0_AS1;
        end
        AS0_P1:begin
            if(layer_done && tile_switch_r) 
                next_state_xolp = P0_AS1;
            else
                next_state_xolp = AS0_P1;
        end
        default:
            next_state_xolp = A0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        x_mode_flag <= 0;
    else begin
        case(cur_state_xolp)
            A0:
                x_mode_flag <= 0;
            P0_AS1:
                x_mode_flag <= 1;
            AS0_P1:
                x_mode_flag <= 0;
            default:
                x_mode_flag <= 0;
        endcase
    end
end

// cnt for tile num , dndm/sr seperated
localparam    INIT    = 1'b0;
localparam    CNT_INC = 1'b1;

reg    [1 - 1 : 0]    cur_state_cnt;
reg    [1 - 1 : 0]    next_state_cnt;
reg                   cnt_state;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cur_state_cnt <= INIT;
    else
        cur_state_cnt <= next_state_cnt;
end

always@(*)begin
    case(cur_state_cnt)
        INIT:begin
            if(stat_ctrl == 2'b11)
                next_state_cnt = CNT_INC;
            else 
                next_state_cnt = INIT;
        end
        CNT_INC:begin
            next_state_cnt = CNT_INC;
        end
        default:
            next_state_cnt = INIT;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cnt_state <= 0;
    else begin
        case(cur_state_cnt)
            INIT:
                if(stat_ctrl == 2'b11)
                    cnt_state <= 1;
                else
                    cnt_state <= 0;
            CNT_INC:
                cnt_state <= 1;
            default:
                cnt_state <= 0;
        endcase
    end
end

reg  [REG_TNX_WIDTH - 1 : 0]  y_tile_num_cnt0   ; //dndm
reg  [REG_TNX_WIDTH - 1 : 0]  xy_tile_num_cnt0  ; //dndm
reg  [REG_TNX_WIDTH - 1 : 0]  y_tile_num_cnt1   ; //sr
reg  [REG_TNX_WIDTH - 1 : 0]  xy_tile_num_cnt1  ; //sr
reg                           nn_proc_r         ;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        nn_proc_r <= 0;
    else
        nn_proc_r <= nn_proc;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        y_tile_num_cnt0 <= 0;
    else if(cnt_state == 0 && nn_proc == 0 && stat_ctrl == 2'b11)
        y_tile_num_cnt0 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(cnt_state == 1 && tile_switch && (nn_proc_r ^ ~model_switch))
        y_tile_num_cnt0 <= (y_tile_num_cnt0 == tile_tot_num_x) ? 0 : y_tile_num_cnt0 + 1;
    else
        y_tile_num_cnt0 <= y_tile_num_cnt0;
end
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_tile_num_cnt0 <= 0;
    else if(cnt_state == 0 && nn_proc == 0 && stat_ctrl == 2'b11)
        xy_tile_num_cnt0 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(cnt_state == 1 && tile_switch && (nn_proc_r ^ ~model_switch))
        xy_tile_num_cnt0 <= (xy_tile_num_cnt0 == tile_tot_num_x + 1) ? 0 : xy_tile_num_cnt0 + 1;
    else
        xy_tile_num_cnt0 <= xy_tile_num_cnt0;
end
*/
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        y_tile_num_cnt1 <= 0;
    else if(cnt_state == 0 && nn_proc == 1 && stat_ctrl == 2'b11)
        y_tile_num_cnt1 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ model_switch))
    else if(cnt_state == 1 && tile_switch && (nn_proc_r ^ model_switch))
        y_tile_num_cnt1 <= (y_tile_num_cnt1 == tile_tot_num_x) ? 0 : y_tile_num_cnt1 + 1;
    else
        y_tile_num_cnt1 <= y_tile_num_cnt1;
end
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_tile_num_cnt1 <= 0;
    else if(cnt_state == 0 && nn_proc == 1 && stat_ctrl == 2'b11)
        xy_tile_num_cnt1 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ model_switch))
    else if(cnt_state == 1 && tile_switch && (nn_proc_r ^ model_switch))
        xy_tile_num_cnt1 <= (xy_tile_num_cnt1 == tile_tot_num_x + 1) ? 0 : xy_tile_num_cnt1 + 1;
    else
        xy_tile_num_cnt1 <= xy_tile_num_cnt1;
end*/

assign is_axi_wr_lst_4row = (axi2f_waddr[AXI2F_ADDR_WIDTH - 2 - 1 : 0] == 7);

// ping-pong control
assign x_l1_0_waddr = {(DNDM_L1_CH*ROW_GRP_NUM){axi2f_waddr[X_L1_ADDR_WIDTH - 1 : 0]}};
// assign x_l1_0_wen   = (cnt_layer == 1 || x_mode_flag == 1) ? 0 :
assign x_l1_0_wen   = (x_mode_flag == 1) ? 0 :
                      (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{axi2f_wen}}} :
                      (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{axi2f_wen}},
                                                                                             {ROW_GRP_NUM{1'b0}}} :
                      (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{axi2f_wen}},
                                                                                             {ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{1'b0}}} : 0;
assign x_l1_0_wdata = {DNDM_L1_CH{axi2f_wdata[0*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 0*AXI2F_DATA_WIDTH/4],
                                  axi2f_wdata[1*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 1*AXI2F_DATA_WIDTH/4],
                                  axi2f_wdata[2*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 2*AXI2F_DATA_WIDTH/4],
                                  axi2f_wdata[3*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 3*AXI2F_DATA_WIDTH/4]}};
assign x_l1_0_raddr = {DNDM_L1_CH{sch2x_raddr_3[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_2[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_1[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_0[X_L1_ADDR_WIDTH - 1 : 0]}};
/*assign x_l1_0_raddr = {DNDM_L1_CH{sch2x_raddr_0[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_1[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_2[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_3[X_L1_ADDR_WIDTH - 1 : 0]}};*/
assign x_l1_0_ren   = (x_mode_flag == 0 && cnt_layer == 1) ? {DNDM_L1_CH{sch2x_ren[0], sch2x_ren[1], sch2x_ren[2], sch2x_ren[3]}} : 0;
assign x_l1_1_waddr = {(DNDM_L1_CH*ROW_GRP_NUM){axi2f_waddr[X_L1_ADDR_WIDTH - 1 : 0]}};
// assign x_l1_1_wen   = (cnt_layer == 1 || x_mode_flag == 0) ? 0 :
assign x_l1_1_wen   = (x_mode_flag == 0) ? 0 :
                      (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{axi2f_wen}}} :
                      (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{axi2f_wen}},
                                                                                             {ROW_GRP_NUM{1'b0}}} :
                      (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{axi2f_wen}},
                                                                                             {ROW_GRP_NUM{1'b0}},
                                                                                             {ROW_GRP_NUM{1'b0}}} : 0;
assign x_l1_1_wdata = {DNDM_L1_CH{axi2f_wdata[0*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 0*AXI2F_DATA_WIDTH/4],
                                  axi2f_wdata[1*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 1*AXI2F_DATA_WIDTH/4],
                                  axi2f_wdata[2*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 2*AXI2F_DATA_WIDTH/4],
                                  axi2f_wdata[3*AXI2F_DATA_WIDTH/4+X_BUF_WIDTH - 1 : 3*AXI2F_DATA_WIDTH/4]}};
assign x_l1_1_raddr = {DNDM_L1_CH{sch2x_raddr_3[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_2[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_1[X_L1_ADDR_WIDTH - 1 : 0],
                                  sch2x_raddr_0[X_L1_ADDR_WIDTH - 1 : 0]}};
assign x_l1_1_ren   = (x_mode_flag == 1 && cnt_layer == 1) ? {DNDM_L1_CH{sch2x_ren[0], sch2x_ren[1], sch2x_ren[2], sch2x_ren[3]}} : 0;
assign x_0_waddr = {CH_GRP_NUM*ROW_GRP_NUM{pu2x_waddr}};
assign x_0_wen   = (x_mode_flag == 1) ? pu2x_wen : 0;
assign x_0_wdata = {pu2x_wdata_3_3, pu2x_wdata_3_2, pu2x_wdata_3_1, pu2x_wdata_3_0,
                    pu2x_wdata_2_3, pu2x_wdata_2_2, pu2x_wdata_2_1, pu2x_wdata_2_0,
                    pu2x_wdata_1_3, pu2x_wdata_1_2, pu2x_wdata_1_1, pu2x_wdata_1_0,
                    pu2x_wdata_0_3, pu2x_wdata_0_2, pu2x_wdata_0_1, pu2x_wdata_0_0};
assign x_0_raddr = {CH_GRP_NUM{sch2x_raddr_3, sch2x_raddr_2, sch2x_raddr_1, sch2x_raddr_0}};
assign x_0_ren   = (x_mode_flag == 0 && cnt_layer != 1) ? {CH_GRP_NUM{sch2x_ren[0],sch2x_ren[1],sch2x_ren[2],sch2x_ren[3]}} : 0;
assign x_1_waddr = {CH_GRP_NUM*ROW_GRP_NUM{pu2x_waddr}};
assign x_1_wen   = (x_mode_flag == 0) ? {pu2x_wen} : 0;
assign x_1_wdata = {pu2x_wdata_3_3, pu2x_wdata_3_2, pu2x_wdata_3_1, pu2x_wdata_3_0,
                    pu2x_wdata_2_3, pu2x_wdata_2_2, pu2x_wdata_2_1, pu2x_wdata_2_0,
                    pu2x_wdata_1_3, pu2x_wdata_1_2, pu2x_wdata_1_1, pu2x_wdata_1_0,
                    pu2x_wdata_0_3, pu2x_wdata_0_2, pu2x_wdata_0_1, pu2x_wdata_0_0};
assign x_1_raddr = {CH_GRP_NUM{sch2x_raddr_3, sch2x_raddr_2, sch2x_raddr_1, sch2x_raddr_0}};
assign x_1_ren   = (x_mode_flag == 1 && cnt_layer != 1) ? {CH_GRP_NUM{sch2x_ren[0],sch2x_ren[1],sch2x_ren[2],sch2x_ren[3]}} : 0;
assign x2sch_rdata_w = (x_mode_flag == 0 && cnt_layer == 1) ? {{(X_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}},x_l1_0_rdata} :
                       (x_mode_flag == 1 && cnt_layer == 1) ? {{(X_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}},x_l1_1_rdata} :
                       (x_mode_flag == 0 && cnt_layer != 1) ? x_0_rdata : x_1_rdata;
assign x2sch_rdata_0_0 = x2sch_rdata_w[ 1*X_BUF_WIDTH - 1 :  0*X_BUF_WIDTH];
assign x2sch_rdata_0_1 = x2sch_rdata_w[ 2*X_BUF_WIDTH - 1 :  1*X_BUF_WIDTH];
assign x2sch_rdata_0_2 = x2sch_rdata_w[ 3*X_BUF_WIDTH - 1 :  2*X_BUF_WIDTH];
assign x2sch_rdata_0_3 = x2sch_rdata_w[ 4*X_BUF_WIDTH - 1 :  3*X_BUF_WIDTH];
assign x2sch_rdata_1_0 = x2sch_rdata_w[ 5*X_BUF_WIDTH - 1 :  4*X_BUF_WIDTH];
assign x2sch_rdata_1_1 = x2sch_rdata_w[ 6*X_BUF_WIDTH - 1 :  5*X_BUF_WIDTH];
assign x2sch_rdata_1_2 = x2sch_rdata_w[ 7*X_BUF_WIDTH - 1 :  6*X_BUF_WIDTH];
assign x2sch_rdata_1_3 = x2sch_rdata_w[ 8*X_BUF_WIDTH - 1 :  7*X_BUF_WIDTH];
assign x2sch_rdata_2_0 = x2sch_rdata_w[ 9*X_BUF_WIDTH - 1 :  8*X_BUF_WIDTH];
assign x2sch_rdata_2_1 = x2sch_rdata_w[10*X_BUF_WIDTH - 1 :  9*X_BUF_WIDTH];
assign x2sch_rdata_2_2 = x2sch_rdata_w[11*X_BUF_WIDTH - 1 : 10*X_BUF_WIDTH];
assign x2sch_rdata_2_3 = x2sch_rdata_w[12*X_BUF_WIDTH - 1 : 11*X_BUF_WIDTH];
assign x2sch_rdata_3_0 = x2sch_rdata_w[13*X_BUF_WIDTH - 1 : 12*X_BUF_WIDTH];
assign x2sch_rdata_3_1 = x2sch_rdata_w[14*X_BUF_WIDTH - 1 : 13*X_BUF_WIDTH];
assign x2sch_rdata_3_2 = x2sch_rdata_w[15*X_BUF_WIDTH - 1 : 14*X_BUF_WIDTH];
assign x2sch_rdata_3_3 = x2sch_rdata_w[16*X_BUF_WIDTH - 1 : 15*X_BUF_WIDTH];
/*assign x2sch_rdata_w = (x_mode_flag == 0 && cnt_layer == 1) ? {x_l1_0_rdata, {(X_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}}} :
                       (x_mode_flag == 1 && cnt_layer == 1) ? {x_l1_1_rdata, {(X_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}}} :
                       (x_mode_flag == 0 && cnt_layer != 1) ? x_0_rdata : x_1_rdata;
assign x2sch_rdata_0_0 = x2sch_rdata_w[16*X_BUF_WIDTH - 1 : 15*X_BUF_WIDTH];
assign x2sch_rdata_0_1 = x2sch_rdata_w[15*X_BUF_WIDTH - 1 : 14*X_BUF_WIDTH];
assign x2sch_rdata_0_2 = x2sch_rdata_w[14*X_BUF_WIDTH - 1 : 13*X_BUF_WIDTH];
assign x2sch_rdata_0_3 = x2sch_rdata_w[13*X_BUF_WIDTH - 1 : 12*X_BUF_WIDTH];
assign x2sch_rdata_1_0 = x2sch_rdata_w[12*X_BUF_WIDTH - 1 : 11*X_BUF_WIDTH];
assign x2sch_rdata_1_1 = x2sch_rdata_w[11*X_BUF_WIDTH - 1 : 10*X_BUF_WIDTH];
assign x2sch_rdata_1_2 = x2sch_rdata_w[10*X_BUF_WIDTH - 1 :  9*X_BUF_WIDTH];
assign x2sch_rdata_1_3 = x2sch_rdata_w[ 9*X_BUF_WIDTH - 1 :  8*X_BUF_WIDTH];
assign x2sch_rdata_2_0 = x2sch_rdata_w[ 8*X_BUF_WIDTH - 1 :  7*X_BUF_WIDTH];
assign x2sch_rdata_2_1 = x2sch_rdata_w[ 7*X_BUF_WIDTH - 1 :  6*X_BUF_WIDTH];
assign x2sch_rdata_2_2 = x2sch_rdata_w[ 6*X_BUF_WIDTH - 1 :  5*X_BUF_WIDTH];
assign x2sch_rdata_2_3 = x2sch_rdata_w[ 5*X_BUF_WIDTH - 1 :  4*X_BUF_WIDTH];
assign x2sch_rdata_3_0 = x2sch_rdata_w[ 4*X_BUF_WIDTH - 1 :  3*X_BUF_WIDTH];
assign x2sch_rdata_3_1 = x2sch_rdata_w[ 3*X_BUF_WIDTH - 1 :  2*X_BUF_WIDTH];
assign x2sch_rdata_3_2 = x2sch_rdata_w[ 2*X_BUF_WIDTH - 1 :  1*X_BUF_WIDTH];
assign x2sch_rdata_3_3 = x2sch_rdata_w[ 1*X_BUF_WIDTH - 1 :  0*X_BUF_WIDTH];*/

assign y_l1_0_waddr = {(DNDM_L1_CH*ROW_GRP_NUM){y_tile_num_cnt0}};
assign y_l1_0_wen   = (is_axi_wr_lst_4row && (nn_proc ^~ model_switch_r)) ? ((axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                                                                                    {ROW_GRP_NUM{1'b0}},
                                                                                                                                                    {ROW_GRP_NUM{axi2f_wen}}} :
                                                                             (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                                                                                    {ROW_GRP_NUM{axi2f_wen}},
                                                                                                                                                    {ROW_GRP_NUM{1'b0}}} :
                                                                             (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{axi2f_wen}},
                                                                                                                                                    {ROW_GRP_NUM{1'b0}},
                                                                                                                                                    {ROW_GRP_NUM{1'b0}}} : 0) : 0;
assign y_l1_0_wdata = {DNDM_L1_CH{axi2f_wdata[1*AXI2F_DATA_WIDTH/4 - 1 : 0*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH],
                                  axi2f_wdata[2*AXI2F_DATA_WIDTH/4 - 1 : 1*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH],
                                  axi2f_wdata[3*AXI2F_DATA_WIDTH/4 - 1 : 2*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH],
                                  axi2f_wdata[4*AXI2F_DATA_WIDTH/4 - 1 : 3*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH]}};
assign y_l1_0_raddr = {(DNDM_L1_CH*ROW_GRP_NUM){sch2y_raddr[Y_L1_ADDR_WIDTH - 1 : 0]}};
assign y_l1_0_ren   = (nn_proc == 0 && cnt_layer == 1) ? {DNDM_L1_CH{sch2y_ren[0],sch2y_ren[1],sch2y_ren[2],sch2y_ren[3]}} : 0;
assign y_l1_1_waddr = {(SR_L1_CH*ROW_GRP_NUM){y_tile_num_cnt1}};
assign y_l1_1_wen   = (is_axi_wr_lst_4row && (nn_proc ^ model_switch_r)) ? ((axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {ROW_GRP_NUM{axi2f_wen}} : 0) : 0;
assign y_l1_1_wdata = {SR_L1_CH{axi2f_wdata[1*AXI2F_DATA_WIDTH/4 - 1 : 0*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH],
                                axi2f_wdata[2*AXI2F_DATA_WIDTH/4 - 1 : 1*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH],
                                axi2f_wdata[3*AXI2F_DATA_WIDTH/4 - 1 : 2*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH],
                                axi2f_wdata[4*AXI2F_DATA_WIDTH/4 - 1 : 3*AXI2F_DATA_WIDTH/4 + XY_BUF_WIDTH]}};
assign y_l1_1_raddr = {(SR_L1_CH*ROW_GRP_NUM){sch2y_raddr[Y_L1_ADDR_WIDTH - 1 : 0]}};
assign y_l1_1_ren   = (nn_proc == 1 && cnt_layer == 1) ? {SR_L1_CH{sch2y_ren[0],sch2y_ren[1],sch2y_ren[2],sch2y_ren[3]}} : 0;
assign y_0_waddr = {(CH_GRP_NUM*ROW_GRP_NUM){pu2y_waddr}}; //pu2y_waddr error
assign y_0_wen   = (nn_proc == 0) ? pu2y_wen : 0;
assign y_0_wdata = {pu2y_wdata_3_3, pu2y_wdata_3_2, pu2y_wdata_3_1, pu2y_wdata_3_0,
                    pu2y_wdata_2_3, pu2y_wdata_2_2, pu2y_wdata_2_1, pu2y_wdata_2_0,
                    pu2y_wdata_1_3, pu2y_wdata_1_2, pu2y_wdata_1_1, pu2y_wdata_1_0,
                    pu2y_wdata_0_3, pu2y_wdata_0_2, pu2y_wdata_0_1, pu2y_wdata_0_0};
assign y_0_raddr = {(CH_GRP_NUM*ROW_GRP_NUM){sch2y_raddr}};
assign y_0_ren   = (nn_proc == 0 && cnt_layer != 1) ? {CH_GRP_NUM{sch2y_ren[0],sch2y_ren[1],sch2y_ren[2],sch2y_ren[3]}} : 0;
assign y_1_waddr = {(CH_GRP_NUM*ROW_GRP_NUM){pu2y_waddr}};
assign y_1_wen   = (nn_proc == 1) ? pu2y_wen : 0;
assign y_1_wdata = {pu2y_wdata_3_3, pu2y_wdata_3_2, pu2y_wdata_3_1, pu2y_wdata_3_0,
                    pu2y_wdata_2_3, pu2y_wdata_2_2, pu2y_wdata_2_1, pu2y_wdata_2_0,
                    pu2y_wdata_1_3, pu2y_wdata_1_2, pu2y_wdata_1_1, pu2y_wdata_1_0,
                    pu2y_wdata_0_3, pu2y_wdata_0_2, pu2y_wdata_0_1, pu2y_wdata_0_0};
assign y_1_raddr = {(CH_GRP_NUM*ROW_GRP_NUM){sch2y_raddr}};
assign y_1_ren   = (nn_proc == 1 && cnt_layer != 1) ? {CH_GRP_NUM{sch2y_ren[0],sch2y_ren[1],sch2y_ren[2],sch2y_ren[3]}} : 0;
assign y2sch_rdata_w = (nn_proc == 0 && cnt_layer == 1) ? {{(Y_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}},y_l1_0_rdata} :
                       (nn_proc == 1 && cnt_layer == 1) ? {{(Y_BUF_WIDTH*(CH_GRP_NUM-SR_L1_CH)*ROW_GRP_NUM){1'b0}},y_l1_1_rdata} :
                       (nn_proc == 0 && cnt_layer != 1) ? y_0_rdata : y_1_rdata;
assign y2sch_rdata_0_0 = y2sch_rdata_w[ 1*Y_BUF_WIDTH - 1 :  0*Y_BUF_WIDTH];
assign y2sch_rdata_0_1 = y2sch_rdata_w[ 2*Y_BUF_WIDTH - 1 :  1*Y_BUF_WIDTH];
assign y2sch_rdata_0_2 = y2sch_rdata_w[ 3*Y_BUF_WIDTH - 1 :  2*Y_BUF_WIDTH];
assign y2sch_rdata_0_3 = y2sch_rdata_w[ 4*Y_BUF_WIDTH - 1 :  3*Y_BUF_WIDTH];
assign y2sch_rdata_1_0 = y2sch_rdata_w[ 5*Y_BUF_WIDTH - 1 :  4*Y_BUF_WIDTH];
assign y2sch_rdata_1_1 = y2sch_rdata_w[ 6*Y_BUF_WIDTH - 1 :  5*Y_BUF_WIDTH];
assign y2sch_rdata_1_2 = y2sch_rdata_w[ 7*Y_BUF_WIDTH - 1 :  6*Y_BUF_WIDTH];
assign y2sch_rdata_1_3 = y2sch_rdata_w[ 8*Y_BUF_WIDTH - 1 :  7*Y_BUF_WIDTH];
assign y2sch_rdata_2_0 = y2sch_rdata_w[ 9*Y_BUF_WIDTH - 1 :  8*Y_BUF_WIDTH];
assign y2sch_rdata_2_1 = y2sch_rdata_w[10*Y_BUF_WIDTH - 1 :  9*Y_BUF_WIDTH];
assign y2sch_rdata_2_2 = y2sch_rdata_w[11*Y_BUF_WIDTH - 1 : 10*Y_BUF_WIDTH];
assign y2sch_rdata_2_3 = y2sch_rdata_w[12*Y_BUF_WIDTH - 1 : 11*Y_BUF_WIDTH];
assign y2sch_rdata_3_0 = y2sch_rdata_w[13*Y_BUF_WIDTH - 1 : 12*Y_BUF_WIDTH];
assign y2sch_rdata_3_1 = y2sch_rdata_w[14*Y_BUF_WIDTH - 1 : 13*Y_BUF_WIDTH];
assign y2sch_rdata_3_2 = y2sch_rdata_w[15*Y_BUF_WIDTH - 1 : 14*Y_BUF_WIDTH];
assign y2sch_rdata_3_3 = y2sch_rdata_w[16*Y_BUF_WIDTH - 1 : 15*Y_BUF_WIDTH];

reg  [REG_TNX_WIDTH - 2 : 0]  xy_l1_0_evn_num_cnt0  ; //dndm
reg  [REG_TNX_WIDTH - 2 : 0]  xy_l1_0_odd_num_cnt0  ; //dndm
wire [REG_TNX_WIDTH     : 0]  tile_tot_num_x_w      ;
wire                          add_xy_tile_num_cnt0  ;
wire                          xy_l1_0_evn_wr_eb     ;
wire                          xy_l1_0_odd_wr_eb     ;

reg  [REG_TNX_WIDTH - 2 : 0]  xy_l1_1_evn_num_cnt1  ; //dndm
reg  [REG_TNX_WIDTH - 2 : 0]  xy_l1_1_odd_num_cnt1  ; //dndm
wire                          add_xy_tile_num_cnt1  ;
wire                          xy_l1_1_evn_wr_eb     ;
wire                          xy_l1_1_odd_wr_eb     ;

//***************** DNDM *********************//

assign tile_tot_num_x_w = tile_tot_num_x << 1;
assign add_xy_tile_num_cnt0 = cnt_state == 1 && tile_switch && (nn_proc_r ^ ~model_switch);

// ===================================================================================================
// l1_0_evn_wr_eb condiftion
// 1. xy_tile_num_cnt == 0, the first tile axi wr every two lines
// 2. (1). if tile_tot_num_x is odd
// ---------------------------------------------------------------------------------------------------
// the odd condition , e.g tile_tot_num_x == 5
// ____      ____           ____      ____           ____
//     |____|    |_________|    |____|    |_________|    |     -> xy_l1_0_evn_wr_eb
//   0    1    2    3   4     5   6     7    8   9    10  ...  -> xy_tile_num_cnt0
// |   <-      line0   ->  |    <-   line1     ->   |          -> num of tile
// if first line, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 0
// if second line, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 1
// ----------------------------------------------------------------------------------------------------
// 2. (2). if tile_tot_num_x if evn, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 0
// ===================================================================================================
assign xy_l1_0_evn_wr_eb = xy_tile_num_cnt0 == 0 || (tile_tot_num_x[0] ? 
                           xy_tile_num_cnt0[0] == (xy_tile_num_cnt0 + 1 > tile_tot_num_x ? 1 : 0) && xy_tile_num_cnt0 != tile_tot_num_x - 1 && xy_tile_num_cnt0 != tile_tot_num_x_w - 1
                           : xy_tile_num_cnt0[0] == 0);

// ===================================================================================================
// xy_l1_0_evn addr, the puls condition:
// 1. (add_xy_tile_num_cnt0 && xy_l1_0_evn_wr_eb)
// 2. xy_l1_0_evn_num_cnt0 == tile_tot_num_x >> 1
// ===================================================================================================
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_l1_0_evn_num_cnt0 <= 0;
    else if(cnt_state == 0 && nn_proc == 0 && stat_ctrl == 2'b11)
        xy_l1_0_evn_num_cnt0 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(add_xy_tile_num_cnt0 && xy_l1_0_evn_wr_eb)
        xy_l1_0_evn_num_cnt0 <= (xy_l1_0_evn_num_cnt0 == tile_tot_num_x >> 1) ? 0 : xy_l1_0_evn_num_cnt0 + 1;
    else
        xy_l1_0_evn_num_cnt0 <= xy_l1_0_evn_num_cnt0;
end

// ===================================================================================================
// l1_0_odd_wr_eb condiftion
// 1. if tile_tot_num_x is odd
// ---------------------------------------------------------------------------------------------------
// the odd condition , e.g tile_tot_num_x == 5
//      ____      ____           ____      ____           ____
// ____|    |____|    |_________|    |____|    |_________|    |     -> xy_l1_0_evn_wr_eb
//   0    1    2    3   4    5    6     7    8   9    10   11  ...  -> xy_tile_num_cnt0
// |   <-      line0   ->  |    <-   line1     ->   |               -> num of tile
// if first line, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 1
// if second line, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 0
// ----------------------------------------------------------------------------------------------------
// 2. if tile_tot_num_x if evn
// ---------------------------------------------------------------------------------------------------
// the odd condition , e.g tile_tot_num_x == 4
//      ____      ____      ____      ____      ____
// ____|    |____|    |____|    |____|    |____|    |     -> xy_l1_0_evn_wr_eb
//   0    1    2    3    4    5    6    7   8    9   ... -> xy_tile_num_cnt0
// |  <-  line0   ->  | <-   line1   ->   |               -> num of tile
// if first line, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 1
// if second line, xy_l1_0_evn_wr_eb == 1 when xy_tile_num_cnt0[0] == 1
// but the location 3 and 7 is virtual wr, we do not use this addr in the later cycle
// ----------------------------------------------------------------------------------------------------
// ===================================================================================================

assign xy_l1_0_odd_wr_eb = tile_tot_num_x[0] == 1 ? xy_tile_num_cnt0[0] == (xy_tile_num_cnt0 + 1 > tile_tot_num_x ? 0 : 1)
                                                  : xy_tile_num_cnt0[0] == 1;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_l1_0_odd_num_cnt0 <= 0;
    else if(cnt_state == 0 && nn_proc == 0 && stat_ctrl == 2'b11)
        xy_l1_0_odd_num_cnt0 <= 0;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(add_xy_tile_num_cnt0 && xy_l1_0_odd_wr_eb)
        xy_l1_0_odd_num_cnt0 <= (xy_l1_0_odd_num_cnt0 == tile_tot_num_x >> 1) ? 0 : xy_l1_0_odd_num_cnt0 + 1;
    else
        xy_l1_0_odd_num_cnt0 <= xy_l1_0_odd_num_cnt0;
end

//cnt every 2 lines axi wr in
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_tile_num_cnt0 <= 0;
    else if(cnt_state == 0 && nn_proc == 0 && stat_ctrl == 2'b11)
        xy_tile_num_cnt0 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(add_xy_tile_num_cnt0)
        xy_tile_num_cnt0 <= (xy_tile_num_cnt0 == tile_tot_num_x_w - 1) ? 0 : xy_tile_num_cnt0 + 1;
    else
        xy_tile_num_cnt0 <= xy_tile_num_cnt0;
end

//***************** SR *********************//

assign add_xy_tile_num_cnt1 = cnt_state == 1 && tile_switch && (nn_proc_r ^ model_switch);

assign xy_l1_1_evn_wr_eb = xy_tile_num_cnt1 == 0 || (tile_tot_num_x[0] ? 
                           xy_tile_num_cnt1[0] == (xy_tile_num_cnt1 + 1 > tile_tot_num_x ? 1 : 0) && xy_tile_num_cnt1 != tile_tot_num_x - 1 && xy_tile_num_cnt1 != tile_tot_num_x_w - 1
                           : xy_tile_num_cnt1[0] == 0);

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_l1_1_evn_num_cnt1 <= 0;
    else if(cnt_state == 0 && nn_proc == 1 && stat_ctrl == 2'b11)
        xy_l1_1_evn_num_cnt1 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(add_xy_tile_num_cnt1 && xy_l1_1_evn_wr_eb)
        xy_l1_1_evn_num_cnt1 <= (xy_l1_1_evn_num_cnt1 == tile_tot_num_x >> 1) ? 0 : xy_l1_1_evn_num_cnt1 + 1;
    else
        xy_l1_1_evn_num_cnt1 <= xy_l1_1_evn_num_cnt1;
end

assign xy_l1_1_odd_wr_eb = tile_tot_num_x[0] == 1 ? xy_tile_num_cnt1[0] == (xy_tile_num_cnt1 + 1 > tile_tot_num_x ? 0 : 1)
                                                  : xy_tile_num_cnt1[0] == 1;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_l1_1_odd_num_cnt1 <= 0;
    else if(cnt_state == 0 && nn_proc == 1 && stat_ctrl == 2'b11)
        xy_l1_1_odd_num_cnt1 <= 0;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ ~model_switch))
    else if(add_xy_tile_num_cnt1 && xy_l1_1_odd_wr_eb)
        xy_l1_1_odd_num_cnt1 <= (xy_l1_1_odd_num_cnt1== tile_tot_num_x >> 1) ? 0 : xy_l1_1_odd_num_cnt1 + 1;
    else
        xy_l1_1_odd_num_cnt1 <= xy_l1_1_odd_num_cnt1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        xy_tile_num_cnt1 <= 0;
    else if(cnt_state == 0 && nn_proc == 1 && stat_ctrl == 2'b11)
        xy_tile_num_cnt1 <= 1;
    // else if(cnt_state == 1 && tile_switch && (nn_proc ^ model_switch))
    else if(add_xy_tile_num_cnt1)
        xy_tile_num_cnt1 <= (xy_tile_num_cnt1 == tile_tot_num_x_w - 1) ? 0 : xy_tile_num_cnt1 + 1;
    else
        xy_tile_num_cnt1 <= xy_tile_num_cnt1;
end


assign xy_l1_0_evn_waddr = {(DNDM_L1_CH*ROW_GRP_NUM){xy_l1_0_evn_num_cnt0}};
assign xy_l1_0_evn_wen   = (is_axi_wr_lst_4row && (~(nn_proc ^ model_switch_r)) && (xy_l1_0_evn_wr_eb)) ? ((axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                   {ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                   {ROW_GRP_NUM{axi2f_wen}}} :
                                                                                                            (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                   {ROW_GRP_NUM{axi2f_wen}},
                                                                                                                                                                                   {ROW_GRP_NUM{1'b0}}} :
                                                                                                            (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{axi2f_wen}},
                                                                                                                                                                                   {ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                   {ROW_GRP_NUM{1'b0}}} : 0) : 0;
assign xy_l1_0_evn_wdata = {DNDM_L1_CH{axi2f_wdata[0*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 0*AXI2F_DATA_WIDTH/4],
                                       axi2f_wdata[1*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 1*AXI2F_DATA_WIDTH/4],
                                       axi2f_wdata[2*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 2*AXI2F_DATA_WIDTH/4],
                                       axi2f_wdata[3*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 3*AXI2F_DATA_WIDTH/4]}};
assign xy_l1_0_evn_raddr = {(DNDM_L1_CH*ROW_GRP_NUM){sch2xy_raddr_evn[XY_L1_ADDR_WIDTH - 1 : 0]}};
assign xy_l1_0_evn_ren   = (nn_proc == 0 && cnt_layer == 1) ? {DNDM_L1_CH{sch2xy_evn_ren}} : 0;
assign xy_l1_0_odd_waddr = {(DNDM_L1_CH*ROW_GRP_NUM){xy_l1_0_odd_num_cnt0}};
assign xy_l1_0_odd_wen   = (is_axi_wr_lst_4row && (~(nn_proc ^ model_switch_r)) && (xy_l1_0_odd_wr_eb)) ? ((axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                  {ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                  {ROW_GRP_NUM{axi2f_wen}}} :
                                                                                                           (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                  {ROW_GRP_NUM{axi2f_wen}},
                                                                                                                                                                                  {ROW_GRP_NUM{1'b0}}} :
                                                                                                           (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{axi2f_wen}},
                                                                                                                                                                                  {ROW_GRP_NUM{1'b0}},
                                                                                                                                                                                  {ROW_GRP_NUM{1'b0}}} : 0) : 0;
assign xy_l1_0_odd_wdata = {DNDM_L1_CH{axi2f_wdata[0*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 0*AXI2F_DATA_WIDTH/4],
                                       axi2f_wdata[1*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 1*AXI2F_DATA_WIDTH/4],
                                       axi2f_wdata[2*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 2*AXI2F_DATA_WIDTH/4],
                                       axi2f_wdata[3*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 3*AXI2F_DATA_WIDTH/4]}};
assign xy_l1_0_odd_raddr = {(DNDM_L1_CH*ROW_GRP_NUM){sch2xy_raddr_odd[XY_L1_ADDR_WIDTH - 1 : 0]}};
assign xy_l1_0_odd_ren   = (nn_proc == 0 && cnt_layer == 1) ? {DNDM_L1_CH{sch2xy_odd_ren}} : 0;
assign xy_l1_1_evn_waddr = {(SR_L1_CH*ROW_GRP_NUM){xy_l1_1_evn_num_cnt1}};
assign xy_l1_1_evn_wen   = (is_axi_wr_lst_4row && (nn_proc ^ model_switch_r) && (xy_l1_1_evn_wr_eb)) ? ((axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {ROW_GRP_NUM{axi2f_wen}} : 0) : 0;
assign xy_l1_1_evn_wdata = {SR_L1_CH{axi2f_wdata[0*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 0*AXI2F_DATA_WIDTH/4],
                                     axi2f_wdata[1*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 1*AXI2F_DATA_WIDTH/4],
                                     axi2f_wdata[2*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 2*AXI2F_DATA_WIDTH/4],
                                     axi2f_wdata[3*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 3*AXI2F_DATA_WIDTH/4]}};
assign xy_l1_1_evn_raddr = {(SR_L1_CH*ROW_GRP_NUM){sch2xy_raddr_evn[XY_L1_ADDR_WIDTH - 1 : 0]}};
assign xy_l1_1_evn_ren   = (nn_proc == 1 && cnt_layer == 1) ? {SR_L1_CH{sch2xy_evn_ren}} : 0;
assign xy_l1_1_odd_waddr = {(SR_L1_CH*ROW_GRP_NUM){xy_l1_1_odd_num_cnt1}};
assign xy_l1_1_odd_wen   = (is_axi_wr_lst_4row && (nn_proc ^ model_switch_r) && (xy_l1_1_odd_wr_eb)) ? ((axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {ROW_GRP_NUM{axi2f_wen}} : 0) : 0;
assign xy_l1_1_odd_wdata = {SR_L1_CH{axi2f_wdata[0*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 0*AXI2F_DATA_WIDTH/4],
                                     axi2f_wdata[1*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 1*AXI2F_DATA_WIDTH/4],
                                     axi2f_wdata[2*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 2*AXI2F_DATA_WIDTH/4],
                                     axi2f_wdata[3*AXI2F_DATA_WIDTH/4+XY_BUF_WIDTH - 1 : 3*AXI2F_DATA_WIDTH/4]}};
assign xy_l1_1_odd_raddr = {(SR_L1_CH*ROW_GRP_NUM){sch2xy_raddr_odd[XY_L1_ADDR_WIDTH - 1 : 0]}};
assign xy_l1_1_odd_ren   = (nn_proc == 1 && cnt_layer == 1) ? {SR_L1_CH{sch2xy_odd_ren}} : 0;
assign xy_0_evn_waddr = {CH_GRP_NUM*ROW_GRP_NUM{pu2xy_evn_waddr}};
assign xy_0_evn_wen   = (nn_proc == 0) ? pu2xy_evn_wen : 0;
assign xy_0_evn_wdata = {pu2xy_evn_wdata_3_3, pu2xy_evn_wdata_3_2, pu2xy_evn_wdata_3_1, pu2xy_evn_wdata_3_0,
                         pu2xy_evn_wdata_2_3, pu2xy_evn_wdata_2_2, pu2xy_evn_wdata_2_1, pu2xy_evn_wdata_2_0,
                         pu2xy_evn_wdata_1_3, pu2xy_evn_wdata_1_2, pu2xy_evn_wdata_1_1, pu2xy_evn_wdata_1_0,
                         pu2xy_evn_wdata_0_3, pu2xy_evn_wdata_0_2, pu2xy_evn_wdata_0_1, pu2xy_evn_wdata_0_0};
assign xy_0_evn_raddr = {(CH_GRP_NUM*ROW_GRP_NUM){sch2xy_raddr_evn}};
assign xy_0_evn_ren   = (nn_proc == 0 && cnt_layer != 1) ? {CH_GRP_NUM{sch2xy_evn_ren}} : 0;
assign xy_0_odd_waddr = {CH_GRP_NUM*ROW_GRP_NUM{pu2xy_odd_waddr}};
assign xy_0_odd_wen   = (nn_proc == 0) ? pu2xy_odd_wen : 0;
assign xy_0_odd_wdata = {pu2xy_odd_wdata_3_3, pu2xy_odd_wdata_3_2, pu2xy_odd_wdata_3_1, pu2xy_odd_wdata_3_0,
                         pu2xy_odd_wdata_2_3, pu2xy_odd_wdata_2_2, pu2xy_odd_wdata_2_1, pu2xy_odd_wdata_2_0,
                         pu2xy_odd_wdata_1_3, pu2xy_odd_wdata_1_2, pu2xy_odd_wdata_1_1, pu2xy_odd_wdata_1_0,
                         pu2xy_odd_wdata_0_3, pu2xy_odd_wdata_0_2, pu2xy_odd_wdata_0_1, pu2xy_odd_wdata_0_0};
assign xy_0_odd_raddr = {(CH_GRP_NUM*ROW_GRP_NUM){sch2xy_raddr_odd}};
assign xy_0_odd_ren   = (nn_proc == 0 && cnt_layer != 1) ? {CH_GRP_NUM{sch2xy_odd_ren}} : 0;
assign xy_1_evn_waddr = {CH_GRP_NUM*ROW_GRP_NUM{pu2xy_evn_waddr}};
assign xy_1_evn_wen   = (nn_proc == 1) ? pu2xy_evn_wen : 0;
assign xy_1_evn_wdata = {pu2xy_evn_wdata_3_3, pu2xy_evn_wdata_3_2, pu2xy_evn_wdata_3_1, pu2xy_evn_wdata_3_0,
                         pu2xy_evn_wdata_2_3, pu2xy_evn_wdata_2_2, pu2xy_evn_wdata_2_1, pu2xy_evn_wdata_2_0,
                         pu2xy_evn_wdata_1_3, pu2xy_evn_wdata_1_2, pu2xy_evn_wdata_1_1, pu2xy_evn_wdata_1_0,
                         pu2xy_evn_wdata_0_3, pu2xy_evn_wdata_0_2, pu2xy_evn_wdata_0_1, pu2xy_evn_wdata_0_0};
assign xy_1_evn_raddr = {(CH_GRP_NUM*ROW_GRP_NUM){sch2xy_raddr_evn}};
assign xy_1_evn_ren   = (nn_proc == 1 && cnt_layer != 1) ? {CH_GRP_NUM{sch2xy_evn_ren}} : 0;
assign xy_1_odd_waddr = {CH_GRP_NUM*ROW_GRP_NUM{pu2xy_odd_waddr}};
assign xy_1_odd_wen   = (nn_proc == 1) ? pu2xy_odd_wen : 0;
assign xy_1_odd_wdata = {pu2xy_odd_wdata_3_3, pu2xy_odd_wdata_3_2, pu2xy_odd_wdata_3_1, pu2xy_odd_wdata_3_0,
                         pu2xy_odd_wdata_2_3, pu2xy_odd_wdata_2_2, pu2xy_odd_wdata_2_1, pu2xy_odd_wdata_2_0,
                         pu2xy_odd_wdata_1_3, pu2xy_odd_wdata_1_2, pu2xy_odd_wdata_1_1, pu2xy_odd_wdata_1_0,
                         pu2xy_odd_wdata_0_3, pu2xy_odd_wdata_0_2, pu2xy_odd_wdata_0_1, pu2xy_odd_wdata_0_0};
assign xy_1_odd_raddr = {(CH_GRP_NUM*ROW_GRP_NUM){sch2xy_raddr_odd}};
assign xy_1_odd_ren   = (nn_proc == 1 && cnt_layer != 1) ? {CH_GRP_NUM{sch2xy_odd_ren}} : 0;
assign xy2sch_evn_rdata_w = (nn_proc == 0 && cnt_layer == 1) ? {{(XY_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}},xy_l1_0_evn_rdata} :
                            (nn_proc == 1 && cnt_layer == 1) ? {{(XY_BUF_WIDTH*(CH_GRP_NUM-SR_L1_CH)*ROW_GRP_NUM){1'b0}},xy_l1_1_evn_rdata} :
                            (nn_proc == 0 && cnt_layer != 1) ? xy_0_evn_rdata : xy_1_evn_rdata;
assign xy2sch_odd_rdata_w = (nn_proc == 0 && cnt_layer == 1) ? {{(XY_BUF_WIDTH*(CH_GRP_NUM-DNDM_L1_CH)*ROW_GRP_NUM){1'b0}},xy_l1_0_odd_rdata} :
                            (nn_proc == 1 && cnt_layer == 1) ? {{(XY_BUF_WIDTH*(CH_GRP_NUM-SR_L1_CH)*ROW_GRP_NUM){1'b0}},xy_l1_1_odd_rdata} :
                            (nn_proc == 0 && cnt_layer != 1) ? xy_0_odd_rdata : xy_1_odd_rdata;
assign xy2sch_evn_rdata_0_0 = xy2sch_evn_rdata_w[ 1*XY_BUF_WIDTH - 1 :  0*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_0_1 = xy2sch_evn_rdata_w[ 2*XY_BUF_WIDTH - 1 :  1*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_0_2 = xy2sch_evn_rdata_w[ 3*XY_BUF_WIDTH - 1 :  2*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_0_3 = xy2sch_evn_rdata_w[ 4*XY_BUF_WIDTH - 1 :  3*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_1_0 = xy2sch_evn_rdata_w[ 5*XY_BUF_WIDTH - 1 :  4*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_1_1 = xy2sch_evn_rdata_w[ 6*XY_BUF_WIDTH - 1 :  5*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_1_2 = xy2sch_evn_rdata_w[ 7*XY_BUF_WIDTH - 1 :  6*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_1_3 = xy2sch_evn_rdata_w[ 8*XY_BUF_WIDTH - 1 :  7*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_2_0 = xy2sch_evn_rdata_w[ 9*XY_BUF_WIDTH - 1 :  8*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_2_1 = xy2sch_evn_rdata_w[10*XY_BUF_WIDTH - 1 :  9*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_2_2 = xy2sch_evn_rdata_w[11*XY_BUF_WIDTH - 1 : 10*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_2_3 = xy2sch_evn_rdata_w[12*XY_BUF_WIDTH - 1 : 11*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_3_0 = xy2sch_evn_rdata_w[13*XY_BUF_WIDTH - 1 : 12*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_3_1 = xy2sch_evn_rdata_w[14*XY_BUF_WIDTH - 1 : 13*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_3_2 = xy2sch_evn_rdata_w[15*XY_BUF_WIDTH - 1 : 14*XY_BUF_WIDTH];
assign xy2sch_evn_rdata_3_3 = xy2sch_evn_rdata_w[16*XY_BUF_WIDTH - 1 : 15*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_0_0 = xy2sch_odd_rdata_w[ 1*XY_BUF_WIDTH - 1 :  0*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_0_1 = xy2sch_odd_rdata_w[ 2*XY_BUF_WIDTH - 1 :  1*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_0_2 = xy2sch_odd_rdata_w[ 3*XY_BUF_WIDTH - 1 :  2*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_0_3 = xy2sch_odd_rdata_w[ 4*XY_BUF_WIDTH - 1 :  3*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_1_0 = xy2sch_odd_rdata_w[ 5*XY_BUF_WIDTH - 1 :  4*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_1_1 = xy2sch_odd_rdata_w[ 6*XY_BUF_WIDTH - 1 :  5*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_1_2 = xy2sch_odd_rdata_w[ 7*XY_BUF_WIDTH - 1 :  6*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_1_3 = xy2sch_odd_rdata_w[ 8*XY_BUF_WIDTH - 1 :  7*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_2_0 = xy2sch_odd_rdata_w[ 9*XY_BUF_WIDTH - 1 :  8*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_2_1 = xy2sch_odd_rdata_w[10*XY_BUF_WIDTH - 1 :  9*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_2_2 = xy2sch_odd_rdata_w[11*XY_BUF_WIDTH - 1 : 10*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_2_3 = xy2sch_odd_rdata_w[12*XY_BUF_WIDTH - 1 : 11*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_3_0 = xy2sch_odd_rdata_w[13*XY_BUF_WIDTH - 1 : 12*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_3_1 = xy2sch_odd_rdata_w[14*XY_BUF_WIDTH - 1 : 13*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_3_2 = xy2sch_odd_rdata_w[15*XY_BUF_WIDTH - 1 : 14*XY_BUF_WIDTH];
assign xy2sch_odd_rdata_3_3 = xy2sch_odd_rdata_w[16*XY_BUF_WIDTH - 1 : 15*XY_BUF_WIDTH];

// olp buffer instantiation
genvar  idx_inst_0;
genvar  idx_inst_1;
genvar  idx_inst_2;

generate
    for(idx_inst_0 = 0; idx_inst_0 < DNDM_L1_CH*ROW_GRP_NUM; idx_inst_0 = idx_inst_0 + 1)begin: dndm_l1_inst
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (X_L1_ADDR_WIDTH                                                                            ),
            .DATA_WIDTH     (X_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (X_L1_BUF_DEPTH                                                                             )
        )
        u_x_l1_0_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (x_l1_0_waddr [(idx_inst_0+1)*X_L1_ADDR_WIDTH - 1 : idx_inst_0*X_L1_ADDR_WIDTH]             ),
            .wr_en          (x_l1_0_wen   [idx_inst_0]                                                                  ),
            .wr_data        (x_l1_0_wdata [(idx_inst_0+1)*X_BUF_WIDTH - 1 : idx_inst_0*X_BUF_WIDTH]                     ),
            .rd_addr        (x_l1_0_raddr [(idx_inst_0+1)*X_L1_ADDR_WIDTH - 1 : idx_inst_0*X_L1_ADDR_WIDTH]             ),
            .rd_en          (x_l1_0_ren   [idx_inst_0]                                                                  ),
            .rd_data        (x_l1_0_rdata [(idx_inst_0+1)*X_BUF_WIDTH - 1 : idx_inst_0*X_BUF_WIDTH]                     )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (X_L1_ADDR_WIDTH                                                                            ),
            .DATA_WIDTH     (X_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (X_L1_BUF_DEPTH                                                                             )
        )
        u_x_l1_1_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (x_l1_1_waddr [(idx_inst_0+1)*X_L1_ADDR_WIDTH - 1 : idx_inst_0*X_L1_ADDR_WIDTH]             ),
            .wr_en          (x_l1_1_wen   [idx_inst_0]                                                                  ),
            .wr_data        (x_l1_1_wdata [(idx_inst_0+1)*X_BUF_WIDTH - 1 : idx_inst_0*X_BUF_WIDTH]                     ),
            .rd_addr        (x_l1_1_raddr [(idx_inst_0+1)*X_L1_ADDR_WIDTH - 1 : idx_inst_0*X_L1_ADDR_WIDTH]             ),
            .rd_en          (x_l1_1_ren   [idx_inst_0]                                                                  ),
            .rd_data        (x_l1_1_rdata [(idx_inst_0+1)*X_BUF_WIDTH - 1 : idx_inst_0*X_BUF_WIDTH]                     )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (Y_L1_ADDR_WIDTH                                                                            ),
            .DATA_WIDTH     (Y_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (Y_L1_BUF_DEPTH                                                                             )
        )
        u_y_l1_0_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (y_l1_0_waddr [(idx_inst_0+1)*Y_L1_ADDR_WIDTH - 1 : idx_inst_0*Y_L1_ADDR_WIDTH]             ),
            .wr_en          (y_l1_0_wen   [idx_inst_0]                                                                  ),
            .wr_data        (y_l1_0_wdata [(idx_inst_0+1)*Y_BUF_WIDTH - 1 : idx_inst_0*Y_BUF_WIDTH]                     ),
            .rd_addr        (y_l1_0_raddr [(idx_inst_0+1)*Y_L1_ADDR_WIDTH - 1 : idx_inst_0*Y_L1_ADDR_WIDTH]             ),
            .rd_en          (y_l1_0_ren   [idx_inst_0]                                                                  ),
            .rd_data        (y_l1_0_rdata [(idx_inst_0+1)*Y_BUF_WIDTH - 1 : idx_inst_0*Y_BUF_WIDTH]                     )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_L1_ADDR_WIDTH                                                                           ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_L1_BUF_DEPTH                                                                            )
        )
        u_xy_l1_0_evn_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_l1_0_evn_waddr [(idx_inst_0+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_0*XY_L1_ADDR_WIDTH]      ),
            .wr_en          (xy_l1_0_evn_wen   [idx_inst_0]                                                             ),
            .wr_data        (xy_l1_0_evn_wdata [(idx_inst_0+1)*XY_BUF_WIDTH - 1 : idx_inst_0*XY_BUF_WIDTH]              ),
            .rd_addr        (xy_l1_0_evn_raddr [(idx_inst_0+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_0*XY_L1_ADDR_WIDTH]      ),
            .rd_en          (xy_l1_0_evn_ren   [idx_inst_0]                                                             ),
            .rd_data        (xy_l1_0_evn_rdata [(idx_inst_0+1)*XY_BUF_WIDTH - 1 : idx_inst_0*XY_BUF_WIDTH]              )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_L1_ADDR_WIDTH                                                                           ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_L1_BUF_DEPTH                                                                            )
        )
        u_xy_l1_0_odd_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_l1_0_odd_waddr [(idx_inst_0+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_0*XY_L1_ADDR_WIDTH]      ),
            .wr_en          (xy_l1_0_odd_wen   [idx_inst_0]                                                             ),
            .wr_data        (xy_l1_0_odd_wdata [(idx_inst_0+1)*XY_BUF_WIDTH - 1 : idx_inst_0*XY_BUF_WIDTH]              ),
            .rd_addr        (xy_l1_0_odd_raddr [(idx_inst_0+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_0*XY_L1_ADDR_WIDTH]      ),
            .rd_en          (xy_l1_0_odd_ren   [idx_inst_0]                                                             ),
            .rd_data        (xy_l1_0_odd_rdata [(idx_inst_0+1)*XY_BUF_WIDTH - 1 : idx_inst_0*XY_BUF_WIDTH]              )
        );
    end
endgenerate

generate
    for(idx_inst_1 = 0; idx_inst_1 < SR_L1_CH*ROW_GRP_NUM; idx_inst_1 = idx_inst_1 + 1)begin: sr_l1_inst
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (Y_L1_ADDR_WIDTH                                                                            ),
            .DATA_WIDTH     (Y_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (Y_L1_BUF_DEPTH                                                                             )
        )
        u_y_l1_1_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (y_l1_1_waddr [(idx_inst_1+1)*Y_L1_ADDR_WIDTH - 1 : idx_inst_1*Y_L1_ADDR_WIDTH]             ),
            .wr_en          (y_l1_1_wen   [idx_inst_1]                                                                  ),
            .wr_data        (y_l1_1_wdata [(idx_inst_1+1)*Y_BUF_WIDTH - 1 : idx_inst_1*Y_BUF_WIDTH]                     ),
            .rd_addr        (y_l1_1_raddr [(idx_inst_1+1)*Y_L1_ADDR_WIDTH - 1 : idx_inst_1*Y_L1_ADDR_WIDTH]             ),
            .rd_en          (y_l1_1_ren   [idx_inst_1]                                                                  ),
            .rd_data        (y_l1_1_rdata [(idx_inst_1+1)*Y_BUF_WIDTH - 1 : idx_inst_1*Y_BUF_WIDTH]                     )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_L1_ADDR_WIDTH                                                                           ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_L1_BUF_DEPTH                                                                            )
        )
        u_xy_l1_1_evn_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_l1_1_evn_waddr [(idx_inst_1+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_1*XY_L1_ADDR_WIDTH]      ),
            .wr_en          (xy_l1_1_evn_wen   [idx_inst_1]                                                             ),
            .wr_data        (xy_l1_1_evn_wdata [(idx_inst_1+1)*XY_BUF_WIDTH - 1 : idx_inst_1*XY_BUF_WIDTH]              ),
            .rd_addr        (xy_l1_1_evn_raddr [(idx_inst_1+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_1*XY_L1_ADDR_WIDTH]      ),
            .rd_en          (xy_l1_1_evn_ren   [idx_inst_1]                                                             ),
            .rd_data        (xy_l1_1_evn_rdata [(idx_inst_1+1)*XY_BUF_WIDTH - 1 : idx_inst_1*XY_BUF_WIDTH]              )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_L1_ADDR_WIDTH                                                                           ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_L1_BUF_DEPTH                                                                            )
        )
        u_xy_l1_1_odd_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_l1_1_odd_waddr [(idx_inst_1+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_1*XY_L1_ADDR_WIDTH]      ),
            .wr_en          (xy_l1_1_odd_wen   [idx_inst_1]                                                             ),
            .wr_data        (xy_l1_1_odd_wdata [(idx_inst_1+1)*XY_BUF_WIDTH - 1 : idx_inst_1*XY_BUF_WIDTH]              ),
            .rd_addr        (xy_l1_1_odd_raddr [(idx_inst_1+1)*XY_L1_ADDR_WIDTH - 1 : idx_inst_1*XY_L1_ADDR_WIDTH]      ),
            .rd_en          (xy_l1_1_odd_ren   [idx_inst_1]                                                             ),
            .rd_data        (xy_l1_1_odd_rdata [(idx_inst_1+1)*XY_BUF_WIDTH - 1 : idx_inst_1*XY_BUF_WIDTH]              )
        );
    end
endgenerate

generate
    for(idx_inst_2 = 0; idx_inst_2 < CH_GRP_NUM*ROW_GRP_NUM; idx_inst_2 = idx_inst_2 + 1)begin: l2345_inst
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (X_ADDR_WIDTH                                                                               ),
            .DATA_WIDTH     (X_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (X_BUF_DEPTH                                                                                )
        )
        u_x_0_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (x_0_waddr [(idx_inst_2+1)*X_ADDR_WIDTH - 1 : idx_inst_2*X_ADDR_WIDTH]                      ),
            .wr_en          (x_0_wen   [idx_inst_2]                                                                     ),
            .wr_data        (x_0_wdata [(idx_inst_2+1)*X_BUF_WIDTH - 1 : idx_inst_2*X_BUF_WIDTH]                        ),
            .rd_addr        (x_0_raddr [(idx_inst_2+1)*X_ADDR_WIDTH - 1 : idx_inst_2*X_ADDR_WIDTH]                      ),
            .rd_en          (x_0_ren   [idx_inst_2]                                                                     ),
            .rd_data        (x_0_rdata [(idx_inst_2+1)*X_BUF_WIDTH - 1 : idx_inst_2*X_BUF_WIDTH]                        )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (X_ADDR_WIDTH                                                                               ),
            .DATA_WIDTH     (X_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (X_BUF_DEPTH                                                                                )
        )
        u_x_1_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (x_1_waddr [(idx_inst_2+1)*X_ADDR_WIDTH - 1 : idx_inst_2*X_ADDR_WIDTH]                      ),
            .wr_en          (x_1_wen   [idx_inst_2]                                                                     ),
            .wr_data        (x_1_wdata [(idx_inst_2+1)*X_BUF_WIDTH - 1 : idx_inst_2*X_BUF_WIDTH]                        ),
            .rd_addr        (x_1_raddr [(idx_inst_2+1)*X_ADDR_WIDTH - 1 : idx_inst_2*X_ADDR_WIDTH]                      ),
            .rd_en          (x_1_ren   [idx_inst_2]                                                                     ),
            .rd_data        (x_1_rdata [(idx_inst_2+1)*X_BUF_WIDTH - 1 : idx_inst_2*X_BUF_WIDTH]                        )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (Y_ADDR_WIDTH                                                                               ),
            .DATA_WIDTH     (Y_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (Y_BUF_DEPTH                                                                                )
        )
        u_y_0_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (y_0_waddr [(idx_inst_2+1)*Y_ADDR_WIDTH - 1 : idx_inst_2*Y_ADDR_WIDTH]                      ),
            .wr_en          (y_0_wen   [idx_inst_2]                                                                     ),
            .wr_data        (y_0_wdata [(idx_inst_2+1)*Y_BUF_WIDTH - 1 : idx_inst_2*Y_BUF_WIDTH]                        ),
            .rd_addr        (y_0_raddr [(idx_inst_2+1)*Y_ADDR_WIDTH - 1 : idx_inst_2*Y_ADDR_WIDTH]                      ),
            .rd_en          (y_0_ren   [idx_inst_2]                                                                     ),
            .rd_data        (y_0_rdata [(idx_inst_2+1)*Y_BUF_WIDTH - 1 : idx_inst_2*Y_BUF_WIDTH]                        )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (Y_ADDR_WIDTH                                                                               ),
            .DATA_WIDTH     (Y_BUF_WIDTH                                                                                ),
            .DATA_DEPTH     (Y_BUF_DEPTH                                                                                )
        )
        u_y_1_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (y_1_waddr [(idx_inst_2+1)*Y_ADDR_WIDTH - 1 : idx_inst_2*Y_ADDR_WIDTH]                      ),
            .wr_en          (y_1_wen   [idx_inst_2]                                                                     ),
            .wr_data        (y_1_wdata [(idx_inst_2+1)*Y_BUF_WIDTH - 1 : idx_inst_2*Y_BUF_WIDTH]                        ),
            .rd_addr        (y_1_raddr [(idx_inst_2+1)*Y_ADDR_WIDTH - 1 : idx_inst_2*Y_ADDR_WIDTH]                      ),
            .rd_en          (y_1_ren   [idx_inst_2]                                                                     ),
            .rd_data        (y_1_rdata [(idx_inst_2+1)*Y_BUF_WIDTH - 1 : idx_inst_2*Y_BUF_WIDTH]                        )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_ADDR_WIDTH                                                                              ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_BUF_DEPTH                                                                               )
        )
        u_xy_0_evn_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_0_evn_waddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .wr_en          (xy_0_evn_wen   [idx_inst_2]                                                                ),
            .wr_data        (xy_0_evn_wdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 ),
            .rd_addr        (xy_0_evn_raddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .rd_en          (xy_0_evn_ren   [idx_inst_2]                                                                ),
            .rd_data        (xy_0_evn_rdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_ADDR_WIDTH                                                                              ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_BUF_DEPTH                                                                               )
        )
        u_xy_0_odd_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_0_odd_waddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .wr_en          (xy_0_odd_wen   [idx_inst_2]                                                                ),
            .wr_data        (xy_0_odd_wdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 ),
            .rd_addr        (xy_0_odd_raddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .rd_en          (xy_0_odd_ren   [idx_inst_2]                                                                ),
            .rd_data        (xy_0_odd_rdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_ADDR_WIDTH                                                                              ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_BUF_DEPTH                                                                               )
        )
        u_xy_1_evn_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_1_evn_waddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .wr_en          (xy_1_evn_wen   [idx_inst_2]                                                                ),
            .wr_data        (xy_1_evn_wdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 ),
            .rd_addr        (xy_1_evn_raddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .rd_en          (xy_1_evn_ren   [idx_inst_2]                                                                ),
            .rd_data        (xy_1_evn_rdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 )
        );
        dp_ram_regout #(
            .KNOB_REGOUT    (KNOB_REGOUT                                                                                ),
            .ADDR_WIDTH     (XY_ADDR_WIDTH                                                                              ),
            .DATA_WIDTH     (XY_BUF_WIDTH                                                                               ),
            .DATA_DEPTH     (XY_BUF_DEPTH                                                                               )
        )
        u_xy_1_odd_buf(
            .clk            (clk                                                                                        ),
            .wr_addr        (xy_1_odd_waddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .wr_en          (xy_1_odd_wen   [idx_inst_2]                                                                ),
            .wr_data        (xy_1_odd_wdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 ),
            .rd_addr        (xy_1_odd_raddr [(idx_inst_2+1)*XY_ADDR_WIDTH - 1 : idx_inst_2*XY_ADDR_WIDTH]               ),
            .rd_en          (xy_1_odd_ren   [idx_inst_2]                                                                ),
            .rd_data        (xy_1_odd_rdata [(idx_inst_2+1)*XY_BUF_WIDTH - 1 : idx_inst_2*XY_BUF_WIDTH]                 )
        );
    end
endgenerate
endmodule
