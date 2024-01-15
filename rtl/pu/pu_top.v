// ************************************************************* //
//  > File Name: pu_top.v
//  > Author : weiyuheng

// ************************************************************* //
//`include "debug_mon.vh"
//`define DEBUG_MONITOR
//------------------------------------------------------------------------------
 //  Modified       : 2023-9-13 by WYH
  //  Description    : add hbm & lbm
  //
 //  Modified       : 2023-9-05 by WYH
  //  Description    : add model switch
  //
  //  Modified       : 2023-8-22 by WYH
  //  Description    : add x y xy resi rd / wr
  //
  //  Modified       : 2023-8-16 by WYH
  //  Description    : add x olp , y olp, xy olp write
  //
  //  Modified       : 2023-8-13 by WYH
  //  Description    : pipelined mul and add, add memory  addressing count

  
//------------------------------------------------------------------------------
//(*DONT_TOUCH = "yes"*)
//`define DEBUG_MONITOR

module pu_top #(
    parameter   REG_OC_WIDTH            = 8      ,
    parameter   REG_OH_WIDTH            = 6      ,
    parameter   PE_OUTPUT_WD            = 18     ,     // pe partial sum width 18 bit
    parameter   PE_COL_NUM              = 32     ,
    parameter   BIAS_ADDR_WD            = 8      ,
    parameter   RES_ADDR_WD             = 8      ,
    parameter   FEATURE_ADDR_WD         = 8      ,
    parameter   OVERLAP_ADDR_WD         = 8      ,
    parameter   PU_RF_BIAS_IN_WD        = 48     ,
    parameter   PU_RF_RES_IN_WD         = 8 * 40 ,
    parameter   PU_RF_RES_OUT_WD        = 8 * 32 ,
    parameter   PU_RF_FE_OUT_WD         = 8 * 32 ,
    parameter   PU_RF_OLP_OUT_WD        = 8 * 4  ,
    parameter   PU_RF_ACCU_WD           = 32 * 24,
    parameter   BIAS_RF_WD              = 8 * 2  ,     // bias 16 bit
    parameter   RES_WD                  = 32 * 8 ,
    parameter   PU_RF_WD                = 32 * 8 ,
    parameter   X_OLP_ADR_WD            = 3      ,      //TODO:  
    parameter   X_OLP_DAT_WD            = 4 * 8  ,
    parameter   Y_OLP_ADR_WD            = 10     ,
    parameter   Y_OLP_DAT_WD            = 28 * 8 ,
    parameter   XY_OLP_ADR_WD           = 10     ,
    parameter   XY_OLP_DAT_WD           = 4 * 8  ,
    parameter   X_RESI_ADR_WD           = 10     ,     // TODO:
    parameter   X_RESI_DAT_WD           = 8 * 32 ,
    parameter   Y_RESI_ADR_WD           = 8      ,     // TODO:
    parameter   Y_RESI_DAT_WD           = 8 * 29 ,
    parameter   XY_RESI_ADR_WD          = 8      ,     // TODO:
    parameter   XY_RESI_DAT_WD          = 8 * 3  ,     // TODO:
    parameter   Y_L234_DEPTH            = 64     ,
    parameter   X_L234_DEPTH            = 32     ,
    parameter   XY_L234_DEPTH           = 34     ,
    parameter   REG_TNX_WIDTH           = 6
)(

    `ifdef DEBUG_MONITOR

    output                                                  mon_hs_conv_acc_o       ,
    output  [640                                    -1: 0]  mon_acc_c_0_h_0_o   ,
    output  [640                                    -1: 0]  mon_acc_c_0_h_1_o   ,
    output  [640                                    -1: 0]  mon_acc_c_0_h_2_o   ,
    output  [640                                    -1: 0]  mon_acc_c_0_h_3_o   ,
    output  [640                                    -1: 0]  mon_acc_c_1_h_0_o   ,
    output  [640                                    -1: 0]  mon_acc_c_1_h_1_o   ,
    output  [640                                    -1: 0]  mon_acc_c_1_h_2_o   ,
    output  [640                                    -1: 0]  mon_acc_c_1_h_3_o   ,
    output  [640                                    -1: 0]  mon_acc_c_2_h_0_o   ,
    output  [640                                    -1: 0]  mon_acc_c_2_h_1_o   ,
    output  [640                                    -1: 0]  mon_acc_c_2_h_2_o   ,
    output  [640                                    -1: 0]  mon_acc_c_2_h_3_o   ,
    output  [640                                    -1: 0]  mon_acc_c_3_h_0_o   ,
    output  [640                                    -1: 0]  mon_acc_c_3_h_1_o   ,
    output  [640                                    -1: 0]  mon_acc_c_3_h_2_o   ,
    output  [640                                    -1: 0]  mon_acc_c_3_h_3_o   ,

    output                                                 mon_hs_conv_bias_o   ,
    output  [640                                    -1: 0] mon_bias_oc0_o    ,
    output  [640                                    -1: 0] mon_bias_oc1_o    ,   
    output  [640                                    -1: 0] mon_bias_oc2_o    ,   
    output  [640                                    -1: 0] mon_bias_oc3_o    ,

    output                                                 mon_hs_lbm_o      ,
    output  [256                                    -1: 0] mon_lbm_oc0_o     ,
    output  [256                                    -1: 0] mon_lbm_oc1_o     ,
    output  [256                                    -1: 0] mon_lbm_oc2_o     ,
    output  [256                                    -1: 0] mon_lbm_oc3_o     ,
    

    `endif 

    input                                                   clk                 ,
    input                                                   rstn                ,
    // configure instruction and control
    // data channel interface
    // postprocess instruction fifo
    // ctrl signal
    input                                                   layer_start_i       ,
    input                                                   tile_switch_i       , 
    input                                                   strip_switch_i       ,
    output                                                  pu2ctrl_tile_done_o ,    // current layer current tile 's last 32wx4hx4oc block has been stored to febuf 
    input   [REG_OH_WIDTH                       -1: 0]      tile_h_i            ,
    input   [REG_OC_WIDTH                       -1: 0]      tile_c_i            ,
    input   [6                                  -1: 0]      tile_num_x_i        ,
    input   [3                                  -1: 0]      knl_size_i          ,    // 01 =>1x1  10 =>3x3  11 =>5x5
    input   [2                                    : 0]      ksize_nxt           ,
    input   [2                                  -1: 0]      res_proc_type_i     ,    // 00 deafult , 01 resi store , 10 resi load & add
    input   [4                                  -1: 0]      res_shift_i         ,
    input                                                   x4_shuffle_vld_i    ,    
    input                                                   pu_if_dnsamp_i      ,
    input                                                   model_switch_i      ,
    input                                                   nn_proc_i           ,    // 1'b1 : sr, 1'b0: dndm, 
    input   [6                                  -1: 0]      pu_hbm_shift_i      ,
    input   [6                                  -1: 0]      pu_lbm_shift_i      ,
    input                                                   pu_prelu_en_i       ,  
    input   [3                                    : 0]      tile_loc            ,
    input   [REG_TNX_WIDTH - 1                    : 0]      tile_tot_num_x      ,


    output  [100                                -1: 0]      pu2sch_olp_addr_o   ,
    // pe_array

    input                                                   pe2pu_vld_i         ,
    output                                                  pu2pe_rdy_o         ,

    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_0_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_0_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_0_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_0_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_1_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_1_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_1_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_1_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_2_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_2_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_2_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_2_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_3_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_3_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_3_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_0_3_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_0_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_0_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_0_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_0_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_1_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_1_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_1_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_1_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_2_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_2_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_2_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_2_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_3_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_3_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_3_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_1_3_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_0_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_0_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_0_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_0_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_1_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_1_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_1_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_1_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_2_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_2_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_2_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_2_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_3_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_3_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_3_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_2_3_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_0_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_0_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_0_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_0_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_1_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_1_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_1_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_1_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_2_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_2_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_2_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_2_3_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_3_0_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_3_1_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_3_2_i      ,
    input   [PE_OUTPUT_WD * PE_COL_NUM           -1: 0]     pe_row_3_3_3_i      ,
    // mem
    // mem ctrl signal

    // bias & preluparam buffer
    // data
    output  [1                                   -1: 0]     bias_buf_rd_en_o      ,
    output  [BIAS_ADDR_WD                        -1: 0]     bias_buf_rd_addr_o    ,
    input   [PU_RF_BIAS_IN_WD                    -1: 0]     bias_buf_rd_dat_0_i   ,
    input   [PU_RF_BIAS_IN_WD                    -1: 0]     bias_buf_rd_dat_1_i   ,
    input   [PU_RF_BIAS_IN_WD                    -1: 0]     bias_buf_rd_dat_2_i   ,
    input   [PU_RF_BIAS_IN_WD                    -1: 0]     bias_buf_rd_dat_3_i   ,

    // x resi buffer 
    output  [16                                  -1: 0]     x_resi_rd_en_o         ,
    output  [X_RESI_ADR_WD                       -1: 0]     x_resi_rd_addr_o       ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c0_h0_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c0_h1_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c0_h2_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c0_h3_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c1_h0_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c1_h1_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c1_h2_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c1_h3_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c2_h0_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c2_h1_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c2_h2_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c2_h3_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c3_h0_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c3_h1_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c3_h2_i  ,
    input   [X_RESI_DAT_WD                       -1: 0]     x_resi_rd_dat_c3_h3_i  ,
        
    output  [16                                  -1: 0]     x_resi_wr_en_o         ,
    output  [X_RESI_ADR_WD                       -1: 0]     x_resi_wr_addr_h0_o    ,
    output  [X_RESI_ADR_WD                       -1: 0]     x_resi_wr_addr_h1_o    ,
    output  [X_RESI_ADR_WD                       -1: 0]     x_resi_wr_addr_h2_o    ,
    output  [X_RESI_ADR_WD                       -1: 0]     x_resi_wr_addr_h3_o    ,

    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c0_h0_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c0_h1_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c0_h2_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c0_h3_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c1_h0_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c1_h1_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c1_h2_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c1_h3_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c2_h0_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c2_h1_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c2_h2_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c2_h3_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c3_h0_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c3_h1_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c3_h2_o  ,
    output  [X_RESI_DAT_WD                       -1: 0]     x_resi_wr_dat_c3_h3_o  ,
    
    // y resi buffer 
    output  [12                                  -1: 0]     y_resi_rd_en_o         ,
    output  [Y_RESI_ADR_WD                       -1: 0]     y_resi_rd_addr_o       ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c0_h0_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c0_h1_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c0_h2_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c1_h0_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c1_h1_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c1_h2_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c2_h0_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c2_h1_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c2_h2_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c3_h0_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c3_h1_i  ,
    input   [Y_RESI_DAT_WD                       -1: 0]     y_resi_rd_dat_c3_h2_i  ,
        
    output  [12                                  -1: 0]     y_resi_wr_en_o         ,
    output  [Y_RESI_ADR_WD                       -1: 0]     y_resi_wr_addr_o       ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c0_h0_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c0_h1_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c0_h2_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c1_h0_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c1_h1_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c1_h2_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c2_h0_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c2_h1_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c2_h2_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c3_h0_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c3_h1_o  ,
    output  [Y_RESI_DAT_WD                       -1: 0]     y_resi_wr_dat_c3_h2_o  ,

    // xy resi buffer
    output  [12                                   -1: 0]    xy_resi_rd_en_o        ,
    output  [XY_RESI_ADR_WD                       -1: 0]    xy_resi_rd_addr_o      ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c0_h0_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c0_h1_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c0_h2_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c1_h0_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c1_h1_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c1_h2_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c2_h0_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c2_h1_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c2_h2_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c3_h0_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c3_h1_i ,
    input   [XY_RESI_DAT_WD                       -1: 0]    xy_resi_rd_dat_c3_h2_i ,
        
    output  [12                                  -1: 0]     xy_resi_wr_en_o        ,
    output  [XY_RESI_ADR_WD                      -1: 0]     xy_resi_wr_addr_o      ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c0_h0_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c0_h1_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c0_h2_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c1_h0_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c1_h1_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c1_h2_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c2_h0_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c2_h1_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c2_h2_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c3_h0_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c3_h1_o ,
    output  [XY_RESI_DAT_WD                      -1: 0]     xy_resi_wr_dat_c3_h2_o ,

     // feature  write out
    output  [16                                  -1: 0]     fe_buf_wr_en_o        ,
    output  [FEATURE_ADDR_WD                     -1: 0]     fe_buf_wr_addr_o      ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_0_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_1_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_2_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_3_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_0_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_1_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_2_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_3_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_0_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_1_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_2_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_3_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_0_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_1_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_2_o   ,
    output  [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_3_o   ,

     // X_OLP_WRITE
    output  [16                                  -1: 0]     x_olp_buf_wr_en_o       ,
    output  [X_OLP_ADR_WD                        -1: 0]     x_olp_buf_wr_addr_o     ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_0_0_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_0_1_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_0_2_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_0_3_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_1_0_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_1_1_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_1_2_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_1_3_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_2_0_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_2_1_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_2_2_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_2_3_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_3_0_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_3_1_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_3_2_o  ,
    output  [X_OLP_DAT_WD                        -1: 0]     x_olp_buf_wr_dat_3_3_o  ,

     // Y_OLP_WRITE
    output  [16                                  -1: 0]     y_olp_buf_wr_en_o       ,
    output  [Y_OLP_ADR_WD                        -1: 0]     y_olp_buf_wr_addr_o     ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_0_0_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_0_1_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_0_2_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_0_3_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_1_0_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_1_1_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_1_2_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_1_3_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_2_0_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_2_1_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_2_2_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_2_3_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_3_0_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_3_1_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_3_2_o  ,
    output  [Y_OLP_DAT_WD                        -1: 0]     y_olp_buf_wr_dat_3_3_o  ,

    // XY_OLP_WRITE  even  buffer, half of total xy olp buf size
    output  [16                                  -1: 0]     evn_xy_olp_buf_wr_en_o       ,
    output  [XY_OLP_ADR_WD                       -1: 0]     evn_xy_olp_buf_wr_addr_o     ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_0_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_0_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_0_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_0_3_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_1_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_1_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_1_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_1_3_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_2_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_2_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_2_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_2_3_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_3_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_3_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_3_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     evn_xy_olp_buf_wr_dat_3_3_o  ,

      // XY_OLP_WRITE odd buffer, half of total xy olp buf size
    output  [16                                  -1: 0]     odd_xy_olp_buf_wr_en_o       ,
    output  [XY_OLP_ADR_WD                       -1: 0]     odd_xy_olp_buf_wr_addr_o     ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_0_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_0_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_0_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_0_3_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_1_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_1_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_1_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_1_3_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_2_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_2_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_2_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_2_3_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_3_0_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_3_1_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_3_2_o  ,
    output  [XY_OLP_DAT_WD                       -1: 0]     odd_xy_olp_buf_wr_dat_3_3_o  

);

// local params

localparam                                                  CONV1    = 2'b01     ,
                                                            CONV3    = 2'b10     ,
                                                            CONV5    = 2'b11     ,
                                                            RESI_RD  = 2'b10     ,
                                                            RESI_WR  = 2'b01     ;


//-------------------------------

// WIRE & REG

//-------------------------------




    wire                                                   pipe1_vld_w          ;               
    wire                                                   pipe1_rdy_w          ;
         
    wire                                                   pipe2_vld_w          ;               
    wire                                                   pipe2_rdy_w          ;
         
    wire                                                   pipe3_vld_w          ;               
    wire                                                   pipe3_rdy_w          ;
         
    wire                                                   pipe4_vld_w          ;               
    wire                                                   pipe4_rdy_w          ;
         
    wire                                                   pipe5_vld_w          ;               
    wire                                                   pipe5_rdy_w          ;

    wire                                                    acc2bsadd_vld_w     ;
    wire                                                    bsadd2acc_rdy_w     ;
    
    wire                                                    bsrd2bsadd_vld_w     ; 
    wire                                                    bsadd2bsrd_rdy_w     ;

    wire                                                    hs_in_eg_w           ;   // handshake in egress 
    wire                                                    hs_in_pipe2_w        ;
    wire                                                    hs_in_pipe3_w        ;


    reg    [640                                 -1: 0]     acc_0_w             ;
    reg    [640                                 -1: 0]     acc_1_w             ;
    reg    [640                                 -1: 0]     acc_2_w             ;
    reg    [640                                 -1: 0]     acc_3_w             ;
    reg    [3                                   -1: 0]     bias_h_cnt_r        ;
    reg    [3                                   -1: 0]     res_h_cnt_r         ;

    wire                                                   is_bias_end_w       ;
    wire                                                   is_res_end_w        ;

    wire                                                   is_resi_wr_w         ;
    wire                                                   is_resi_rd_w        ;
    reg                                                    x4_ps_en_r          ;
    reg    [REG_OH_WIDTH                         : 0]      tile_h_r            ;
    reg    [REG_OC_WIDTH                       -1: 0]      tile_c_r            ;
    reg    [REG_OH_WIDTH                       -1: 0]      tile_h_4_aligned_r  ;
    reg    [REG_OC_WIDTH                       -1: 0]      tile_c_4_aligned_r  ;
    reg    [2                                  -1: 0]      knl_size_r          ;
    reg    [2                                  -1: 0]      res_proc_type_r     ;
    reg    [6                                  -1: 0]      tile_num_x_r        ;
    reg    [6                                  -1: 0]      tile_num_x_sub1_r   ;


    reg                                                    bias_vld_r          ;
    reg    [100                                 -1: 0]     pu2sch_olp_addr_r   ;

    wire   [640                                    -1: 0]     accum_0_0_w         ;
    wire   [640                                    -1: 0]     accum_0_1_w         ;
    wire   [640                                    -1: 0]     accum_0_2_w         ;
    wire   [640                                    -1: 0]     accum_0_3_w         ;
    wire   [640                                    -1: 0]     accum_1_0_w         ;
    wire   [640                                    -1: 0]     accum_1_1_w         ;
    wire   [640                                    -1: 0]     accum_1_2_w         ;
    wire   [640                                    -1: 0]     accum_1_3_w         ;
    wire   [640                                    -1: 0]     accum_2_0_w         ;
    wire   [640                                    -1: 0]     accum_2_1_w         ;
    wire   [640                                    -1: 0]     accum_2_2_w         ;
    wire   [640                                    -1: 0]     accum_2_3_w         ;
    wire   [640                                    -1: 0]     accum_3_0_w         ;
    wire   [640                                    -1: 0]     accum_3_1_w         ;
    wire   [640                                    -1: 0]     accum_3_2_w         ;
    wire   [640                                    -1: 0]     accum_3_3_w         ;
 
 
    wire   [BIAS_RF_WD                           -1: 0]     bias_0_w           ;
    wire   [BIAS_RF_WD                           -1: 0]     bias_1_w           ;
    wire   [BIAS_RF_WD                           -1: 0]     bias_2_w           ;
    wire   [BIAS_RF_WD                           -1: 0]     bias_3_w           ;


    wire   [640                                  -1: 0]      conv_oc0_w         ;
    wire   [640                                  -1: 0]      conv_oc1_w         ;
    wire   [640                                  -1: 0]      conv_oc2_w         ;
    wire   [640                                  -1: 0]      conv_oc3_w         ;




    wire   [16                                  -1: 0]     relu_para_oc0_w     ;
    wire   [16                                  -1: 0]     relu_para_oc1_w     ;
    wire   [16                                  -1: 0]     relu_para_oc2_w     ;
    wire   [16                                  -1: 0]     relu_para_oc3_w     ;

    wire   [32*8                               -1: 0]     prelu_oc0_w         ; 
    wire   [32*8                               -1: 0]     prelu_oc1_w         ; 
    wire   [32*8                               -1: 0]     prelu_oc2_w         ; 
    wire   [32*8                               -1: 0]     prelu_oc3_w         ; 

    reg    [32 * 8                              -1: 0]     resi_oc0_w          ;
    reg    [32 * 8                              -1: 0]     resi_oc1_w          ;
    reg    [32 * 8                              -1: 0]     resi_oc2_w          ;
    reg    [32 * 8                              -1: 0]     resi_oc3_w          ;

    wire   [32 * 11                             -1: 0]     resi2lbm_oc0_w        ;
    wire   [32 * 11                             -1: 0]     resi2lbm_oc1_w        ;
    wire   [32 * 11                             -1: 0]     resi2lbm_oc2_w        ;
    wire   [32 * 11                             -1: 0]     resi2lbm_oc3_w        ;
    
    wire   [32 * 8                              -1: 0]     requant_oc0_w       ;
    wire   [32 * 8                              -1: 0]     requant_oc1_w       ;
    wire   [32 * 8                              -1: 0]     requant_oc2_w       ;
    wire   [32 * 8                              -1: 0]     requant_oc3_w       ;


    wire                                                   is_requant_end_w    ;
    reg    [4                                   -1 :0]     fe_h_en_w           ;
    reg    [3                                   -1 :0]     requant_h_cnt_r     ;

    wire   [6                                  -1 : 0]     strip_cnt_r         ;
    reg    [10                                 -1 : 0]     tile_cnt_r          ;            //x y
    reg    [4                                  -1 : 0]     layer_cnt_r         ;
    reg    [REG_OH_WIDTH                       -1 : 0]     tile_h_cnt_r        ;
    reg    [REG_OC_WIDTH                       -1 : 0]     tile_oc_cnt_r       ; 
    wire                                                   is_tile_done_w      ;
    wire                                                   is_tile_lst_c_h_w   ;
    wire                                                   is_tile_lst_c_w     ;
    wire                                                   is_tile_lst_h_w     ;
    wire                                                   is_blk_done_w       ;
    wire                                                   is_lst_tile_w       ;
    reg                                                    is_blk_done_dly_r   ;


    wire   [16                                   -1: 0]     res_add_en;
    wire   [4                                    -1: 0]     bias_add_en;
    wire   [4                                    -1: 0]     bias_rf_wr_en;
    wire                                                    rf_x2_shuffle_en;


   
    wire  [16                                    -1: 0]     rf_row_input_msk;
    wire  [16                                    -1: 0]     rf_row_shift_msk;
    wire  [4                                     -1: 0]     bias_buf_rd_en_w;

    //ps lines 

    wire   [32 * 8                              -1: 0]     ps_line_part0_w    ;
    wire   [32 * 8                              -1: 0]     ps_line_part1_w    ;
    wire   [32 * 8                              -1: 0]     ps_line_part2_w    ;
    wire   [32 * 8                              -1: 0]     ps_line_part3_w    ;

    wire   [1                                     : 0]     lst_h4_bias        ;

// fe buf write delay
    reg    [16                                  -1: 0]     fe_buf_wr_en_r       ;
    reg    [FEATURE_ADDR_WD                     -1: 0]     fe_buf_wr_addr_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_0_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_1_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_2_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_0_3_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_0_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_1_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_2_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_1_3_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_0_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_1_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_2_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_2_3_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_0_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_1_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_2_r   ;
    reg    [PU_RF_FE_OUT_WD                     -1: 0]     fe_buf_wr_dat_3_3_r   ;


//   y olp write

    reg    [Y_OLP_ADR_WD                        -1: 0]     y_olp_buf_wr_addr_r             ;
    reg    [Y_OLP_ADR_WD                        -1: 0]     y_olp_buf_cur_layer_base_addr   ;
    

    reg    [6                                   -1: 0]     y_olp_rot_cnt_r                 ;   // 960 / 32 =30, 31 for y olp , 32 for xy_olp , 5 bit is ok
    wire   [6                                   -1: 0]     y_olp_rot_len_w                 ;
    wire                                                   is_y_olp_rot_end_w              ;
    wire                                                   is_1x1_conv_w                   ;
    wire                                                   is_3x3_conv_w                   ;
    wire                                                   is_5x5_conv_w                   ;
    wire   [16                                  -1: 0]     y_olp_buf_wr_en_w               ;

//   xy olp write 
    reg    [6                                   -1: 0]     xy_olp_rot_cnt_r                ;
    reg    [XY_OLP_ADR_WD                       -2: 0]     xy_olp_buf_cur_layer_base_addr   ;

    wire   [6                                   -1: 0]     half_xy_olp_rot_len_w           ;
    wire   [6                                   -1: 0]     xy_olp_rot_len_w                ;
    wire                                                   is_xy_olp_rot_end_w             ;
    
    wire                                                   wr_xy_olp_odd_en_w              ;
    wire                                                   wr_xy_olp_evn_en_w             ;
    
    wire   [16                                  -1: 0]     xy_olp_buf_wr_en_w              ;
    
// x resi write 

    wire   [3                                   -1: 0]     tile_h_cnt4_plus_one_w          ;
//    reg    [4                                   -1: 0]     x_resi_wr_h_en_w                ;

// y resi write
    wire                                                   is_resi_wr_lst_3lines_w         ;
    wire                                                   is_y_resi_wr_rot_end_w          ;
    wire   [6                                   -1: 0]     y_resi_wr_rot_len_w             ;
//    reg    [6                                   -1: 0]     y_resi_wr_rot_cnt_r             ;
//    reg    [3                                   -1: 0]     y_resi_wr_h_en_w                ;
// xy resi write 


    wire                                                   is_xy_resi_wr_rot_end_w         ;
    wire   [6                                   -1: 0]     xy_resi_wr_rot_len_w            ;
    reg    [3                                   -1: 0]     xy_resi_wr_h_en_w               ;
    reg    [6                                   -1: 0]     xy_resi_wr_rot_cnt_r            ;

// resi read 

    reg    [6                                   -1: 0]     resi_rd_line_cnt_r             ;
    reg    [6                                   -1: 0]     y_resi_rd_rot_cnt_r            ;
    reg    [6                                   -1: 0]     xy_resi_rd_rot_cnt_r           ;
    wire   [6                                   -1: 0]     y_resi_rd_rot_len_w            ;
    wire   [6                                   -1: 0]     xy_resi_rd_rot_len_w           ;
    
    wire                                                   is_y_resi_rd_rot_end_w         ;
    wire                                                   is_xy_resi_rd_rot_end_w        ;
    wire                                                   is_resi_rd_frt_3lines_w        ;
    
    wire                                                   is_frt_strip_w                 ;
    wire                                                   is_norm_strip_w                ;

    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c0_h0_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c0_h1_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c0_h2_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c1_h0_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c1_h1_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c1_h2_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c2_h0_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c2_h1_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c2_h2_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c3_h0_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c3_h1_w    ;
    wire   [X_RESI_DAT_WD                       -1: 0]     cat_resi_frt_3lines_c3_h2_w    ;







    localparam                          DMC = 1'b0,
                                        DM  = 1'b0, 
                                        SR  = 1'b1;

    reg                                 model_proc_r;
    

    always @(posedge clk or negedge rstn)begin
        if(~rstn)begin
            model_proc_r <= DMC;
        end
        else begin
            model_proc_r <= model_switch_i ? ~model_proc_r : model_proc_r;
        end
    end


reg   [ 6         - 1 : 0]  pu_hbm_shift_r ;
reg   [ 6         - 1 : 0]  pu_lbm_shift_r ;
reg                         pu_prelu_en_r  ;

always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        x4_ps_en_r      <= 1'b0             ;
        tile_h_r        <= 'd0              ;
        tile_c_r        <= 'd0              ;
        knl_size_r      <= 'd0              ;
        res_proc_type_r <= 'd0              ;
        tile_num_x_r    <= 'd0              ;
        tile_num_x_sub1_r <= 'd0             ;
        pu_hbm_shift_r  <= 'd0              ;
        pu_lbm_shift_r  <= 'd0              ;
        pu_prelu_en_r   <= 'd0              ;
    end
    else if(layer_start_i) begin
        x4_ps_en_r      <= x4_shuffle_vld_i ;
        tile_h_r        <= {tile_h_i[ REG_OH_WIDTH -1 : 2] + |tile_h_i[2 -1 : 0], 2'b00} ;
        tile_c_r        <= {tile_c_i[ REG_OC_WIDTH -1 : 2] + |tile_c_i[2 -1 : 0], 2'b00}   ;
        //knl_size_r      <= knl_size_i       ;
        //tile_h_r        <= tile_h_i         ;
        //tile_c_r        <= tile_c_i         ;
        //knl_size_r      <= knl_size_i       ;
        knl_size_r      <= knl_size_i == 3'b01 ? 2'b01 : (knl_size_i == 3'b11 ? 2'b01 : 2'b11) ;
        pu_prelu_en_r   <= pu_prelu_en_i    ;
        res_proc_type_r <= res_proc_type_i  ;
        tile_num_x_r    <= tile_num_x_i     ;
        tile_num_x_sub1_r <= tile_num_x_i -'d1 ;
        pu_hbm_shift_r  <= pu_hbm_shift_i   ;
        pu_lbm_shift_r  <= pu_lbm_shift_i   ;
    end
end


// tile x cnt 
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        tile_cnt_r <= 'd0;
    end
    else if(tile_switch_i)begin
        tile_cnt_r <= is_lst_tile_w ? 'd0 : tile_cnt_r + 'd1 ;
    end
end

assign is_lst_tile_w = tile_cnt_r == tile_num_x_sub1_r  ;


//strip count
reg    [6                   -1 : 0]     dndm_strip_cnt_r         ;
reg    [6                   -1 : 0]     sr_strip_cnt_r          ;
reg                                     nn_proc_r                ;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        nn_proc_r <= 0;
    else
        nn_proc_r <= nn_proc_i;
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        dndm_strip_cnt_r <= 'd0;
    end
    else if(is_lst_tile_w && nn_proc_r == 0)begin
        dndm_strip_cnt_r <= tile_switch_i ? dndm_strip_cnt_r + 'd1 : dndm_strip_cnt_r ;
    end
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        sr_strip_cnt_r <= 'd0;
    end
    else if(is_lst_tile_w && nn_proc_r == 1)begin
        sr_strip_cnt_r <= tile_switch_i ? sr_strip_cnt_r + 'd1 : sr_strip_cnt_r ;
    end
end

assign strip_cnt_r = nn_proc_i == 1 ? sr_strip_cnt_r : dndm_strip_cnt_r;


/*
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        strip_cnt_r <= 'd0;
    end
    else if(is_lst_tile_w)begin
        strip_cnt_r <= tile_switch_i ? strip_cnt_r + 'd1 : strip_cnt_r ;
    end
end*/

// layer cnt
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        layer_cnt_r <= 'd0               ;
    end
    else if(tile_switch_i)begin
        layer_cnt_r <= 'd0               ;
    end
    else if(is_tile_done_w)begin
        layer_cnt_r <= layer_cnt_r + 'd1 ;
    end
end

assign pu2ctrl_tile_done_o = is_tile_done_w                                ;
assign is_blk_done_w     = is_blk_done_dly_r                               ;  // a 32x4x4 block has write back to fe/resi/olp
assign is_tile_done_w    = is_tile_lst_c_h_w && is_blk_done_w              ;

assign is_tile_lst_c_w   = (tile_oc_cnt_r >> 2)  + 'd1 == ((tile_c_r >> 2) ) ;
assign is_tile_lst_h_w   = (tile_h_cnt_r  >> 2)  + 'd1 == ((tile_h_r >> 2) ) ;  // reach a tile 's last 4 line ?
//assign is_tile_lst_c_w   = (tile_oc_cnt_r >> 2) == ((tile_c_r >> 2) - 'd1) ;
//assign is_tile_lst_c_w   = (tile_oc_cnt_r >> 2) == (((tile_c_r + 3) >> 2) - 1) ;
//assign is_tile_lst_h_w   = (tile_h_cnt_r  >> 2) == ((tile_h_r >> 2) - 'd1) ;  // reach a tile 's last 4 line ?
//assign is_tile_lst_h_w   = (tile_h_cnt_r  >> 2) == (((tile_h_r + 3) >> 2) - 1) ;  // reach a tile 's last 4 line ?
assign is_tile_lst_c_h_w = is_tile_lst_c_w & is_tile_lst_h_w               ;


//oc cnt 

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        tile_oc_cnt_r <= 'd0 ;
    end
    else if(layer_start_i) begin
        tile_oc_cnt_r <= 'd0 ;
    end
    else if(is_blk_done_w) begin         //count in egress
        tile_oc_cnt_r <= is_tile_lst_c_w ? 'd0 : tile_oc_cnt_r + 'd4 ;
    end
end

// h cnt
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        tile_h_cnt_r  <= 'd0 ;
    end
    else if(layer_start_i) begin
        tile_h_cnt_r  <= 'd0 ;
    end
    else if( is_blk_done_w & is_tile_lst_c_w) begin   //count in egress
        tile_h_cnt_r  <= is_tile_lst_h_w ? 'd0 : tile_h_cnt_r + 'd4 ;
    end
end


// bias & relu param buffer read
reg   [2 - 1 : 0]           tile_oc_cnt_ig_r   ;
wire                        is_tile_lst_c_ig_w ;
reg   [BIAS_ADDR_WD -1 : 0] bias_buf_rd_addr_r ;
reg   [BIAS_ADDR_WD -1 : 0] bias_buf_rd_base_addr ;

assign is_tile_lst_c_ig_w = (tile_oc_cnt_ig_r + 2'd1) == ((tile_c_r >> 2) ) ;
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        bias_buf_rd_base_addr <= 'd0;
    end
    else if(tile_switch_i)begin
        bias_buf_rd_base_addr <= 'd0;
    end
    else if(is_tile_done_w)begin
        bias_buf_rd_base_addr <= bias_buf_rd_base_addr + ((tile_c_r >> 2) );
    end
end
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        tile_oc_cnt_ig_r <= 'd0 ;
        bias_buf_rd_addr_r <= 'd0 ;
    end
    else if(tile_switch_i) begin
        tile_oc_cnt_ig_r   <= 'd0 ;
        bias_buf_rd_addr_r <= 'd0 ;
    end
    else if(layer_start_i) begin
        tile_oc_cnt_ig_r   <= 'd0 ;
        bias_buf_rd_addr_r <= bias_buf_rd_base_addr ;
    end
    else if(pu2pe_rdy_o & pe2pu_vld_i) begin         //count in egress
        tile_oc_cnt_ig_r   <= is_tile_lst_c_ig_w ? 'd0 : tile_oc_cnt_ig_r + 2'd1 ;
        bias_buf_rd_addr_r <= bias_buf_rd_base_addr + (is_tile_lst_c_ig_w ? 'd0 : tile_oc_cnt_ig_r + 2'd1) ;
    end
end


assign bias_buf_rd_en_o   = pu2pe_rdy_o & pe2pu_vld_i       ;
assign bias_buf_rd_addr_o = bias_buf_rd_addr_r              ;
// UNPACK BIAS_BUF
wire    [ 16 - 1 : 0]        bias_unpack_c_0_w ;
wire    [ 16 - 1 : 0]        bias_unpack_c_1_w ;
wire    [ 16 - 1 : 0]        bias_unpack_c_2_w ;
wire    [ 16 - 1 : 0]        bias_unpack_c_3_w ;
wire    [ 16 - 1 : 0]        hbm_unpack_c_0_w ;
wire    [ 16 - 1 : 0]        hbm_unpack_c_1_w ;
wire    [ 16 - 1 : 0]        hbm_unpack_c_2_w ;
wire    [ 16 - 1 : 0]        hbm_unpack_c_3_w ;
wire    [ 16 - 1 : 0]        lbm_unpack_c_0_w ;
wire    [ 16 - 1 : 0]        lbm_unpack_c_1_w ;
wire    [ 16 - 1 : 0]        lbm_unpack_c_2_w ;
wire    [ 16 - 1 : 0]        lbm_unpack_c_3_w ;
assign    {bias_unpack_c_0_w, hbm_unpack_c_0_w, lbm_unpack_c_0_w} = bias_buf_rd_dat_0_i ;
assign    {bias_unpack_c_1_w, hbm_unpack_c_1_w, lbm_unpack_c_1_w} = bias_buf_rd_dat_1_i ;
assign    {bias_unpack_c_2_w, hbm_unpack_c_2_w, lbm_unpack_c_2_w} = bias_buf_rd_dat_2_i ;
assign    {bias_unpack_c_3_w, hbm_unpack_c_3_w, lbm_unpack_c_3_w} = bias_buf_rd_dat_3_i ;



// memory  has 1 cyc delay
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        bias_vld_r <= 1'b0         ;
    end
    else if(pu2pe_rdy_o & pe2pu_vld_i) begin
        bias_vld_r <=  1'b1        ;
    end
    else if(~(pu2pe_rdy_o & pe2pu_vld_i) & bsadd2bsrd_rdy_w )begin
        bias_vld_r <=  1'b0        ;
    end

end

assign  bsrd2bsadd_vld_w  = bias_vld_r ;



// pipeline 


//----------------------------------------------------------------------------------------------------------

//            PIPE0:           partial sum  add

//----------------------------------------------------------------------------------------------------------




pu_ic_add_pipe0 #(
     .PE_OUTPUT_WD      ( PE_OUTPUT_WD       ),
     .PE_COL_NUM        ( 32                 ),
     .ACC_OUTPUT_WD     ( PE_OUTPUT_WD + 2   )
)
pu_pipe0_u
(

    // from pe_array  ic_oc_h
    .clk                    (clk                       )  ,
    .rstn                   (rstn                      )  ,
    .pu_accum_ic_p0_vld_i   (pe2pu_vld_i               )  ,
    //.pu_channel_vld_i       (pe2pu_c_vld_i             )  ,
    .pu_accum_ic_p0_rdy_o   (pu2pe_rdy_o               )  ,                              

    .pe_row_rf_0_0_0_i      (pe_row_0_0_0_i            )  ,
    .pe_row_rf_0_0_1_i      (pe_row_0_0_1_i            )  ,
    .pe_row_rf_0_0_2_i      (pe_row_0_0_2_i            )  ,
    .pe_row_rf_0_0_3_i      (pe_row_0_0_3_i            )  ,
    .pe_row_rf_0_1_0_i      (pe_row_0_1_0_i            )  ,
    .pe_row_rf_0_1_1_i      (pe_row_0_1_1_i            )  ,
    .pe_row_rf_0_1_2_i      (pe_row_0_1_2_i            )  ,
    .pe_row_rf_0_1_3_i      (pe_row_0_1_3_i            )  ,
    .pe_row_rf_0_2_0_i      (pe_row_0_2_0_i            )  ,
    .pe_row_rf_0_2_1_i      (pe_row_0_2_1_i            )  ,
    .pe_row_rf_0_2_2_i      (pe_row_0_2_2_i            )  ,
    .pe_row_rf_0_2_3_i      (pe_row_0_2_3_i            )  ,
    .pe_row_rf_0_3_0_i      (pe_row_0_3_0_i            )  ,
    .pe_row_rf_0_3_1_i      (pe_row_0_3_1_i            )  ,
    .pe_row_rf_0_3_2_i      (pe_row_0_3_2_i            )  ,
    .pe_row_rf_0_3_3_i      (pe_row_0_3_3_i            )  ,


    .pe_row_rf_1_0_0_i      (pe_row_1_0_0_i            )  ,
    .pe_row_rf_1_0_1_i      (pe_row_1_0_1_i            )  ,
    .pe_row_rf_1_0_2_i      (pe_row_1_0_2_i            )  ,
    .pe_row_rf_1_0_3_i      (pe_row_1_0_3_i            )  ,
    .pe_row_rf_1_1_0_i      (pe_row_1_1_0_i            )  ,
    .pe_row_rf_1_1_1_i      (pe_row_1_1_1_i            )  ,
    .pe_row_rf_1_1_2_i      (pe_row_1_1_2_i            )  ,
    .pe_row_rf_1_1_3_i      (pe_row_1_1_3_i            )  ,
    .pe_row_rf_1_2_0_i      (pe_row_1_2_0_i            )  ,
    .pe_row_rf_1_2_1_i      (pe_row_1_2_1_i            )  ,
    .pe_row_rf_1_2_2_i      (pe_row_1_2_2_i            )  ,
    .pe_row_rf_1_2_3_i      (pe_row_1_2_3_i            )  ,
    .pe_row_rf_1_3_0_i      (pe_row_1_3_0_i            )  ,
    .pe_row_rf_1_3_1_i      (pe_row_1_3_1_i            )  ,
    .pe_row_rf_1_3_2_i      (pe_row_1_3_2_i            )  ,
    .pe_row_rf_1_3_3_i      (pe_row_1_3_3_i            )  ,

    .pe_row_rf_2_0_0_i      (pe_row_2_0_0_i            )  ,
    .pe_row_rf_2_0_1_i      (pe_row_2_0_1_i            )  ,
    .pe_row_rf_2_0_2_i      (pe_row_2_0_2_i            )  ,
    .pe_row_rf_2_0_3_i      (pe_row_2_0_3_i            )  ,
    .pe_row_rf_2_1_0_i      (pe_row_2_1_0_i            )  ,
    .pe_row_rf_2_1_1_i      (pe_row_2_1_1_i            )  ,
    .pe_row_rf_2_1_2_i      (pe_row_2_1_2_i            )  ,
    .pe_row_rf_2_1_3_i      (pe_row_2_1_3_i            )  ,
    .pe_row_rf_2_2_0_i      (pe_row_2_2_0_i            )  ,
    .pe_row_rf_2_2_1_i      (pe_row_2_2_1_i            )  ,
    .pe_row_rf_2_2_2_i      (pe_row_2_2_2_i            )  ,
    .pe_row_rf_2_2_3_i      (pe_row_2_2_3_i            )  ,
    .pe_row_rf_2_3_0_i      (pe_row_2_3_0_i            )  ,
    .pe_row_rf_2_3_1_i      (pe_row_2_3_1_i            )  ,
    .pe_row_rf_2_3_2_i      (pe_row_2_3_2_i            )  ,
    .pe_row_rf_2_3_3_i      (pe_row_2_3_3_i            )  ,

    .pe_row_rf_3_0_0_i      (pe_row_3_0_0_i            )  ,
    .pe_row_rf_3_0_1_i      (pe_row_3_0_1_i            )  ,
    .pe_row_rf_3_0_2_i      (pe_row_3_0_2_i            )  ,
    .pe_row_rf_3_0_3_i      (pe_row_3_0_3_i            )  ,
    .pe_row_rf_3_1_0_i      (pe_row_3_1_0_i            )  ,
    .pe_row_rf_3_1_1_i      (pe_row_3_1_1_i            )  ,
    .pe_row_rf_3_1_2_i      (pe_row_3_1_2_i            )  ,
    .pe_row_rf_3_1_3_i      (pe_row_3_1_3_i            )  ,
    .pe_row_rf_3_2_0_i      (pe_row_3_2_0_i            )  ,
    .pe_row_rf_3_2_1_i      (pe_row_3_2_1_i            )  ,
    .pe_row_rf_3_2_2_i      (pe_row_3_2_2_i            )  ,
    .pe_row_rf_3_2_3_i      (pe_row_3_2_3_i            )  ,
    .pe_row_rf_3_3_0_i      (pe_row_3_3_0_i            )  ,
    .pe_row_rf_3_3_1_i      (pe_row_3_3_1_i            )  ,
    .pe_row_rf_3_3_2_i      (pe_row_3_3_2_i            )  ,
    .pe_row_rf_3_3_3_i      (pe_row_3_3_3_i            )  ,

    // output oc - h
    .pu_accum_ic_p0_vld_o   (acc2bsadd_vld_w           )  ,
    .pu_accum_ic_p0_rdy_i   (bsadd2acc_rdy_w           )  ,
    .accum_0_0_o            (accum_0_0_w               )  ,
    .accum_0_1_o            (accum_0_1_w               )  ,
    .accum_0_2_o            (accum_0_2_w               )  ,
    .accum_0_3_o            (accum_0_3_w               )  ,
    .accum_1_0_o            (accum_1_0_w               )  ,
    .accum_1_1_o            (accum_1_1_w               )  ,
    .accum_1_2_o            (accum_1_2_w               )  ,
    .accum_1_3_o            (accum_1_3_w               )  ,
    .accum_2_0_o            (accum_2_0_w               )  ,
    .accum_2_1_o            (accum_2_1_w               )  ,
    .accum_2_2_o            (accum_2_2_w               )  ,
    .accum_2_3_o            (accum_2_3_w               )  ,
    .accum_3_0_o            (accum_3_0_w               )  ,
    .accum_3_1_o            (accum_3_1_w               )  ,
    .accum_3_2_o            (accum_3_2_w               )  ,
    .accum_3_3_o            (accum_3_3_w               )  
);

//   bias_add need to handshake with acc and bias_read 



assign       bsadd2acc_rdy_w  = pipe1_rdy_w &is_bias_end_w & bsrd2bsadd_vld_w ;
assign       bsadd2bsrd_rdy_w = pipe1_rdy_w &is_bias_end_w & acc2bsadd_vld_w  ;
assign       pipe1_vld_w      = bsrd2bsadd_vld_w & acc2bsadd_vld_w            ;


//----------------------------------------------------------------------------------------------------------

//                PIPE1:      BIAS_ADD

//----------------------------------------------------------------------------------------------------------


// mux accum_oc_h_w to acc_oc_w

always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        bias_h_cnt_r <= 3'd0;
    end
    else if(pipe1_vld_w && pipe1_rdy_w) begin
        bias_h_cnt_r <= is_bias_end_w ? 'd0 : bias_h_cnt_r + 'd1 ;
    end
end
assign is_bias_end_w = bias_h_cnt_r == 'd3 ;

always@(*)begin
    case(bias_h_cnt_r)
        3'd0: begin
            acc_0_w = accum_0_0_w ;
            acc_1_w = accum_1_0_w ;
            acc_2_w = accum_2_0_w ;
            acc_3_w = accum_3_0_w ;
        end
        3'd1: begin
            acc_0_w = accum_0_1_w ;
            acc_1_w = accum_1_1_w ;
            acc_2_w = accum_2_1_w ;
            acc_3_w = accum_3_1_w ; 
        end
        3'd2: begin
            acc_0_w = accum_0_2_w ;
            acc_1_w = accum_1_2_w ;
            acc_2_w = accum_2_2_w ;
            acc_3_w = accum_3_2_w ; 
        end
        3'd3: begin
            acc_0_w = accum_0_3_w ;
            acc_1_w = accum_1_3_w ;
            acc_2_w = accum_2_3_w ;
            acc_3_w = accum_3_3_w ;  
        end                     
        default: begin
            acc_0_w = 'd0         ;
            acc_1_w = 'd0         ;
            acc_2_w = 'd0         ;
            acc_3_w = 'd0         ;     
        end    
    endcase
end


assign  bias_0_w = bias_unpack_c_0_w ;
assign  bias_1_w = bias_unpack_c_1_w ;
assign  bias_2_w = bias_unpack_c_2_w ;
assign  bias_3_w = bias_unpack_c_3_w ;

pu_bias_add_pipe1 #(
    .PE_OUTPUT_WD      ( PE_OUTPUT_WD + 2   )   ,
    .PE_COL_NUM        ( 32                 )   ,
    .ACCUM_OUTPUT_WD   ( PE_OUTPUT_WD + 2   )   ,
    .BIAS_WD           ( BIAS_RF_WD )
)
pu_pipe1_u
(
    .clk                   (clk                        )   ,
    .rstn                  (rstn                       )   ,
    .pu_accum_bias_p1_vld_i(pipe1_vld_w                )   ,
    .pu_accum_bias_p1_rdy_o(pipe1_rdy_w                )   ,                              
    .acc_0_i               (acc_0_w                    )   ,  // one row of oc0
    .acc_1_i               (acc_1_w                    )   ,  // one row of oc1
    .acc_2_i               (acc_2_w                    )   ,  // one row of oc2
    .acc_3_i               (acc_3_w                    )   ,  // one row of oc3
    .bias_oc0_i            (bias_0_w                   )   ,
    .bias_oc1_i            (bias_1_w                   )   ,
    .bias_oc2_i            (bias_2_w                   )   ,
    .bias_oc3_i            (bias_3_w                   )   ,  
    .pu_accum_bias_p1_vld_o(pipe2_vld_w                )   ,
    .pu_accum_bias_p1_rdy_i(pipe2_rdy_w                )   ,
    .conv_oc0_o            (conv_oc0_w                 )   ,
    .conv_oc1_o            (conv_oc1_w                 )   ,
    .conv_oc2_o            (conv_oc2_w                 )   ,
    .conv_oc3_o            (conv_oc3_w                 )   
);


//----------------------------------------------------------------------------------------------------------

//                PIPE2:      RELU MUL     

//----------------------------------------------------------------------------------------------------------


  pu_hbm_pipe #(
     .HBM_IN_WD        (PE_OUTPUT_WD + 2    )    ,
     .HBM_PARAM_WD     (16                  )    ,  
     .HBM_MUL_WD       (PE_OUTPUT_WD + 2 + 16)   , 
     .HBM_OUT_WD       (8                   )    ,
     .PE_COL_NUM       (32                  ) 
    )
    pu_pipe2_u
    (
    
        .clk                  (clk              ),
        .rstn                 (rstn             ),
    
        .hbm_vld_i            (pipe2_vld_w            ),
        .hbm_rdy_o            (pipe2_rdy_w            ),   

        .pu_prelu_en_i        (pu_prelu_en_r          ),
        .pu_hbm_shift_i       ( pu_hbm_shift_r        ), 
        .layer_cnt_i          (layer_cnt_r            ),                     
        .conv_oc0_i           ( conv_oc0_w            ),  // one row of oc0
        .conv_oc1_i           ( conv_oc1_w            ),  // one row of oc1
        .conv_oc2_i           ( conv_oc2_w            ),  // one row of oc2
        .conv_oc3_i           ( conv_oc3_w            ),  // one row of oc3
        
        .hbm_para_oc0_i       ( hbm_unpack_c_0_w             ),     //16bit
        .hbm_para_oc1_i       ( hbm_unpack_c_0_w             ),
        .hbm_para_oc2_i       ( hbm_unpack_c_0_w             ),
        .hbm_para_oc3_i       ( hbm_unpack_c_0_w             ),  
    
        .hbm_vld_o            (pipe3_vld_w              ),
        .hbm_rdy_i            (pipe3_rdy_w             ),
     
        .hbm_oc0_o            (prelu_oc0_w              ),
        .hbm_oc1_o            (prelu_oc1_w              ),
        .hbm_oc2_o            (prelu_oc2_w              ),
        .hbm_oc3_o            (prelu_oc3_w              )
    );

assign hs_in_pipe2_w = pipe2_vld_w & pipe2_rdy_w ;
assign hs_in_pipe3_w = pipe3_vld_w && pipe3_rdy_w ;




//----------------------------------------------------------------------------------------------------------

//                PIPE3:      ADD RESI

//----------------------------------------------------------------------------------------------------------

// resi read 


reg    [6   -1 : 0]      y_resi_rd_rot_cnt0_r ;
reg    [6   -1 : 0]      y_resi_rd_rot_cnt1_r ;
wire                     is_y_resi_rd_rot_end0_w ;
wire                     is_y_resi_rd_rot_end1_w ;

reg    [6   -1 : 0]      xy_resi_rd_rot_cnt0_r ;
reg    [6   -1 : 0]      xy_resi_rd_rot_cnt1_r ;
wire                     is_xy_resi_rd_rot_end0_w ;
wire                     is_xy_resi_rd_rot_end1_w ;

assign y_resi_rd_rot_len_w = tile_num_x_r  ;   

//y  rd 0
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        y_resi_rd_rot_cnt0_r <= 'd1 ;
    end
    else if(tile_switch_i & model_proc_r == DM)begin
        y_resi_rd_rot_cnt0_r <= is_y_resi_rd_rot_end0_w ? 'd0 : y_resi_rd_rot_cnt0_r + 'd1 ;
    end
end

assign is_y_resi_rd_rot_end0_w = y_resi_rd_rot_cnt0_r == y_resi_rd_rot_len_w ;

//y  rd 1
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        y_resi_rd_rot_cnt1_r <= 'd1 ;
    end
    else if(tile_switch_i & model_proc_r == SR)begin
        y_resi_rd_rot_cnt1_r <= is_y_resi_rd_rot_end1_w ? 'd0 : y_resi_rd_rot_cnt1_r + 'd1 ;
    end
end

assign is_y_resi_rd_rot_end1_w = y_resi_rd_rot_cnt1_r == y_resi_rd_rot_len_w ;

//xy rd 0

assign xy_resi_rd_rot_len_w = tile_num_x_r  + 'd1;   

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        xy_resi_rd_rot_cnt0_r <= 'd1 ;
    end
    else if(tile_switch_i & model_proc_r == DM)begin
        xy_resi_rd_rot_cnt0_r <= is_xy_resi_rd_rot_end0_w ? 'd0 : xy_resi_rd_rot_cnt0_r + 'd1 ;
    end
end

assign is_xy_resi_rd_rot_end0_w = xy_resi_rd_rot_cnt0_r == xy_resi_rd_rot_len_w ;

// xy rd 1
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        xy_resi_rd_rot_cnt1_r <= 'd1 ;
    end
    else if(tile_switch_i & model_proc_r == SR)begin
        xy_resi_rd_rot_cnt1_r <= is_xy_resi_rd_rot_end1_w ? 'd0 : xy_resi_rd_rot_cnt1_r + 'd1 ;
    end
end

assign is_xy_resi_rd_rot_end1_w = xy_resi_rd_rot_cnt1_r == xy_resi_rd_rot_len_w ;


always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        resi_rd_line_cnt_r <= 'd0;
    end
    else if(layer_start_i)begin 
        resi_rd_line_cnt_r <= 'd0;
    end
    else if(hs_in_pipe3_w)begin
        resi_rd_line_cnt_r <= resi_rd_line_cnt_r == 'd3 ? 'd0 : resi_rd_line_cnt_r + 'd1 ;
    end
end
assign is_resi_rd_frt_3lines_w      =  (tile_h_cnt_r == 'd0) && (resi_rd_line_cnt_r == 'd0 | 
                                        resi_rd_line_cnt_r == 'd1 | 
                                        resi_rd_line_cnt_r == 'd2 );

assign is_frt_strip_w               =  strip_cnt_r == 'd0 ;
assign is_norm_strip_w              =  ~is_frt_strip_w    ;

assign is_resi_rd_w       =   res_proc_type_r == RESI_RD                                     ;

// rd x_resi when pe finish a 32w x 4h x 4c block 
assign x_resi_rd_en_o     = {16{is_resi_rd_w & pu2pe_rdy_o & pe2pu_vld_i }}                  ;
assign x_resi_rd_addr_o   = {tile_oc_cnt_r[4 -1  : 2], tile_h_cnt_r[5 -1 : 2] }              ;  
// rd y_resi and xy_resi when pe finish a 32w x 4h x 4c block 
assign y_resi_rd_en_o     = {12{is_resi_rd_w & pu2pe_rdy_o & pe2pu_vld_i }}                  ;
assign y_resi_rd_addr_o   = model_proc_r == DM ? {y_resi_rd_rot_cnt0_r , tile_oc_cnt_r[4 -1  : 2]} :
                                                 {y_resi_rd_rot_cnt1_r , tile_oc_cnt_r[4 -1  : 2]}  ;  
// rd y_resi and xy_resi when pe finish a 32w x 4h x 4c block 
assign xy_resi_rd_en_o     = {12{is_resi_rd_w & pu2pe_rdy_o & pe2pu_vld_i }}                  ;  
assign xy_resi_rd_addr_o   = model_proc_r == DM ? {xy_resi_rd_rot_cnt0_r ,tile_oc_cnt_r[4 -1  : 2] } :
                                                  {xy_resi_rd_rot_cnt1_r ,tile_oc_cnt_r[4 -1  : 2] }  ;     


assign   cat_resi_frt_3lines_c0_h0_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c0_h0_i, y_resi_rd_dat_c0_h0_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c0_h1_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c0_h1_i, y_resi_rd_dat_c0_h1_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c0_h2_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c0_h2_i, y_resi_rd_dat_c0_h2_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c1_h0_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c1_h0_i, y_resi_rd_dat_c1_h0_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c1_h1_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c1_h1_i, y_resi_rd_dat_c1_h1_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c1_h2_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c1_h2_i, y_resi_rd_dat_c1_h2_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c2_h0_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c2_h0_i, y_resi_rd_dat_c2_h0_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c2_h1_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c2_h1_i, y_resi_rd_dat_c2_h1_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c2_h2_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c2_h2_i, y_resi_rd_dat_c2_h2_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c3_h0_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c3_h0_i, y_resi_rd_dat_c3_h0_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c3_h1_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c3_h1_i, y_resi_rd_dat_c3_h1_i };    // xy / y resi mem read is invalid in first strip 
assign   cat_resi_frt_3lines_c3_h2_w = is_frt_strip_w ? 'd0 : { xy_resi_rd_dat_c3_h2_i, y_resi_rd_dat_c3_h2_i };    // xy / y resi mem read is invalid in first strip 

always @(*) begin
        case(resi_rd_line_cnt_r[2 -1 : 0])
        2'd0: begin 
                resi_oc0_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c0_h0_w  : x_resi_rd_dat_c0_h0_i ;
                resi_oc1_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c1_h0_w  : x_resi_rd_dat_c1_h0_i ;
                resi_oc2_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c2_h0_w  : x_resi_rd_dat_c2_h0_i ;
                resi_oc3_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c3_h0_w  : x_resi_rd_dat_c3_h0_i ;
        end
        2'd1: begin
                resi_oc0_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c0_h1_w  : x_resi_rd_dat_c0_h1_i ;
                resi_oc1_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c1_h1_w  : x_resi_rd_dat_c1_h1_i ;
                resi_oc2_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c2_h1_w  : x_resi_rd_dat_c2_h1_i ;
                resi_oc3_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c3_h1_w  : x_resi_rd_dat_c3_h1_i ;
        end        
        2'd2: begin
                resi_oc0_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c0_h2_w  :x_resi_rd_dat_c0_h2_i ;
                resi_oc1_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c1_h2_w  :x_resi_rd_dat_c1_h2_i ;
                resi_oc2_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c2_h2_w  :x_resi_rd_dat_c2_h2_i ;
                resi_oc3_w = is_norm_strip_w & is_resi_rd_frt_3lines_w ? cat_resi_frt_3lines_c3_h2_w  :x_resi_rd_dat_c3_h2_i ;
        end     
        2'd3: begin
                resi_oc0_w = is_norm_strip_w ? x_resi_rd_dat_c0_h3_i : x_resi_rd_dat_c0_h3_i;
                resi_oc1_w = is_norm_strip_w ? x_resi_rd_dat_c1_h3_i : x_resi_rd_dat_c1_h3_i;
                resi_oc2_w = is_norm_strip_w ? x_resi_rd_dat_c2_h3_i : x_resi_rd_dat_c2_h3_i;
                resi_oc3_w = is_norm_strip_w ? x_resi_rd_dat_c3_h3_i : x_resi_rd_dat_c3_h3_i;
        end     
        default: begin
                resi_oc0_w = 'd0  ;
                resi_oc1_w = 'd0  ;
                resi_oc2_w = 'd0  ;
                resi_oc3_w = 'd0  ;
        end   
        endcase
end


pu_resi_add_pipe_p3 #(
    .PE_OUTPUT_WD    ( 8   )    ,
    .PE_COL_NUM      ( 32  )    ,
    .ACCUM_OUTPUT_WD ( 9   )    ,
    .RESI_WD         ( 8   )
)
pu_pipe3_u
(

   .clk                   (clk                         )  ,
   .rstn                  (rstn                        )  ,

   .pu_resi_add_p3_vld_i  (pipe3_vld_w                 )  ,
   .pu_resi_add_p3_rdy_o  (pipe3_rdy_w                 )  ,   
   .is_bypass_i           (~is_resi_rd_w               )  ,
           
   .prelu_0_i             (prelu_oc0_w                 )    ,  // one row of oc0
   .prelu_1_i             (prelu_oc1_w                 )    ,  // one row of oc1
   .prelu_2_i             (prelu_oc2_w                 )    ,  // one row of oc2
   .prelu_3_i             (prelu_oc3_w                 )    ,  // one row of oc3

   .resi_oc0_i            (resi_oc0_w                  )  ,
   .resi_oc1_i            (resi_oc1_w                  )  ,
   .resi_oc2_i            (resi_oc2_w                  )  ,
   .resi_oc3_i            (resi_oc3_w                  )  ,  

   .pu_resi_add_p3_vld_o  (pipe4_vld_w                 )  ,
   .pu_resi_add_p3_rdy_i  (pipe4_rdy_w                 )  ,

   .resi_oc0_o            (resi2lbm_oc0_w                )  ,
   .resi_oc1_o            (resi2lbm_oc1_w                )  ,
   .resi_oc2_o            (resi2lbm_oc2_w                )  ,
   .resi_oc3_o            (resi2lbm_oc3_w                )  

);

wire  [16 - 1 : 0]  lbm_para_oc0_w ;
wire  [16 - 1 : 0]  lbm_para_oc1_w ;
wire  [16 - 1 : 0]  lbm_para_oc2_w ;
wire  [16 - 1 : 0]  lbm_para_oc3_w ;



  pu_lbm_pipe #(
    .LBM_IN_WD   ( 11        )    ,
    .LBM_PARAM_WD( 16       )    ,  
    .LBM_MUL_WD  ( 27       )    , 
    .LBM_OUT_WD  ( 8        )    ,
    .PE_COL_NUM  ( 32       )    
   )pu_pipe4_u
   (
   
    .clk            ( clk                    )           ,
    .rstn           ( rstn                   )           ,
    .lbm_vld_i      ( pipe4_vld_w            )           ,
    .lbm_rdy_o      ( pipe4_rdy_w            )           ,       
    .pu_lbm_shift_i ( pu_lbm_shift_r[5 -1 : 0])           , 
    .is_bypass_i    ( res_proc_type_r !=  RESI_RD )           ,         
    .lbm_oc0_i      ( resi2lbm_oc0_w            )          ,  // one row of oc0
    .lbm_oc1_i      ( resi2lbm_oc1_w            )          ,  // one row of oc1
    .lbm_oc2_i      ( resi2lbm_oc2_w            )          ,  // one row of oc2
    .lbm_oc3_i      ( resi2lbm_oc3_w            )          ,  // one row of oc3
    .lbm_para_oc0_i ( lbm_unpack_c_0_w          )           ,
    .lbm_para_oc1_i ( lbm_unpack_c_1_w          )           ,
    .lbm_para_oc2_i ( lbm_unpack_c_2_w            )           ,
    .lbm_para_oc3_i ( lbm_unpack_c_3_w            )           ,  
    .lbm_vld_o      (pipe5_vld_w               )           ,
    .lbm_rdy_i      (pipe5_rdy_w               )           ,
    .lbm_oc0_o      (requant_oc0_w             )           ,
    .lbm_oc1_o      (requant_oc1_w             )           ,
    .lbm_oc2_o      (requant_oc2_w             )           ,
    .lbm_oc3_o      (requant_oc3_w             )        
 );


