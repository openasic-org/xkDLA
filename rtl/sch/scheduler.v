//////////////////////////////////////////////////
//
// File:            addr_if.v
// Project Name:    DLA_v2
// Module Name:     addr_if
// Description:     addr calculation logic of scheduler
//
// Author:          Wanwei Xiao
// Setup Data:      17/7/2023
// Modify Date:     01/9/2023
//
//////////////////////////////////////////////////
module scheduler
#(
  parameter   REG_IH_WIDTH      = 5  ,
  parameter   REG_IW_WIDTH      = 6  ,
  parameter   REG_IC_WIDTH      = 6  ,
  parameter   REG_OH_WIDTH      = 5  ,
  parameter   REG_OW_WIDTH      = 6  ,
  parameter   REG_OC_WIDTH      = 6  ,
  parameter   IFM_WIDTH         = 8  ,
  parameter   SCH_COL_NUM       = 36 ,
  parameter   WT_WIDTH          = 8  ,
  parameter   PE_COL_NUM        = 32 ,
  parameter   PE_H_NUM          = 4  ,
  parameter   PE_IC_NUM         = 4  ,
  parameter   PE_OC_NUM         = 4  ,
  parameter   FE_BUF_WIDTH      = 32 * IFM_WIDTH ,
  parameter   X_BUF_WIDTH       = 4  ,
  parameter   Y_BUF_WIDTH       = 28 ,
  parameter   XY_BUF_WIDTH      = 4  ,
  parameter   FE_ADDR_WIDTH     = 9  ,
  parameter   WT_ADDR_WIDTH     = 11 ,
  parameter   X_ADDR_WIDTH      = 10 ,
  parameter   Y_ADDR_WIDTH      = 10 ,
  parameter   XY_ADDR_WIDTH     = 10 ,
  parameter   P2S_OADDR_WIDTH   = 100,
  parameter   WIDTH_KSIZE       = 3  ,
  parameter   WIDTH_FEA_X       = 6  ,
  parameter   WIDTH_FEA_Y       = 6  ,
  parameter   Y_L234_DEPTH      = 64 ,
  parameter   X_L234_DEPTH      = 32 ,
  parameter   XY_L234_DEPTH     = 34 ,
  parameter   KNOB_REGOUT       = 0
)
(
  rst_n                ,
  clk                  ,
  //ctrl
  //input
  tile_switch          ,
  ctrl2sch_layer_start ,
  cnt_layer            ,
  tile_loc             ,
  ksize                ,
  pe2sch_rdy           ,
  tile_in_h            ,
  tile_out_h           ,
  tile_in_w            ,
  tile_out_w           ,
  tile_in_c            ,
  tile_out_c           ,
  model_switch         ,
  nn_proc              ,
  tile_tot_num_x       ,

  //output
  sch2fe_ren           ,
  sch2fe_raddr_0       ,
  sch2fe_raddr_1       ,
  sch2fe_raddr_2       ,
  sch2fe_raddr_3       ,
  sch2x_ren            ,
  sch2x_raddr_0        ,
  sch2x_raddr_1        ,
  sch2x_raddr_2        ,
  sch2x_raddr_3        ,
  wt_buf_rd_en         ,
  wt_buf_rd_addr       ,
  sch2y_ren            ,
  sch2y_raddr          ,
  sch2xy_evn_ren       ,
  sch2xy_odd_ren       ,
  sch2xy_raddr_evn     ,
  sch2xy_raddr_odd     ,

  sch2pe_row_start     ,
  sch2pe_row_done      ,
  sch2pe_vld_o         ,
  mux_col_vld_o        ,
  mux_row_vld_o        ,
  mux_array_vld_o      ,

  //data
  //input
  fe2sch_rdata_0_0     ,
  fe2sch_rdata_0_1     ,
  fe2sch_rdata_0_2     ,
  fe2sch_rdata_0_3     ,
  fe2sch_rdata_1_0     ,
  fe2sch_rdata_1_1     ,
  fe2sch_rdata_1_2     ,
  fe2sch_rdata_1_3     ,
  fe2sch_rdata_2_0     ,
  fe2sch_rdata_2_1     ,
  fe2sch_rdata_2_2     ,
  fe2sch_rdata_2_3     ,
  fe2sch_rdata_3_0     ,
  fe2sch_rdata_3_1     ,
  fe2sch_rdata_3_2     ,
  fe2sch_rdata_3_3     ,

  x2sch_rdata_0_0      ,
  x2sch_rdata_0_1      ,
  x2sch_rdata_0_2      ,
  x2sch_rdata_0_3      ,
  x2sch_rdata_1_0      ,
  x2sch_rdata_1_1      ,
  x2sch_rdata_1_2      ,
  x2sch_rdata_1_3      ,
  x2sch_rdata_2_0      ,
  x2sch_rdata_2_1      ,
  x2sch_rdata_2_2      ,
  x2sch_rdata_2_3      ,
  x2sch_rdata_3_0      ,
  x2sch_rdata_3_1      ,
  x2sch_rdata_3_2      ,
  x2sch_rdata_3_3      ,

  y2sch_rdata_0_0      ,
  y2sch_rdata_0_1      ,
  y2sch_rdata_0_2      ,
  y2sch_rdata_0_3      ,
  y2sch_rdata_1_0      ,
  y2sch_rdata_1_1      ,
  y2sch_rdata_1_2      ,
  y2sch_rdata_1_3      ,
  y2sch_rdata_2_0      ,
  y2sch_rdata_2_1      ,
  y2sch_rdata_2_2      ,
  y2sch_rdata_2_3      ,
  y2sch_rdata_3_0      ,
  y2sch_rdata_3_1      ,
  y2sch_rdata_3_2      ,
  y2sch_rdata_3_3      ,

  xy2sch_evn_rdata_0_0 ,
  xy2sch_evn_rdata_0_1 ,
  xy2sch_evn_rdata_0_2 ,
  xy2sch_evn_rdata_0_3 ,
  xy2sch_evn_rdata_1_0 ,
  xy2sch_evn_rdata_1_1 ,
  xy2sch_evn_rdata_1_2 ,
  xy2sch_evn_rdata_1_3 ,
  xy2sch_evn_rdata_2_0 ,
  xy2sch_evn_rdata_2_1 ,
  xy2sch_evn_rdata_2_2 ,
  xy2sch_evn_rdata_2_3 ,
  xy2sch_evn_rdata_3_0 ,
  xy2sch_evn_rdata_3_1 ,
  xy2sch_evn_rdata_3_2 ,
  xy2sch_evn_rdata_3_3 ,

  xy2sch_odd_rdata_0_0 ,
  xy2sch_odd_rdata_0_1 ,
  xy2sch_odd_rdata_0_2 ,
  xy2sch_odd_rdata_0_3 ,
  xy2sch_odd_rdata_1_0 ,
  xy2sch_odd_rdata_1_1 ,
  xy2sch_odd_rdata_1_2 ,
  xy2sch_odd_rdata_1_3 ,
  xy2sch_odd_rdata_2_0 ,
  xy2sch_odd_rdata_2_1 ,
  xy2sch_odd_rdata_2_2 ,
  xy2sch_odd_rdata_2_3 ,
  xy2sch_odd_rdata_3_0 ,
  xy2sch_odd_rdata_3_1 ,
  xy2sch_odd_rdata_3_2 ,
  xy2sch_odd_rdata_3_3 ,

  sch_weight_input_0_0 ,
  sch_weight_input_0_1 ,
  sch_weight_input_0_2 ,
  sch_weight_input_0_3 ,
  sch_weight_input_1_0 ,
  sch_weight_input_1_1 ,
  sch_weight_input_1_2 ,
  sch_weight_input_1_3 ,
  sch_weight_input_2_0 ,
  sch_weight_input_2_1 ,
  sch_weight_input_2_2 ,
  sch_weight_input_2_3 ,
  sch_weight_input_3_0 ,
  sch_weight_input_3_1 ,
  sch_weight_input_3_2 ,
  sch_weight_input_3_3 ,
  //output
  sch_data_output_0_0  ,
  sch_data_output_0_1  ,
  sch_data_output_0_2  ,
  sch_data_output_0_3  ,
  sch_data_output_1_0  ,
  sch_data_output_1_1  ,
  sch_data_output_1_2  ,
  sch_data_output_1_3  ,
  sch_data_output_2_0  ,
  sch_data_output_2_1  ,
  sch_data_output_2_2  ,
  sch_data_output_2_3  ,
  sch_data_output_3_0  ,
  sch_data_output_3_1  ,
  sch_data_output_3_2  ,
  sch_data_output_3_3  ,

  sch_weight_output_0_0,
  sch_weight_output_0_1,
  sch_weight_output_0_2,
  sch_weight_output_0_3,
  sch_weight_output_1_0,
  sch_weight_output_1_1,
  sch_weight_output_1_2,
  sch_weight_output_1_3,
  sch_weight_output_2_0,
  sch_weight_output_2_1,
  sch_weight_output_2_2,
  sch_weight_output_2_3,
  sch_weight_output_3_0,
  sch_weight_output_3_1,
  sch_weight_output_3_2,
  sch_weight_output_3_3
);

