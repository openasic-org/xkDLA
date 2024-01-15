//////////////////////////////////////////////////
//
// File:            handshake_sche2pe.v
// Project Name:    DLA_v2
// Module Name:     handshake_sche2pe
// Description:     handshake between scheduler and pe
//
// Author:          Wanwei Xiao
// Setup Data:      13/8/2023
// Modify Date:     01/9/2023
//
//////////////////////////////////////////////////
module handshake_sche2pe
#(
  parameter   PE_COL_NUM   = 32 ,
  parameter   PE_H_NUM     = 4  ,
  parameter   PE_IC_NUM    = 4  ,
  parameter   IFM_WIDTH    = 8  ,
  parameter   WT_WIDTH     = 8
)
(
  clk                  ,
  rst_n                ,
  pe2sch_rdy           ,

  sch2pe_row_start_i   ,
  sch2pe_row_done_i    ,
  sch2pe_vld_i         ,
  mux_col_vld_i        ,
  mux_row_vld_i        ,
  mux_array_vld_i      ,

  sch_data_output_0_0_i,
  sch_data_output_0_1_i,
  sch_data_output_0_2_i,
  sch_data_output_0_3_i,
  sch_data_output_1_0_i,
  sch_data_output_1_1_i,
  sch_data_output_1_2_i,
  sch_data_output_1_3_i,
  sch_data_output_2_0_i,
  sch_data_output_2_1_i,
  sch_data_output_2_2_i,
  sch_data_output_2_3_i,
  sch_data_output_3_0_i,
  sch_data_output_3_1_i,
  sch_data_output_3_2_i,
  sch_data_output_3_3_i,

  sch_weight_output_0_0_i,
  sch_weight_output_0_1_i,
  sch_weight_output_0_2_i,
  sch_weight_output_0_3_i,
  sch_weight_output_1_0_i,
  sch_weight_output_1_1_i,
  sch_weight_output_1_2_i,
  sch_weight_output_1_3_i,
  sch_weight_output_2_0_i,
  sch_weight_output_2_1_i,
  sch_weight_output_2_2_i,
  sch_weight_output_2_3_i,
  sch_weight_output_3_0_i,
  sch_weight_output_3_1_i,
  sch_weight_output_3_2_i,
  sch_weight_output_3_3_i,

  sch2pe_row_start_o   ,
  sch2pe_row_done_o    ,
  sch2pe_vld_o         ,
  mux_col_vld_o        ,
  mux_row_vld_o        ,
  mux_array_vld_o      ,

  sch_data_output_0_0_o,
  sch_data_output_0_1_o,
  sch_data_output_0_2_o,
  sch_data_output_0_3_o,
  sch_data_output_1_0_o,
  sch_data_output_1_1_o,
  sch_data_output_1_2_o,
  sch_data_output_1_3_o,
  sch_data_output_2_0_o,
  sch_data_output_2_1_o,
  sch_data_output_2_2_o,
  sch_data_output_2_3_o,
  sch_data_output_3_0_o,
  sch_data_output_3_1_o,
  sch_data_output_3_2_o,
  sch_data_output_3_3_o,

  sch_weight_output_0_0_o,
  sch_weight_output_0_1_o,
  sch_weight_output_0_2_o,
  sch_weight_output_0_3_o,
  sch_weight_output_1_0_o,
  sch_weight_output_1_1_o,
  sch_weight_output_1_2_o,
  sch_weight_output_1_3_o,
  sch_weight_output_2_0_o,
  sch_weight_output_2_1_o,
  sch_weight_output_2_2_o,
  sch_weight_output_2_3_o,
  sch_weight_output_3_0_o,
  sch_weight_output_3_1_o,
  sch_weight_output_3_2_o,
  sch_weight_output_3_3_o
);

input                            clk                 ;
input                            rst_n               ;
input                            pe2sch_rdy          ;

input                                       sch2pe_row_start_i;
input                                       sch2pe_row_done_i ;
input                                       sch2pe_vld_i      ;
input      [PE_COL_NUM          - 1 : 0]    mux_col_vld_i     ;
input      [PE_H_NUM            - 1 : 0]    mux_row_vld_i     ;
input      [PE_IC_NUM           - 1 : 0]    mux_array_vld_i   ;

input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_0_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_1_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_2_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_3_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_0_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_1_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_2_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_3_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_0_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_1_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_2_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_3_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_0_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_1_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_2_i;
input  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_3_i;

input      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_0_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_1_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_2_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_0_3_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_0_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_1_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_2_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_1_3_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_0_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_1_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_2_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_2_3_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_0_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_1_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_2_i;
input      [WT_WIDTH            - 1 : 0]    sch_weight_output_3_3_i;

output reg                                      sch2pe_row_start_o;
output reg                                      sch2pe_row_done_o ;
output reg                                      sch2pe_vld_o      ;
output reg     [PE_COL_NUM          - 1 : 0]    mux_col_vld_o     ;
output reg     [PE_H_NUM            - 1 : 0]    mux_row_vld_o     ;
output reg     [PE_IC_NUM           - 1 : 0]    mux_array_vld_o   ;