assign hs_in_eg_w = pipe5_vld_w & pipe5_rdy_w      ;

//---------------------

// X4 PIXEL SHIFFLE

// 4 output channels form a x4 width line

//---------------------



assign  ps_line_part0_w =  {requant_oc0_w[32 * 8 - 1 - 0  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 0  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 0  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 0  * 8 -:8], 
                            requant_oc0_w[32 * 8 - 1 - 1  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 1  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 1  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 1  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 2  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 2  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 2  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 2  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 3  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 3  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 3  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 3  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 4  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 4  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 4  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 4  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 5  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 5  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 5  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 5  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 6  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 6  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 6  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 6  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 7  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 7  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 7  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 7  * 8 -:8]
                            } ;    // w 0  - 31
assign  ps_line_part1_w =  {requant_oc0_w[32 * 8 - 1 - 8  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 8  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 8  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 8  * 8 -:8], 
                            requant_oc0_w[32 * 8 - 1 - 9  * 8 -:8], requant_oc1_w[32 * 8 - 1 - 9  * 8 -:8], requant_oc2_w[32 * 8 - 1 - 9  * 8 -:8], requant_oc3_w[32 * 8 - 1 - 9  * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 10 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 10 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 10 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 10 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 11 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 11 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 11 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 11 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 12 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 12 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 12 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 12 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 13 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 13 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 13 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 13 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 14 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 14 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 14 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 14 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 15 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 15 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 15 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 15 * 8 -:8]
                            }  ;   // w 32 - 63