input                            clk                 ;
input                            rst_n               ;

input                            tile_switch         ;
input                            ctrl2sch_layer_start;
input      [2              : 0]  cnt_layer           ;
input      [3              : 0]  tile_loc            ;
input      [WIDTH_KSIZE - 1: 0]  ksize               ;
input                            pe2sch_rdy          ;
input      [REG_IH_WIDTH-1 : 0]  tile_in_h           ;
input      [REG_OH_WIDTH-1 : 0]  tile_out_h          ;
input      [REG_IW_WIDTH-1 : 0]  tile_in_w           ;
input      [REG_OW_WIDTH-1 : 0]  tile_out_w          ;
input      [REG_IC_WIDTH-1 : 0]  tile_in_c           ;
input      [REG_OC_WIDTH-1 : 0]  tile_out_c          ;
input                            model_switch        ;
input                            nn_proc             ;
input      [WIDTH_FEA_X -1 : 0]  tile_tot_num_x      ;

output     [3                 : 0]  sch2fe_ren       ;
output     [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_0   ;
output     [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_1   ;
output     [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_2   ;
output     [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_3   ;
output     [3                 : 0]  sch2x_ren        ;
output     [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_0    ;
output     [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_1    ;
output     [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_2    ;
output     [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_3    ;
output     [7                 : 0]  wt_buf_rd_en     ;
output     [WT_ADDR_WIDTH - 1 : 0]  wt_buf_rd_addr   ;
output     [3                 : 0]  sch2y_ren        ;
output     [Y_ADDR_WIDTH-1    : 0]  sch2y_raddr      ;
output     [3                 : 0]  sch2xy_evn_ren   ;
output     [3                 : 0]  sch2xy_odd_ren   ;
output     [XY_ADDR_WIDTH-1   : 0]  sch2xy_raddr_evn ;
output     [XY_ADDR_WIDTH-1   : 0]  sch2xy_raddr_odd ;

output                                      sch2pe_row_start;
output                                      sch2pe_row_done;
output                                      sch2pe_vld_o   ;
output     [PE_COL_NUM          - 1 : 0]    mux_col_vld_o  ;
output     [PE_H_NUM            - 1 : 0]    mux_row_vld_o  ;
output     [PE_IC_NUM           - 1 : 0]    mux_array_vld_o;

// interface with scheduler
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_0_0    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_0_1    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_0_2    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_0_3    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_1_0    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_1_1    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_1_2    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_1_3    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_2_0    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_2_1    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_2_2    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_2_3    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_3_0    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_3_1    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_3_2    ;
input  [FE_BUF_WIDTH                        - 1 : 0]    fe2sch_rdata_3_3    ;

input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_0_0     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_0_1     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_0_2     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_0_3     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_1_0     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_1_1     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_1_2     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_1_3     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_2_0     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_2_1     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_2_2     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_2_3     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_3_0     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_3_1     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_3_2     ;
input  [X_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    x2sch_rdata_3_3     ;

input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_0_0     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_0_1     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_0_2     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_0_3     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_1_0     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_1_1     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_1_2     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_1_3     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_2_0     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_2_1     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_2_2     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_2_3     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_3_0     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_3_1     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_3_2     ;
input  [Y_BUF_WIDTH * IFM_WIDTH             - 1 : 0]    y2sch_rdata_3_3     ;

input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_0_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_0_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_0_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_0_3;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_1_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_1_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_1_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_1_3;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_2_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_2_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_2_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_2_3;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_3_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_3_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_3_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_evn_rdata_3_3;

input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_0_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_0_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_0_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_0_3;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_1_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_1_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_1_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_1_3;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_2_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_2_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_2_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_2_3;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_3_0;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_3_1;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_3_2;
input  [XY_BUF_WIDTH * IFM_WIDTH            - 1 : 0]    xy2sch_odd_rdata_3_3;

input  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_0;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_1;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_2;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_3;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_0;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_1;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_2;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_3;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_0;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_1;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_2;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_3;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_0;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_1;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_2;
input  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_3;

// dat_o
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_0;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_1;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_2;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_3;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_0;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_1;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_2;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_3;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_0;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_1;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_2;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_3;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_0;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_1;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_2;
output [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_3;

output     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_0;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_1;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_2;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_3;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_0;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_1;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_2;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_3;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_0;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_1;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_2;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_3;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_0;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_1;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_2;
output     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_3;

reg        [3                       : 0]    yolp_rd_r            ;
reg        [3                       : 0]    xyolp_evn_rd_r       ;
reg        [3                       : 0]    xyolp_odd_rd_r       ;

reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_0_0_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_0_1_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_0_2_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_0_3_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_1_0_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_1_1_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_1_2_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_1_3_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_2_0_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_2_1_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_2_2_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_2_3_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_3_0_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_3_1_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_3_2_r;
reg        [Y_BUF_WIDTH * IFM_WIDTH         - 1 : 0]    sch_data_input_yolp_3_3_r;

reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_0_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_0_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_0_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_0_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_1_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_1_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_1_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_1_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_2_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_2_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_2_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_2_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_3_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_3_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_3_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_evn_3_3_r;

reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_0_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_0_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_0_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_0_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_1_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_1_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_1_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_1_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_2_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_2_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_2_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_2_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_3_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_3_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_3_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_odd_3_3_r;

reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_0_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_0_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_0_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_0_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_1_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_1_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_1_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_1_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_2_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_2_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_2_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_2_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_3_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_3_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_3_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_left_3_3_r;

reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_0_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_0_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_0_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_0_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_1_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_1_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_1_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_1_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_2_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_2_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_2_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_2_3_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_3_0_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_3_1_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_3_2_r;
reg        [XY_BUF_WIDTH * IFM_WIDTH        - 1 : 0]    sch_data_input_xyolp_right_3_3_r;

wire       [3                       : 0]    xyolp_left_w         ;

wire                             row_start     ;
wire                             row_done      ;
wire                             sch2pe_vld    ;
wire       [PE_COL_NUM - 1 : 0]  mux_col_vld   ;
wire       [PE_H_NUM - 1   : 0]  mux_row_vld   ;
wire       [PE_IC_NUM  - 1 : 0]  mux_array_vld ;
wire       [WIDTH_KSIZE -1 : 0]  cnt_ksize_w   ;
wire       [2              : 0]  cur_state_w   ;
wire                             tile_state_w  ;
wire       [2              : 0]  addr_offset   ;
wire                             wt_buf_rd_en_w;
wire                             olp_buf_rd_en ;

wire                                       sch2pe_row_start_w;
wire                                       sch2pe_row_done_w ;
wire                                       sch2pe_vld_w   ;
wire      [PE_COL_NUM          - 1 : 0]    mux_col_vld_w  ;
wire      [PE_H_NUM            - 1 : 0]    mux_row_vld_w  ;
wire      [PE_IC_NUM           - 1 : 0]    mux_array_vld_w;
wire      [3                       : 0]    sch2fe_ren_w   ;

reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_0;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_1;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_2;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_3;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_0;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_1;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_2;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_3;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_0;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_1;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_2;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_3;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_0;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_1;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_2;
reg   [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_3;

wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_0_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_1_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_2_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_3_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_0_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_1_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_2_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_3_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_0_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_1_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_2_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_3_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_0_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_1_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_2_w;
wire  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_3_w;

wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_0_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_1_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_2_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_3_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_0_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_1_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_2_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_3_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_0_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_1_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_2_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_3_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_0_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_1_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_2_w;
wire      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_3_w;

// ================================================================
// the signals syn to data & weight
// ================================================================
reg        [4           * (KNOB_REGOUT + 1) - 1 : 0]    sch2fe_ren_dly_r         ;
reg        [4           * (KNOB_REGOUT + 1) - 1 : 0]    sch2fe_ren_addr_if_dly_r ;
reg        [KNOB_REGOUT                         : 0]    wt_buf_ren_dly_r         ;
reg        [KNOB_REGOUT                         : 0]    olp_buf_ren_dly_r        ;
(* max_fanout = "256" *) reg        [4 * (KNOB_REGOUT + 1) - 1 : 0]    sch2y_ren_dly_r          ;
reg        [4           * (KNOB_REGOUT + 1) - 1 : 0]    sch2x_ren_dly_r          ;
reg        [4           * (KNOB_REGOUT + 1) - 1 : 0]    sch2xy_evn_ren_dly_r     ;
reg        [4           * (KNOB_REGOUT + 1) - 1 : 0]    sch2xy_odd_ren_dly_r     ;

(* max_fanout = "256" *) reg        [FE_ADDR_WIDTH * (KNOB_REGOUT + 1)      - 1 : 0]    sch2fe_raddr_0_dly_r     ;
(* max_fanout = "256" *) reg        [FE_ADDR_WIDTH * (KNOB_REGOUT + 1)      - 1 : 0]    sch2fe_raddr_1_dly_r     ;
(* max_fanout = "256" *) reg        [FE_ADDR_WIDTH * (KNOB_REGOUT + 1)      - 1 : 0]    sch2fe_raddr_2_dly_r     ;
(* max_fanout = "256" *) reg        [FE_ADDR_WIDTH * (KNOB_REGOUT + 1)      - 1 : 0]    sch2fe_raddr_3_dly_r     ;

reg        [KNOB_REGOUT                         : 0]    tile_state_dly_r         ;
reg        [KNOB_REGOUT                         : 0]    sch2pe_vld_dly_r         ;
reg        [PE_COL_NUM  * (KNOB_REGOUT + 1) - 1 : 0]    mux_col_vld_dly_r        ;
reg        [PE_H_NUM    * (KNOB_REGOUT + 1) - 1 : 0]    mux_row_vld_dly_r        ;
reg        [PE_IC_NUM   * (KNOB_REGOUT + 1) - 1 : 0]    mux_array_vld_dly_r      ;

reg        [KNOB_REGOUT                         : 0]    row_start_dly_r          ;
reg        [KNOB_REGOUT                         : 0]    row_done_dly_r           ;
reg        [WIDTH_KSIZE * (KNOB_REGOUT + 1) - 1 : 0]    cnt_ksize_dly_r          ;
reg        [3           * (KNOB_REGOUT + 1) - 1 : 0]    cur_state_dly_r          ;
reg        [3           * (KNOB_REGOUT + 1) - 1 : 0]    addr_offset_dly_r        ;

wire       [3                       : 0]    sch2fe_ren_syn_w         ;
wire       [3                       : 0]    sch2fe_ren_addr_if_syn_w         ;
wire                                        wt_buf_ren_syn_w         ;
wire                                        olp_buf_ren_syn_w        ;
(* max_fanout = "256" *) wire       [3                       : 0]    sch2y_ren_syn_w          ;
wire       [3                       : 0]    sch2x_ren_syn_w          ;
wire       [3                       : 0]    sch2xy_evn_ren_syn_w     ;
wire       [3                       : 0]    sch2xy_odd_ren_syn_w     ;

wire       [FE_ADDR_WIDTH       - 1 : 0]    sch2fe_raddr_0_syn_w     ;
wire       [FE_ADDR_WIDTH       - 1 : 0]    sch2fe_raddr_1_syn_w     ;
wire       [FE_ADDR_WIDTH       - 1 : 0]    sch2fe_raddr_2_syn_w     ;
wire       [FE_ADDR_WIDTH       - 1 : 0]    sch2fe_raddr_3_syn_w     ;

wire                                        tile_state_syn_w       ;
wire                                        sch2pe_vld_syn_w       ;
wire       [PE_COL_NUM          - 1 : 0]    mux_col_vld_syn_w      ;
wire       [PE_H_NUM            - 1 : 0]    mux_row_vld_syn_w      ;
wire       [PE_IC_NUM           - 1 : 0]    mux_array_vld_syn_w    ;

wire                                        row_start_syn_w        ;
wire                                        row_done_syn_w         ;
wire       [WIDTH_KSIZE         - 1 : 0]    cnt_ksize_syn_w        ;
wire       [2                       : 0]    cur_state_syn_w        ;
wire       [2                       : 0]    addr_offset_syn_w      ;

wire       [REG_IH_WIDTH        - 2 : 0]    cnt_y                  ;
wire       [REG_OH_WIDTH        - 2 : 0]    num_y                  ;
wire       [REG_IH_WIDTH            : 0]    tile_out_h_w           ;
wire       [REG_IC_WIDTH        - 2 : 0]    cnt_curf               ;

addr_if #(
  .REG_IH_WIDTH          (REG_IH_WIDTH         ),
  .REG_IW_WIDTH          (REG_IW_WIDTH         ),
  .REG_IC_WIDTH          (REG_IC_WIDTH         ),
  .REG_OH_WIDTH          (REG_OH_WIDTH         ),
  .REG_OW_WIDTH          (REG_OW_WIDTH         ),
  .REG_OC_WIDTH          (REG_OC_WIDTH         ),
  .IFM_WIDTH             (IFM_WIDTH            ),
  .SCH_COL_NUM           (SCH_COL_NUM          ),
  .WT_WIDTH              (WT_WIDTH             ),
  .PE_COL_NUM            (PE_COL_NUM           ),
  .PE_H_NUM              (PE_H_NUM             ),
  .PE_IC_NUM             (PE_IC_NUM            ),
  .PE_OC_NUM             (PE_OC_NUM            ),
  .FE_ADDR_WIDTH         (FE_ADDR_WIDTH        ),
  .WT_ADDR_WIDTH         (WT_ADDR_WIDTH        ),
  .X_ADDR_WIDTH          (X_ADDR_WIDTH         ),
  .Y_ADDR_WIDTH          (Y_ADDR_WIDTH         ),
  .XY_ADDR_WIDTH         (XY_ADDR_WIDTH        ),
  .P2S_OADDR_WIDTH       (P2S_OADDR_WIDTH      ),
  .WIDTH_KSIZE           (WIDTH_KSIZE          ),
  .WIDTH_FEA_X           (WIDTH_FEA_X          ),
  .WIDTH_FEA_Y           (WIDTH_FEA_Y          ),
  .Y_L234_DEPTH          (Y_L234_DEPTH         ),
  .X_L234_DEPTH          (X_L234_DEPTH         ),
  .XY_L234_DEPTH         (XY_L234_DEPTH        )
)
u0_addr_if
(
  .rst_n                 (rst_n                ),
  .clk                   (clk                  ),

  // ctrl_i
  .tile_switch           (tile_switch          ),
  .ctrl2sch_layer_start  (ctrl2sch_layer_start ),
  .cnt_layer             (cnt_layer            ),
  .tile_loc              (tile_loc             ),
  .ksize                 (ksize                ),
  .pe2sch_rdy            (pe2sch_rdy           ),
  .tile_in_h             (tile_in_h            ),
  .tile_out_h            (tile_out_h           ),
  .tile_in_w             (tile_in_w            ),
  .tile_out_w            (tile_out_w           ),
  .tile_in_c             (tile_in_c            ),
  .tile_out_c            (tile_out_c           ),
  .model_switch          (model_switch         ),
  .nn_proc               (nn_proc              ),
  .tile_tot_num_x        (tile_tot_num_x       ),

  //buffer rd
  .sch2fe_ren            (sch2fe_ren_w         ),
  .sch2fe_raddr_0        (sch2fe_raddr_0       ),
  .sch2fe_raddr_1        (sch2fe_raddr_1       ),
  .sch2fe_raddr_2        (sch2fe_raddr_2       ),
  .sch2fe_raddr_3        (sch2fe_raddr_3       ),
  .sch2x_raddr_0         (sch2x_raddr_0        ),
  .sch2x_raddr_1         (sch2x_raddr_1        ),
  .sch2x_raddr_2         (sch2x_raddr_2        ),
  .sch2x_raddr_3         (sch2x_raddr_3        ),
  .wt_buf_rd_en          (wt_buf_rd_en         ),
  .wt_buf_rd_addr        (wt_buf_rd_addr       ),
  .sch2y_ren             (sch2y_ren            ),
  .sch2y_raddr           (sch2y_raddr          ),
  .sch2xy_evn_ren        (sch2xy_evn_ren       ),
  .sch2xy_odd_ren        (sch2xy_odd_ren       ),
  .sch2xy_raddr_evn      (sch2xy_raddr_evn     ),
  .sch2xy_raddr_odd      (sch2xy_raddr_odd     ),

  .row_start             (row_start            ),
  .row_done              (row_done             ),
//  .sch2pe_vld            (sch2pe_vld           ),
//  .mux_col_vld           (mux_col_vld          ),
//  .mux_row_vld           (mux_row_vld          ),
//  .mux_array_vld         (mux_array_vld        ),
  .cnt_ksize             (cnt_ksize_w          ),
  .cur_state_o           (cur_state_w          ),
  .tile_state_o          (tile_state_w         ),
  .addr_offset           (addr_offset          ),
  .cnt_y_o               (cnt_y                ),
  .num_y_o               (num_y                ),
  .tile_out_h_w_o        (tile_out_h_w         ),
  .cnt_curf_o            (cnt_curf             )
);

sche_sub #(
  .REG_IW_WIDTH          (REG_IW_WIDTH         ),
  .IFM_WIDTH             (IFM_WIDTH            ),
  .SCH_COL_NUM           (SCH_COL_NUM          ),
  .WT_WIDTH              (WT_WIDTH             ),
  .PE_COL_NUM            (PE_COL_NUM           ),
  .PE_H_NUM              (PE_H_NUM             ),
  .PE_IC_NUM             (PE_IC_NUM            ),
  .PE_OC_NUM             (PE_OC_NUM            ),
  .WIDTH_KSIZE           (WIDTH_KSIZE          )
)
u0_sche_sub
(
  .clk                   (clk                  ),
  .rst_n                 (rst_n                ),
  .sch_data_input_0_0    (sch_data_input_0_0   ),
  .sch_data_input_0_1    (sch_data_input_0_1   ),
  .sch_data_input_0_2    (sch_data_input_0_2   ),
  .sch_data_input_0_3    (sch_data_input_0_3   ),
  .sch_data_input_1_0    (sch_data_input_1_0   ),
  .sch_data_input_1_1    (sch_data_input_1_1   ),
  .sch_data_input_1_2    (sch_data_input_1_2   ),
  .sch_data_input_1_3    (sch_data_input_1_3   ),
  .sch_data_input_2_0    (sch_data_input_2_0   ),
  .sch_data_input_2_1    (sch_data_input_2_1   ),
  .sch_data_input_2_2    (sch_data_input_2_2   ),
  .sch_data_input_2_3    (sch_data_input_2_3   ),
  .sch_data_input_3_0    (sch_data_input_3_0   ),
  .sch_data_input_3_1    (sch_data_input_3_1   ),
  .sch_data_input_3_2    (sch_data_input_3_2   ),
  .sch_data_input_3_3    (sch_data_input_3_3   ),

  .sch_weight_input_0_0  (sch_weight_input_0_0 ),
  .sch_weight_input_0_1  (sch_weight_input_0_1 ),
  .sch_weight_input_0_2  (sch_weight_input_0_2 ),
  .sch_weight_input_0_3  (sch_weight_input_0_3 ),
  .sch_weight_input_1_0  (sch_weight_input_1_0 ),
  .sch_weight_input_1_1  (sch_weight_input_1_1 ),
  .sch_weight_input_1_2  (sch_weight_input_1_2 ),
  .sch_weight_input_1_3  (sch_weight_input_1_3 ),
  .sch_weight_input_2_0  (sch_weight_input_2_0 ),
  .sch_weight_input_2_1  (sch_weight_input_2_1 ),
  .sch_weight_input_2_2  (sch_weight_input_2_2 ),
  .sch_weight_input_2_3  (sch_weight_input_2_3 ),
  .sch_weight_input_3_0  (sch_weight_input_3_0 ),
  .sch_weight_input_3_1  (sch_weight_input_3_1 ),
  .sch_weight_input_3_2  (sch_weight_input_3_2 ),
  .sch_weight_input_3_3  (sch_weight_input_3_3 ),

  .sch_data_output_0_0   (sch_data_output_0_0_w),
  .sch_data_output_0_1   (sch_data_output_0_1_w),
  .sch_data_output_0_2   (sch_data_output_0_2_w),
  .sch_data_output_0_3   (sch_data_output_0_3_w),
  .sch_data_output_1_0   (sch_data_output_1_0_w),
  .sch_data_output_1_1   (sch_data_output_1_1_w),
  .sch_data_output_1_2   (sch_data_output_1_2_w),
  .sch_data_output_1_3   (sch_data_output_1_3_w),
  .sch_data_output_2_0   (sch_data_output_2_0_w),
  .sch_data_output_2_1   (sch_data_output_2_1_w),
  .sch_data_output_2_2   (sch_data_output_2_2_w),
  .sch_data_output_2_3   (sch_data_output_2_3_w),
  .sch_data_output_3_0   (sch_data_output_3_0_w),
  .sch_data_output_3_1   (sch_data_output_3_1_w),
  .sch_data_output_3_2   (sch_data_output_3_2_w),
  .sch_data_output_3_3   (sch_data_output_3_3_w),

  .sch_weight_output_0_0 (sch_weight_output_0_0_w),
  .sch_weight_output_0_1 (sch_weight_output_0_1_w),
  .sch_weight_output_0_2 (sch_weight_output_0_2_w),
  .sch_weight_output_0_3 (sch_weight_output_0_3_w),
  .sch_weight_output_1_0 (sch_weight_output_1_0_w),
  .sch_weight_output_1_1 (sch_weight_output_1_1_w),
  .sch_weight_output_1_2 (sch_weight_output_1_2_w),
  .sch_weight_output_1_3 (sch_weight_output_1_3_w),
  .sch_weight_output_2_0 (sch_weight_output_2_0_w),
  .sch_weight_output_2_1 (sch_weight_output_2_1_w),
  .sch_weight_output_2_2 (sch_weight_output_2_2_w),
  .sch_weight_output_2_3 (sch_weight_output_2_3_w),
  .sch_weight_output_3_0 (sch_weight_output_3_0_w),
  .sch_weight_output_3_1 (sch_weight_output_3_1_w),
  .sch_weight_output_3_2 (sch_weight_output_3_2_w),
  .sch_weight_output_3_3 (sch_weight_output_3_3_w),

  .pe2sch_rdy            (pe2sch_rdy           ),
  .tile_loc              (tile_loc             ),
  .ksize                 (ksize                ),
  .sch2fe_ren_dly_syn_i  (sch2fe_ren_addr_if_syn_w),
  .wt_buf_ren_dly_syn_i  (wt_buf_ren_syn_w     ),
  .olp_bufren_dly_syn_i  (olp_buf_ren_syn_w    ),
  .tile_in_w             (tile_in_w            ),

  .sch2pe_row_start      (sch2pe_row_start_w   ),
  .sch2pe_row_done       (sch2pe_row_done_w    ),
  .sch2pe_vld_o          (sch2pe_vld_w         ),
  .mux_col_vld_o         (mux_col_vld_w        ),
  .mux_row_vld_o         (mux_row_vld_w        ),
  .mux_array_vld_o       (mux_array_vld_w      ),

// interface with addr_if
  .row_start_dly_syn_i   (row_start_syn_w      ),
  .row_done_dly_syn_i    (row_done_syn_w       ),
  .sch2pe_vld_dly_syn_i  (sch2pe_vld_syn_w     ),
  .mux_col_vld_dly_syn_i (mux_col_vld_syn_w    ),
  .mux_row_vld_dly_syn_i (mux_row_vld_syn_w    ),
  .mux_array_vld_dly_syn_i(mux_array_vld_syn_w  ),
  .cnt_ksize_dly_syn_i(cnt_ksize_syn_w     ),
  .cur_state_dly_syn_i   (cur_state_syn_w      ),
  .addr_offset_dly_syn_i (addr_offset_syn_w    )
);

handshake_sche2pe#(
  .PE_COL_NUM   (PE_COL_NUM) ,
  .PE_H_NUM     (PE_H_NUM  ) ,
  .PE_IC_NUM    (PE_IC_NUM ) ,
  .IFM_WIDTH    (IFM_WIDTH ) ,
  .WT_WIDTH     (WT_WIDTH  )
)
u0_hanshake_sche2pe
(
  .clk                   (clk                  ),
  .rst_n                 (rst_n                ),
  .pe2sch_rdy            (pe2sch_rdy           ),

  .sch2pe_row_start_i    (sch2pe_row_start_w   ),
  .sch2pe_row_done_i     (sch2pe_row_done_w    ),
  .sch2pe_vld_i          (sch2pe_vld_w         ),
  .mux_col_vld_i         (mux_col_vld_w        ),
  .mux_row_vld_i         (mux_row_vld_w        ),
  .mux_array_vld_i       (mux_array_vld_w      ),

  .sch_data_output_0_0_i (sch_data_output_0_0_w),
  .sch_data_output_0_1_i (sch_data_output_0_1_w),
  .sch_data_output_0_2_i (sch_data_output_0_2_w),
  .sch_data_output_0_3_i (sch_data_output_0_3_w),
  .sch_data_output_1_0_i (sch_data_output_1_0_w),
  .sch_data_output_1_1_i (sch_data_output_1_1_w),
  .sch_data_output_1_2_i (sch_data_output_1_2_w),
  .sch_data_output_1_3_i (sch_data_output_1_3_w),
  .sch_data_output_2_0_i (sch_data_output_2_0_w),
  .sch_data_output_2_1_i (sch_data_output_2_1_w),
  .sch_data_output_2_2_i (sch_data_output_2_2_w),
  .sch_data_output_2_3_i (sch_data_output_2_3_w),
  .sch_data_output_3_0_i (sch_data_output_3_0_w),
  .sch_data_output_3_1_i (sch_data_output_3_1_w),
  .sch_data_output_3_2_i (sch_data_output_3_2_w),
  .sch_data_output_3_3_i (sch_data_output_3_3_w),

  .sch_weight_output_0_0_i (sch_weight_output_0_0_w),
  .sch_weight_output_0_1_i (sch_weight_output_0_1_w),
  .sch_weight_output_0_2_i (sch_weight_output_0_2_w),
  .sch_weight_output_0_3_i (sch_weight_output_0_3_w),
  .sch_weight_output_1_0_i (sch_weight_output_1_0_w),
  .sch_weight_output_1_1_i (sch_weight_output_1_1_w),
  .sch_weight_output_1_2_i (sch_weight_output_1_2_w),
  .sch_weight_output_1_3_i (sch_weight_output_1_3_w),
  .sch_weight_output_2_0_i (sch_weight_output_2_0_w),
  .sch_weight_output_2_1_i (sch_weight_output_2_1_w),
  .sch_weight_output_2_2_i (sch_weight_output_2_2_w),
  .sch_weight_output_2_3_i (sch_weight_output_2_3_w),
  .sch_weight_output_3_0_i (sch_weight_output_3_0_w),
  .sch_weight_output_3_1_i (sch_weight_output_3_1_w),
  .sch_weight_output_3_2_i (sch_weight_output_3_2_w),
  .sch_weight_output_3_3_i (sch_weight_output_3_3_w),

  .sch2pe_row_start_o    (sch2pe_row_start     ),
  .sch2pe_row_done_o     (sch2pe_row_done      ),
  .sch2pe_vld_o          (sch2pe_vld_o         ),
  .mux_col_vld_o         (mux_col_vld_o        ),
  .mux_row_vld_o         (mux_row_vld_o        ),
  .mux_array_vld_o       (mux_array_vld_o      ),

  .sch_data_output_0_0_o (sch_data_output_0_0  ),
  .sch_data_output_0_1_o (sch_data_output_0_1  ),
  .sch_data_output_0_2_o (sch_data_output_0_2  ),
  .sch_data_output_0_3_o (sch_data_output_0_3  ),
  .sch_data_output_1_0_o (sch_data_output_1_0  ),
  .sch_data_output_1_1_o (sch_data_output_1_1  ),
  .sch_data_output_1_2_o (sch_data_output_1_2  ),
  .sch_data_output_1_3_o (sch_data_output_1_3  ),
  .sch_data_output_2_0_o (sch_data_output_2_0  ),
  .sch_data_output_2_1_o (sch_data_output_2_1  ),
  .sch_data_output_2_2_o (sch_data_output_2_2  ),
  .sch_data_output_2_3_o (sch_data_output_2_3  ),
  .sch_data_output_3_0_o (sch_data_output_3_0  ),
  .sch_data_output_3_1_o (sch_data_output_3_1  ),
  .sch_data_output_3_2_o (sch_data_output_3_2  ),
  .sch_data_output_3_3_o (sch_data_output_3_3  ),

  .sch_weight_output_0_0_o (sch_weight_output_0_0),
  .sch_weight_output_0_1_o (sch_weight_output_0_1),
  .sch_weight_output_0_2_o (sch_weight_output_0_2),
  .sch_weight_output_0_3_o (sch_weight_output_0_3),
  .sch_weight_output_1_0_o (sch_weight_output_1_0),
  .sch_weight_output_1_1_o (sch_weight_output_1_1),
  .sch_weight_output_1_2_o (sch_weight_output_1_2),
  .sch_weight_output_1_3_o (sch_weight_output_1_3),
  .sch_weight_output_2_0_o (sch_weight_output_2_0),
  .sch_weight_output_2_1_o (sch_weight_output_2_1),
  .sch_weight_output_2_2_o (sch_weight_output_2_2),
  .sch_weight_output_2_3_o (sch_weight_output_2_3),
  .sch_weight_output_3_0_o (sch_weight_output_3_0),
  .sch_weight_output_3_1_o (sch_weight_output_3_1),
  .sch_weight_output_3_2_o (sch_weight_output_3_2),
  .sch_weight_output_3_3_o (sch_weight_output_3_3)
);

assign wt_buf_rd_en_w = |wt_buf_rd_en;

assign olp_buf_rd_en = (sch2y_ren != 0) || (sch2xy_evn_ren != 0) || (sch2xy_odd_ren != 0);

assign sch2x_ren = sch2fe_ren;

// the logic between buf and sche
assign sch2fe_ren[3] = sch2fe_ren_w[3] ? (&sch2fe_raddr_0 == 1'b1 ? 0 : 1) : 0;
assign sch2fe_ren[2] = sch2fe_ren_w[2] ? (&sch2fe_raddr_1 == 1'b1 ? 0 : 1) : 0;
assign sch2fe_ren[1] = sch2fe_ren_w[1] ? (&sch2fe_raddr_2 == 1'b1 ? 0 : 1) : 0;
assign sch2fe_ren[0] = sch2fe_ren_w[0] ? (&sch2fe_raddr_3 == 1'b1 ? 0 : 1) : 0;

always @(*)
begin
  case(sch2y_ren_syn_w)
    4'b1111: yolp_rd_r = 4'b1111;
    4'b0011, 4'b1100: yolp_rd_r = 4'b0011;
    default: yolp_rd_r = 4'b0000;
  endcase
end

always @(*)
begin
  case(sch2xy_evn_ren_syn_w)
    4'b1111: xyolp_evn_rd_r = 4'b1111;
    4'b0011, 4'b1100: xyolp_evn_rd_r = 4'b0011;
    default: xyolp_evn_rd_r = 4'b0000;
  endcase
end

always @(*)
begin
  case(sch2xy_odd_ren_syn_w)
    4'b1111: xyolp_odd_rd_r = 4'b1111;
    4'b0011, 4'b1100: xyolp_odd_rd_r = 4'b0011;
    default: xyolp_odd_rd_r = 4'b0000;
  endcase
end

assign xyolp_left_w = tile_state_syn_w == 0 ? xyolp_odd_rd_r : xyolp_evn_rd_r;

always @(*)
begin
  sch_data_input_yolp_0_0_r = (sch2y_ren_syn_w[3] & yolp_rd_r[3]) ? y2sch_rdata_0_0 : -128;
  sch_data_input_yolp_0_1_r = (sch2y_ren_syn_w[2] & yolp_rd_r[2]) ? y2sch_rdata_0_1 : -128;
  sch_data_input_yolp_0_2_r = (sch2y_ren_syn_w[1] & yolp_rd_r[1]) ? y2sch_rdata_0_2 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_0_0 : -128);
  sch_data_input_yolp_0_3_r = (sch2y_ren_syn_w[0] & yolp_rd_r[0]) ? y2sch_rdata_0_3 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_0_1 : -128);
  sch_data_input_yolp_1_0_r = (sch2y_ren_syn_w[3] & yolp_rd_r[3]) ? y2sch_rdata_1_0 : -128;
  sch_data_input_yolp_1_1_r = (sch2y_ren_syn_w[2] & yolp_rd_r[2]) ? y2sch_rdata_1_1 : -128;
  sch_data_input_yolp_1_2_r = (sch2y_ren_syn_w[1] & yolp_rd_r[1]) ? y2sch_rdata_1_2 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_1_0 : -128);
  sch_data_input_yolp_1_3_r = (sch2y_ren_syn_w[0] & yolp_rd_r[0]) ? y2sch_rdata_1_3 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_1_1 : -128);
  sch_data_input_yolp_2_0_r = (sch2y_ren_syn_w[3] & yolp_rd_r[3]) ? y2sch_rdata_2_0 : -128;
  sch_data_input_yolp_2_1_r = (sch2y_ren_syn_w[2] & yolp_rd_r[2]) ? y2sch_rdata_2_1 : -128;
  sch_data_input_yolp_2_2_r = (sch2y_ren_syn_w[1] & yolp_rd_r[1]) ? y2sch_rdata_2_2 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_2_0 : -128);
  sch_data_input_yolp_2_3_r = (sch2y_ren_syn_w[0] & yolp_rd_r[0]) ? y2sch_rdata_2_3 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_2_1 : -128);
  sch_data_input_yolp_3_0_r = (sch2y_ren_syn_w[3] & yolp_rd_r[3]) ? y2sch_rdata_3_0 : -128;
  sch_data_input_yolp_3_1_r = (sch2y_ren_syn_w[2] & yolp_rd_r[2]) ? y2sch_rdata_3_1 : -128;
  sch_data_input_yolp_3_2_r = (sch2y_ren_syn_w[1] & yolp_rd_r[1]) ? y2sch_rdata_3_2 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_3_0 : -128);
  sch_data_input_yolp_3_3_r = (sch2y_ren_syn_w[0] & yolp_rd_r[0]) ? y2sch_rdata_3_3 : (sch2y_ren_syn_w == 4'b1100 ? y2sch_rdata_3_1 : -128);
end

always @(*)
begin
  sch_data_input_xyolp_evn_0_0_r = (sch2xy_evn_ren_syn_w[3] & xyolp_evn_rd_r[3]) ? xy2sch_evn_rdata_0_0 : -128;
  sch_data_input_xyolp_evn_0_1_r = (sch2xy_evn_ren_syn_w[2] & xyolp_evn_rd_r[2]) ? xy2sch_evn_rdata_0_1 : -128;
  sch_data_input_xyolp_evn_0_2_r = (sch2xy_evn_ren_syn_w[1] & xyolp_evn_rd_r[1]) ? xy2sch_evn_rdata_0_2 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_0_0 : -128);
  sch_data_input_xyolp_evn_0_3_r = (sch2xy_evn_ren_syn_w[0] & xyolp_evn_rd_r[0]) ? xy2sch_evn_rdata_0_3 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_0_1 : -128);
  sch_data_input_xyolp_evn_1_0_r = (sch2xy_evn_ren_syn_w[3] & xyolp_evn_rd_r[3]) ? xy2sch_evn_rdata_1_0 : -128;
  sch_data_input_xyolp_evn_1_1_r = (sch2xy_evn_ren_syn_w[2] & xyolp_evn_rd_r[2]) ? xy2sch_evn_rdata_1_1 : -128;
  sch_data_input_xyolp_evn_1_2_r = (sch2xy_evn_ren_syn_w[1] & xyolp_evn_rd_r[1]) ? xy2sch_evn_rdata_1_2 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_1_0 : -128);
  sch_data_input_xyolp_evn_1_3_r = (sch2xy_evn_ren_syn_w[0] & xyolp_evn_rd_r[0]) ? xy2sch_evn_rdata_1_3 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_1_1 : -128);
  sch_data_input_xyolp_evn_2_0_r = (sch2xy_evn_ren_syn_w[3] & xyolp_evn_rd_r[3]) ? xy2sch_evn_rdata_2_0 : -128;
  sch_data_input_xyolp_evn_2_1_r = (sch2xy_evn_ren_syn_w[2] & xyolp_evn_rd_r[2]) ? xy2sch_evn_rdata_2_1 : -128;
  sch_data_input_xyolp_evn_2_2_r = (sch2xy_evn_ren_syn_w[1] & xyolp_evn_rd_r[1]) ? xy2sch_evn_rdata_2_2 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_2_0 : -128);
  sch_data_input_xyolp_evn_2_3_r = (sch2xy_evn_ren_syn_w[0] & xyolp_evn_rd_r[0]) ? xy2sch_evn_rdata_2_3 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_2_1 : -128);
  sch_data_input_xyolp_evn_3_0_r = (sch2xy_evn_ren_syn_w[3] & xyolp_evn_rd_r[3]) ? xy2sch_evn_rdata_3_0 : -128;
  sch_data_input_xyolp_evn_3_1_r = (sch2xy_evn_ren_syn_w[2] & xyolp_evn_rd_r[2]) ? xy2sch_evn_rdata_3_1 : -128;
  sch_data_input_xyolp_evn_3_2_r = (sch2xy_evn_ren_syn_w[1] & xyolp_evn_rd_r[1]) ? xy2sch_evn_rdata_3_2 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_3_0 : -128);
  sch_data_input_xyolp_evn_3_3_r = (sch2xy_evn_ren_syn_w[0] & xyolp_evn_rd_r[0]) ? xy2sch_evn_rdata_3_3 : (sch2xy_evn_ren_syn_w == 4'b1100 ? xy2sch_evn_rdata_3_1 : -128);
end

always @(*)
begin
  sch_data_input_xyolp_odd_0_0_r = (sch2xy_odd_ren_syn_w[3] & xyolp_odd_rd_r[3]) ? xy2sch_odd_rdata_0_0 : -128;
  sch_data_input_xyolp_odd_0_1_r = (sch2xy_odd_ren_syn_w[2] & xyolp_odd_rd_r[2]) ? xy2sch_odd_rdata_0_1 : -128;
  sch_data_input_xyolp_odd_0_2_r = (sch2xy_odd_ren_syn_w[1] & xyolp_odd_rd_r[1]) ? xy2sch_odd_rdata_0_2 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_0_0 : -128);
  sch_data_input_xyolp_odd_0_3_r = (sch2xy_odd_ren_syn_w[0] & xyolp_odd_rd_r[0]) ? xy2sch_odd_rdata_0_3 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_0_1 : -128);
  sch_data_input_xyolp_odd_1_0_r = (sch2xy_odd_ren_syn_w[3] & xyolp_odd_rd_r[3]) ? xy2sch_odd_rdata_1_0 : -128;
  sch_data_input_xyolp_odd_1_1_r = (sch2xy_odd_ren_syn_w[2] & xyolp_odd_rd_r[2]) ? xy2sch_odd_rdata_1_1 : -128;
  sch_data_input_xyolp_odd_1_2_r = (sch2xy_odd_ren_syn_w[1] & xyolp_odd_rd_r[1]) ? xy2sch_odd_rdata_1_2 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_1_0 : -128);
  sch_data_input_xyolp_odd_1_3_r = (sch2xy_odd_ren_syn_w[0] & xyolp_odd_rd_r[0]) ? xy2sch_odd_rdata_1_3 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_1_1 : -128);
  sch_data_input_xyolp_odd_2_0_r = (sch2xy_odd_ren_syn_w[3] & xyolp_odd_rd_r[3]) ? xy2sch_odd_rdata_2_0 : -128;
  sch_data_input_xyolp_odd_2_1_r = (sch2xy_odd_ren_syn_w[2] & xyolp_odd_rd_r[2]) ? xy2sch_odd_rdata_2_1 : -128;
  sch_data_input_xyolp_odd_2_2_r = (sch2xy_odd_ren_syn_w[1] & xyolp_odd_rd_r[1]) ? xy2sch_odd_rdata_2_2 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_2_0 : -128);
  sch_data_input_xyolp_odd_2_3_r = (sch2xy_odd_ren_syn_w[0] & xyolp_odd_rd_r[0]) ? xy2sch_odd_rdata_2_3 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_2_1 : -128);
  sch_data_input_xyolp_odd_3_0_r = (sch2xy_odd_ren_syn_w[3] & xyolp_odd_rd_r[3]) ? xy2sch_odd_rdata_3_0 : -128;
  sch_data_input_xyolp_odd_3_1_r = (sch2xy_odd_ren_syn_w[2] & xyolp_odd_rd_r[2]) ? xy2sch_odd_rdata_3_1 : -128;
  sch_data_input_xyolp_odd_3_2_r = (sch2xy_odd_ren_syn_w[1] & xyolp_odd_rd_r[1]) ? xy2sch_odd_rdata_3_2 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_3_0 : -128);
  sch_data_input_xyolp_odd_3_3_r = (sch2xy_odd_ren_syn_w[0] & xyolp_odd_rd_r[0]) ? xy2sch_odd_rdata_3_3 : (sch2xy_odd_ren_syn_w == 4'b1100 ? xy2sch_odd_rdata_3_1 : -128);
end

always @(*)
begin
  sch_data_input_xyolp_left_0_0_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_0_0_r : sch_data_input_xyolp_evn_0_0_r;
  sch_data_input_xyolp_left_0_1_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_0_1_r : sch_data_input_xyolp_evn_0_1_r;
  sch_data_input_xyolp_left_0_2_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_0_2_r : sch_data_input_xyolp_evn_0_2_r;
  sch_data_input_xyolp_left_0_3_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_0_3_r : sch_data_input_xyolp_evn_0_3_r;
  sch_data_input_xyolp_left_1_0_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_1_0_r : sch_data_input_xyolp_evn_1_0_r;
  sch_data_input_xyolp_left_1_1_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_1_1_r : sch_data_input_xyolp_evn_1_1_r;
  sch_data_input_xyolp_left_1_2_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_1_2_r : sch_data_input_xyolp_evn_1_2_r;
  sch_data_input_xyolp_left_1_3_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_1_3_r : sch_data_input_xyolp_evn_1_3_r;
  sch_data_input_xyolp_left_2_0_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_2_0_r : sch_data_input_xyolp_evn_2_0_r;
  sch_data_input_xyolp_left_2_1_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_2_1_r : sch_data_input_xyolp_evn_2_1_r;
  sch_data_input_xyolp_left_2_2_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_2_2_r : sch_data_input_xyolp_evn_2_2_r;
  sch_data_input_xyolp_left_2_3_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_2_3_r : sch_data_input_xyolp_evn_2_3_r;
  sch_data_input_xyolp_left_3_0_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_3_0_r : sch_data_input_xyolp_evn_3_0_r;
  sch_data_input_xyolp_left_3_1_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_3_1_r : sch_data_input_xyolp_evn_3_1_r;
  sch_data_input_xyolp_left_3_2_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_3_2_r : sch_data_input_xyolp_evn_3_2_r;
  sch_data_input_xyolp_left_3_3_r = tile_state_syn_w == 0 ? sch_data_input_xyolp_odd_3_3_r : sch_data_input_xyolp_evn_3_3_r;
end

always @(*)
begin
  sch_data_input_xyolp_right_0_0_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_0_0_r : sch_data_input_xyolp_evn_0_0_r;
  sch_data_input_xyolp_right_0_1_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_0_1_r : sch_data_input_xyolp_evn_0_1_r;
  sch_data_input_xyolp_right_0_2_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_0_2_r : sch_data_input_xyolp_evn_0_2_r;
  sch_data_input_xyolp_right_0_3_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_0_3_r : sch_data_input_xyolp_evn_0_3_r;
  sch_data_input_xyolp_right_1_0_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_1_0_r : sch_data_input_xyolp_evn_1_0_r;
  sch_data_input_xyolp_right_1_1_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_1_1_r : sch_data_input_xyolp_evn_1_1_r;
  sch_data_input_xyolp_right_1_2_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_1_2_r : sch_data_input_xyolp_evn_1_2_r;
  sch_data_input_xyolp_right_1_3_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_1_3_r : sch_data_input_xyolp_evn_1_3_r;
  sch_data_input_xyolp_right_2_0_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_2_0_r : sch_data_input_xyolp_evn_2_0_r;
  sch_data_input_xyolp_right_2_1_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_2_1_r : sch_data_input_xyolp_evn_2_1_r;
  sch_data_input_xyolp_right_2_2_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_2_2_r : sch_data_input_xyolp_evn_2_2_r;
  sch_data_input_xyolp_right_2_3_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_2_3_r : sch_data_input_xyolp_evn_2_3_r;
  sch_data_input_xyolp_right_3_0_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_3_0_r : sch_data_input_xyolp_evn_3_0_r;
  sch_data_input_xyolp_right_3_1_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_3_1_r : sch_data_input_xyolp_evn_3_1_r;
  sch_data_input_xyolp_right_3_2_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_3_2_r : sch_data_input_xyolp_evn_3_2_r;
  sch_data_input_xyolp_right_3_3_r = tile_state_syn_w == 1 ? sch_data_input_xyolp_odd_3_3_r : sch_data_input_xyolp_evn_3_3_r;
end

always @(*)
begin
    sch_data_input_0_0[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[3] == 1 ? {sch_data_input_yolp_0_0_r , sch_data_input_xyolp_right_0_0_r} :
                         (sch2fe_ren_syn_w[3] ? (&sch2fe_raddr_0_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_0_0) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_0_1[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[2] == 1 ? {sch_data_input_yolp_0_1_r , sch_data_input_xyolp_right_0_1_r} :
                         (sch2fe_ren_syn_w[2] ? (&sch2fe_raddr_1_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_0_1) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_0_2[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[1] == 1 ? {sch_data_input_yolp_0_2_r , sch_data_input_xyolp_right_0_2_r} :
                         (sch2fe_ren_syn_w[1] ? (&sch2fe_raddr_2_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_0_2) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_0_3[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[0] == 1 ? {sch_data_input_yolp_0_3_r , sch_data_input_xyolp_right_0_3_r} :
                         (sch2fe_ren_syn_w[0] ? (&sch2fe_raddr_3_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_0_3) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_1_0[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[3] == 1 ? {sch_data_input_yolp_1_0_r , sch_data_input_xyolp_right_1_0_r} :
                         (sch2fe_ren_syn_w[3] ? (&sch2fe_raddr_0_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_1_0) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_1_1[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[2] == 1 ? {sch_data_input_yolp_1_1_r , sch_data_input_xyolp_right_1_1_r} :
                         (sch2fe_ren_syn_w[2] ? (&sch2fe_raddr_1_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_1_1) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_1_2[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[1] == 1 ? {sch_data_input_yolp_1_2_r , sch_data_input_xyolp_right_1_2_r} :
                         (sch2fe_ren_syn_w[1] ? (&sch2fe_raddr_2_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_1_2) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_1_3[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[0] == 1 ? {sch_data_input_yolp_1_3_r , sch_data_input_xyolp_right_1_3_r} :
                         (sch2fe_ren_syn_w[0] ? (&sch2fe_raddr_3_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_1_3) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_2_0[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[3] == 1 ? {sch_data_input_yolp_2_0_r , sch_data_input_xyolp_right_2_0_r} :
                         (sch2fe_ren_syn_w[3] ? (&sch2fe_raddr_0_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_2_0) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_2_1[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[2] == 1 ? {sch_data_input_yolp_2_1_r , sch_data_input_xyolp_right_2_1_r} :
                         (sch2fe_ren_syn_w[2] ? (&sch2fe_raddr_1_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_2_1) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_2_2[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[1] == 1 ? {sch_data_input_yolp_2_2_r , sch_data_input_xyolp_right_2_2_r} :
                         (sch2fe_ren_syn_w[1] ? (&sch2fe_raddr_2_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_2_2) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_2_3[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[0] == 1 ? {sch_data_input_yolp_2_3_r , sch_data_input_xyolp_right_2_3_r} :
                         (sch2fe_ren_syn_w[0] ? (&sch2fe_raddr_3_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_2_3) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_3_0[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[3] == 1 ? {sch_data_input_yolp_3_0_r , sch_data_input_xyolp_right_3_0_r} :
                         (sch2fe_ren_syn_w[3] ? (&sch2fe_raddr_0_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_3_0) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_3_1[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[2] == 1 ? {sch_data_input_yolp_3_1_r , sch_data_input_xyolp_right_3_1_r} :
                         (sch2fe_ren_syn_w[2] ? (&sch2fe_raddr_1_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_3_1) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_3_2[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[1] == 1 ? {sch_data_input_yolp_3_2_r , sch_data_input_xyolp_right_3_2_r} :
                         (sch2fe_ren_syn_w[1] ? (&sch2fe_raddr_2_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_3_2) : {PE_COL_NUM{8'b1000_0000}});
    sch_data_input_3_3[PE_COL_NUM * IFM_WIDTH - 1 : 0] = yolp_rd_r[0] == 1 ? {sch_data_input_yolp_3_3_r , sch_data_input_xyolp_right_3_3_r} :
                         (sch2fe_ren_syn_w[0] ? (&sch2fe_raddr_3_syn_w == 1'b1 ? {PE_COL_NUM{8'b1000_0000}} : fe2sch_rdata_3_3) : {PE_COL_NUM{8'b1000_0000}});
end

always @(*)
begin
  sch_data_input_0_0[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[3] == 1 ? sch_data_input_xyolp_left_0_0_r : (sch2x_ren_syn_w[3] ? x2sch_rdata_0_0 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_0_1[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[2] == 1 ? sch_data_input_xyolp_left_0_1_r : (sch2x_ren_syn_w[2] ? x2sch_rdata_0_1 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_0_2[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[1] == 1 ? sch_data_input_xyolp_left_0_2_r : (sch2x_ren_syn_w[1] ? x2sch_rdata_0_2 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_0_3[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[0] == 1 ? sch_data_input_xyolp_left_0_3_r : (sch2x_ren_syn_w[0] ? x2sch_rdata_0_3 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_1_0[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[3] == 1 ? sch_data_input_xyolp_left_1_0_r : (sch2x_ren_syn_w[3] ? x2sch_rdata_1_0 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_1_1[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[2] == 1 ? sch_data_input_xyolp_left_1_1_r : (sch2x_ren_syn_w[2] ? x2sch_rdata_1_1 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_1_2[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[1] == 1 ? sch_data_input_xyolp_left_1_2_r : (sch2x_ren_syn_w[1] ? x2sch_rdata_1_2 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_1_3[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[0] == 1 ? sch_data_input_xyolp_left_1_3_r : (sch2x_ren_syn_w[0] ? x2sch_rdata_1_3 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_2_0[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[3] == 1 ? sch_data_input_xyolp_left_2_0_r : (sch2x_ren_syn_w[3] ? x2sch_rdata_2_0 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_2_1[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[2] == 1 ? sch_data_input_xyolp_left_2_1_r : (sch2x_ren_syn_w[2] ? x2sch_rdata_2_1 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_2_2[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[1] == 1 ? sch_data_input_xyolp_left_2_2_r : (sch2x_ren_syn_w[1] ? x2sch_rdata_2_2 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_2_3[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[0] == 1 ? sch_data_input_xyolp_left_2_3_r : (sch2x_ren_syn_w[0] ? x2sch_rdata_2_3 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_3_0[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[3] == 1 ? sch_data_input_xyolp_left_3_0_r : (sch2x_ren_syn_w[3] ? x2sch_rdata_3_0 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_3_1[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[2] == 1 ? sch_data_input_xyolp_left_3_1_r : (sch2x_ren_syn_w[2] ? x2sch_rdata_3_1 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_3_2[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[1] == 1 ? sch_data_input_xyolp_left_3_2_r : (sch2x_ren_syn_w[1] ? x2sch_rdata_3_2 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
  sch_data_input_3_3[SCH_COL_NUM * IFM_WIDTH - 1 : PE_COL_NUM * IFM_WIDTH] = xyolp_left_w[0] == 1 ? sch_data_input_xyolp_left_3_3_r : (sch2x_ren_syn_w[0] ? x2sch_rdata_3_3 : {(SCH_COL_NUM - PE_COL_NUM){8'b1000_0000}});
end


// =================================
// the signals syn to data & weight
// =================================

// the buf eb delay syn
always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch2fe_ren_dly_r         <= 0;
    sch2fe_ren_addr_if_dly_r <= 0;
    wt_buf_ren_dly_r         <= 0;
    olp_buf_ren_dly_r        <= 0;
    sch2y_ren_dly_r          <= 0;
    sch2x_ren_dly_r          <= 0;
    sch2xy_evn_ren_dly_r     <= 0;
    sch2xy_odd_ren_dly_r     <= 0;
  end
  else if (pe2sch_rdy) begin
    sch2fe_ren_dly_r         <= {sch2fe_ren_dly_r        , sch2fe_ren    };
    sch2fe_ren_addr_if_dly_r <= {sch2fe_ren_addr_if_dly_r, sch2fe_ren_w  };
    wt_buf_ren_dly_r         <= {wt_buf_ren_dly_r        , wt_buf_rd_en_w};
    olp_buf_ren_dly_r        <= {olp_buf_ren_dly_r       , olp_buf_rd_en };
    sch2y_ren_dly_r          <= {sch2y_ren_dly_r         , sch2y_ren     };
    sch2x_ren_dly_r          <= {sch2x_ren_dly_r         , sch2x_ren     };
    sch2xy_evn_ren_dly_r     <= {sch2xy_evn_ren_dly_r    , sch2xy_evn_ren};
    sch2xy_odd_ren_dly_r     <= {sch2xy_odd_ren_dly_r    , sch2xy_odd_ren};
  end
end

// the buf addr delay syn
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch2fe_raddr_0_dly_r <= 0;
    sch2fe_raddr_1_dly_r <= 0;
    sch2fe_raddr_2_dly_r <= 0;
    sch2fe_raddr_3_dly_r <= 0;
  end
  else begin
    sch2fe_raddr_0_dly_r <= {sch2fe_raddr_0_dly_r, sch2fe_raddr_0};
    sch2fe_raddr_1_dly_r <= {sch2fe_raddr_1_dly_r, sch2fe_raddr_1};
    sch2fe_raddr_2_dly_r <= {sch2fe_raddr_2_dly_r, sch2fe_raddr_2};
    sch2fe_raddr_3_dly_r <= {sch2fe_raddr_3_dly_r, sch2fe_raddr_3};
  end
end

// other signals delay dly, interface from addr
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    row_start_dly_r     <= 0;
    row_done_dly_r      <= 0;
    cnt_ksize_dly_r     <= 0;
    cur_state_dly_r     <= 0;
    addr_offset_dly_r   <= 0;
  end
  else if(pe2sch_rdy) begin
    row_start_dly_r     <= {row_start_dly_r  , row_start  };
    row_done_dly_r      <= {row_done_dly_r   , row_done   };
    cnt_ksize_dly_r     <= {cnt_ksize_dly_r  , cnt_ksize_w};
    cur_state_dly_r     <= {cur_state_dly_r  , cur_state_w};
    addr_offset_dly_r   <= {addr_offset_dly_r, addr_offset};
  end
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    tile_state_dly_r <= 0;
  else
    tile_state_dly_r <= {tile_state_dly_r, tile_state_w};
end
//assign sch2pe_vld_dly_r    = sch2pe_vld;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    sch2pe_vld_dly_r <= 0;
  else if(cur_state_w != 0)
    sch2pe_vld_dly_r <= {sch2pe_vld_dly_r, 1'b1};
  else
    sch2pe_vld_dly_r <= {sch2pe_vld_dly_r, 1'b0};
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    mux_col_vld_dly_r <= 0;
  else if(cur_state_w != 0) begin
    if(tile_loc[3] == 1)
      mux_col_vld_dly_r <= {mux_col_vld_dly_r, (32'hffff_ffff >> (32 - tile_out_w))};//{{tile_out_w{1'b1}},1'b1};
    else if(tile_loc[2] == 1)
      mux_col_vld_dly_r <= {mux_col_vld_dly_r, (32'hffff_ffff << (32 - tile_out_w))};
    else
      mux_col_vld_dly_r <= {mux_col_vld_dly_r, 32'hffff_ffff};
  end
  else
    mux_col_vld_dly_r <= {mux_col_vld_dly_r, 32'h0};
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    mux_row_vld_dly_r <= 0;
  else if(cur_state_w != 0) begin
    if(cnt_y == (num_y - 1) && tile_out_h_w[1:0] != 0)
      mux_row_vld_dly_r <= {mux_row_vld_dly_r, (4'b1111 << (4 - tile_out_h_w[1:0]))};
    else
      mux_row_vld_dly_r <= {mux_row_vld_dly_r, 4'b1111};
  end
  else
    mux_row_vld_dly_r <= {mux_row_vld_dly_r, 4'h0};
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    mux_array_vld_dly_r <= 0;
  else if(cur_state_w != 0) begin
    if(cnt_curf == (((tile_in_c >> 2) + (|tile_in_c[1:0])) - 1) && tile_in_c[1:0] != 0)
      mux_array_vld_dly_r <= {mux_array_vld_dly_r, (4'b1111 << (4 - tile_in_c[1:0]))};
    else
      mux_array_vld_dly_r <= {mux_array_vld_dly_r, 4'b1111};
  end
  else
    mux_array_vld_dly_r <= {mux_array_vld_dly_r, 4'h0};
end

assign sch2fe_ren_syn_w         = sch2fe_ren_dly_r[KNOB_REGOUT * 4 +: 4];
assign sch2fe_ren_addr_if_syn_w = sch2fe_ren_addr_if_dly_r[KNOB_REGOUT * 4 +: 4];
assign wt_buf_ren_syn_w         = wt_buf_ren_dly_r[KNOB_REGOUT +: 1];
assign olp_buf_ren_syn_w        = olp_buf_ren_dly_r[KNOB_REGOUT +: 1];
assign sch2y_ren_syn_w          = sch2y_ren_dly_r[KNOB_REGOUT * 4 +: 4];
assign sch2x_ren_syn_w          = sch2x_ren_dly_r[KNOB_REGOUT * 4 +: 4];
assign sch2xy_evn_ren_syn_w     = sch2xy_evn_ren_dly_r[KNOB_REGOUT * 4 +: 4];
assign sch2xy_odd_ren_syn_w     = sch2xy_odd_ren_dly_r[KNOB_REGOUT * 4 +: 4];

assign sch2fe_raddr_0_syn_w     = sch2fe_raddr_0_dly_r[KNOB_REGOUT * FE_ADDR_WIDTH +: FE_ADDR_WIDTH];
assign sch2fe_raddr_1_syn_w     = sch2fe_raddr_1_dly_r[KNOB_REGOUT * FE_ADDR_WIDTH +: FE_ADDR_WIDTH];
assign sch2fe_raddr_2_syn_w     = sch2fe_raddr_2_dly_r[KNOB_REGOUT * FE_ADDR_WIDTH +: FE_ADDR_WIDTH];
assign sch2fe_raddr_3_syn_w     = sch2fe_raddr_3_dly_r[KNOB_REGOUT * FE_ADDR_WIDTH +: FE_ADDR_WIDTH];

assign tile_state_syn_w         = tile_state_dly_r[KNOB_REGOUT +: 1];
assign sch2pe_vld_syn_w         = sch2pe_vld_dly_r[KNOB_REGOUT +: 1];
assign mux_col_vld_syn_w        = mux_col_vld_dly_r[KNOB_REGOUT * PE_COL_NUM +: PE_COL_NUM];
assign mux_row_vld_syn_w        = mux_row_vld_dly_r[KNOB_REGOUT * PE_H_NUM   +: PE_H_NUM];
assign mux_array_vld_syn_w      = mux_array_vld_dly_r[KNOB_REGOUT * PE_IC_NUM +: PE_IC_NUM];

assign row_start_syn_w          = row_start_dly_r[KNOB_REGOUT +: 1];
assign row_done_syn_w           = row_done_dly_r[KNOB_REGOUT +: 1];
assign cnt_ksize_syn_w          = cnt_ksize_dly_r[KNOB_REGOUT * WIDTH_KSIZE +: WIDTH_KSIZE];
assign cur_state_syn_w          = cur_state_dly_r[KNOB_REGOUT * 3 +: 3];
assign addr_offset_syn_w        = addr_offset_dly_r[KNOB_REGOUT * 3 +: 3];


endmodule