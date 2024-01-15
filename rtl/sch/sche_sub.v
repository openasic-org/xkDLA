//////////////////////////////////////////////////
//
// File:            sche_sub.v
// Project Name:    DLA_v2
// Module Name:     sche_sub
// Description:     scheduler logic
//
// Author:          Wanwei Xiao
// Setup Data:      17/7/2023
// Modify Date:     01/9/2023
//
//////////////////////////////////////////////////
module sche_sub#(
  parameter   REG_IW_WIDTH = 6  ,
  parameter   IFM_WIDTH    = 8  ,
  parameter   SCH_COL_NUM  = 36 ,
  parameter   WT_WIDTH     = 16 ,
  parameter   PE_COL_NUM   = 32 ,
  parameter   PE_H_NUM     = 4  ,
  parameter   PE_IC_NUM    = 4  ,
  parameter   PE_OC_NUM    = 4  ,
  parameter   WIDTH_KSIZE  = 3
)
(
  rst_n                ,
  clk                  ,

  // interface with scheduler
  sch_data_input_0_0   ,
  sch_data_input_0_1   ,
  sch_data_input_0_2   ,
  sch_data_input_0_3   ,
  sch_data_input_1_0   ,
  sch_data_input_1_1   ,
  sch_data_input_1_2   ,
  sch_data_input_1_3   ,
  sch_data_input_2_0   ,
  sch_data_input_2_1   ,
  sch_data_input_2_2   ,
  sch_data_input_2_3   ,
  sch_data_input_3_0   ,
  sch_data_input_3_1   ,
  sch_data_input_3_2   ,
  sch_data_input_3_3   ,

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

  // dat_o
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
  sch_weight_output_3_3,

  pe2sch_rdy           ,
  tile_loc             ,
  ksize                ,
  sch2fe_ren_dly_syn_i ,
  wt_buf_ren_dly_syn_i ,
  olp_bufren_dly_syn_i ,
  tile_in_w            ,
  sch2pe_row_start     ,
  sch2pe_row_done      ,
  sch2pe_vld_o         ,
  mux_col_vld_o        ,
  mux_row_vld_o        ,
  mux_array_vld_o      ,

// interface with addr_if
  row_start_dly_syn_i  ,
  row_done_dly_syn_i   ,
  sch2pe_vld_dly_syn_i ,
  mux_col_vld_dly_syn_i,
  mux_row_vld_dly_syn_i,
  mux_array_vld_dly_syn_i,
  cnt_ksize_dly_syn_i          ,
  cur_state_dly_syn_i          ,
  addr_offset_dly_syn_i
);

localparam      IDLE      = 3'd0;
localparam      ADDR_INIT = 3'd1;
localparam      ADDR_PLUS = 3'd2;
localparam      IC_PLUS4  = 3'd3;
localparam      OC_PLUS4  = 3'd4;
localparam      NEXT_ROW4 = 3'd5;

input                                rst_n;
input                                clk  ;
// interface with scheduler
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_0;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_1;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_2;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_3;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_0;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_1;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_2;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_3;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_0;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_1;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_2;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_3;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_0;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_1;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_2;
input  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_3;

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

output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_0_0;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_0_1;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_0_2;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_0_3;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_1_0;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_1_1;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_1_2;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_1_3;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_2_0;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_2_1;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_2_2;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_2_3;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_3_0;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_3_1;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_3_2;
output reg [WT_WIDTH            - 1 : 0]    sch_weight_output_3_3;

input                                       pe2sch_rdy           ;
input      [3                       : 0]    tile_loc             ;
input      [WIDTH_KSIZE         - 1 : 0]    ksize                ;
input      [3                       : 0]    sch2fe_ren_dly_syn_i ;
input                                       wt_buf_ren_dly_syn_i ;
input                                       olp_bufren_dly_syn_i ;
input      [REG_IW_WIDTH-1          : 0]    tile_in_w            ;
output reg                                  sch2pe_row_start     ;
output reg                                  sch2pe_row_done      ;
output reg                                  sch2pe_vld_o         ;
output reg [PE_COL_NUM          - 1 : 0]    mux_col_vld_o        ;
output reg [PE_H_NUM            - 1 : 0]    mux_row_vld_o        ;
output reg [PE_IC_NUM           - 1 : 0]    mux_array_vld_o      ;

// interface with addr_if
input                                       row_start_dly_syn_i            ;
input                                       row_done_dly_syn_i             ;
input                                       sch2pe_vld_dly_syn_i           ;
input      [PE_COL_NUM          - 1 : 0]    mux_col_vld_dly_syn_i          ;
input      [PE_H_NUM            - 1 : 0]    mux_row_vld_dly_syn_i          ;
input      [PE_IC_NUM           - 1 : 0]    mux_array_vld_dly_syn_i        ;
input      [WIDTH_KSIZE         - 1 : 0]    cnt_ksize_dly_syn_i          ;
input      [2                       : 0]    cur_state_dly_syn_i          ;
input      [2                       : 0]    addr_offset_dly_syn_i          ;

// reg
reg        [WIDTH_KSIZE         - 1 : 0]    cnt_ksize_r2         ;

reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_0_0;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_0_1;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_0_2;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_0_3;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_1_0;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_1_1;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_1_2;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_1_3;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_2_0;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_2_1;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_2_2;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_2_3;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_3_0;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_3_1;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_3_2;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w1_3_3;

reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w2_0_3;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w2_1_3;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w2_2_3;
reg    [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_w2_3_3;

reg    [IFM_WIDTH - 1  : 0]    rf_r_0_0 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_0_1 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_0_2 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_0_3 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_1_0 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_1_1 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_1_2 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_1_3 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_2_0 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_2_1 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_2_2 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_2_3 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_3_0 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_3_1 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_3_2 [0:SCH_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    rf_r_3_3 [0:SCH_COL_NUM-1];

reg    [IFM_WIDTH - 1  : 0]    mux_r_0_0 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_0_1 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_0_2 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_0_3 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_1_0 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_1_1 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_1_2 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_1_3 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_2_0 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_2_1 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_2_2 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_2_3 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_3_0 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_3_1 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_3_2 [0:PE_COL_NUM-1];
reg    [IFM_WIDTH - 1  : 0]    mux_r_3_3 [0:PE_COL_NUM-1];

(* max_fanout = "256" *) reg    [2              : 0]    addr_offset_dly_syn_i            ;

reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_0_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_0_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_0_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_0_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_1_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_1_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_1_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_1_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_2_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_2_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_2_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_2_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_3_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_3_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_3_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    store_data_input_3_3;

reg  [WT_WIDTH                - 1 : 0]    store_weight_input_0_0;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_0_1;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_0_2;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_0_3;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_1_0;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_1_1;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_1_2;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_1_3;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_2_0;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_2_1;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_2_2;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_2_3;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_3_0;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_3_1;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_3_2;
reg  [WT_WIDTH                - 1 : 0]    store_weight_input_3_3;

reg pe2sch_rdy_pre;

// wire
wire   [2              : 0]    mux_sel                   ;

genvar                         gvIdx                     ;
genvar                         gvIdx_out                 ;
genvar                         gvIdx_in                  ;
genvar                         gvIdx_mux                 ;
genvar                         gvIdx_pe                  ;

// store in buffer
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    store_data_input_0_0 <= -128;
    store_data_input_0_1 <= -128;
    store_data_input_0_2 <= -128;
    store_data_input_0_3 <= -128;
    store_data_input_1_0 <= -128;
    store_data_input_1_1 <= -128;
    store_data_input_1_2 <= -128;
    store_data_input_1_3 <= -128;
    store_data_input_2_0 <= -128;
    store_data_input_2_1 <= -128;
    store_data_input_2_2 <= -128;
    store_data_input_2_3 <= -128;
    store_data_input_3_0 <= -128;
    store_data_input_3_1 <= -128;
    store_data_input_3_2 <= -128;
    store_data_input_3_3 <= -128;
    store_weight_input_0_0 <= -128;
    store_weight_input_0_1 <= -128;
    store_weight_input_0_2 <= -128;
    store_weight_input_0_3 <= -128;
    store_weight_input_1_0 <= -128;
    store_weight_input_1_1 <= -128;
    store_weight_input_1_2 <= -128;
    store_weight_input_1_3 <= -128;
    store_weight_input_2_0 <= -128;
    store_weight_input_2_1 <= -128;
    store_weight_input_2_2 <= -128;
    store_weight_input_2_3 <= -128;
    store_weight_input_3_0 <= -128;
    store_weight_input_3_1 <= -128;
    store_weight_input_3_2 <= -128;
    store_weight_input_3_3 <= -128;
  end
  else if(pe2sch_rdy == 0 && pe2sch_rdy_pre == 1) begin
    store_data_input_0_0 <= sch_data_input_0_0;
    store_data_input_0_1 <= sch_data_input_0_1;
    store_data_input_0_2 <= sch_data_input_0_2;
    store_data_input_0_3 <= sch_data_input_0_3;
    store_data_input_1_0 <= sch_data_input_1_0;
    store_data_input_1_1 <= sch_data_input_1_1;
    store_data_input_1_2 <= sch_data_input_1_2;
    store_data_input_1_3 <= sch_data_input_1_3;
    store_data_input_2_0 <= sch_data_input_2_0;
    store_data_input_2_1 <= sch_data_input_2_1;
    store_data_input_2_2 <= sch_data_input_2_2;
    store_data_input_2_3 <= sch_data_input_2_3;
    store_data_input_3_0 <= sch_data_input_3_0;
    store_data_input_3_1 <= sch_data_input_3_1;
    store_data_input_3_2 <= sch_data_input_3_2;
    store_data_input_3_3 <= sch_data_input_3_3;
    store_weight_input_0_0 <= sch_weight_input_0_0;
    store_weight_input_0_1 <= sch_weight_input_0_1;
    store_weight_input_0_2 <= sch_weight_input_0_2;
    store_weight_input_0_3 <= sch_weight_input_0_3;
    store_weight_input_1_0 <= sch_weight_input_1_0;
    store_weight_input_1_1 <= sch_weight_input_1_1;
    store_weight_input_1_2 <= sch_weight_input_1_2;
    store_weight_input_1_3 <= sch_weight_input_1_3;
    store_weight_input_2_0 <= sch_weight_input_2_0;
    store_weight_input_2_1 <= sch_weight_input_2_1;
    store_weight_input_2_2 <= sch_weight_input_2_2;
    store_weight_input_2_3 <= sch_weight_input_2_3;
    store_weight_input_3_0 <= sch_weight_input_3_0;
    store_weight_input_3_1 <= sch_weight_input_3_1;
    store_weight_input_3_2 <= sch_weight_input_3_2;
    store_weight_input_3_3 <= sch_weight_input_3_3;
  end
  else if(pe2sch_rdy == 0) begin
    store_data_input_0_0 <= store_data_input_0_0;
    store_data_input_0_1 <= store_data_input_0_1;
    store_data_input_0_2 <= store_data_input_0_2;
    store_data_input_0_3 <= store_data_input_0_3;
    store_data_input_1_0 <= store_data_input_1_0;
    store_data_input_1_1 <= store_data_input_1_1;
    store_data_input_1_2 <= store_data_input_1_2;
    store_data_input_1_3 <= store_data_input_1_3;
    store_data_input_2_0 <= store_data_input_2_0;
    store_data_input_2_1 <= store_data_input_2_1;
    store_data_input_2_2 <= store_data_input_2_2;
    store_data_input_2_3 <= store_data_input_2_3;
    store_data_input_3_0 <= store_data_input_3_0;
    store_data_input_3_1 <= store_data_input_3_1;
    store_data_input_3_2 <= store_data_input_3_2;
    store_data_input_3_3 <= store_data_input_3_3;
    store_weight_input_0_0 <= store_weight_input_0_0;
    store_weight_input_0_1 <= store_weight_input_0_1;
    store_weight_input_0_2 <= store_weight_input_0_2;
    store_weight_input_0_3 <= store_weight_input_0_3;
    store_weight_input_1_0 <= store_weight_input_1_0;
    store_weight_input_1_1 <= store_weight_input_1_1;
    store_weight_input_1_2 <= store_weight_input_1_2;
    store_weight_input_1_3 <= store_weight_input_1_3;
    store_weight_input_2_0 <= store_weight_input_2_0;
    store_weight_input_2_1 <= store_weight_input_2_1;
    store_weight_input_2_2 <= store_weight_input_2_2;
    store_weight_input_2_3 <= store_weight_input_2_3;
    store_weight_input_3_0 <= store_weight_input_3_0;
    store_weight_input_3_1 <= store_weight_input_3_1;
    store_weight_input_3_2 <= store_weight_input_3_2;
    store_weight_input_3_3 <= store_weight_input_3_3;
  end
  else begin
    store_data_input_0_0 <= sch_data_input_0_0;
    store_data_input_0_1 <= sch_data_input_0_1;
    store_data_input_0_2 <= sch_data_input_0_2;
    store_data_input_0_3 <= sch_data_input_0_3;
    store_data_input_1_0 <= sch_data_input_1_0;
    store_data_input_1_1 <= sch_data_input_1_1;
    store_data_input_1_2 <= sch_data_input_1_2;
    store_data_input_1_3 <= sch_data_input_1_3;
    store_data_input_2_0 <= sch_data_input_2_0;
    store_data_input_2_1 <= sch_data_input_2_1;
    store_data_input_2_2 <= sch_data_input_2_2;
    store_data_input_2_3 <= sch_data_input_2_3;
    store_data_input_3_0 <= sch_data_input_3_0;
    store_data_input_3_1 <= sch_data_input_3_1;
    store_data_input_3_2 <= sch_data_input_3_2;
    store_data_input_3_3 <= sch_data_input_3_3;
    store_weight_input_0_0 <= sch_weight_input_0_0;
    store_weight_input_0_1 <= sch_weight_input_0_1;
    store_weight_input_0_2 <= sch_weight_input_0_2;
    store_weight_input_0_3 <= sch_weight_input_0_3;
    store_weight_input_1_0 <= sch_weight_input_1_0;
    store_weight_input_1_1 <= sch_weight_input_1_1;
    store_weight_input_1_2 <= sch_weight_input_1_2;
    store_weight_input_1_3 <= sch_weight_input_1_3;
    store_weight_input_2_0 <= sch_weight_input_2_0;
    store_weight_input_2_1 <= sch_weight_input_2_1;
    store_weight_input_2_2 <= sch_weight_input_2_2;
    store_weight_input_2_3 <= sch_weight_input_2_3;
    store_weight_input_3_0 <= sch_weight_input_3_0;
    store_weight_input_3_1 <= sch_weight_input_3_1;
    store_weight_input_3_2 <= sch_weight_input_3_2;
    store_weight_input_3_3 <= sch_weight_input_3_3;
  end
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) pe2sch_rdy_pre <= 0;
  else      pe2sch_rdy_pre <=pe2sch_rdy;
end

// ------------ feature scheduler ------------------- //
always @(*)
begin
  sch_data_input_w1_0_0 = -128;
  sch_data_input_w1_0_1 = -128;
  sch_data_input_w1_0_2 = -128;
  sch_data_input_w1_0_3 = -128;
  sch_data_input_w1_1_0 = -128;
  sch_data_input_w1_1_1 = -128;
  sch_data_input_w1_1_2 = -128;
  sch_data_input_w1_1_3 = -128;
  sch_data_input_w1_2_0 = -128;
  sch_data_input_w1_2_1 = -128;
  sch_data_input_w1_2_2 = -128;
  sch_data_input_w1_2_3 = -128;
  sch_data_input_w1_3_0 = -128;
  sch_data_input_w1_3_1 = -128;
  sch_data_input_w1_3_2 = -128;
  sch_data_input_w1_3_3 = -128;
  case(addr_offset_dly_syn_i)
    4: begin
      sch_data_input_w1_0_0 = pe2sch_rdy_pre ? sch_data_input_0_0 : store_data_input_0_0;
      sch_data_input_w1_0_1 = pe2sch_rdy_pre ? sch_data_input_0_1 : store_data_input_0_1;
      sch_data_input_w1_0_2 = pe2sch_rdy_pre ? sch_data_input_0_2 : store_data_input_0_2;
      sch_data_input_w1_0_3 = pe2sch_rdy_pre ? sch_data_input_0_3 : store_data_input_0_3;
      sch_data_input_w1_1_0 = pe2sch_rdy_pre ? sch_data_input_1_0 : store_data_input_1_0;
      sch_data_input_w1_1_1 = pe2sch_rdy_pre ? sch_data_input_1_1 : store_data_input_1_1;
      sch_data_input_w1_1_2 = pe2sch_rdy_pre ? sch_data_input_1_2 : store_data_input_1_2;
      sch_data_input_w1_1_3 = pe2sch_rdy_pre ? sch_data_input_1_3 : store_data_input_1_3;
      sch_data_input_w1_2_0 = pe2sch_rdy_pre ? sch_data_input_2_0 : store_data_input_2_0;
      sch_data_input_w1_2_1 = pe2sch_rdy_pre ? sch_data_input_2_1 : store_data_input_2_1;
      sch_data_input_w1_2_2 = pe2sch_rdy_pre ? sch_data_input_2_2 : store_data_input_2_2;
      sch_data_input_w1_2_3 = pe2sch_rdy_pre ? sch_data_input_2_3 : store_data_input_2_3;
      sch_data_input_w1_3_0 = pe2sch_rdy_pre ? sch_data_input_3_0 : store_data_input_3_0;
      sch_data_input_w1_3_1 = pe2sch_rdy_pre ? sch_data_input_3_1 : store_data_input_3_1;
      sch_data_input_w1_3_2 = pe2sch_rdy_pre ? sch_data_input_3_2 : store_data_input_3_2;
      sch_data_input_w1_3_3 = pe2sch_rdy_pre ? sch_data_input_3_3 : store_data_input_3_3;
    end
    3: begin
      sch_data_input_w1_0_0 = pe2sch_rdy_pre ? sch_data_input_0_1 : store_data_input_0_1;
      sch_data_input_w1_0_1 = pe2sch_rdy_pre ? sch_data_input_0_2 : store_data_input_0_2;
      sch_data_input_w1_0_2 = pe2sch_rdy_pre ? sch_data_input_0_3 : store_data_input_0_3;
      sch_data_input_w1_0_3 = pe2sch_rdy_pre ? sch_data_input_0_0 : store_data_input_0_0;
      sch_data_input_w1_1_0 = pe2sch_rdy_pre ? sch_data_input_1_1 : store_data_input_1_1;
      sch_data_input_w1_1_1 = pe2sch_rdy_pre ? sch_data_input_1_2 : store_data_input_1_2;
      sch_data_input_w1_1_2 = pe2sch_rdy_pre ? sch_data_input_1_3 : store_data_input_1_3;
      sch_data_input_w1_1_3 = pe2sch_rdy_pre ? sch_data_input_1_0 : store_data_input_1_0;
      sch_data_input_w1_2_0 = pe2sch_rdy_pre ? sch_data_input_2_1 : store_data_input_2_1;
      sch_data_input_w1_2_1 = pe2sch_rdy_pre ? sch_data_input_2_2 : store_data_input_2_2;
      sch_data_input_w1_2_2 = pe2sch_rdy_pre ? sch_data_input_2_3 : store_data_input_2_3;
      sch_data_input_w1_2_3 = pe2sch_rdy_pre ? sch_data_input_2_0 : store_data_input_2_0;
      sch_data_input_w1_3_0 = pe2sch_rdy_pre ? sch_data_input_3_1 : store_data_input_3_1;
      sch_data_input_w1_3_1 = pe2sch_rdy_pre ? sch_data_input_3_2 : store_data_input_3_2;
      sch_data_input_w1_3_2 = pe2sch_rdy_pre ? sch_data_input_3_3 : store_data_input_3_3;
      sch_data_input_w1_3_3 = pe2sch_rdy_pre ? sch_data_input_3_0 : store_data_input_3_0;
    end
    2: begin
      sch_data_input_w1_0_0 = pe2sch_rdy_pre ? sch_data_input_0_2 : store_data_input_0_2;
      sch_data_input_w1_0_1 = pe2sch_rdy_pre ? sch_data_input_0_3 : store_data_input_0_3;
      sch_data_input_w1_0_2 = pe2sch_rdy_pre ? sch_data_input_0_0 : store_data_input_0_0;
      sch_data_input_w1_0_3 = pe2sch_rdy_pre ? sch_data_input_0_1 : store_data_input_0_1;
      sch_data_input_w1_1_0 = pe2sch_rdy_pre ? sch_data_input_1_2 : store_data_input_1_2;
      sch_data_input_w1_1_1 = pe2sch_rdy_pre ? sch_data_input_1_3 : store_data_input_1_3;
      sch_data_input_w1_1_2 = pe2sch_rdy_pre ? sch_data_input_1_0 : store_data_input_1_0;
      sch_data_input_w1_1_3 = pe2sch_rdy_pre ? sch_data_input_1_1 : store_data_input_1_1;
      sch_data_input_w1_2_0 = pe2sch_rdy_pre ? sch_data_input_2_2 : store_data_input_2_2;
      sch_data_input_w1_2_1 = pe2sch_rdy_pre ? sch_data_input_2_3 : store_data_input_2_3;
      sch_data_input_w1_2_2 = pe2sch_rdy_pre ? sch_data_input_2_0 : store_data_input_2_0;
      sch_data_input_w1_2_3 = pe2sch_rdy_pre ? sch_data_input_2_1 : store_data_input_2_1;
      sch_data_input_w1_3_0 = pe2sch_rdy_pre ? sch_data_input_3_2 : store_data_input_3_2;
      sch_data_input_w1_3_1 = pe2sch_rdy_pre ? sch_data_input_3_3 : store_data_input_3_3;
      sch_data_input_w1_3_2 = pe2sch_rdy_pre ? sch_data_input_3_0 : store_data_input_3_0;
      sch_data_input_w1_3_3 = pe2sch_rdy_pre ? sch_data_input_3_1 : store_data_input_3_1;
    end
    1: begin
      sch_data_input_w1_0_0 = pe2sch_rdy_pre ? sch_data_input_0_3 : store_data_input_0_3;
      sch_data_input_w1_0_1 = pe2sch_rdy_pre ? sch_data_input_0_0 : store_data_input_0_0;
      sch_data_input_w1_0_2 = pe2sch_rdy_pre ? sch_data_input_0_1 : store_data_input_0_1;
      sch_data_input_w1_0_3 = pe2sch_rdy_pre ? sch_data_input_0_2 : store_data_input_0_2;
      sch_data_input_w1_1_0 = pe2sch_rdy_pre ? sch_data_input_1_3 : store_data_input_1_3;
      sch_data_input_w1_1_1 = pe2sch_rdy_pre ? sch_data_input_1_0 : store_data_input_1_0;
      sch_data_input_w1_1_2 = pe2sch_rdy_pre ? sch_data_input_1_1 : store_data_input_1_1;
      sch_data_input_w1_1_3 = pe2sch_rdy_pre ? sch_data_input_1_2 : store_data_input_1_2;
      sch_data_input_w1_2_0 = pe2sch_rdy_pre ? sch_data_input_2_3 : store_data_input_2_3;
      sch_data_input_w1_2_1 = pe2sch_rdy_pre ? sch_data_input_2_0 : store_data_input_2_0;
      sch_data_input_w1_2_2 = pe2sch_rdy_pre ? sch_data_input_2_1 : store_data_input_2_1;
      sch_data_input_w1_2_3 = pe2sch_rdy_pre ? sch_data_input_2_2 : store_data_input_2_2;
      sch_data_input_w1_3_0 = pe2sch_rdy_pre ? sch_data_input_3_3 : store_data_input_3_3;
      sch_data_input_w1_3_1 = pe2sch_rdy_pre ? sch_data_input_3_0 : store_data_input_3_0;
      sch_data_input_w1_3_2 = pe2sch_rdy_pre ? sch_data_input_3_1 : store_data_input_3_1;
      sch_data_input_w1_3_3 = pe2sch_rdy_pre ? sch_data_input_3_2 : store_data_input_3_2;
    end
  endcase
end

always @(*)
begin
  sch_data_input_w2_0_3 = sch_data_input_0_3;
  sch_data_input_w2_1_3 = sch_data_input_1_3;
  sch_data_input_w2_2_3 = sch_data_input_2_3;
  sch_data_input_w2_3_3 = sch_data_input_3_3;
  case(addr_offset_dly_syn_i)
    1:begin
      sch_data_input_w2_0_3 = pe2sch_rdy_pre ? sch_data_input_0_3 : store_data_input_0_3;
      sch_data_input_w2_1_3 = pe2sch_rdy_pre ? sch_data_input_1_3 : store_data_input_1_3;
      sch_data_input_w2_2_3 = pe2sch_rdy_pre ? sch_data_input_2_3 : store_data_input_2_3;
      sch_data_input_w2_3_3 = pe2sch_rdy_pre ? sch_data_input_3_3 : store_data_input_3_3;
    end
    2:begin
      sch_data_input_w2_0_3 = pe2sch_rdy_pre ? sch_data_input_0_2 : store_data_input_0_2;
      sch_data_input_w2_1_3 = pe2sch_rdy_pre ? sch_data_input_1_2 : store_data_input_1_2;
      sch_data_input_w2_2_3 = pe2sch_rdy_pre ? sch_data_input_2_2 : store_data_input_2_2;
      sch_data_input_w2_3_3 = pe2sch_rdy_pre ? sch_data_input_3_2 : store_data_input_3_2;
    end
    3:begin
      sch_data_input_w2_0_3 = pe2sch_rdy_pre ? sch_data_input_0_1 : store_data_input_0_1;
      sch_data_input_w2_1_3 = pe2sch_rdy_pre ? sch_data_input_1_1 : store_data_input_1_1;
      sch_data_input_w2_2_3 = pe2sch_rdy_pre ? sch_data_input_2_1 : store_data_input_2_1;
      sch_data_input_w2_3_3 = pe2sch_rdy_pre ? sch_data_input_3_1 : store_data_input_3_1;
    end
    4:begin
      sch_data_input_w2_0_3 = pe2sch_rdy_pre ? sch_data_input_0_0 : store_data_input_0_0;
      sch_data_input_w2_1_3 = pe2sch_rdy_pre ? sch_data_input_1_0 : store_data_input_1_0;
      sch_data_input_w2_2_3 = pe2sch_rdy_pre ? sch_data_input_2_0 : store_data_input_2_0;
      sch_data_input_w2_3_3 = pe2sch_rdy_pre ? sch_data_input_3_0 : store_data_input_3_0;
    end
  endcase
end

generate
  for (gvIdx = 0; gvIdx < SCH_COL_NUM; gvIdx = gvIdx + 1) begin
    always @(posedge clk or negedge rst_n)
    begin
      if(!rst_n) begin
        rf_r_0_0[gvIdx] <= -128;
        rf_r_0_1[gvIdx] <= -128;
        rf_r_0_2[gvIdx] <= -128;
        rf_r_0_3[gvIdx] <= -128;
        rf_r_1_0[gvIdx] <= -128;
        rf_r_1_1[gvIdx] <= -128;
        rf_r_1_2[gvIdx] <= -128;
        rf_r_1_3[gvIdx] <= -128;
        rf_r_2_0[gvIdx] <= -128;
        rf_r_2_1[gvIdx] <= -128;
        rf_r_2_2[gvIdx] <= -128;
        rf_r_2_3[gvIdx] <= -128;
        rf_r_3_0[gvIdx] <= -128;
        rf_r_3_1[gvIdx] <= -128;
        rf_r_3_2[gvIdx] <= -128;
        rf_r_3_3[gvIdx] <= -128;
      end
      else if(cur_state_dly_syn_i == ADDR_PLUS && (sch2fe_ren_dly_syn_i != 0 || olp_bufren_dly_syn_i == 1 ) && pe2sch_rdy) begin
        rf_r_0_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_0_1[gvIdx];
        rf_r_0_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_0_2[gvIdx];
        rf_r_0_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_0_3[gvIdx];
        rf_r_0_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w2_0_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_1_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_1_1[gvIdx];
        rf_r_1_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_1_2[gvIdx];
        rf_r_1_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_1_3[gvIdx];
        rf_r_1_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w2_1_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_2_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_2_1[gvIdx];
        rf_r_2_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_2_2[gvIdx];
        rf_r_2_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_2_3[gvIdx];
        rf_r_2_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w2_2_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_3_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_3_1[gvIdx];
        rf_r_3_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_3_2[gvIdx];
        rf_r_3_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : rf_r_3_3[gvIdx];
        rf_r_3_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w2_3_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
      end
      else if(cur_state_dly_syn_i != ADDR_PLUS && cur_state_dly_syn_i != IDLE && pe2sch_rdy &&
             ((sch2fe_ren_dly_syn_i != 0 || olp_bufren_dly_syn_i == 1) && cnt_ksize_dly_syn_i == 0)) begin
        rf_r_0_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_0_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_0_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_0_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_0_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_0_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_0_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_0_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_1_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_1_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_1_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_1_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_1_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_1_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_1_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_1_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_2_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_2_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_2_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_2_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_2_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_2_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_2_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_2_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_3_0[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_3_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_3_1[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_3_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_3_2[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_3_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
        rf_r_3_3[gvIdx] <= (gvIdx > (tile_in_w - 1) && tile_loc[3]==1)|| (gvIdx < (PE_COL_NUM - tile_in_w) && tile_loc[2] == 1) ? -128 : sch_data_input_w1_3_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH];
      end
      else begin
        rf_r_0_0[gvIdx] <= rf_r_0_0[gvIdx];
        rf_r_0_1[gvIdx] <= rf_r_0_1[gvIdx];
        rf_r_0_2[gvIdx] <= rf_r_0_2[gvIdx];
        rf_r_0_3[gvIdx] <= rf_r_0_3[gvIdx];
        rf_r_1_0[gvIdx] <= rf_r_1_0[gvIdx];
        rf_r_1_1[gvIdx] <= rf_r_1_1[gvIdx];
        rf_r_1_2[gvIdx] <= rf_r_1_2[gvIdx];
        rf_r_1_3[gvIdx] <= rf_r_1_3[gvIdx];
        rf_r_2_0[gvIdx] <= rf_r_2_0[gvIdx];
        rf_r_2_1[gvIdx] <= rf_r_2_1[gvIdx];
        rf_r_2_2[gvIdx] <= rf_r_2_2[gvIdx];
        rf_r_2_3[gvIdx] <= rf_r_2_3[gvIdx];
        rf_r_3_0[gvIdx] <= rf_r_3_0[gvIdx];
        rf_r_3_1[gvIdx] <= rf_r_3_1[gvIdx];
        rf_r_3_2[gvIdx] <= rf_r_3_2[gvIdx];
        rf_r_3_3[gvIdx] <= rf_r_3_3[gvIdx];
      end
    end
  end
endgenerate

// ----------------------- mux -----------------------//
assign mux_sel = ksize - 1 - cnt_ksize_r2;

generate
  for (gvIdx_mux = 0; gvIdx_mux < PE_COL_NUM; gvIdx_mux = gvIdx_mux + 1) begin
    always @(*) begin
      case(mux_sel)
        4'd0:begin
          mux_r_0_0[gvIdx_mux] = rf_r_0_0[gvIdx_mux];
          mux_r_0_1[gvIdx_mux] = rf_r_0_1[gvIdx_mux];
          mux_r_0_2[gvIdx_mux] = rf_r_0_2[gvIdx_mux];
          mux_r_0_3[gvIdx_mux] = rf_r_0_3[gvIdx_mux];
          mux_r_1_0[gvIdx_mux] = rf_r_1_0[gvIdx_mux];
          mux_r_1_1[gvIdx_mux] = rf_r_1_1[gvIdx_mux];
          mux_r_1_2[gvIdx_mux] = rf_r_1_2[gvIdx_mux];
          mux_r_1_3[gvIdx_mux] = rf_r_1_3[gvIdx_mux];
          mux_r_2_0[gvIdx_mux] = rf_r_2_0[gvIdx_mux];
          mux_r_2_1[gvIdx_mux] = rf_r_2_1[gvIdx_mux];
          mux_r_2_2[gvIdx_mux] = rf_r_2_2[gvIdx_mux];
          mux_r_2_3[gvIdx_mux] = rf_r_2_3[gvIdx_mux];
          mux_r_3_0[gvIdx_mux] = rf_r_3_0[gvIdx_mux];
          mux_r_3_1[gvIdx_mux] = rf_r_3_1[gvIdx_mux];
          mux_r_3_2[gvIdx_mux] = rf_r_3_2[gvIdx_mux];
          mux_r_3_3[gvIdx_mux] = rf_r_3_3[gvIdx_mux];
        end
        4'd1:begin
          mux_r_0_0[gvIdx_mux] = rf_r_0_0[gvIdx_mux + 1];
          mux_r_0_1[gvIdx_mux] = rf_r_0_1[gvIdx_mux + 1];
          mux_r_0_2[gvIdx_mux] = rf_r_0_2[gvIdx_mux + 1];
          mux_r_0_3[gvIdx_mux] = rf_r_0_3[gvIdx_mux + 1];
          mux_r_1_0[gvIdx_mux] = rf_r_1_0[gvIdx_mux + 1];
          mux_r_1_1[gvIdx_mux] = rf_r_1_1[gvIdx_mux + 1];
          mux_r_1_2[gvIdx_mux] = rf_r_1_2[gvIdx_mux + 1];
          mux_r_1_3[gvIdx_mux] = rf_r_1_3[gvIdx_mux + 1];
          mux_r_2_0[gvIdx_mux] = rf_r_2_0[gvIdx_mux + 1];
          mux_r_2_1[gvIdx_mux] = rf_r_2_1[gvIdx_mux + 1];
          mux_r_2_2[gvIdx_mux] = rf_r_2_2[gvIdx_mux + 1];
          mux_r_2_3[gvIdx_mux] = rf_r_2_3[gvIdx_mux + 1];
          mux_r_3_0[gvIdx_mux] = rf_r_3_0[gvIdx_mux + 1];
          mux_r_3_1[gvIdx_mux] = rf_r_3_1[gvIdx_mux + 1];
          mux_r_3_2[gvIdx_mux] = rf_r_3_2[gvIdx_mux + 1];
          mux_r_3_3[gvIdx_mux] = rf_r_3_3[gvIdx_mux + 1];
        end
        4'd2:begin
          mux_r_0_0[gvIdx_mux] = rf_r_0_0[gvIdx_mux + 2];
          mux_r_0_1[gvIdx_mux] = rf_r_0_1[gvIdx_mux + 2];
          mux_r_0_2[gvIdx_mux] = rf_r_0_2[gvIdx_mux + 2];
          mux_r_0_3[gvIdx_mux] = rf_r_0_3[gvIdx_mux + 2];
          mux_r_1_0[gvIdx_mux] = rf_r_1_0[gvIdx_mux + 2];
          mux_r_1_1[gvIdx_mux] = rf_r_1_1[gvIdx_mux + 2];
          mux_r_1_2[gvIdx_mux] = rf_r_1_2[gvIdx_mux + 2];
          mux_r_1_3[gvIdx_mux] = rf_r_1_3[gvIdx_mux + 2];
          mux_r_2_0[gvIdx_mux] = rf_r_2_0[gvIdx_mux + 2];
          mux_r_2_1[gvIdx_mux] = rf_r_2_1[gvIdx_mux + 2];
          mux_r_2_2[gvIdx_mux] = rf_r_2_2[gvIdx_mux + 2];
          mux_r_2_3[gvIdx_mux] = rf_r_2_3[gvIdx_mux + 2];
          mux_r_3_0[gvIdx_mux] = rf_r_3_0[gvIdx_mux + 2];
          mux_r_3_1[gvIdx_mux] = rf_r_3_1[gvIdx_mux + 2];
          mux_r_3_2[gvIdx_mux] = rf_r_3_2[gvIdx_mux + 2];
          mux_r_3_3[gvIdx_mux] = rf_r_3_3[gvIdx_mux + 2];
        end
        4'd3:begin
          mux_r_0_0[gvIdx_mux] = rf_r_0_0[gvIdx_mux + 3];
          mux_r_0_1[gvIdx_mux] = rf_r_0_1[gvIdx_mux + 3];
          mux_r_0_2[gvIdx_mux] = rf_r_0_2[gvIdx_mux + 3];
          mux_r_0_3[gvIdx_mux] = rf_r_0_3[gvIdx_mux + 3];
          mux_r_1_0[gvIdx_mux] = rf_r_1_0[gvIdx_mux + 3];
          mux_r_1_1[gvIdx_mux] = rf_r_1_1[gvIdx_mux + 3];
          mux_r_1_2[gvIdx_mux] = rf_r_1_2[gvIdx_mux + 3];
          mux_r_1_3[gvIdx_mux] = rf_r_1_3[gvIdx_mux + 3];
          mux_r_2_0[gvIdx_mux] = rf_r_2_0[gvIdx_mux + 3];
          mux_r_2_1[gvIdx_mux] = rf_r_2_1[gvIdx_mux + 3];
          mux_r_2_2[gvIdx_mux] = rf_r_2_2[gvIdx_mux + 3];
          mux_r_2_3[gvIdx_mux] = rf_r_2_3[gvIdx_mux + 3];
          mux_r_3_0[gvIdx_mux] = rf_r_3_0[gvIdx_mux + 3];
          mux_r_3_1[gvIdx_mux] = rf_r_3_1[gvIdx_mux + 3];
          mux_r_3_2[gvIdx_mux] = rf_r_3_2[gvIdx_mux + 3];
          mux_r_3_3[gvIdx_mux] = rf_r_3_3[gvIdx_mux + 3];
        end
        4'd4:begin
          mux_r_0_0[gvIdx_mux] = rf_r_0_0[gvIdx_mux + 4];
          mux_r_0_1[gvIdx_mux] = rf_r_0_1[gvIdx_mux + 4];
          mux_r_0_2[gvIdx_mux] = rf_r_0_2[gvIdx_mux + 4];
          mux_r_0_3[gvIdx_mux] = rf_r_0_3[gvIdx_mux + 4];
          mux_r_1_0[gvIdx_mux] = rf_r_1_0[gvIdx_mux + 4];
          mux_r_1_1[gvIdx_mux] = rf_r_1_1[gvIdx_mux + 4];
          mux_r_1_2[gvIdx_mux] = rf_r_1_2[gvIdx_mux + 4];
          mux_r_1_3[gvIdx_mux] = rf_r_1_3[gvIdx_mux + 4];
          mux_r_2_0[gvIdx_mux] = rf_r_2_0[gvIdx_mux + 4];
          mux_r_2_1[gvIdx_mux] = rf_r_2_1[gvIdx_mux + 4];
          mux_r_2_2[gvIdx_mux] = rf_r_2_2[gvIdx_mux + 4];
          mux_r_2_3[gvIdx_mux] = rf_r_2_3[gvIdx_mux + 4];
          mux_r_3_0[gvIdx_mux] = rf_r_3_0[gvIdx_mux + 4];
          mux_r_3_1[gvIdx_mux] = rf_r_3_1[gvIdx_mux + 4];
          mux_r_3_2[gvIdx_mux] = rf_r_3_2[gvIdx_mux + 4];
          mux_r_3_3[gvIdx_mux] = rf_r_3_3[gvIdx_mux + 4];
        end
        default: begin
          mux_r_0_0[gvIdx_mux] = rf_r_0_0[gvIdx_mux];
          mux_r_0_1[gvIdx_mux] = rf_r_0_1[gvIdx_mux];
          mux_r_0_2[gvIdx_mux] = rf_r_0_2[gvIdx_mux];
          mux_r_0_3[gvIdx_mux] = rf_r_0_3[gvIdx_mux];
          mux_r_1_0[gvIdx_mux] = rf_r_1_0[gvIdx_mux];
          mux_r_1_1[gvIdx_mux] = rf_r_1_1[gvIdx_mux];
          mux_r_1_2[gvIdx_mux] = rf_r_1_2[gvIdx_mux];
          mux_r_1_3[gvIdx_mux] = rf_r_1_3[gvIdx_mux];
          mux_r_2_0[gvIdx_mux] = rf_r_2_0[gvIdx_mux];
          mux_r_2_1[gvIdx_mux] = rf_r_2_1[gvIdx_mux];
          mux_r_2_2[gvIdx_mux] = rf_r_2_2[gvIdx_mux];
          mux_r_2_3[gvIdx_mux] = rf_r_2_3[gvIdx_mux];
          mux_r_3_0[gvIdx_mux] = rf_r_3_0[gvIdx_mux];
          mux_r_3_1[gvIdx_mux] = rf_r_3_1[gvIdx_mux];
          mux_r_3_2[gvIdx_mux] = rf_r_3_2[gvIdx_mux];
          mux_r_3_3[gvIdx_mux] = rf_r_3_3[gvIdx_mux];
        end
      endcase
    end
  end
endgenerate

// ---------------------- output ----------------------- //
generate
  for (gvIdx = 0; gvIdx < PE_COL_NUM; gvIdx = gvIdx + 1) begin
    assign sch_data_output_0_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_0_0[gvIdx];
    assign sch_data_output_0_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_0_1[gvIdx];
    assign sch_data_output_0_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_0_2[gvIdx];
    assign sch_data_output_0_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_0_3[gvIdx];
    assign sch_data_output_1_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_1_0[gvIdx];
    assign sch_data_output_1_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_1_1[gvIdx];
    assign sch_data_output_1_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_1_2[gvIdx];
    assign sch_data_output_1_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_1_3[gvIdx];
    assign sch_data_output_2_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_2_0[gvIdx];
    assign sch_data_output_2_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_2_1[gvIdx];
    assign sch_data_output_2_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_2_2[gvIdx];
    assign sch_data_output_2_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_2_3[gvIdx];
    assign sch_data_output_3_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_3_0[gvIdx];
    assign sch_data_output_3_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_3_1[gvIdx];
    assign sch_data_output_3_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_3_2[gvIdx];
    assign sch_data_output_3_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = mux_r_3_3[gvIdx];
  end
endgenerate

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch_weight_output_0_0 <= 0;
    sch_weight_output_0_1 <= 0;
    sch_weight_output_0_2 <= 0;
    sch_weight_output_0_3 <= 0;
    sch_weight_output_1_0 <= 0;
    sch_weight_output_1_1 <= 0;
    sch_weight_output_1_2 <= 0;
    sch_weight_output_1_3 <= 0;
    sch_weight_output_2_0 <= 0;
    sch_weight_output_2_1 <= 0;
    sch_weight_output_2_2 <= 0;
    sch_weight_output_2_3 <= 0;
    sch_weight_output_3_0 <= 0;
    sch_weight_output_3_1 <= 0;
    sch_weight_output_3_2 <= 0;
    sch_weight_output_3_3 <= 0;
  end
  else if(wt_buf_ren_dly_syn_i && pe2sch_rdy) begin
    sch_weight_output_0_0 <= pe2sch_rdy_pre ? sch_weight_input_0_0 : store_weight_input_0_0;
    sch_weight_output_0_1 <= pe2sch_rdy_pre ? sch_weight_input_0_1 : store_weight_input_0_1;
    sch_weight_output_0_2 <= pe2sch_rdy_pre ? sch_weight_input_0_2 : store_weight_input_0_2;
    sch_weight_output_0_3 <= pe2sch_rdy_pre ? sch_weight_input_0_3 : store_weight_input_0_3;
    sch_weight_output_1_0 <= pe2sch_rdy_pre ? sch_weight_input_1_0 : store_weight_input_1_0;
    sch_weight_output_1_1 <= pe2sch_rdy_pre ? sch_weight_input_1_1 : store_weight_input_1_1;
    sch_weight_output_1_2 <= pe2sch_rdy_pre ? sch_weight_input_1_2 : store_weight_input_1_2;
    sch_weight_output_1_3 <= pe2sch_rdy_pre ? sch_weight_input_1_3 : store_weight_input_1_3;
    sch_weight_output_2_0 <= pe2sch_rdy_pre ? sch_weight_input_2_0 : store_weight_input_2_0;
    sch_weight_output_2_1 <= pe2sch_rdy_pre ? sch_weight_input_2_1 : store_weight_input_2_1;
    sch_weight_output_2_2 <= pe2sch_rdy_pre ? sch_weight_input_2_2 : store_weight_input_2_2;
    sch_weight_output_2_3 <= pe2sch_rdy_pre ? sch_weight_input_2_3 : store_weight_input_2_3;
    sch_weight_output_3_0 <= pe2sch_rdy_pre ? sch_weight_input_3_0 : store_weight_input_3_0;
    sch_weight_output_3_1 <= pe2sch_rdy_pre ? sch_weight_input_3_1 : store_weight_input_3_1;
    sch_weight_output_3_2 <= pe2sch_rdy_pre ? sch_weight_input_3_2 : store_weight_input_3_2;
    sch_weight_output_3_3 <= pe2sch_rdy_pre ? sch_weight_input_3_3 : store_weight_input_3_3;
  end
  else begin
    sch_weight_output_0_0 <= sch_weight_output_0_0;
    sch_weight_output_0_1 <= sch_weight_output_0_1;
    sch_weight_output_0_2 <= sch_weight_output_0_2;
    sch_weight_output_0_3 <= sch_weight_output_0_3;
    sch_weight_output_1_0 <= sch_weight_output_1_0;
    sch_weight_output_1_1 <= sch_weight_output_1_1;
    sch_weight_output_1_2 <= sch_weight_output_1_2;
    sch_weight_output_1_3 <= sch_weight_output_1_3;
    sch_weight_output_2_0 <= sch_weight_output_2_0;
    sch_weight_output_2_1 <= sch_weight_output_2_1;
    sch_weight_output_2_2 <= sch_weight_output_2_2;
    sch_weight_output_2_3 <= sch_weight_output_2_3;
    sch_weight_output_3_0 <= sch_weight_output_3_0;
    sch_weight_output_3_1 <= sch_weight_output_3_1;
    sch_weight_output_3_2 <= sch_weight_output_3_2;
    sch_weight_output_3_3 <= sch_weight_output_3_3;
  end
end

// ----------------- dealy -------------------------- //
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_ksize_r2 <= 0;
  else if(pe2sch_rdy)
    cnt_ksize_r2 <= cnt_ksize_dly_syn_i;
  else
    cnt_ksize_r2 <= cnt_ksize_r2;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch2pe_row_done <= 0;
    sch2pe_row_start <= 0;
  end
  else if(pe2sch_rdy) begin
    sch2pe_row_done <= row_done_dly_syn_i;
    sch2pe_row_start <= row_start_dly_syn_i;
  end
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch2pe_vld_o    <= 0;
    mux_col_vld_o   <= 0;
    mux_row_vld_o   <= 0;
    mux_array_vld_o <= 0;
  end
  else if(pe2sch_rdy) begin
    sch2pe_vld_o    <= sch2pe_vld_dly_syn_i;
    mux_col_vld_o   <= mux_col_vld_dly_syn_i;
    mux_row_vld_o   <= mux_row_vld_dly_syn_i;
    mux_array_vld_o <= mux_array_vld_dly_syn_i;
  end
  else begin
    sch2pe_vld_o    <= sch2pe_vld_o;
    mux_col_vld_o   <= mux_col_vld_o;
    mux_row_vld_o   <= mux_row_vld_o;
    mux_array_vld_o <= mux_array_vld_o;
  end
end

endmodule