assign  ps_line_part2_w =  {requant_oc0_w[32 * 8 - 1 - 16 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 16 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 16 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 16 * 8 -:8], 
                            requant_oc0_w[32 * 8 - 1 - 17 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 17 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 17 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 17 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 18 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 18 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 18 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 18 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 19 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 19 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 19 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 19 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 20 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 20 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 20 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 20 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 21 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 21 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 21 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 21 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 22 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 22 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 22 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 22 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 23 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 23 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 23 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 23 * 8 -:8]
                            }  ;    // w 64 - 95
assign  ps_line_part3_w =  {requant_oc0_w[32 * 8 - 1 - 24 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 24 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 24 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 24 * 8 -:8], 
                            requant_oc0_w[32 * 8 - 1 - 25 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 25 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 25 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 25 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 26 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 26 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 26 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 26 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 27 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 27 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 27 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 27 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 28 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 28 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 28 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 28 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 29 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 29 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 29 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 29 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 30 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 30 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 30 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 30 * 8 -:8],
                            requant_oc0_w[32 * 8 - 1 - 31 * 8 -:8], requant_oc1_w[32 * 8 - 1 - 31 * 8 -:8], requant_oc2_w[32 * 8 - 1 - 31 * 8 -:8], requant_oc3_w[32 * 8 - 1 - 31 * 8 -:8]
                            }  ;     // w 96 - 127



