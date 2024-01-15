/*
    Top Module:  res_buf.v
    Author:      Hao Zhang
    Time:        202307
*/

module res_buf#(
    parameter   RESX_ADDR_WIDTH    = 6      ,
    parameter   RESX_BUF_DEPTH     = 32     ,
    parameter   RESX_LBUF_WIDTH    = 232    ,
    parameter   RESX_SBUF_WIDTH    = 24     ,
    parameter   RESY_ADDR_WIDTH    = 8      ,
    parameter   RESY_BUF_DEPTH     = 128    ,
    parameter   RESY_BUF_WIDTH     = 232    ,
    parameter   RESXY_ADDR_WIDTH   = 8      ,
    parameter   RESXY_BUF_DEPTH    = 132    ,
    parameter   RESXY_BUF_WIDTH    = 24     
)
(
    input   wire                                                           clk                  ,
    input   wire                                                           rst_n                ,
    // control                                                                                      
    input   wire                                                           layer_done           ,
    input   wire     [                                       1 : 0]        res_proc_type        ,
    input   wire                                                           nn_proc              ,
    input   wire     [                                       3 : 0]        tile_loc             ,
    // x rd                                                                                      
    input   wire     [  16                                 - 1 : 0]        pu2rx_ren            ,
    input   wire     [  RESX_ADDR_WIDTH                    - 1 : 0]        pu2rx_raddr          ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_0_0      , //_c_h
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_0_1      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_0_2      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_0_3      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_1_0      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_1_1      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_1_2      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_1_3      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_2_0      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_2_1      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_2_2      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_2_3      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_3_0      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_3_1      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_3_2      ,
    output  wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        rx2pu_rdata_3_3      ,
    // x wr                                                                                      
    input   wire     [  16                                 - 1 : 0]        pu2rx_wen            ,
    input   wire     [  RESX_ADDR_WIDTH                    - 1 : 0]        pu2rx_waddr_0        , //_h
    input   wire     [  RESX_ADDR_WIDTH                    - 1 : 0]        pu2rx_waddr_1        ,
    input   wire     [  RESX_ADDR_WIDTH                    - 1 : 0]        pu2rx_waddr_2        ,
    input   wire     [  RESX_ADDR_WIDTH                    - 1 : 0]        pu2rx_waddr_3        ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_0_0      , //_c_h
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_0_1      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_0_2      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_0_3      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_1_0      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_1_1      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_1_2      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_1_3      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_2_0      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_2_1      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_2_2      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_2_3      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_3_0      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_3_1      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_3_2      ,
    input   wire     [  RESX_LBUF_WIDTH + RESX_SBUF_WIDTH  - 1 : 0]        pu2rx_wdata_3_3      ,
    // y rd                                                                                      
    input   wire     [  12                                 - 1 : 0]        pu2ry_ren            ,
    input   wire     [  RESY_ADDR_WIDTH                    - 1 : 0]        pu2ry_raddr          ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_0_0      , //_c_h
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_0_1      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_0_2      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_1_0      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_1_1      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_1_2      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_2_0      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_2_1      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_2_2      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_3_0      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_3_1      ,
    output  wire     [  RESY_BUF_WIDTH                     - 1 : 0]        ry2pu_rdata_3_2      ,
    // y wr                                                                                      
    input   wire     [  12                                 - 1 : 0]        pu2ry_wen            ,
    input   wire     [  RESY_ADDR_WIDTH                    - 1 : 0]        pu2ry_waddr          ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_0_0      , //_c_h
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_0_1      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_0_2      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_1_0      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_1_1      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_1_2      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_2_0      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_2_1      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_2_2      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_3_0      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_3_1      ,
    input   wire     [  RESY_BUF_WIDTH                     - 1 : 0]        pu2ry_wdata_3_2      ,
    // xy rd                                                                                      
    input   wire     [  12                                 - 1 : 0]        pu2rxy_ren           ,
    input   wire     [  RESXY_ADDR_WIDTH                   - 1 : 0]        pu2rxy_raddr         ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_0_0     , //_c_h
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_0_1     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_0_2     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_1_0     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_1_1     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_1_2     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_2_0     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_2_1     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_2_2     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_3_0     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_3_1     ,
    output  wire     [  RESXY_BUF_WIDTH                    - 1 : 0]        rxy2pu_rdata_3_2     ,
    // xy wr                                                                                      
    input  wire      [  12                                 - 1 : 0]        pu2rxy_wen          ,
    input  wire      [  RESXY_ADDR_WIDTH                   - 1 : 0]        pu2rxy_waddr        ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_0_0    , //_c_h
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_0_1    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_0_2    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_1_0    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_1_1    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_1_2    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_2_0    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_2_1    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_2_2    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_3_0    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_3_1    ,
    input  wire      [  RESXY_BUF_WIDTH                    - 1 : 0]        pu2rxy_wdata_3_2    
);

    localparam  ROW_GRP_NUM_X   = 4;
    localparam  ROW_GRP_NUM_Y   = 3;
    localparam  CH_GRP_NUM      = 4;

    wire    [   RESX_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_l_waddr      ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_l_wen        ;
    wire    [   RESX_LBUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_l_wdata      ;
    wire    [   RESX_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_l_raddr      ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_l_ren        ;
    wire    [   RESX_LBUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_l_rdata      ;
    wire    [   RESX_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s0_waddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s0_wen       ;
    wire    [   RESX_SBUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s0_wdata     ;
    wire    [   RESX_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s0_raddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s0_ren       ;
    wire    [   RESX_SBUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s0_rdata     ;
    wire    [   RESX_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s1_waddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s1_wen       ;
    wire    [   RESX_SBUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s1_wdata     ;
    wire    [   RESX_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s1_raddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s1_ren       ;
    wire    [   RESX_SBUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_X - 1 : 0]   rx_s1_rdata     ;
    wire    [   RESY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_0_waddr      ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_0_wen        ;
    wire    [    RESY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_0_wdata      ;
    wire    [   RESY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_0_raddr      ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_0_ren        ;
    wire    [    RESY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_0_rdata      ;
    wire    [   RESY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_1_waddr      ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_1_wen        ;
    wire    [    RESY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_1_wdata      ;
    wire    [   RESY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_1_raddr      ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_1_ren        ;
    wire    [    RESY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   ry_1_rdata      ;
    wire    [  RESXY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_0_waddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_0_wen       ;
    wire    [   RESXY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_0_wdata     ;
    wire    [  RESXY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_0_raddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_0_ren       ;
    wire    [   RESXY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_0_rdata     ;
    wire    [  RESXY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_1_waddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_1_wen       ;
    wire    [   RESXY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_1_wdata     ;
    wire    [  RESXY_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_1_raddr     ;
    wire    [                   CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_1_ren       ;
    wire    [   RESXY_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM_Y - 1 : 0]   rxy_1_rdata     ;

// ping-pong fsm
localparam    WL1_R0L = 1'b0;
localparam    WL0_R1L = 1'b1;

reg    cur_state;
reg    next_state;
reg    mode_flag;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cur_state <= WL1_R0L;
    else
        cur_state <= next_state;
end

always@(*)begin
    case(cur_state)
        WL1_R0L:begin
            if(res_proc_type == 2'b10 && layer_done)
                next_state = WL0_R1L;
            else
                next_state = WL1_R0L;
        end
        WL0_R1L:begin
            if(res_proc_type == 2'b10 && layer_done)
                next_state = WL1_R0L;
            else
                next_state = WL0_R1L;
        end
        default:
            next_state = WL1_R0L;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        mode_flag <= 1'b0;
    else
        case(cur_state)
            WL1_R0L:begin
                mode_flag <= 1'b0;
            end
            WL0_R1L:begin
                mode_flag <= 1'b1;
            end            
            default:
                mode_flag <= 1'b0;
        endcase
end

// buffer_wr & buffer_rd
assign rx_l_waddr  = {CH_GRP_NUM{pu2rx_waddr_3, pu2rx_waddr_2, pu2rx_waddr_1, pu2rx_waddr_0}};
assign rx_l_wen    = pu2rx_wen;
assign rx_l_wdata  = {pu2rx_wdata_3_3[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_3_2[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_3_1[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_3_0[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_2_3[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_2_2[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_2_1[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_2_0[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_1_3[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_1_2[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_1_1[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_1_0[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_0_3[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_0_2[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_0_1[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH],
                      pu2rx_wdata_0_0[ RESX_LBUF_WIDTH + RESX_SBUF_WIDTH - 1 : RESX_SBUF_WIDTH]};
assign rx_l_raddr  = {(CH_GRP_NUM*ROW_GRP_NUM_X){pu2rx_raddr}};
assign rx_l_ren    = pu2rx_ren;
assign rx_s0_waddr = {CH_GRP_NUM{pu2rx_waddr_3, pu2rx_waddr_2, pu2rx_waddr_1, pu2rx_waddr_0}};
assign rx_s0_wen   = (mode_flag == 1) ? pu2rx_wen : 0;
assign rx_s0_wdata = {pu2rx_wdata_3_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_3_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_3_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_3_0[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_0[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_0[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_0[ RESX_SBUF_WIDTH - 1 : 0]};
assign rx_s0_raddr = {(CH_GRP_NUM*ROW_GRP_NUM_X){pu2rx_raddr}};
assign rx_s0_ren   = (mode_flag == 0) ? pu2rx_ren : 0;
assign rx_s1_waddr = {CH_GRP_NUM{pu2rx_waddr_3, pu2rx_waddr_2, pu2rx_waddr_1, pu2rx_waddr_0}};
assign rx_s1_wen   = (mode_flag == 0) ? pu2rx_wen : 0;
assign rx_s1_wdata = {pu2rx_wdata_3_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_3_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_3_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_3_0[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_2_0[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_1_0[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_3[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_2[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_1[ RESX_SBUF_WIDTH - 1 : 0],
                      pu2rx_wdata_0_0[ RESX_SBUF_WIDTH - 1 : 0]};
assign rx_s1_raddr = {(CH_GRP_NUM*ROW_GRP_NUM_X){pu2rx_raddr}};
assign rx_s1_ren   = (mode_flag == 1) ? pu2rx_ren : 0;
assign ry_0_waddr  = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2ry_waddr}};
assign ry_0_wen    = (nn_proc == 0) ? pu2ry_wen : 0; 
assign ry_0_wdata  = {pu2ry_wdata_3_2,
                      pu2ry_wdata_3_1,
                      pu2ry_wdata_3_0,
                      pu2ry_wdata_2_2,
                      pu2ry_wdata_2_1,
                      pu2ry_wdata_2_0,
                      pu2ry_wdata_1_2,
                      pu2ry_wdata_1_1,
                      pu2ry_wdata_1_0,
                      pu2ry_wdata_0_2,
                      pu2ry_wdata_0_1,
                      pu2ry_wdata_0_0};
assign ry_0_raddr  = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2ry_raddr}};
assign ry_0_ren    = (nn_proc == 0) ? pu2ry_ren : 0; 
assign ry_1_waddr  = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2ry_waddr}};
assign ry_1_wen    = (nn_proc == 1) ? pu2ry_wen : 0; 
assign ry_1_wdata  = {pu2ry_wdata_3_2,
                      pu2ry_wdata_3_1,
                      pu2ry_wdata_3_0,
                      pu2ry_wdata_2_2,
                      pu2ry_wdata_2_1,
                      pu2ry_wdata_2_0,
                      pu2ry_wdata_1_2,
                      pu2ry_wdata_1_1,
                      pu2ry_wdata_1_0,
                      pu2ry_wdata_0_2,
                      pu2ry_wdata_0_1,
                      pu2ry_wdata_0_0};
assign ry_1_raddr  = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2ry_raddr}};
assign ry_1_ren    = (nn_proc == 1) ? pu2ry_ren : 0; 
assign rxy_0_waddr = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2rxy_waddr}};
assign rxy_0_wen   = (nn_proc == 0) ? pu2rxy_wen : 0; 
assign rxy_0_wdata = {pu2rxy_wdata_3_2,
                      pu2rxy_wdata_3_1,
                      pu2rxy_wdata_3_0,
                      pu2rxy_wdata_2_2,
                      pu2rxy_wdata_2_1,
                      pu2rxy_wdata_2_0,
                      pu2rxy_wdata_1_2,
                      pu2rxy_wdata_1_1,
                      pu2rxy_wdata_1_0,
                      pu2rxy_wdata_0_2,
                      pu2rxy_wdata_0_1,
                      pu2rxy_wdata_0_0};
assign rxy_0_raddr = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2rxy_raddr}};
assign rxy_0_ren   = (nn_proc == 0) ? pu2rxy_ren : 0; 
assign rxy_1_waddr = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2rxy_waddr}};
assign rxy_1_wen   = (nn_proc == 1) ? pu2rxy_wen : 0; 
assign rxy_1_wdata = {pu2rxy_wdata_3_2,
                      pu2rxy_wdata_3_1,
                      pu2rxy_wdata_3_0,
                      pu2rxy_wdata_2_2,
                      pu2rxy_wdata_2_1,
                      pu2rxy_wdata_2_0,
                      pu2rxy_wdata_1_2,
                      pu2rxy_wdata_1_1,
                      pu2rxy_wdata_1_0,
                      pu2rxy_wdata_0_2,
                      pu2rxy_wdata_0_1,
                      pu2rxy_wdata_0_0};
assign rxy_1_raddr = {(CH_GRP_NUM*ROW_GRP_NUM_Y){pu2rxy_raddr}};
assign rxy_1_ren   = (nn_proc == 1) ? pu2rxy_ren : 0;
assign rx2pu_rdata_0_0  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 1 * RESX_LBUF_WIDTH - 1 :  0 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 1 * RESX_SBUF_WIDTH - 1 :  0 * RESX_SBUF_WIDTH], rx_l_rdata[ 1 * RESX_LBUF_WIDTH - 1 :  0 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 1 * RESX_SBUF_WIDTH - 1 :  0 * RESX_SBUF_WIDTH], rx_l_rdata[ 1 * RESX_LBUF_WIDTH - 1 :  0 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_0_1  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 2 * RESX_LBUF_WIDTH - 1 :  1 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 2 * RESX_SBUF_WIDTH - 1 :  1 * RESX_SBUF_WIDTH], rx_l_rdata[ 2 * RESX_LBUF_WIDTH - 1 :  1 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 2 * RESX_SBUF_WIDTH - 1 :  1 * RESX_SBUF_WIDTH], rx_l_rdata[ 2 * RESX_LBUF_WIDTH - 1 :  1 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_0_2  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 3 * RESX_LBUF_WIDTH - 1 :  2 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 3 * RESX_SBUF_WIDTH - 1 :  2 * RESX_SBUF_WIDTH], rx_l_rdata[ 3 * RESX_LBUF_WIDTH - 1 :  2 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 3 * RESX_SBUF_WIDTH - 1 :  2 * RESX_SBUF_WIDTH], rx_l_rdata[ 3 * RESX_LBUF_WIDTH - 1 :  2 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_0_3  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 4 * RESX_LBUF_WIDTH - 1 :  3 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 4 * RESX_SBUF_WIDTH - 1 :  3 * RESX_SBUF_WIDTH], rx_l_rdata[ 4 * RESX_LBUF_WIDTH - 1 :  3 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 4 * RESX_SBUF_WIDTH - 1 :  3 * RESX_SBUF_WIDTH], rx_l_rdata[ 4 * RESX_LBUF_WIDTH - 1 :  3 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_1_0  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 5 * RESX_LBUF_WIDTH - 1 :  4 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 5 * RESX_SBUF_WIDTH - 1 :  4 * RESX_SBUF_WIDTH], rx_l_rdata[ 5 * RESX_LBUF_WIDTH - 1 :  4 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 5 * RESX_SBUF_WIDTH - 1 :  4 * RESX_SBUF_WIDTH], rx_l_rdata[ 5 * RESX_LBUF_WIDTH - 1 :  4 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_1_1  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 6 * RESX_LBUF_WIDTH - 1 :  5 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 6 * RESX_SBUF_WIDTH - 1 :  5 * RESX_SBUF_WIDTH], rx_l_rdata[ 6 * RESX_LBUF_WIDTH - 1 :  5 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 6 * RESX_SBUF_WIDTH - 1 :  5 * RESX_SBUF_WIDTH], rx_l_rdata[ 6 * RESX_LBUF_WIDTH - 1 :  5 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_1_2  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 7 * RESX_LBUF_WIDTH - 1 :  6 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 7 * RESX_SBUF_WIDTH - 1 :  6 * RESX_SBUF_WIDTH], rx_l_rdata[ 7 * RESX_LBUF_WIDTH - 1 :  6 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 7 * RESX_SBUF_WIDTH - 1 :  6 * RESX_SBUF_WIDTH], rx_l_rdata[ 7 * RESX_LBUF_WIDTH - 1 :  6 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_1_3  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 8 * RESX_LBUF_WIDTH - 1 :  7 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 8 * RESX_SBUF_WIDTH - 1 :  7 * RESX_SBUF_WIDTH], rx_l_rdata[ 8 * RESX_LBUF_WIDTH - 1 :  7 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 8 * RESX_SBUF_WIDTH - 1 :  7 * RESX_SBUF_WIDTH], rx_l_rdata[ 8 * RESX_LBUF_WIDTH - 1 :  7 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_2_0  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[ 9 * RESX_LBUF_WIDTH - 1 :  8 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[ 9 * RESX_SBUF_WIDTH - 1 :  8 * RESX_SBUF_WIDTH], rx_l_rdata[ 9 * RESX_LBUF_WIDTH - 1 :  8 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[ 9 * RESX_SBUF_WIDTH - 1 :  8 * RESX_SBUF_WIDTH], rx_l_rdata[ 9 * RESX_LBUF_WIDTH - 1 :  8 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_2_1  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[10 * RESX_LBUF_WIDTH - 1 :  9 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[10 * RESX_SBUF_WIDTH - 1 :  9 * RESX_SBUF_WIDTH], rx_l_rdata[10 * RESX_LBUF_WIDTH - 1 :  9 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[10 * RESX_SBUF_WIDTH - 1 :  9 * RESX_SBUF_WIDTH], rx_l_rdata[10 * RESX_LBUF_WIDTH - 1 :  9 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_2_2  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[11 * RESX_LBUF_WIDTH - 1 : 10 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[11 * RESX_SBUF_WIDTH - 1 : 10 * RESX_SBUF_WIDTH], rx_l_rdata[11 * RESX_LBUF_WIDTH - 1 : 10 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[11 * RESX_SBUF_WIDTH - 1 : 10 * RESX_SBUF_WIDTH], rx_l_rdata[11 * RESX_LBUF_WIDTH - 1 : 10 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_2_3  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[12 * RESX_LBUF_WIDTH - 1 : 11 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[12 * RESX_SBUF_WIDTH - 1 : 11 * RESX_SBUF_WIDTH], rx_l_rdata[12 * RESX_LBUF_WIDTH - 1 : 11 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[12 * RESX_SBUF_WIDTH - 1 : 11 * RESX_SBUF_WIDTH], rx_l_rdata[12 * RESX_LBUF_WIDTH - 1 : 11 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_3_0  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[13 * RESX_LBUF_WIDTH - 1 : 12 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[13 * RESX_SBUF_WIDTH - 1 : 12 * RESX_SBUF_WIDTH], rx_l_rdata[13 * RESX_LBUF_WIDTH - 1 : 12 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[13 * RESX_SBUF_WIDTH - 1 : 12 * RESX_SBUF_WIDTH], rx_l_rdata[13 * RESX_LBUF_WIDTH - 1 : 12 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_3_1  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[14 * RESX_LBUF_WIDTH - 1 : 13 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[14 * RESX_SBUF_WIDTH - 1 : 13 * RESX_SBUF_WIDTH], rx_l_rdata[14 * RESX_LBUF_WIDTH - 1 : 13 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[14 * RESX_SBUF_WIDTH - 1 : 13 * RESX_SBUF_WIDTH], rx_l_rdata[14 * RESX_LBUF_WIDTH - 1 : 13 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_3_2  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[15 * RESX_LBUF_WIDTH - 1 : 14 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[15 * RESX_SBUF_WIDTH - 1 : 14 * RESX_SBUF_WIDTH], rx_l_rdata[15 * RESX_LBUF_WIDTH - 1 : 14 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[15 * RESX_SBUF_WIDTH - 1 : 14 * RESX_SBUF_WIDTH], rx_l_rdata[15 * RESX_LBUF_WIDTH - 1 : 14 * RESX_LBUF_WIDTH]} ;
assign rx2pu_rdata_3_3  = (mode_flag == 0) ? (tile_loc == 4'b1010 ? ({{RESX_SBUF_WIDTH{1'b0}}, rx_l_rdata[16 * RESX_LBUF_WIDTH - 1 : 15 * RESX_LBUF_WIDTH]}) : ({rx_s0_rdata[16 * RESX_SBUF_WIDTH - 1 : 15 * RESX_SBUF_WIDTH], rx_l_rdata[16 * RESX_LBUF_WIDTH - 1 : 15 * RESX_LBUF_WIDTH]})) : {rx_s1_rdata[16 * RESX_SBUF_WIDTH - 1 : 15 * RESX_SBUF_WIDTH], rx_l_rdata[16 * RESX_LBUF_WIDTH - 1 : 15 * RESX_LBUF_WIDTH]} ;
assign ry2pu_rdata_0_0  = (nn_proc == 0) ? ry_0_rdata[ 1 * RESY_BUF_WIDTH - 1 :  0 * RESY_BUF_WIDTH] : ry_1_rdata[ 1 * RESY_BUF_WIDTH - 1 :  0 * RESY_BUF_WIDTH];
assign ry2pu_rdata_0_1  = (nn_proc == 0) ? ry_0_rdata[ 2 * RESY_BUF_WIDTH - 1 :  1 * RESY_BUF_WIDTH] : ry_1_rdata[ 2 * RESY_BUF_WIDTH - 1 :  1 * RESY_BUF_WIDTH];
assign ry2pu_rdata_0_2  = (nn_proc == 0) ? ry_0_rdata[ 3 * RESY_BUF_WIDTH - 1 :  2 * RESY_BUF_WIDTH] : ry_1_rdata[ 3 * RESY_BUF_WIDTH - 1 :  2 * RESY_BUF_WIDTH];
assign ry2pu_rdata_1_0  = (nn_proc == 0) ? ry_0_rdata[ 4 * RESY_BUF_WIDTH - 1 :  3 * RESY_BUF_WIDTH] : ry_1_rdata[ 4 * RESY_BUF_WIDTH - 1 :  3 * RESY_BUF_WIDTH];
assign ry2pu_rdata_1_1  = (nn_proc == 0) ? ry_0_rdata[ 5 * RESY_BUF_WIDTH - 1 :  4 * RESY_BUF_WIDTH] : ry_1_rdata[ 5 * RESY_BUF_WIDTH - 1 :  4 * RESY_BUF_WIDTH];
assign ry2pu_rdata_1_2  = (nn_proc == 0) ? ry_0_rdata[ 6 * RESY_BUF_WIDTH - 1 :  5 * RESY_BUF_WIDTH] : ry_1_rdata[ 6 * RESY_BUF_WIDTH - 1 :  5 * RESY_BUF_WIDTH];
assign ry2pu_rdata_2_0  = (nn_proc == 0) ? ry_0_rdata[ 7 * RESY_BUF_WIDTH - 1 :  6 * RESY_BUF_WIDTH] : ry_1_rdata[ 7 * RESY_BUF_WIDTH - 1 :  6 * RESY_BUF_WIDTH];
assign ry2pu_rdata_2_1  = (nn_proc == 0) ? ry_0_rdata[ 8 * RESY_BUF_WIDTH - 1 :  7 * RESY_BUF_WIDTH] : ry_1_rdata[ 8 * RESY_BUF_WIDTH - 1 :  7 * RESY_BUF_WIDTH];
assign ry2pu_rdata_2_2  = (nn_proc == 0) ? ry_0_rdata[ 9 * RESY_BUF_WIDTH - 1 :  8 * RESY_BUF_WIDTH] : ry_1_rdata[ 9 * RESY_BUF_WIDTH - 1 :  8 * RESY_BUF_WIDTH];
assign ry2pu_rdata_3_0  = (nn_proc == 0) ? ry_0_rdata[10 * RESY_BUF_WIDTH - 1 :  9 * RESY_BUF_WIDTH] : ry_1_rdata[10 * RESY_BUF_WIDTH - 1 :  9 * RESY_BUF_WIDTH];
assign ry2pu_rdata_3_1  = (nn_proc == 0) ? ry_0_rdata[11 * RESY_BUF_WIDTH - 1 : 10 * RESY_BUF_WIDTH] : ry_1_rdata[11 * RESY_BUF_WIDTH - 1 : 10 * RESY_BUF_WIDTH];
assign ry2pu_rdata_3_2  = (nn_proc == 0) ? ry_0_rdata[12 * RESY_BUF_WIDTH - 1 : 11 * RESY_BUF_WIDTH] : ry_1_rdata[12 * RESY_BUF_WIDTH - 1 : 11 * RESY_BUF_WIDTH];
assign rxy2pu_rdata_0_0 = (nn_proc == 0) ? rxy_0_rdata[ 1 * RESXY_BUF_WIDTH - 1 :  0 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 1 * RESXY_BUF_WIDTH - 1 :  0 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_0_1 = (nn_proc == 0) ? rxy_0_rdata[ 2 * RESXY_BUF_WIDTH - 1 :  1 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 2 * RESXY_BUF_WIDTH - 1 :  1 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_0_2 = (nn_proc == 0) ? rxy_0_rdata[ 3 * RESXY_BUF_WIDTH - 1 :  2 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 3 * RESXY_BUF_WIDTH - 1 :  2 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_1_0 = (nn_proc == 0) ? rxy_0_rdata[ 4 * RESXY_BUF_WIDTH - 1 :  3 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 4 * RESXY_BUF_WIDTH - 1 :  3 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_1_1 = (nn_proc == 0) ? rxy_0_rdata[ 5 * RESXY_BUF_WIDTH - 1 :  4 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 5 * RESXY_BUF_WIDTH - 1 :  4 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_1_2 = (nn_proc == 0) ? rxy_0_rdata[ 6 * RESXY_BUF_WIDTH - 1 :  5 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 6 * RESXY_BUF_WIDTH - 1 :  5 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_2_0 = (nn_proc == 0) ? rxy_0_rdata[ 7 * RESXY_BUF_WIDTH - 1 :  6 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 7 * RESXY_BUF_WIDTH - 1 :  6 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_2_1 = (nn_proc == 0) ? rxy_0_rdata[ 8 * RESXY_BUF_WIDTH - 1 :  7 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 8 * RESXY_BUF_WIDTH - 1 :  7 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_2_2 = (nn_proc == 0) ? rxy_0_rdata[ 9 * RESXY_BUF_WIDTH - 1 :  8 * RESXY_BUF_WIDTH] : rxy_1_rdata[ 9 * RESXY_BUF_WIDTH - 1 :  8 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_3_0 = (nn_proc == 0) ? rxy_0_rdata[10 * RESXY_BUF_WIDTH - 1 :  9 * RESXY_BUF_WIDTH] : rxy_1_rdata[10 * RESXY_BUF_WIDTH - 1 :  9 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_3_1 = (nn_proc == 0) ? rxy_0_rdata[11 * RESXY_BUF_WIDTH - 1 : 10 * RESXY_BUF_WIDTH] : rxy_1_rdata[11 * RESXY_BUF_WIDTH - 1 : 10 * RESXY_BUF_WIDTH];
assign rxy2pu_rdata_3_2 = (nn_proc == 0) ? rxy_0_rdata[12 * RESXY_BUF_WIDTH - 1 : 11 * RESXY_BUF_WIDTH] : rxy_1_rdata[12 * RESXY_BUF_WIDTH - 1 : 11 * RESXY_BUF_WIDTH];

// residual ping-pong buffer instantiation
genvar  idx_inst_x;
genvar  idx_inst_y;

generate
    for(idx_inst_x = 0; idx_inst_x < CH_GRP_NUM * ROW_GRP_NUM_X; idx_inst_x = idx_inst_x + 1)begin: rx_inst
        dp_ram #(
            .ADDR_WIDTH                     (  RESX_ADDR_WIDTH),
            .DATA_WIDTH                     (  RESX_LBUF_WIDTH),
            .DATA_DEPTH                     (   RESX_BUF_DEPTH)
        )
        u_rx_l_buf(
            .clk                            (clk                                                                            ),
            .wr_addr                        (rx_l_waddr [(idx_inst_x+1)*RESX_ADDR_WIDTH - 1 : idx_inst_x*RESX_ADDR_WIDTH]   ),
            .wr_en                          (rx_l_wen   [idx_inst_x]                                                        ),
            .wr_data                        (rx_l_wdata [(idx_inst_x+1)*RESX_LBUF_WIDTH - 1 : idx_inst_x*RESX_LBUF_WIDTH]   ),
            .rd_addr                        (rx_l_raddr [(idx_inst_x+1)*RESX_ADDR_WIDTH - 1 : idx_inst_x*RESX_ADDR_WIDTH]   ),
            .rd_en                          (rx_l_ren   [idx_inst_x]                                                        ),
            .rd_data                        (rx_l_rdata [(idx_inst_x+1)*RESX_LBUF_WIDTH - 1 : idx_inst_x*RESX_LBUF_WIDTH]   )
        );
        dp_ram #(
            .ADDR_WIDTH                     (  RESX_ADDR_WIDTH),
            .DATA_WIDTH                     (  RESX_SBUF_WIDTH),
            .DATA_DEPTH                     (   RESX_BUF_DEPTH)
        )
        u_rx_s0_buf(
            .clk                            (clk                                                                              ),
            .wr_addr                        (rx_s0_waddr  [(idx_inst_x+1)*RESX_ADDR_WIDTH - 1 : idx_inst_x*RESX_ADDR_WIDTH]   ),
            .wr_en                          (rx_s0_wen    [idx_inst_x]                                                        ),
            .wr_data                        (rx_s0_wdata  [(idx_inst_x+1)*RESX_SBUF_WIDTH - 1 : idx_inst_x*RESX_SBUF_WIDTH]   ),
            .rd_addr                        (rx_s0_raddr  [(idx_inst_x+1)*RESX_ADDR_WIDTH - 1 : idx_inst_x*RESX_ADDR_WIDTH]   ),
            .rd_en                          (rx_s0_ren    [idx_inst_x]                                                        ),
            .rd_data                        (rx_s0_rdata  [(idx_inst_x+1)*RESX_SBUF_WIDTH - 1 : idx_inst_x*RESX_SBUF_WIDTH]   )
        );
        dp_ram #(
            .ADDR_WIDTH                     (  RESX_ADDR_WIDTH),
            .DATA_WIDTH                     (  RESX_SBUF_WIDTH),
            .DATA_DEPTH                     (   RESX_BUF_DEPTH)
        )
        u_rx_s1_buf(
            .clk                            (clk                                                                              ),
            .wr_addr                        (rx_s1_waddr  [(idx_inst_x+1)*RESX_ADDR_WIDTH - 1 : idx_inst_x*RESX_ADDR_WIDTH]   ),
            .wr_en                          (rx_s1_wen    [idx_inst_x]                                                        ),
            .wr_data                        (rx_s1_wdata  [(idx_inst_x+1)*RESX_SBUF_WIDTH - 1 : idx_inst_x*RESX_SBUF_WIDTH]   ),
            .rd_addr                        (rx_s1_raddr  [(idx_inst_x+1)*RESX_ADDR_WIDTH - 1 : idx_inst_x*RESX_ADDR_WIDTH]   ),
            .rd_en                          (rx_s1_ren    [idx_inst_x]                                                        ),
            .rd_data                        (rx_s1_rdata  [(idx_inst_x+1)*RESX_SBUF_WIDTH - 1 : idx_inst_x*RESX_SBUF_WIDTH]   )
        );
    end
endgenerate

generate
    for(idx_inst_y = 0; idx_inst_y < CH_GRP_NUM * ROW_GRP_NUM_Y; idx_inst_y = idx_inst_y + 1)begin: ry_rxy_inst
        dp_ram #(
            .ADDR_WIDTH                     (  RESY_ADDR_WIDTH),
            .DATA_WIDTH                     (   RESY_BUF_WIDTH),
            .DATA_DEPTH                     (   RESY_BUF_DEPTH)
        )
        u_ry_0_buf( //dndm
            .clk                            (clk                                                                            ),
            .wr_addr                        (ry_0_waddr [(idx_inst_y+1)*RESY_ADDR_WIDTH - 1 : idx_inst_y*RESY_ADDR_WIDTH]   ),
            .wr_en                          (ry_0_wen   [idx_inst_y]                                                        ),
            .wr_data                        (ry_0_wdata [(idx_inst_y+1)*RESY_BUF_WIDTH - 1 : idx_inst_y*RESY_BUF_WIDTH]     ),
            .rd_addr                        (ry_0_raddr [(idx_inst_y+1)*RESY_ADDR_WIDTH - 1 : idx_inst_y*RESY_ADDR_WIDTH]   ),
            .rd_en                          (ry_0_ren   [idx_inst_y]                                                        ),
            .rd_data                        (ry_0_rdata [(idx_inst_y+1)*RESY_BUF_WIDTH - 1 : idx_inst_y*RESY_BUF_WIDTH]     )
        );
        dp_ram #(
            .ADDR_WIDTH                     (  RESY_ADDR_WIDTH),
            .DATA_WIDTH                     (   RESY_BUF_WIDTH),
            .DATA_DEPTH                     (   RESY_BUF_DEPTH)
        )
        u_ry_1_buf( //sr
            .clk                            (clk                                                                            ),
            .wr_addr                        (ry_1_waddr [(idx_inst_y+1)*RESY_ADDR_WIDTH - 1 : idx_inst_y*RESY_ADDR_WIDTH]   ),
            .wr_en                          (ry_1_wen   [idx_inst_y]                                                        ),
            .wr_data                        (ry_1_wdata [(idx_inst_y+1)*RESY_BUF_WIDTH - 1 : idx_inst_y*RESY_BUF_WIDTH]     ),
            .rd_addr                        (ry_1_raddr [(idx_inst_y+1)*RESY_ADDR_WIDTH - 1 : idx_inst_y*RESY_ADDR_WIDTH]   ),
            .rd_en                          (ry_1_ren   [idx_inst_y]                                                        ),
            .rd_data                        (ry_1_rdata [(idx_inst_y+1)*RESY_BUF_WIDTH - 1 : idx_inst_y*RESY_BUF_WIDTH]     )
        );
        dp_ram #(
            .ADDR_WIDTH                     (  RESXY_ADDR_WIDTH),
            .DATA_WIDTH                     (   RESXY_BUF_WIDTH),
            .DATA_DEPTH                     (   RESXY_BUF_DEPTH)
        )
        u_rxy_0_buf( //dndm
            .clk                            (clk                                                                               ),
            .wr_addr                        (rxy_0_waddr [(idx_inst_y+1)*RESXY_ADDR_WIDTH - 1 : idx_inst_y*RESXY_ADDR_WIDTH]   ),
            .wr_en                          (rxy_0_wen   [idx_inst_y]                                                          ),
            .wr_data                        (rxy_0_wdata [(idx_inst_y+1)*RESXY_BUF_WIDTH - 1 : idx_inst_y*RESXY_BUF_WIDTH]     ),
            .rd_addr                        (rxy_0_raddr [(idx_inst_y+1)*RESXY_ADDR_WIDTH - 1 : idx_inst_y*RESXY_ADDR_WIDTH]   ),
            .rd_en                          (rxy_0_ren   [idx_inst_y]                                                          ),
            .rd_data                        (rxy_0_rdata [(idx_inst_y+1)*RESXY_BUF_WIDTH - 1 : idx_inst_y*RESXY_BUF_WIDTH]     )
        );
        dp_ram #(
            .ADDR_WIDTH                     (  RESXY_ADDR_WIDTH),
            .DATA_WIDTH                     (   RESXY_BUF_WIDTH),
            .DATA_DEPTH                     (   RESXY_BUF_DEPTH)
        )
        u_rxy_1_buf( //sr
            .clk                            (clk                                                                               ),
            .wr_addr                        (rxy_1_waddr [(idx_inst_y+1)*RESXY_ADDR_WIDTH - 1 : idx_inst_y*RESXY_ADDR_WIDTH]   ),
            .wr_en                          (rxy_1_wen   [idx_inst_y]                                                          ),
            .wr_data                        (rxy_1_wdata [(idx_inst_y+1)*RESXY_BUF_WIDTH - 1 : idx_inst_y*RESXY_BUF_WIDTH]     ),
            .rd_addr                        (rxy_1_raddr [(idx_inst_y+1)*RESXY_ADDR_WIDTH - 1 : idx_inst_y*RESXY_ADDR_WIDTH]   ),
            .rd_en                          (rxy_1_ren   [idx_inst_y]                                                          ),
            .rd_data                        (rxy_1_rdata [(idx_inst_y+1)*RESXY_BUF_WIDTH - 1 : idx_inst_y*RESXY_BUF_WIDTH]     )
        );
    end
endgenerate

endmodule