output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_0_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_1_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_2_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_3_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_0_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_1_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_2_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_3_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_0_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_1_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_2_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_3_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_0_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_1_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_2_o;
output reg [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_3_o;

output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_0_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_1_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_2_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_0_3_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_0_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_1_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_2_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_1_3_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_0_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_1_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_2_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_2_3_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_0_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_1_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_2_o;
output reg     [WT_WIDTH            - 1 : 0]    sch_weight_output_3_3_o;

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch2pe_row_start_o    <= 0 ;
    //sch2pe_row_done_o     <= 0 ;
    sch_data_output_0_0_o <= 0 ;
    sch_data_output_0_1_o <= 0 ;
    sch_data_output_0_2_o <= 0 ;
    sch_data_output_0_3_o <= 0 ;
    sch_data_output_1_0_o <= 0 ;
    sch_data_output_1_1_o <= 0 ;
    sch_data_output_1_2_o <= 0 ;
    sch_data_output_1_3_o <= 0 ;
    sch_data_output_2_0_o <= 0 ;
    sch_data_output_2_1_o <= 0 ;
    sch_data_output_2_2_o <= 0 ;
    sch_data_output_2_3_o <= 0 ;
    sch_data_output_3_0_o <= 0 ;
    sch_data_output_3_1_o <= 0 ;
    sch_data_output_3_2_o <= 0 ;
    sch_data_output_3_3_o <= 0 ;
    sch_weight_output_0_0_o <= 0 ;
    sch_weight_output_0_1_o <= 0 ;
    sch_weight_output_0_2_o <= 0 ;
    sch_weight_output_0_3_o <= 0 ;
    sch_weight_output_1_0_o <= 0 ;
    sch_weight_output_1_1_o <= 0 ;
    sch_weight_output_1_2_o <= 0 ;
    sch_weight_output_1_3_o <= 0 ;
    sch_weight_output_2_0_o <= 0 ;
    sch_weight_output_2_1_o <= 0 ;
    sch_weight_output_2_2_o <= 0 ;
    sch_weight_output_2_3_o <= 0 ;
    sch_weight_output_3_0_o <= 0 ;
    sch_weight_output_3_1_o <= 0 ;
    sch_weight_output_3_2_o <= 0 ;
    sch_weight_output_3_3_o <= 0 ;
  end
  else if(sch2pe_vld_i && pe2sch_rdy) begin
    sch2pe_row_start_o    <= sch2pe_row_start_i ;
    //sch2pe_row_done_o     <= sch2pe_row_done_i  ;
    sch_data_output_0_0_o <= sch_data_output_0_0_i ;
    sch_data_output_0_1_o <= sch_data_output_0_1_i ;
    sch_data_output_0_2_o <= sch_data_output_0_2_i ;
    sch_data_output_0_3_o <= sch_data_output_0_3_i ;
    sch_data_output_1_0_o <= sch_data_output_1_0_i ;
    sch_data_output_1_1_o <= sch_data_output_1_1_i ;
    sch_data_output_1_2_o <= sch_data_output_1_2_i ;
    sch_data_output_1_3_o <= sch_data_output_1_3_i ;
    sch_data_output_2_0_o <= sch_data_output_2_0_i ;
    sch_data_output_2_1_o <= sch_data_output_2_1_i ;
    sch_data_output_2_2_o <= sch_data_output_2_2_i ;
    sch_data_output_2_3_o <= sch_data_output_2_3_i ;
    sch_data_output_3_0_o <= sch_data_output_3_0_i ;
    sch_data_output_3_1_o <= sch_data_output_3_1_i ;
    sch_data_output_3_2_o <= sch_data_output_3_2_i ;
    sch_data_output_3_3_o <= sch_data_output_3_3_i ;
    sch_weight_output_0_0_o <= sch_weight_output_0_0_i ;
    sch_weight_output_0_1_o <= sch_weight_output_0_1_i ;
    sch_weight_output_0_2_o <= sch_weight_output_0_2_i ;
    sch_weight_output_0_3_o <= sch_weight_output_0_3_i ;
    sch_weight_output_1_0_o <= sch_weight_output_1_0_i ;
    sch_weight_output_1_1_o <= sch_weight_output_1_1_i ;
    sch_weight_output_1_2_o <= sch_weight_output_1_2_i ;
    sch_weight_output_1_3_o <= sch_weight_output_1_3_i ;
    sch_weight_output_2_0_o <= sch_weight_output_2_0_i ;
    sch_weight_output_2_1_o <= sch_weight_output_2_1_i ;
    sch_weight_output_2_2_o <= sch_weight_output_2_2_i ;
    sch_weight_output_2_3_o <= sch_weight_output_2_3_i ;
    sch_weight_output_3_0_o <= sch_weight_output_3_0_i ;
    sch_weight_output_3_1_o <= sch_weight_output_3_1_i ;
    sch_weight_output_3_2_o <= sch_weight_output_3_2_i ;
    sch_weight_output_3_3_o <= sch_weight_output_3_3_i ;
  end
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    sch2pe_row_done_o <= 0;
  else if(sch2pe_vld_i && pe2sch_rdy)
    sch2pe_row_done_o <= sch2pe_row_done_i;
  else
    sch2pe_row_done_o <= sch2pe_row_done_o && sch2pe_vld_i;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    sch2pe_vld_o    <= 0 ;
    mux_col_vld_o   <= 0 ;
    mux_row_vld_o   <= 0 ;
    mux_array_vld_o <= 0 ;
  end
  else if(pe2sch_rdy) begin
    sch2pe_vld_o    <= sch2pe_vld_i    ;
    mux_col_vld_o   <= mux_col_vld_i   ;
    mux_row_vld_o   <= mux_row_vld_i   ;
    mux_array_vld_o <= mux_array_vld_i ;
  end
end

endmodule