assign pipe5_rdy_w          = 1'b1;

assign is_requant_end_w     = requant_h_cnt_r == 'd3 ;
always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        requant_h_cnt_r <= 'd0;
    end
    else if(pipe5_vld_w & pipe5_rdy_w)begin
        requant_h_cnt_r <= is_requant_end_w ? 'd0 : requant_h_cnt_r + 'd1;
    end
end

always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        is_blk_done_dly_r <= 1'b0;
    end
    else begin
        is_blk_done_dly_r <= is_requant_end_w ;
    end
end


always @(*)begin
    case(requant_h_cnt_r)
        3'd0: fe_h_en_w = 4'b0001;
        3'd1: fe_h_en_w = 4'b0010;
        3'd2: fe_h_en_w = 4'b0100;
        3'd3: fe_h_en_w = 4'b1000;
    default:
          fe_h_en_w = 4'd0;
    endcase
end

wire     [16  - 1 : 0]   fe_buf_wr_en_w;

assign fe_buf_wr_en_w         = hs_in_eg_w ?  x4_ps_en_r ? {4{fe_h_en_w}} : 
                                                           {{4{fe_h_en_w[3]}}, {4{fe_h_en_w[2]}},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} :
                                              'd0 ;
wire [16 -1 :0] fe_buf_wr_en_t ;
    buf_en_trans#(
        .H_NUM(4),
        .C_NUM(4)
    )
    trans_h4_c4_u5
    (
        .buf_en_i(fe_buf_wr_en_w      ),
        .buf_en_o(fe_buf_wr_en_t      )
    );


//------------------

// fe write

//------------------

reg           [8 -1 : 0]  blk_cnt_r ;

always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        blk_cnt_r <= 'd0;
    end
    else if(pu2pe_rdy_o & pe2pu_vld_i) begin
        blk_cnt_r <= {tile_oc_cnt_r[4 -1 :2], tile_h_cnt_r[5 - 1 :2] } ;
    end
end


always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        fe_buf_wr_addr_r <= 'd0;
    end
    else begin
        fe_buf_wr_addr_r <= hs_in_eg_w ? blk_cnt_r : 'd0;
    end
end
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        fe_buf_wr_en_r <= 16'd0;
    end
    else begin
        fe_buf_wr_en_r <= hs_in_eg_w ? fe_buf_wr_en_t : 16'd0 ;
    end
end
always @(posedge clk)begin

    if(hs_in_eg_w)

     fe_buf_wr_dat_0_0_r <=  x4_ps_en_r ? ps_line_part0_w : requant_oc0_w ;
     fe_buf_wr_dat_0_1_r <=  x4_ps_en_r ? ps_line_part1_w : requant_oc0_w ;
     fe_buf_wr_dat_0_2_r <=  x4_ps_en_r ? ps_line_part2_w : requant_oc0_w ;
     fe_buf_wr_dat_0_3_r <=  x4_ps_en_r ? ps_line_part3_w : requant_oc0_w ;

     fe_buf_wr_dat_1_0_r <=  x4_ps_en_r ? ps_line_part0_w : requant_oc1_w ;  
     fe_buf_wr_dat_1_1_r <=  x4_ps_en_r ? ps_line_part1_w : requant_oc1_w ;  
     fe_buf_wr_dat_1_2_r <=  x4_ps_en_r ? ps_line_part2_w : requant_oc1_w ;  
     fe_buf_wr_dat_1_3_r <=  x4_ps_en_r ? ps_line_part3_w : requant_oc1_w ;  

     fe_buf_wr_dat_2_0_r <=  x4_ps_en_r ? ps_line_part0_w : requant_oc2_w ;  
     fe_buf_wr_dat_2_1_r <=  x4_ps_en_r ? ps_line_part1_w : requant_oc2_w ;  
     fe_buf_wr_dat_2_2_r <=  x4_ps_en_r ? ps_line_part2_w : requant_oc2_w ;  
     fe_buf_wr_dat_2_3_r <=  x4_ps_en_r ? ps_line_part3_w : requant_oc2_w ;  

     fe_buf_wr_dat_3_0_r <=  x4_ps_en_r ? ps_line_part0_w : requant_oc3_w ;  
     fe_buf_wr_dat_3_1_r <=  x4_ps_en_r ? ps_line_part1_w : requant_oc3_w ;  
     fe_buf_wr_dat_3_2_r <=  x4_ps_en_r ? ps_line_part2_w : requant_oc3_w ;  
     fe_buf_wr_dat_3_3_r <=  x4_ps_en_r ? ps_line_part3_w : requant_oc3_w ;  

end
/*
assign  fe_buf_wr_en_o        =  fe_buf_wr_en_t      ;
assign  fe_buf_wr_addr_o      =  blk_cnt_r           ;
assign  fe_buf_wr_dat_0_0_o   =  x4_ps_en_r ? ps_line_part0_w : requant_oc0_w ;
assign  fe_buf_wr_dat_0_1_o   =  x4_ps_en_r ? ps_line_part1_w : requant_oc0_w ;
assign  fe_buf_wr_dat_0_2_o   =  x4_ps_en_r ? ps_line_part2_w : requant_oc0_w ;
assign  fe_buf_wr_dat_0_3_o   =  x4_ps_en_r ? ps_line_part3_w : requant_oc0_w ;
assign  fe_buf_wr_dat_1_0_o   =  x4_ps_en_r ? ps_line_part0_w : requant_oc1_w ;  
assign  fe_buf_wr_dat_1_1_o   =  x4_ps_en_r ? ps_line_part1_w : requant_oc1_w ;  
assign  fe_buf_wr_dat_1_2_o   =  x4_ps_en_r ? ps_line_part2_w : requant_oc1_w ;  
assign  fe_buf_wr_dat_1_3_o   =  x4_ps_en_r ? ps_line_part3_w : requant_oc1_w ;  
assign  fe_buf_wr_dat_2_0_o   =  x4_ps_en_r ? ps_line_part0_w : requant_oc2_w ;  
assign  fe_buf_wr_dat_2_1_o   =  x4_ps_en_r ? ps_line_part1_w : requant_oc2_w ;  
assign  fe_buf_wr_dat_2_2_o   =  x4_ps_en_r ? ps_line_part2_w : requant_oc2_w ;  
assign  fe_buf_wr_dat_2_3_o   =  x4_ps_en_r ? ps_line_part3_w : requant_oc2_w ;  
assign  fe_buf_wr_dat_3_0_o   =  x4_ps_en_r ? ps_line_part0_w : requant_oc3_w ;  
assign  fe_buf_wr_dat_3_1_o   =  x4_ps_en_r ? ps_line_part1_w : requant_oc3_w ;  
assign  fe_buf_wr_dat_3_2_o   =  x4_ps_en_r ? ps_line_part2_w : requant_oc3_w ;  
assign  fe_buf_wr_dat_3_3_o   =  x4_ps_en_r ? ps_line_part3_w : requant_oc3_w ;  
*/
assign  fe_buf_wr_en_o        =  fe_buf_wr_en_r      ;
assign  fe_buf_wr_addr_o      =  fe_buf_wr_addr_r    ;
assign  fe_buf_wr_dat_0_0_o   =  fe_buf_wr_dat_0_0_r ;
assign  fe_buf_wr_dat_0_1_o   =  fe_buf_wr_dat_0_1_r ;
assign  fe_buf_wr_dat_0_2_o   =  fe_buf_wr_dat_0_2_r ;
assign  fe_buf_wr_dat_0_3_o   =  fe_buf_wr_dat_0_3_r ;
assign  fe_buf_wr_dat_1_0_o   =  fe_buf_wr_dat_1_0_r ;  
assign  fe_buf_wr_dat_1_1_o   =  fe_buf_wr_dat_1_1_r ;  
assign  fe_buf_wr_dat_1_2_o   =  fe_buf_wr_dat_1_2_r ;  
assign  fe_buf_wr_dat_1_3_o   =  fe_buf_wr_dat_1_3_r ;  
assign  fe_buf_wr_dat_2_0_o   =  fe_buf_wr_dat_2_0_r ;  
assign  fe_buf_wr_dat_2_1_o   =  fe_buf_wr_dat_2_1_r ;  
assign  fe_buf_wr_dat_2_2_o   =  fe_buf_wr_dat_2_2_r ;  
assign  fe_buf_wr_dat_2_3_o   =  fe_buf_wr_dat_2_3_r ;  
assign  fe_buf_wr_dat_3_0_o   =  fe_buf_wr_dat_3_0_r ;  
assign  fe_buf_wr_dat_3_1_o   =  fe_buf_wr_dat_3_1_r ;  
assign  fe_buf_wr_dat_3_2_o   =  fe_buf_wr_dat_3_2_r ;  
assign  fe_buf_wr_dat_3_3_o   =  fe_buf_wr_dat_3_3_r ;   
//------------------

// x olp write

//------------------



always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        pu2sch_olp_addr_r <= 'd0;
    end
    else if(is_tile_done_w) begin
        pu2sch_olp_addr_r <= {pu2sch_olp_addr_r[100 -1 -10: 0], {layer_cnt_r, 6'd0} };
    end
end
assign pu2sch_olp_addr_o       = pu2sch_olp_addr_r                               ;
        
wire      [16 -1 : 0 ]    x_olp_buf_wr_en_w ;
assign  x_olp_buf_wr_en_w        = hs_in_eg_w    ? {{4{fe_h_en_w[3]}}, {4{fe_h_en_w[2]}},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} : 'd0  ;

    buf_en_trans#(
        .H_NUM(4),
        .C_NUM(4)
    )
    trans_h4_c4_u4
    (
        .buf_en_i(x_olp_buf_wr_en_w      ),
        .buf_en_o(x_olp_buf_wr_en_o      )
    );



assign  x_olp_buf_wr_addr_o      = {layer_cnt_r,  {tile_oc_cnt_r[2+:2], tile_h_cnt_r[2+:3]} }                      ;   

assign  x_olp_buf_wr_dat_0_0_o   =  requant_oc0_w[0  +:   X_OLP_DAT_WD           ] ;
assign  x_olp_buf_wr_dat_0_1_o   =  requant_oc0_w[0  +:   X_OLP_DAT_WD           ] ;
assign  x_olp_buf_wr_dat_0_2_o   =  requant_oc0_w[0  +:   X_OLP_DAT_WD           ] ;
assign  x_olp_buf_wr_dat_0_3_o   =  requant_oc0_w[0  +:   X_OLP_DAT_WD           ] ;
    
assign  x_olp_buf_wr_dat_1_0_o   =  requant_oc1_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_1_1_o   =  requant_oc1_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_1_2_o   =  requant_oc1_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_1_3_o   =  requant_oc1_w[0  +:   X_OLP_DAT_WD           ] ;  
    
assign  x_olp_buf_wr_dat_2_0_o   =  requant_oc2_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_2_1_o   =  requant_oc2_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_2_2_o   =  requant_oc2_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_2_3_o   =  requant_oc2_w[0  +:   X_OLP_DAT_WD           ] ;  
    
assign  x_olp_buf_wr_dat_3_0_o   =  requant_oc3_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_3_1_o   =  requant_oc3_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_3_2_o   =  requant_oc3_w[0  +:   X_OLP_DAT_WD           ] ;  
assign  x_olp_buf_wr_dat_3_3_o   =  requant_oc3_w[0  +:   X_OLP_DAT_WD           ] ;       

//------------------

// y olp write


//  tile_num_in_x = 8
/***********************************  tile x 0 - 7  ***********************************/

// tile line 0 =====  | * 0 * | * 1 * |  * 2 * | * 3 * | * 4 * | * 5 * | * 6 * | * 7 * |
// tile line 1 =====  | * 8 * | * 0 * |  * 1 * | * 2 * | * 3 * | * 4 * | * 5 * | * 6 * |
// tile line 2 =====  | * 7 * | * 8 * |  * 0 * | * 1 * | * 2 * | * 3 * | * 4 * | * 5 * |
// tile line 3 =====  | * 6 * | * 7 * |  * 8 * | * 0 * | * 1 * | * 2 * | * 3 * | * 4 * |
// tile line 4 =====  | * 5 * | * 6 * |  * 7 * | * 8 * | * 0 * | * 1 * | * 2 * | * 3 * |

//------------------


assign is_1x1_conv_w            =  knl_size_r == CONV1                             ;    
assign is_3x3_conv_w            =  knl_size_r == CONV3                             ;
assign is_5x5_conv_w            =  knl_size_r == CONV5                             ;
assign y_olp_rot_len_w          =  tile_num_x_r                                    ;


wire                is_y_olp_rot_end0_w;
wire                is_y_olp_rot_end1_w;
reg   [6 -1 :0]      y_olp_rot_cnt0_r;
reg   [6 -1 :0]      y_olp_rot_cnt1_r;


// DMC model
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_olp_rot_cnt0_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == DMC) begin
        y_olp_rot_cnt0_r <=is_y_olp_rot_end0_w ? 'd0 : y_olp_rot_cnt0_r + 'd1 ;
    end
end

assign is_y_olp_rot_end0_w = y_olp_rot_cnt0_r == y_olp_rot_len_w ;

//SR model
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_olp_rot_cnt1_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == SR) begin
        y_olp_rot_cnt1_r <=is_y_olp_rot_end1_w ? 'd0 : y_olp_rot_cnt1_r + 'd1 ;
    end
end

assign is_y_olp_rot_end1_w = y_olp_rot_cnt1_r == y_olp_rot_len_w ;


always @(posedge clk  or negedge rstn) begin
    if(~rstn) begin
        y_olp_buf_cur_layer_base_addr <= 'd0;
    end
    else if(tile_switch_i ) begin
        y_olp_buf_cur_layer_base_addr <= 'd0;
    end
    else if(is_tile_done_w & is_5x5_conv_w) begin
        y_olp_buf_cur_layer_base_addr <= y_olp_buf_cur_layer_base_addr + {y_olp_rot_len_w, 2'b0} ;
                                                                                      
    end
    else if(is_tile_done_w & ~is_5x5_conv_w)begin
        y_olp_buf_cur_layer_base_addr <= y_olp_buf_cur_layer_base_addr + {y_olp_rot_len_w, 1'b0} ;
    end
end
    
always @(posedge clk) begin
    if(~rstn)begin
        y_olp_buf_wr_addr_r <= 'd0;
    end
    else if(model_proc_r == DMC)begin
        y_olp_buf_wr_addr_r       <=  y_olp_buf_cur_layer_base_addr  +  is_5x5_conv_w ? {y_olp_rot_cnt0_r, tile_oc_cnt_r[2+:2]} : 
                                                                                     {1'b0, y_olp_rot_cnt0_r, tile_oc_cnt_r[3+:1]} ; //TODO: tile_oc_cnt_r may update ealier, count oc in egress 
    end
    else  begin
       y_olp_buf_wr_addr_r       <=  y_olp_buf_cur_layer_base_addr  +  is_5x5_conv_w ? {y_olp_rot_cnt1_r, tile_oc_cnt_r[2+:2]} : 
                                                                                     {1'b0, y_olp_rot_cnt1_r, tile_oc_cnt_r[3+:1]} ; 
    end
end



/*
 assign y_olp_buf_wr_en_w        =  is_5x5_conv_w    ?  {{4{fe_h_en_w[3]}}, {4{fe_h_en_w[2]}},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} : 
                                    tile_oc_cnt_r[2] ?  {{4{fe_h_en_w[1]}}, {4{fe_h_en_w[0]}},  {4{1'b0        }},  {4{1'b0        }}} :
                                                        {{4{1'b0        }}, {4{1'b0        }},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} ; */
 assign y_olp_buf_wr_en_w        =  {{4{fe_h_en_w[3]}}, {4{fe_h_en_w[2]}},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} ;

wire  [16 -1 : 0] y_olp_buf_wr_en_trans_w  ;
wire  [16 -1 : 0] y_olp_buf_wr_en_trans_w1 ;
reg   [16 -1 : 0] y_olp_buf_wr_en_trans_w2 ;
wire  [16 -1 : 0] olp_en_knl3_0            ;
wire  [16 -1 : 0] olp_en_knl3_1            ;
wire  [16 -1 : 0] olp_en_knl3_2            ;
wire  [16 -1 : 0] olp_en_knl3_3            ;

wire              is_tile_lst2_h_w         ;
wire              is_tile_lst_knl5_h_w     ;
wire              is_tile_lst_knl3_h_w     ;


    buf_en_trans#(
        .H_NUM(4),
        .C_NUM(4)
    )
    trans_h4_c4_u3
    (
        .buf_en_i(y_olp_buf_wr_en_w      ),
        .buf_en_o(y_olp_buf_wr_en_trans_w)
    );


assign lst_h4_bias = tile_h_i[1:0];
assign is_tile_lst_knl5_h_w = tile_h_i < 4 ? 1 : (tile_h_cnt_r >= (((tile_h_i >> 2) - 1) << 2) ? 1 : 0);
assign is_tile_lst_knl3_h_w = tile_h_i < 4 ? 1 : (tile_h_cnt_r >= (((tile_h_i >> 2) - (lst_h4_bias[1] == 0)) << 2) ? 1 : 0);
assign is_tile_lst2_h_w = ksize_nxt == 5 ? is_tile_lst_knl5_h_w : is_tile_lst_knl3_h_w;


assign y_olp_buf_wr_en_trans_w1 = is_tile_lst_h_w ? ({y_olp_buf_wr_en_trans_w[15:12] << (lst_h4_bias == 0 ? 0 : 4 - lst_h4_bias),
                                                      y_olp_buf_wr_en_trans_w[11:8] << (lst_h4_bias == 0 ? 0 : 4 - lst_h4_bias),
                                                      y_olp_buf_wr_en_trans_w[7:4] << (lst_h4_bias == 0 ? 0 : 4 - lst_h4_bias),
                                                      y_olp_buf_wr_en_trans_w[3:0] << (lst_h4_bias == 0 ? 0 : 4 - lst_h4_bias)})
                                                    :{y_olp_buf_wr_en_trans_w[15:12] >> lst_h4_bias, y_olp_buf_wr_en_trans_w[11:8] >> lst_h4_bias,
                                                      y_olp_buf_wr_en_trans_w[7:4] >> lst_h4_bias, y_olp_buf_wr_en_trans_w[3:0] >> lst_h4_bias};


assign olp_en_knl3_0 = is_tile_lst_h_w ? ({(y_olp_buf_wr_en_trans_w[15:12] >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[11:8] >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[7:4] >> 2)  << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[3:0] >> 2)  << tile_oc_cnt_r[2:1]}): 0;

assign olp_en_knl3_1 = is_tile_lst_h_w ? ({(y_olp_buf_wr_en_trans_w[15:12] << 3 >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[11:8] << 3 >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[7:4] << 3 >> 2)  << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[3:0] << 3 >> 2)  << tile_oc_cnt_r[2:1]}):
                                              ({(y_olp_buf_wr_en_trans_w[15:12] >> 3) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[11:8] >> 3) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[7:4] >> 3)  << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[3:0] >> 3)  << tile_oc_cnt_r[2:1]});

assign olp_en_knl3_2 = is_tile_lst_h_w ? ({(y_olp_buf_wr_en_trans_w[15:12] << 2 >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[11:8] << 2 >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[7:4] << 2 >> 2)  << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[3:0] << 2 >> 2)  << tile_oc_cnt_r[2:1]}): 0;

assign olp_en_knl3_3 = is_tile_lst_h_w ? ({(y_olp_buf_wr_en_trans_w[15:12] >> 1 << 2 >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[11:8] >> 1 << 2 >> 2) << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[7:4] >> 1 << 2 >> 2)  << tile_oc_cnt_r[2:1],
                                                (y_olp_buf_wr_en_trans_w[3:0] >> 1 << 2 >> 2)  << tile_oc_cnt_r[2:1]}): 0;


always @(*)
begin
    case(lst_h4_bias)
    2'b00: y_olp_buf_wr_en_trans_w2 = olp_en_knl3_0;
    2'b01: y_olp_buf_wr_en_trans_w2 = olp_en_knl3_1;
    2'b10: y_olp_buf_wr_en_trans_w2 = olp_en_knl3_2;
    2'b11: y_olp_buf_wr_en_trans_w2 = olp_en_knl3_3;
    default: y_olp_buf_wr_en_trans_w2 = olp_en_knl3_0;
    endcase
end


assign  y_olp_buf_wr_en_o        =  is_tile_lst2_h_w & hs_in_eg_w ? (ksize_nxt == 5 ? y_olp_buf_wr_en_trans_w1 : y_olp_buf_wr_en_trans_w2 )   : 'd0  ;
assign  y_olp_buf_wr_addr_o      =  (ksize_nxt == 3 ? y_olp_buf_wr_addr_r >> 1 : y_olp_buf_wr_addr_r) + layer_cnt_r * Y_L234_DEPTH;              

assign  y_olp_buf_wr_dat_0_0_o   =  requant_oc0_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;
assign  y_olp_buf_wr_dat_0_1_o   =  requant_oc0_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;
assign  y_olp_buf_wr_dat_0_2_o   =  requant_oc0_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;
assign  y_olp_buf_wr_dat_0_3_o   =  requant_oc0_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;
    
assign  y_olp_buf_wr_dat_1_0_o   =  requant_oc1_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_1_1_o   =  requant_oc1_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_1_2_o   =  requant_oc1_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_1_3_o   =  requant_oc1_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
    
assign  y_olp_buf_wr_dat_2_0_o   =  requant_oc2_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_2_1_o   =  requant_oc2_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_2_2_o   =  requant_oc2_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_2_3_o   =  requant_oc2_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
    
assign  y_olp_buf_wr_dat_3_0_o   =  requant_oc3_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_3_1_o   =  requant_oc3_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_3_2_o   =  requant_oc3_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;  
assign  y_olp_buf_wr_dat_3_3_o   =  requant_oc3_w[XY_OLP_DAT_WD  +:   Y_OLP_DAT_WD           ] ;   

//------------------

// x y olp write

//  tile_num_in_x = 8

/***********************************  tile x 0 - 7  ***********************************/

// tile line 0 =====  | * 0 * | * 1 * |  * 2 * | * 3 * | * 4 * | * 5 * | * 6 * | * 7 * |
// tile line 1 =====  | * 8 * | * 9 * |  * 0 * | * 1 * | * 2 * | * 3 * | * 4 * | * 5 * |
// tile line 2 =====  | * 6 * | * 7 * |  * 8 * | * 9 * | * 0 * | * 1 * | * 2 * | * 3 * |
// tile line 3 =====  | * 4 * | * 5 * |  * 6 * | * 7 * | * 8 * | * 9 * | * 0 * | * 1 * |
// tile line 4 =====  | * 2 * | * 3 * |  * 4 * | * 5 * | * 6 * | * 7 * | * 8 * | * 9 * |

//------------------


assign xy_olp_rot_len_w          =  tile_num_x_r  + 'd1                                  ;    

assign half_xy_olp_rot_len_w = (xy_olp_rot_len_w + 'd1) >> 1  ;     


wire                   is_xy_olp_rot_end0_w ;
wire                   is_xy_olp_rot_end1_w ;

reg [6  -1 :0]         xy_olp_rot_cnt0_r;
reg [6  -1 :0]         xy_olp_rot_cnt1_r;

reg    [XY_OLP_ADR_WD                       -2: 0]     xy_evn_dndm_olp_buf_wr_addr_r       ;
reg    [XY_OLP_ADR_WD                       -2: 0]     xy_odd_dndm_olp_buf_wr_addr_r       ;
reg    [XY_OLP_ADR_WD                       -2: 0]     xy_evn_sr_olp_buf_wr_addr_r         ;
reg    [XY_OLP_ADR_WD                       -2: 0]     xy_odd_sr_olp_buf_wr_addr_r         ;
reg    [XY_OLP_ADR_WD                       -2: 0]     xy_olp_buf_wr_addr_r                ;
wire   [XY_OLP_ADR_WD                       -2: 0]     xy_olp_buf_wr_addr_w                ;

// ============================= xy olp buf en & addr ====================== //


//DMC
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        xy_olp_rot_cnt0_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == DM) begin
        xy_olp_rot_cnt0_r <=is_xy_olp_rot_end0_w ? 'd0 : xy_olp_rot_cnt0_r + 'd1 ;
    end
end

//assign is_xy_olp_rot_end0_w = xy_olp_rot_cnt0_r == xy_olp_rot_len_w ;
assign is_xy_olp_rot_end0_w = xy_olp_rot_cnt0_r == tile_tot_num_x - 1 ;

//SR
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        xy_olp_rot_cnt1_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == SR) begin
        xy_olp_rot_cnt1_r <=is_xy_olp_rot_end1_w ? 'd0 : xy_olp_rot_cnt1_r + 'd1 ;
    end
end

//assign is_xy_olp_rot_end1_w = xy_olp_rot_cnt1_r == xy_olp_rot_len_w ;
assign is_xy_olp_rot_end1_w = xy_olp_rot_cnt1_r == tile_tot_num_x - 1 ;


always @(posedge clk  or negedge rstn) begin
    if(~rstn) begin
        xy_olp_buf_cur_layer_base_addr <= 'd0;
    end
    else if(tile_switch_i ) begin
        xy_olp_buf_cur_layer_base_addr <= 'd0;
    end
    else if(is_tile_done_w) begin
        xy_olp_buf_cur_layer_base_addr <= xy_olp_buf_cur_layer_base_addr + is_5x5_conv_w ? {half_xy_olp_rot_len_w, 2'b0} :
                                                                                           {half_xy_olp_rot_len_w, 1'b0} ;
    end
end
   
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        xy_evn_dndm_olp_buf_wr_addr_r <= 0;
    else if(model_proc_r == DM && wr_xy_olp_evn_en_w && tile_switch_i)
        xy_evn_dndm_olp_buf_wr_addr_r <= xy_evn_dndm_olp_buf_wr_addr_r == (tile_tot_num_x >> 1) ? 0 : xy_evn_dndm_olp_buf_wr_addr_r + 1;
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        xy_evn_sr_olp_buf_wr_addr_r <= 0;
    else if(model_proc_r == SR && wr_xy_olp_evn_en_w && tile_switch_i)
        xy_evn_sr_olp_buf_wr_addr_r <= xy_evn_sr_olp_buf_wr_addr_r == (tile_tot_num_x >> 1) ? 0 : xy_evn_sr_olp_buf_wr_addr_r + 1;
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        xy_odd_dndm_olp_buf_wr_addr_r <= 0;
    else if(model_proc_r == DM && wr_xy_olp_odd_en_w && tile_switch_i)
        xy_odd_dndm_olp_buf_wr_addr_r <= xy_odd_dndm_olp_buf_wr_addr_r == (tile_tot_num_x >> 1) ? 0 : xy_odd_dndm_olp_buf_wr_addr_r + 1;
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        xy_odd_sr_olp_buf_wr_addr_r <= 0;
    else if(model_proc_r == SR && wr_xy_olp_odd_en_w && tile_switch_i)
        xy_odd_sr_olp_buf_wr_addr_r <= xy_odd_sr_olp_buf_wr_addr_r == (tile_tot_num_x >> 1) ? 0 : xy_odd_sr_olp_buf_wr_addr_r + 1;
end

always @(*) begin
    case({model_proc_r, wr_xy_olp_evn_en_w, wr_xy_olp_odd_en_w})
        3'b010: xy_olp_buf_wr_addr_r = xy_evn_dndm_olp_buf_wr_addr_r;
        3'b001: xy_olp_buf_wr_addr_r = xy_odd_dndm_olp_buf_wr_addr_r;
        3'b110: xy_olp_buf_wr_addr_r = xy_evn_sr_olp_buf_wr_addr_r;
        3'b101: xy_olp_buf_wr_addr_r = xy_odd_sr_olp_buf_wr_addr_r;
        default: xy_olp_buf_wr_addr_r = 0;
    endcase
end

assign xy_olp_buf_wr_addr_w = (xy_olp_buf_wr_addr_r << (layer_cnt_r == 3 ? 2 : 1)) + (layer_cnt_r == 3 ?  (tile_oc_cnt_r >> 2) : (tile_oc_cnt_r >> 3));

/*
always @(posedge clk) begin
    if(model_proc_r == DM)begin

        xy_olp_buf_wr_addr_r       <=  xy_olp_buf_cur_layer_base_addr  +  is_5x5_conv_w ? {xy_olp_rot_cnt0_r[6 -1 : 1], tile_oc_cnt_r[2+:2]} : 
                                                                                       {xy_olp_rot_cnt0_r[6 -1 : 1], tile_oc_cnt_r[3+:1]} ; //TODO: tile_oc_cnt_r may update ealier, count oc in egress 
   
    end
    else begin

        xy_olp_buf_wr_addr_r       <=  xy_olp_buf_cur_layer_base_addr  +  is_5x5_conv_w ? {xy_olp_rot_cnt1_r[6 -1 : 1], tile_oc_cnt_r[2+:2]} : 
                                                                                       {xy_olp_rot_cnt1_r[6 -1 : 1], tile_oc_cnt_r[3+:1]} ; //TODO: tile_oc_cnt_r may update ealier, count oc in egress 
    end
end
*/
    assign  wr_xy_olp_odd_en_w  =  model_proc_r == DM ? xy_olp_rot_cnt0_r[0]  : xy_olp_rot_cnt1_r[0];
    assign  wr_xy_olp_evn_en_w =  model_proc_r == DM ? (tile_tot_num_x == xy_olp_rot_cnt0_r + 1 ? 0 : ~xy_olp_rot_cnt0_r[0]) 
                                                      : (tile_tot_num_x == xy_olp_rot_cnt1_r + 1 ? 0 : ~xy_olp_rot_cnt1_r[0]) ;



    assign       xy_olp_buf_wr_en_w      =  is_5x5_conv_w    ?  {{4{fe_h_en_w[3]}}, {4{fe_h_en_w[2]}},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} : 
                                                tile_oc_cnt_r[2] ?  {{4{fe_h_en_w[1]}}, {4{fe_h_en_w[0]}},  {4{1'b0        }},  {4{1'b0        }}} :
                                                        {{4{1'b0        }}, {4{1'b0        }},  {4{fe_h_en_w[1]}},  {4{fe_h_en_w[0]}}} ; 


    wire  [16 -1 : 0] evn_xy_olp_buf_wr_en_w ;
    wire  [16 -1 : 0] odd_xy_olp_buf_wr_en_w ;
/*
    buf_en_trans#(
        .H_NUM(4),
        .C_NUM(4)
    )
    trans_h4_c4_u1
    (
        .buf_en_i(evn_xy_olp_buf_wr_en_w),
        .buf_en_o(evn_xy_olp_buf_wr_en_o)
    );
    buf_en_trans#(
        .H_NUM(4),
        .C_NUM(4)
    )
    trans_h4_c4_u2
    (
        .buf_en_i(odd_xy_olp_buf_wr_en_w),
        .buf_en_o(odd_xy_olp_buf_wr_en_o)
    );
*/

    assign       evn_xy_olp_buf_wr_en_o      =  wr_xy_olp_evn_en_w & is_tile_lst2_h_w & hs_in_eg_w ? (ksize_nxt == 5 ? y_olp_buf_wr_en_trans_w1 : y_olp_buf_wr_en_trans_w2 )    : 'd0  ;    

    assign       evn_xy_olp_buf_wr_addr_o    =  wr_xy_olp_evn_en_w & is_tile_lst2_h_w & hs_in_eg_w ? xy_olp_buf_wr_addr_w + layer_cnt_r * XY_L234_DEPTH  : 'd0  ;   //TODO:

    assign       evn_xy_olp_buf_wr_dat_0_0_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;
    assign       evn_xy_olp_buf_wr_dat_0_1_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;
    assign       evn_xy_olp_buf_wr_dat_0_2_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;
    assign       evn_xy_olp_buf_wr_dat_0_3_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;

    assign       evn_xy_olp_buf_wr_dat_1_0_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_1_1_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_1_2_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_1_3_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 

    assign       evn_xy_olp_buf_wr_dat_2_0_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_2_1_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_2_2_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_2_3_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 

    assign       evn_xy_olp_buf_wr_dat_3_0_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_3_1_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_3_2_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       evn_xy_olp_buf_wr_dat_3_3_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 

    assign       odd_xy_olp_buf_wr_en_o      =  wr_xy_olp_odd_en_w  & is_tile_lst2_h_w & hs_in_eg_w ? (ksize_nxt == 5 ? y_olp_buf_wr_en_trans_w1 : y_olp_buf_wr_en_trans_w2 )     : 'd0  ; 
    assign       odd_xy_olp_buf_wr_addr_o    =  wr_xy_olp_odd_en_w  & is_tile_lst2_h_w & hs_in_eg_w ? xy_olp_buf_wr_addr_w + layer_cnt_r * XY_L234_DEPTH  : 'd0  ; //TODO:
    
    assign       odd_xy_olp_buf_wr_dat_0_0_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;
    assign       odd_xy_olp_buf_wr_dat_0_1_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;
    assign       odd_xy_olp_buf_wr_dat_0_2_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;
    assign       odd_xy_olp_buf_wr_dat_0_3_o =  requant_oc0_w[0+:  XY_OLP_DAT_WD         ] ;

    assign       odd_xy_olp_buf_wr_dat_1_0_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_1_1_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_1_2_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_1_3_o =  requant_oc1_w[0+:  XY_OLP_DAT_WD         ] ; 

    assign       odd_xy_olp_buf_wr_dat_2_0_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_2_1_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_2_2_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_2_3_o =  requant_oc2_w[0+:  XY_OLP_DAT_WD         ] ; 

    assign       odd_xy_olp_buf_wr_dat_3_0_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_3_1_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_3_2_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 
    assign       odd_xy_olp_buf_wr_dat_3_3_o =  requant_oc3_w[0+:  XY_OLP_DAT_WD         ] ; 

//------------------

// x resi write  

// 8 x 32w x 4c x 4 h x (32 / 4) x (16 /4) 
// do not write last 3 lines 
//------------------

/*always @(*)begin
    case(requant_h_cnt_r)
        3'd0: x_resi_wr_h_en_w = 4'b1000 ;
        3'd1: x_resi_wr_h_en_w = 4'b0001 ;
        3'd2: x_resi_wr_h_en_w = 4'b0010 ;
        3'd3: x_resi_wr_h_en_w = 4'b0100 ;
    default:
          x_resi_wr_h_en_w = 4'd0;
    endcase
end*/


wire    x_resi_buf_overflow_w  ;

assign  is_resi_wr_w             =   res_proc_type_r == RESI_WR                    ;

assign  tile_h_cnt4_plus_one_w   = tile_h_cnt_r[5 - 1 : 2] + 'd1  ;
assign  x_resi_buf_overflow_w    = tile_h_cnt_r[5 - 1 : 2]  == 3'd7 ;

reg   [16 -1 :0]   x_resi_wr_en_w;

always @(*)begin
    if(is_frt_strip_w & is_resi_wr_w & hs_in_eg_w )begin
        case(requant_h_cnt_r)
            3'd0: x_resi_wr_en_w = {4'b0000, 4'b0000, 4'b0000, 4'b1111};
            3'd1: x_resi_wr_en_w =  {4'b0000, 4'b0000, 4'b1111, 4'b0000};
            3'd2: x_resi_wr_en_w =  {4'b0000, 4'b1111, 4'b0000, 4'b0000};
            3'd3: x_resi_wr_en_w =  {4'b1111, 4'b0000, 4'b0000, 4'b0000};
            default: x_resi_wr_en_w =  12'd0;
        endcase
    end
    else if(is_norm_strip_w & is_resi_wr_w & hs_in_eg_w )begin
            case(requant_h_cnt_r)
            3'd0: x_resi_wr_en_w = {4'b1111, 4'b0000, 4'b0000, 4'b0000};
            3'd1: x_resi_wr_en_w =  {16{~x_resi_buf_overflow_w}} & {4'b0000, 4'b0000, 4'b0000, 4'b1111};
            3'd2: x_resi_wr_en_w =  {16{~x_resi_buf_overflow_w}} & {4'b0000, 4'b0000, 4'b1111, 4'b0000};
            3'd3: x_resi_wr_en_w =  {16{~x_resi_buf_overflow_w}} & {4'b0000, 4'b1111, 4'b0000, 4'b0000};
            default: x_resi_wr_en_w =  12'd0;
        endcase
    end
    else begin

          x_resi_wr_en_w =  12'd0;

    end
end

buf_en_trans#(
    .H_NUM(4),
    .C_NUM(4)
)
trans_h4_c4_u0
(
    .buf_en_i(x_resi_wr_en_w),
    .buf_en_o(x_resi_wr_en_o)
);

assign  x_resi_wr_addr_h0_o      =  {5{is_norm_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt4_plus_one_w } | {5{is_frt_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt_r[5 - 1 : 2]}  ;
assign  x_resi_wr_addr_h1_o      =  {5{is_norm_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt4_plus_one_w }| {5{is_frt_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt_r[5 - 1 : 2]}    ;
assign  x_resi_wr_addr_h2_o      =  {5{is_norm_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt4_plus_one_w }| {5{is_frt_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt_r[5 - 1 : 2]}    ;
assign  x_resi_wr_addr_h3_o      =  {5{is_norm_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt_r[5 - 1 : 2] }| {5{is_frt_strip_w}} & {tile_oc_cnt_r[4 - 1 : 2], tile_h_cnt_r[5 - 1 : 2]}    ;

assign  x_resi_wr_dat_c0_h0_o    =  x_resi_wr_en_w[0] ? requant_oc0_w[0 +: X_RESI_DAT_WD] : {256{1'b0}};
assign  x_resi_wr_dat_c0_h1_o    =  x_resi_wr_en_w[4] ? requant_oc0_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c0_h2_o    =  x_resi_wr_en_w[8] ? requant_oc0_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c0_h3_o    =  x_resi_wr_en_w[12] ? requant_oc0_w[0 +: X_RESI_DAT_WD]: {256{1'b0}}  ;
assign  x_resi_wr_dat_c1_h0_o    =  x_resi_wr_en_w[1] ? requant_oc1_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c1_h1_o    =  x_resi_wr_en_w[5] ? requant_oc1_w[0 +: X_RESI_DAT_WD]:  {256{1'b0}}  ;
assign  x_resi_wr_dat_c1_h2_o    =  x_resi_wr_en_w[9] ? requant_oc1_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c1_h3_o    =  x_resi_wr_en_w[13] ? requant_oc1_w[0 +: X_RESI_DAT_WD]: {256{1'b0}}  ;
assign  x_resi_wr_dat_c2_h0_o    =  x_resi_wr_en_w[2] ? requant_oc2_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c2_h1_o    =  x_resi_wr_en_w[6] ? requant_oc2_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c2_h2_o    =  x_resi_wr_en_w[10] ? requant_oc2_w[0 +: X_RESI_DAT_WD]: {256{1'b0}}  ;
assign  x_resi_wr_dat_c2_h3_o    =  x_resi_wr_en_w[14] ? requant_oc2_w[0 +: X_RESI_DAT_WD]: {256{1'b0}}  ;
assign  x_resi_wr_dat_c3_h0_o    =  x_resi_wr_en_w[3] ? requant_oc3_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c3_h1_o    =  x_resi_wr_en_w[7] ? requant_oc3_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c3_h2_o    =  x_resi_wr_en_w[11] ? requant_oc3_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
assign  x_resi_wr_dat_c3_h3_o    =  x_resi_wr_en_w[15] ? requant_oc3_w[0 +: X_RESI_DAT_WD] : {256{1'b0}} ;
  
//------------------

// y resi write  

// 8 x 29w x 4c x 3h x (16 /4) x (tile_num_in_width + 1)

//------------------

assign y_resi_wr_rot_len_w = tile_num_x_r ;


wire                    is_y_resi_wr_rot_end0_w ;
wire                    is_y_resi_wr_rot_end1_w ;
reg   [6 -1 : 0]        y_resi_wr_rot_cnt0_r ;
reg   [6 -1 : 0]        y_resi_wr_rot_cnt1_r ;

//DM
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_resi_wr_rot_cnt0_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == DM) begin
        y_resi_wr_rot_cnt0_r <=is_y_resi_wr_rot_end0_w ? 'd0 : y_resi_wr_rot_cnt0_r + 'd1 ;
    end
end

assign is_y_resi_wr_rot_end0_w = y_resi_wr_rot_cnt0_r == y_resi_wr_rot_len_w ;

//SR
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_resi_wr_rot_cnt1_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == SR) begin
        y_resi_wr_rot_cnt1_r <=is_y_resi_wr_rot_end1_w ? 'd0 : y_resi_wr_rot_cnt1_r + 'd1 ;
    end
end

/*
wire                    is_y_resi_wr_rot_end0_w ;
wire                    is_y_resi_wr_rot_end1_w ;
reg   [6 -1 : 0]        y_resi_wr_rot_cnt0_r ;
reg   [6 -1 : 0]        y_resi_wr_rot_cnt1_r ;

//DM
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_resi_wr_rot_cnt0_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == DM) begin
        y_resi_wr_rot_cnt0_r <=is_y_resi_wr_rot_end0_w ? 'd0 : y_resi_wr_rot_cnt0_r + 'd1 ;
    end
end

assign is_y_resi_wr_rot_end0_w = y_resi_wr_rot_cnt0_r == y_resi_wr_rot_len_w ;

//SR
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_resi_wr_rot_cnt1_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == SR) begin
        y_resi_wr_rot_cnt1_r <=is_y_resi_wr_rot_end1_w ? 'd0 : y_resi_wr_rot_cnt1_r + 'd1 ;
    end
end

*/
assign is_y_resi_wr_rot_end1_w = y_resi_wr_rot_cnt1_r == y_resi_wr_rot_len_w ;


/*always @(*) begin
    case(requant_h_cnt_r)
        3'd0 : y_resi_wr_h_en_w = 3'b000 ;
        3'd1 : y_resi_wr_h_en_w = 3'b001 ;
        3'd2 : y_resi_wr_h_en_w = 3'b010 ;
        3'd3 : y_resi_wr_h_en_w = 3'b100 ;
    default :
          y_resi_wr_h_en_w = 3'b000 ;

    endcase
end*/
    
//penultimate

wire     is_tile_penul_h_w ;
wire     is_resi_wr_lst_3lines_in_frst_strip ;
wire     is_resi_wr_lst_3lines_in_norm_strip ;
assign   is_tile_penul_h_w = (tile_h_cnt_r >>2) +'d2 == (tile_h_r>>2);
assign   is_resi_wr_lst_3lines_in_frst_strip = (is_tile_penul_h_w &  requant_h_cnt_r[1] & requant_h_cnt_r[0] ) ||
                                              (is_tile_lst_h_w   & ~requant_h_cnt_r[2] & ~requant_h_cnt_r[1]) ;
assign   is_resi_wr_lst_3lines_in_norm_strip = is_tile_lst_h_w & (requant_h_cnt_r[1] | requant_h_cnt_r[0]) ;
assign   is_resi_wr_lst_3lines_w             = is_frt_strip_w & is_resi_wr_lst_3lines_in_frst_strip || 
                                               is_norm_strip_w & is_resi_wr_lst_3lines_in_norm_strip ;

reg   [12 -1 : 0]   y_resi_wr_en_w;

//assign   y_resi_wr_en_w         =    is_resi_wr_w & hs_in_eg_w & is_resi_wr_lst_3lines_w ? 
//                                    {{4{y_resi_wr_h_en_w[2]}},  {4{y_resi_wr_h_en_w[1]}},  {4{y_resi_wr_h_en_w[0]}}} : 
//                                    'd0  ;   
always @(*)begin
    if(is_resi_wr_w & hs_in_eg_w)begin
        if( is_frt_strip_w & is_resi_wr_lst_3lines_in_frst_strip )begin
            case(requant_h_cnt_r)
                3'd3: y_resi_wr_en_w = {4'b0000, 4'b0000, 4'b1111};
                3'd0: y_resi_wr_en_w = {4'b0000, 4'b1111, 4'b0000};
                3'd1: y_resi_wr_en_w = {4'b1111, 4'b0000, 4'b0000};
                default: y_resi_wr_en_w = {4'b0000, 4'b0000, 4'b0000};
            endcase
        end
        else if(is_norm_strip_w & is_resi_wr_lst_3lines_in_norm_strip)begin
            case(requant_h_cnt_r)
                3'd1: y_resi_wr_en_w = {4'b0000, 4'b0000, 4'b1111};
                3'd2: y_resi_wr_en_w = {4'b0000, 4'b1111, 4'b0000};
                3'd3: y_resi_wr_en_w = {4'b1111, 4'b0000, 4'b0000};
                default: y_resi_wr_en_w = {4'b0000, 4'b0000, 4'b0000};
            endcase
        end
        else begin
            y_resi_wr_en_w = 12'd0;
        end
    end
    else begin
        y_resi_wr_en_w = 12'd0;
    end
end

buf_en_trans#(
    .H_NUM(3),
    .C_NUM(4)
)
trans_h3_c4_u2
(
    .buf_en_i(y_resi_wr_en_w),
    .buf_en_o(y_resi_wr_en_o)
);

assign   y_resi_wr_addr_o       =  model_proc_r == DM ? { y_resi_wr_rot_cnt0_r, tile_oc_cnt_r[ 4 -1 : 2]  } :
                                                         { y_resi_wr_rot_cnt1_r, tile_oc_cnt_r[ 4 -1 : 2]  }  ;

assign   y_resi_wr_dat_c0_h0_o  =  y_resi_wr_en_w[0]  ? requant_oc0_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}};
assign   y_resi_wr_dat_c0_h1_o  =  y_resi_wr_en_w[4]  ? requant_oc0_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}};
assign   y_resi_wr_dat_c0_h2_o  =  y_resi_wr_en_w[8]  ? requant_oc0_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c1_h0_o  =  y_resi_wr_en_w[1]  ? requant_oc1_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c1_h1_o  =  y_resi_wr_en_w[5]  ? requant_oc1_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c1_h2_o  =  y_resi_wr_en_w[9]  ? requant_oc1_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c2_h0_o  =  y_resi_wr_en_w[2]  ? requant_oc2_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c2_h1_o  =  y_resi_wr_en_w[6]  ? requant_oc2_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c2_h2_o  =  y_resi_wr_en_w[10] ? requant_oc2_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c3_h0_o  =  y_resi_wr_en_w[3]  ? requant_oc3_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c3_h1_o  =  y_resi_wr_en_w[7]  ? requant_oc3_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;
assign   y_resi_wr_dat_c3_h2_o  =  y_resi_wr_en_w[11] ? requant_oc3_w[XY_RESI_DAT_WD +: Y_RESI_DAT_WD] : {232{1'b0}}  ;

//------------------

// x y resi write  

// 8 x 3w x 4c x 3h x (16 /4) x (tile_num_in_width + 2)

//------------------

wire                    is_xy_resi_wr_rot_end0_w    ;
wire                    is_xy_resi_wr_rot_end1_w    ;
reg   [6  -1 : 0]       xy_resi_wr_rot_cnt0_r       ;
reg   [6  -1 : 0]       xy_resi_wr_rot_cnt1_r       ;




assign xy_resi_wr_rot_len_w = tile_num_x_r + 'd1  ;

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        xy_resi_wr_rot_cnt0_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == DM) begin
        xy_resi_wr_rot_cnt0_r <=is_xy_resi_wr_rot_end0_w ? 'd0 : xy_resi_wr_rot_cnt0_r + 'd1 ;
    end
end

assign is_xy_resi_wr_rot_end0_w = xy_resi_wr_rot_cnt0_r == xy_resi_wr_rot_len_w ;

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        xy_resi_wr_rot_cnt1_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == SR) begin
        xy_resi_wr_rot_cnt1_r <=is_xy_resi_wr_rot_end1_w ? 'd0 : xy_resi_wr_rot_cnt1_r + 'd1 ;
    end
end

assign is_xy_resi_wr_rot_end1_w = xy_resi_wr_rot_cnt1_r == xy_resi_wr_rot_len_w ;

/*
assign xy_resi_wr_rot_len_w = tile_num_x_r + 'd1  ;

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        xy_resi_wr_rot_cnt0_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == DM) begin
        xy_resi_wr_rot_cnt0_r <=is_xy_resi_wr_rot_end0_w ? 'd0 : xy_resi_wr_rot_cnt0_r + 'd1 ;
    end
end

assign is_xy_resi_wr_rot_end1_w = xy_resi_wr_rot_cnt0_r == xy_resi_wr_rot_len_w ;

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        y_resi_wr_rot_cnt1_r <= 'd0                   ;
    end
    else if(tile_switch_i & model_proc_r == SR) begin
        y_resi_wr_rot_cnt1_r <=is_xy_resi_wr_rot_end1_w ? 'd0 : y_resi_wr_rot_cnt1_r + 'd1 ;
    end
end

assign is_xy_resi_wr_rot_end1_w = y_resi_wr_rot_cnt1_r == xy_resi_wr_rot_len_w ;
*/

reg     [12 -1 : 0]    xy_resi_wr_en_w ;

always @(*)begin
    if(is_resi_wr_w & hs_in_eg_w)begin
        if( is_frt_strip_w & is_resi_wr_lst_3lines_in_frst_strip )begin
            case(requant_h_cnt_r)
                3'd3: xy_resi_wr_en_w = {4'b0000, 4'b0000, 4'b1111};
                3'd0: xy_resi_wr_en_w = {4'b0000, 4'b1111, 4'b0000};
                3'd1: xy_resi_wr_en_w = {4'b1111, 4'b0000, 4'b0000};
                default: xy_resi_wr_en_w = {4'b0000, 4'b0000, 4'b0000};
            endcase
        end
        else if(is_norm_strip_w & is_resi_wr_lst_3lines_in_norm_strip)begin
            case(requant_h_cnt_r)
                3'd1: xy_resi_wr_en_w = {4'b0000, 4'b0000, 4'b1111};
                3'd2: xy_resi_wr_en_w = {4'b0000, 4'b1111, 4'b0000};
                3'd3: xy_resi_wr_en_w = {4'b1111, 4'b0000, 4'b0000};
                default: xy_resi_wr_en_w = {4'b0000, 4'b0000, 4'b0000};
            endcase
        end
        else begin
            xy_resi_wr_en_w = 12'd0;
        end
    end
    else begin
        xy_resi_wr_en_w = 12'd0;
    end
end

buf_en_trans#(
    .H_NUM(3),
    .C_NUM(4)
)
trans_h3_c4_u3
(
    .buf_en_i(xy_resi_wr_en_w),
    .buf_en_o(xy_resi_wr_en_o)
);
assign   xy_resi_wr_addr_o       =  model_proc_r == DM ? { xy_resi_wr_rot_cnt0_r, tile_oc_cnt_r[ 4 -1 : 2] } :
                                                         { xy_resi_wr_rot_cnt1_r, tile_oc_cnt_r[ 4 -1 : 2] }  ;
assign   xy_resi_wr_dat_c0_h0_o  =  xy_resi_wr_en_w[0] ? requant_oc0_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c0_h1_o  =  xy_resi_wr_en_w[4] ? requant_oc0_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c0_h2_o  =  xy_resi_wr_en_w[8] ? requant_oc0_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c1_h0_o  =  xy_resi_wr_en_w[1] ? requant_oc1_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c1_h1_o  =  xy_resi_wr_en_w[5] ? requant_oc1_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c1_h2_o  =  xy_resi_wr_en_w[9] ? requant_oc1_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c2_h0_o  =  xy_resi_wr_en_w[2] ? requant_oc2_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c2_h1_o  =  xy_resi_wr_en_w[6] ? requant_oc2_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c2_h2_o  =  xy_resi_wr_en_w[10]? requant_oc2_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c3_h0_o  =  xy_resi_wr_en_w[3] ? requant_oc3_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c3_h1_o  =  xy_resi_wr_en_w[7] ? requant_oc3_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;
assign   xy_resi_wr_dat_c3_h2_o  =  xy_resi_wr_en_w[11]? requant_oc3_w[0 +: XY_RESI_DAT_WD         ] : {XY_RESI_DAT_WD{1'b0}} ;




`ifdef DEBUG_MONITOR
    wire mon_hs_conv ;
    wire mon_hs_pipe_p0 ;
    wire mon_hs_pipe_p1 ;
    wire mon_hs_pipe_p2 ;
    wire mon_hs_pipe_p3 ;
    wire mon_hs_pipe_p4 ;
    wire mon_hs_pipe_p5 ;
    wire mon_hs_pipe_p6 ;
    wire mon_hs_pipe_p7 ;

    assign mon_hs_conv    = acc2bsadd_vld_w & bsadd2acc_rdy_w ;
    assign mon_hs_pipe_p0 = pe2pu_vld_i & pu2pe_rdy_o ;
    assign mon_hs_pipe_p1 = pipe1_vld_w & pipe1_rdy_w ;
    assign mon_hs_pipe_p2 = pipe2_vld_w & pipe2_rdy_w ;
    assign mon_hs_pipe_p3 = pipe3_vld_w & pipe3_rdy_w ;
    assign mon_hs_pipe_p4 = pipe4_vld_w & pipe4_rdy_w ;
    assign mon_hs_pipe_p5 = pipe5_vld_w & pipe5_rdy_w ;


    assign mon_hs_conv_acc_o  = mon_hs_conv ;
    assign mon_acc_c_0_h_0_o = accum_0_0_w ;
    assign mon_acc_c_0_h_1_o = accum_0_1_w ;
    assign mon_acc_c_0_h_2_o = accum_0_2_w ;
    assign mon_acc_c_0_h_3_o = accum_0_3_w ;
    assign mon_acc_c_1_h_0_o = accum_1_0_w ;
    assign mon_acc_c_1_h_1_o = accum_1_1_w ;
    assign mon_acc_c_1_h_2_o = accum_1_2_w ;
    assign mon_acc_c_1_h_3_o = accum_1_3_w ;
    assign mon_acc_c_2_h_0_o = accum_2_0_w ;
    assign mon_acc_c_2_h_1_o = accum_2_1_w ;
    assign mon_acc_c_2_h_2_o = accum_2_2_w ;
    assign mon_acc_c_2_h_3_o = accum_2_3_w ;
    assign mon_acc_c_3_h_0_o = accum_3_0_w ;
    assign mon_acc_c_3_h_1_o = accum_3_1_w ;
    assign mon_acc_c_3_h_2_o = accum_3_2_w ;
    assign mon_acc_c_3_h_3_o = accum_3_3_w ;

    assign mon_hs_conv_bias_o = mon_hs_pipe_p2 ;
    assign mon_bias_oc0_o     = conv_oc0_w     ;
    assign mon_bias_oc1_o     = conv_oc1_w     ;
    assign mon_bias_oc2_o     = conv_oc2_w     ;
    assign mon_bias_oc3_o     = conv_oc3_w     ;

    assign mon_hs_lbm_o       = mon_hs_pipe_p5 ;
    assign mon_lbm_oc0_o      = requant_oc0_w  ;
    assign mon_lbm_oc1_o      = requant_oc1_w  ;
    assign mon_lbm_oc2_o      = requant_oc2_w  ;
    assign mon_lbm_oc3_o      = requant_oc3_w  ;
`endif 





endmodule   


module buf_en_trans#(

    parameter  H_NUM = 4,
    parameter  C_NUM = 4

)
(

    input   [H_NUM * C_NUM -1 : 0]   buf_en_i,
    output  [H_NUM * C_NUM -1 : 0]   buf_en_o

);

genvar h,c;
generate
     for(h = 0;h < H_NUM; h = h + 1)begin:H
        for(c = 0; c < C_NUM; c = c + 1)begin:C
            assign buf_en_o[c * H_NUM + h] = buf_en_i[h * C_NUM + c];
        end
     end
endgenerate


endmodule
