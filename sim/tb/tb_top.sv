`timescale 1ns/1ps
`define PERIOD  8
`define DISPLAY 0

//stop when error
//`define RUNALL

// define file path
/*
`define FE_BUF_FILE   "../tv/test0/fe_buf.txt"
`define WT_BUF_FILE   "../tv/test0/wt_buf.txt"
`define OLP_BUF_FILE  "../tv/test0/olp_buf.txt"
`define RES_BUF_FILE  "../tv/test0/res_buf.txt"
`define PARAM_BUF_FILE "../tv/test0/param_buf.txt"
`define REG_FILE      "../tv/test0/reg.txt"
`define GOLDEN_BUF_FILE "../tv/test0/golden.txt"

`define FE_LAYER1 "../tv/test0/layer1.txt"
`define FE_LAYER2 "../tv/test0/layer2.txt"
`define FE_LAYER3 "../tv/test0/layer3.txt"
`define FE_LAYER4 "../tv/test0/layer4.txt"
`define FE_LAYER5 "../tv/test0/layer5.txt"
*/

`define FE_BUF_FILE   "../tv/test2/fe_buf.txt"
`define WT_BUF_FILE   "../tv/test2/wt_buf.txt"
`define OLP_BUF_FILE  "../tv/test2/olp_buf.txt"
`define RES_BUF_FILE  "../tv/test2/res_buf.txt"
`define PARAM_BUF_FILE "../tv/test2/param_buf.txt"
`define REG_FILE      "../tv/test2/reg.txt"
`define GOLDEN_BUF_FILE "../tv/test2/golden.txt"

`define FE_LAYER1 "../tv/test2/layer1.txt"
`define FE_LAYER2 "../tv/test2/layer2.txt"
`define FE_LAYER3 "../tv/test2/layer3.txt"
`define FE_LAYER4 "../tv/test2/layer4.txt"
`define FE_LAYER5 "../tv/test2/layer5_test1.txt"


module tb_top;
  parameter    REG_IFMH_WIDTH       = 10                                                             ;
  parameter    REG_IFMW_WIDTH       = 10                                                             ;
  parameter    REG_TILEH_WIDTH      = 6                                                              ;
  parameter    REG_TNY_WIDTH        = 6                                                              ;
  parameter    REG_TNX_WIDTH        = 6                                                              ;
  parameter    REG_TLW_WIDTH        = 6                                                              ;
  parameter    REG_TLH_WIDTH        = 6                                                              ;
  parameter    TILE_BASE_W          = 32                                                             ;
  parameter    REG_IH_WIDTH         = 6                                                              ;
  parameter    REG_OH_WIDTH         = 6                                                              ;
  parameter    REG_IW_WIDTH         = 6                                                              ;
  parameter    REG_OW_WIDTH         = 6                                                              ;
  parameter    REG_IC_WIDTH         = 6                                                              ;
  parameter    REG_OC_WIDTH         = 6                                                              ;
  parameter    REG_AF_WIDTH         = 1                                                              ;
  parameter    REG_HBM_SFT_WIDTH    = 6                                                              ;
  parameter    REG_LBM_SFT_WIDTH    = 6                                                              ;
  parameter    WT_WIDTH             = 8                                                              ;
  parameter    WT_ADDR_WIDTH        = 7                                                              ;
  //parameter    WT_BUF0_DEPTH        = 73                                                             ;//DNDM
  //parameter    WT_BUF1_DEPTH        = 108                                                            ;//SR
  // modify when tb
  parameter    WT_BUF0_DEPTH        = 117                                                            ;//DNDM
  parameter    WT_BUF1_DEPTH        = 73                                                            ;//SR
  parameter    IC_NUM               = 4                                                              ;
  parameter    OC_NUM               = 4                                                              ;
  parameter    WT_BUF_WIDTH         = WT_WIDTH*IC_NUM*OC_NUM                                         ;
  parameter    WT_GRP_NUM           = 8                                                              ;
  parameter    AXI2W_WIDTH          = WT_BUF_WIDTH*WT_GRP_NUM                                        ;
  parameter    RESX_ADDR_WIDTH      = 6                                                              ;
  parameter    RESX_BUF_DEPTH       = 32                                                             ;
  parameter    RESX_LBUF_WIDTH      = 232                                                            ;
  parameter    RESX_SBUF_WIDTH      = 24                                                             ;
  parameter    RESY_ADDR_WIDTH      = 8                                                              ;
  parameter    RESY_BUF_DEPTH       = 128                                                            ;
  parameter    RESY_BUF_WIDTH       = 232                                                            ;
  parameter    RESXY_ADDR_WIDTH     = 8                                                              ;
  parameter    RESXY_BUF_DEPTH      = 132                                                            ;
  parameter    RESXY_BUF_WIDTH      = 24                                                             ;
  parameter    BIAS_DATA_WIDTH      = 16                                                             ;
  parameter    HBM_DATA_WIDTH       = 16                                                             ;
  parameter    LBM_DATA_WIDTH       = 16                                                             ;
  parameter    P_ADDR_WIDTH         = 5                                                              ;
  //parameter    P_BUF0_DEPTH         = 17                                                             ; //DNDM
  //parameter    P_BUF1_DEPTH         = 20                                                             ; //SR
  // modify when tb
  parameter    P_BUF0_DEPTH         = 20                                                             ; //DNDM
  parameter    P_BUF1_DEPTH         = 17                                                             ; //SR
  parameter    P_BUF_WIDTH          = (BIAS_DATA_WIDTH + HBM_DATA_WIDTH + LBM_DATA_WIDTH) * OC_NUM   ;
  parameter    P2PU_RD_WIDTH        = BIAS_DATA_WIDTH + HBM_DATA_WIDTH + LBM_DATA_WIDTH              ;
  parameter    OLPX_L1_ADDR_WIDTH   = 4                                                              ;
  parameter    OLPX_L1_BUF_DEPTH    = 8                                                              ;
  parameter    OLPX_BUF_NUM         = 4                                                              ;
  parameter    OLPX_BUF_WIDTH       = 32                                                             ;
  parameter    OLPX_ADDR_WIDTH      = 8                                                              ;
  parameter    OLPX_BUF_DEPTH       = 128                                                            ;
  parameter    OLPY_L1_ADDR_WIDTH   = 6                                                              ;
  parameter    OLPY_L1_BUF_DEPTH    = 32                                                             ;
  parameter    OLPY_BUF_NUM         = 28                                                             ;
  parameter    OLPY_BUF_WIDTH       = 224                                                            ;
  parameter    OLPY_ADDR_WIDTH      = 9                                                              ;
  parameter    OLPY_BUF_DEPTH       = 320                                                            ;
  parameter    OLPXY_L1_ADDR_WIDTH  = 5                                                              ;
  parameter    OLPXY_L1_BUF_DEPTH   = 17                                                             ;
  parameter    OLPXY_BUF_NUM        = 4                                                              ;
  parameter    OLPXY_BUF_WIDTH      = 32                                                             ;
  parameter    OLPXY_ADDR_WIDTH     = 8                                                              ;
  parameter    OLPXY_BUF_DEPTH      = 170                                                            ;
  parameter    FE_ADDR_WIDTH        = 6                                                              ;
  parameter    FE_BUF_DEPTH         = 32                                                             ;
  parameter    FE_BUF_WIDTH         = 32*8                                                           ;
  parameter    AXI2F_DATA_WIDTH     = 1024                                                           ;
  parameter    AXI2F_ADDR_WIDTH     = FE_ADDR_WIDTH + 2                                              ;// 2 bit MSB for buf-grouping: 00:_0_x/01:_1_x/10:_2_x/11:_3_x grp
  parameter    IFM_WIDTH            = 8                                                              ;
  parameter    SCH_COL_NUM          = 36                                                             ;
  parameter    PE_COL_NUM           = 32                                                             ;
  parameter    PE_H_NUM             = 4                                                              ;
  parameter    PE_IC_NUM            = IC_NUM                                                         ;
  parameter    PE_OC_NUM            = OC_NUM                                                         ;
  parameter    WIDTH_KSIZE          = 3                                                              ;
  parameter    WIDTH_FEA_X          = 6                                                              ;
  parameter    WIDTH_FEA_Y          = 6                                                              ;
  parameter    OLPY_L234_DEPTH      = 64                                                             ;
  parameter    OLPX_L234_DEPTH      = 32                                                             ;
  parameter    OLPXY_L234_DEPTH     = 34                                                             ;
  parameter    PE_OUTPUT_WD         = 18                                                             ;
  parameter    PU_RF_ACCU_WD        = 32 * 18                                                        ;

  logic                                      clk            ;
  logic                                      rst_n          ;
  logic     [                     32-1:0]    ctrl_reg       ;
  logic     [                     32-1:0]    state_reg      ;
  logic     [                     32-1:0]    reg0           ;
  logic     [                     32-1:0]    reg1           ;
  logic     [      WT_ADDR_WIDTH - 1 : 0]    axi2w_waddr    ;
  logic                                      axi2w_wen      ;
  logic     [        AXI2W_WIDTH - 1 : 0]    axi2w_wdata    ;
  logic     [      WT_ADDR_WIDTH - 1 : 0]    axi2w_raddr    ;
  logic                                      axi2w_ren      ;
  logic     [        AXI2W_WIDTH - 1 : 0]    axi2w_rdata    ;
  logic     [       P_ADDR_WIDTH - 1 : 0]    axi2p_waddr    ;
  logic                                      axi2p_wen      ;
  logic     [        P_BUF_WIDTH - 1 : 0]    axi2p_wdata    ;
  logic     [       P_ADDR_WIDTH - 1 : 0]    axi2p_raddr    ;
  logic                                      axi2p_ren      ;
  logic     [        P_BUF_WIDTH - 1 : 0]    axi2p_rdata    ;
  logic     [   AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_waddr    ;
  logic                                      axi2f_wen      ;
  logic     [   AXI2F_DATA_WIDTH - 1 : 0]    axi2f_wdata    ;
  logic     [   AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_raddr    ;
  logic                                      axi2f_ren      ;
  logic     [   AXI2F_DATA_WIDTH - 1 : 0]    axi2f_rdata    ;

  logic                                      moniter_done   ;

  event    nxt_tile_event ;
  event    nxt_stack_event;
  event    nxt_reg_event;
  event    nxt_loading_event;
  event    nxt_wt_param_event;
/******************************************************************************/
/************************************** DUT ***********************************/
/******************************************************************************/
top #(
  .REG_IFMH_WIDTH       (REG_IFMH_WIDTH      ),
  .REG_IFMW_WIDTH       (REG_IFMW_WIDTH      ),
  .REG_TILEH_WIDTH      (REG_TILEH_WIDTH     ),
  .REG_TNY_WIDTH        (REG_TNY_WIDTH       ),
  .REG_TNX_WIDTH        (REG_TNX_WIDTH       ),
  .REG_TLW_WIDTH        (REG_TLW_WIDTH       ),
  .REG_TLH_WIDTH        (REG_TLH_WIDTH       ),
  .REG_IH_WIDTH         (REG_IH_WIDTH        ),
  .REG_OH_WIDTH         (REG_OH_WIDTH        ),
  .REG_IW_WIDTH         (REG_IW_WIDTH        ),
  .REG_OW_WIDTH         (REG_OW_WIDTH        ),
  .REG_IC_WIDTH         (REG_IC_WIDTH        ),
  .REG_OC_WIDTH         (REG_OC_WIDTH        ),
  .REG_AF_WIDTH         (REG_AF_WIDTH        ),
  .REG_HBM_SFT_WIDTH    (REG_HBM_SFT_WIDTH   ),
  .REG_LBM_SFT_WIDTH    (REG_LBM_SFT_WIDTH   ),
  .WT_WIDTH             (WT_WIDTH            ),
  .WT_ADDR_WIDTH        (WT_ADDR_WIDTH       ),
  .WT_BUF0_DEPTH        (WT_BUF0_DEPTH       ),
  .WT_BUF1_DEPTH        (WT_BUF1_DEPTH       ),
  .IC_NUM               (IC_NUM              ),
  .OC_NUM               (OC_NUM              ),
  .WT_BUF_WIDTH         (WT_BUF_WIDTH        ),
  .WT_GRP_NUM           (WT_GRP_NUM          ),
  .AXI2W_WIDTH          (AXI2W_WIDTH         ),
  .RESX_ADDR_WIDTH      (RESX_ADDR_WIDTH     ),
  .RESX_BUF_DEPTH       (RESX_BUF_DEPTH      ),
  .RESX_LBUF_WIDTH      (RESX_LBUF_WIDTH      ),
  .RESX_SBUF_WIDTH      (RESX_SBUF_WIDTH     ),
  .RESY_ADDR_WIDTH      (RESY_ADDR_WIDTH     ),
  .RESY_BUF_DEPTH       (RESY_BUF_DEPTH      ),
  .RESY_BUF_WIDTH       (RESY_BUF_WIDTH      ),
  .RESXY_ADDR_WIDTH     (RESXY_ADDR_WIDTH    ),
  .RESXY_BUF_DEPTH      (RESXY_BUF_DEPTH     ),
  .RESXY_BUF_WIDTH      (RESXY_BUF_WIDTH     ),
  .BIAS_DATA_WIDTH      (BIAS_DATA_WIDTH     ),
  .HBM_DATA_WIDTH       (HBM_DATA_WIDTH      ),
  .LBM_DATA_WIDTH       (HBM_DATA_WIDTH      ),
  .P_ADDR_WIDTH         (P_ADDR_WIDTH        ),
  .P_BUF0_DEPTH         (P_BUF0_DEPTH        ),
  .P_BUF1_DEPTH         (P_BUF1_DEPTH        ),
  .P_BUF_WIDTH          (P_BUF_WIDTH         ),
  .P2PU_RD_WIDTH        (P2PU_RD_WIDTH       ),
  .OLPX_L1_ADDR_WIDTH   (OLPX_L1_ADDR_WIDTH  ),
  .OLPX_L1_BUF_DEPTH    (OLPX_L1_BUF_DEPTH   ),
  .OLPX_BUF_NUM         (OLPX_BUF_NUM        ),
  .OLPX_BUF_WIDTH       (OLPX_BUF_WIDTH      ),
  .OLPX_ADDR_WIDTH      (OLPX_ADDR_WIDTH     ),
  .OLPX_BUF_DEPTH       (OLPX_BUF_DEPTH      ),
  .OLPY_L1_ADDR_WIDTH   (OLPY_L1_ADDR_WIDTH  ),
  .OLPY_L1_BUF_DEPTH    (OLPY_L1_BUF_DEPTH   ),
  .OLPY_BUF_NUM         (OLPY_BUF_NUM        ),
  .OLPY_BUF_WIDTH       (OLPY_BUF_WIDTH      ),
  .OLPY_ADDR_WIDTH      (OLPY_ADDR_WIDTH     ),
  .OLPY_BUF_DEPTH       (OLPY_BUF_DEPTH      ),
  .OLPXY_L1_ADDR_WIDTH  (OLPXY_L1_ADDR_WIDTH ),
  .OLPXY_L1_BUF_DEPTH   (OLPXY_L1_BUF_DEPTH  ),
  .OLPXY_BUF_NUM        (OLPX_BUF_NUM        ),
  .OLPXY_BUF_WIDTH      (OLPXY_BUF_WIDTH     ), 
  .OLPXY_ADDR_WIDTH     (OLPXY_ADDR_WIDTH    ),
  .OLPXY_BUF_DEPTH      (OLPXY_BUF_DEPTH     ),
  .FE_ADDR_WIDTH        (FE_ADDR_WIDTH       ),
  .FE_BUF_DEPTH         (FE_BUF_DEPTH        ),
  .FE_BUF_WIDTH         (FE_BUF_WIDTH        ),
  .AXI2F_DATA_WIDTH     (AXI2F_DATA_WIDTH    ),
  .AXI2F_ADDR_WIDTH     (AXI2F_ADDR_WIDTH    ), // 2 bit MSB for buf-grouping
  .IFM_WIDTH            (IFM_WIDTH           ),
  .SCH_COL_NUM          (SCH_COL_NUM         ),
  .PE_COL_NUM           (PE_COL_NUM          ),
  .PE_H_NUM             (PE_H_NUM            ),
  .PE_IC_NUM            (PE_IC_NUM           ),
  .PE_OC_NUM            (PE_OC_NUM           ),
  .WIDTH_KSIZE          (WIDTH_KSIZE         ),
  .WIDTH_FEA_X          (WIDTH_FEA_X         ),
  .WIDTH_FEA_Y          (WIDTH_FEA_Y         ),
  .OLPY_L234_DEPTH      (OLPY_L234_DEPTH     ),
  .OLPX_L234_DEPTH      (OLPX_L234_DEPTH     ),
  .OLPXY_L234_DEPTH     (OLPXY_L234_DEPTH    ),
  .PE_OUTPUT_WD         (PE_OUTPUT_WD        ),
  .PU_RF_ACCU_WD        (PU_RF_ACCU_WD       )
)
u_top
(
  .clk                  (clk                 ),
  .rst_n                (rst_n                ),
  .ctrl_reg             (ctrl_reg            ),
  .state_reg            (state_reg           ),
  .reg0                 (reg0                ),
  .reg1                 (reg1                ),
  .axi2w_waddr          (axi2w_waddr         ),
  .axi2w_wen            (axi2w_wen           ),
  .axi2w_wdata          (axi2w_wdata         ),
  .axi2w_raddr          (axi2w_raddr         ),
  .axi2w_ren            (axi2w_ren           ),
  .axi2w_rdata          (axi2w_rdata         ),
  .axi2p_waddr          (axi2p_waddr         ),
  .axi2p_wen            (axi2p_wen           ),
  .axi2p_wdata          (axi2p_wdata         ),
  .axi2p_raddr          (axi2p_raddr         ),
  .axi2p_ren            (axi2p_ren           ),
  .axi2p_rdata          (axi2p_rdata         ),
  .axi2f_waddr          (axi2f_waddr         ),
  .axi2f_wen            (axi2f_wen           ),
  .axi2f_wdata          (axi2f_wdata         ),
  .axi2f_raddr          (axi2f_raddr         ),
  .axi2f_ren            (axi2f_ren           ),
  .axi2f_rdata          (axi2f_rdata         )
);

/******************************************************************************/
/**************************** Clock Value Generation **************************/
/******************************************************************************/
initial begin
  clk = 1'b1;
end

always #(`PERIOD/2) clk = ~clk;

/*******************************************************************************/
/******************************* Test Flow Generation **************************/
/*******************************************************************************/
initial begin
  system_rst_n();
  wait_some_cycles();

  fork
    loading_fe_buf();
    loading_param_buf();
    loading_wt_buf();
    //loading_reg();
    wait_one_cycle();
  join
end

// finish
reg ctrl_reg_pre;
always @(posedge clk) ctrl_reg_pre <= u_top.u_ctrl_engine.cur_state;

initial begin
  wait(u_top.u_ctrl_engine.cur_state == 0 && ctrl_reg_pre == 1);
  #(`PERIOD*1000);
  $finish;
end

initial begin
  #(`PERIOD*1000000) $display("Simulation Timeout!");
  $finish;
end

//loading reg
integer reg_file;

initial begin
  reg_file = $fopen(`REG_FILE, "r");
  #(`PERIOD*500) begin
    $fscanf(reg_file, "%h", ctrl_reg);
  end
  #(`PERIOD*500) begin
    $fscanf(reg_file, "%h", reg0);
    $fscanf(reg_file, "%h", reg1);
    wait_one_cycle();
    $fscanf(reg_file, "%h", ctrl_reg);
    wait_one_cycle();
    $fscanf(reg_file, "%h", ctrl_reg);
  end
  $fclose(reg_file);
end

// nxt_loading_event
/*
initial begin
  forever begin
    @(negedge u_top.tile_switch_r);
      ->nxt_tile_event;
    wait(u_top.u_fe_buf.layer_done && u_top.u_fe_buf.tile_switch_r);
    begin
      -> nxt_loading_event;
    end
  end
end*/
// nxt_loading_event
initial begin
  forever begin
    @(posedge u_top.u_ctrl_engine.layer_done);
      if (u_top.u_ctrl_engine.cnt_layer == 1) begin
        wait_some_cycles();
        -> nxt_loading_event;
      end
  end
end
/*
initial begin
    #(`PERIOD*1010) -> nxt_loading_event;
end*/

initial begin
    #(`PERIOD*30) -> nxt_loading_event;
end

//nxt_wt_param_event

initial begin
    #(`PERIOD*40) -> nxt_wt_param_event;
end


// nxt_reg_event
initial begin
  forever begin
    @(posedge u_top.layer_done);
      -> nxt_reg_event;
  end
end

initial begin
    #(`PERIOD*1000) -> nxt_reg_event;
end


/******************************************************************************/
/********************************** moniter ***********************************/
/******************************************************************************/
/*
integer golden_buf;
integer golden_i;
integer golden_j;
reg [REG_IH_WIDTH     : 0] fe_oh;
reg [REG_IC_WIDTH - 1 : 0] fe_oc;
reg [REG_OH_WIDTH - 1 : 0] golden_oh;
reg [REG_OC_WIDTH - 1 : 0] golden_oc;
reg [REG_OC_WIDTH - 1 : 0] num_oc;
reg [AXI2F_DATA_WIDTH - 1 : 0]    axi2f_rdata_golden;
reg [AXI2F_DATA_WIDTH - 1 : 0]    axi2f_rdata_golden_r;
reg [AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_raddr_r;
reg  axi2f_ren_r;
reg  moniter_done;
reg  lst_tile_done_r;
reg  lst_tile_done_r2;
wire lst_tile_done;
reg  layer_done_r;
//reg [AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_raddr_golden;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) lst_tile_done_r <= 0;
  else if(reg0 == 32'hffffffff && reg1 == 32'hffffffff && ctrl_reg == 32'h00000001)
             lst_tile_done_r <= 1;
end

always @(posedge clk) lst_tile_done_r2 <= lst_tile_done_r;
always @(posedge clk) layer_done_r <= u_top.u_fe_buf.layer_done;

assign lst_tile_done = lst_tile_done_r2 ^ lst_tile_done_r;

initial begin
  forever begin
    wait((layer_done_r && u_top.u_ctrl_engine.tile_switch) || lst_tile_done) begin
      golden_buf = $fopen(`GOLDEN_BUF_FILE ,"r" );

      $fscanf(golden_buf, "%h", fe_oc);
      $fscanf(golden_buf, "%h", fe_oh);
      axi2f_ren <= 0;

      for(golden_i = 0; golden_i < (((fe_oc + 3) >> 2) << 2); golden_i = golden_i + 1) begin
        $fscanf(golden_buf, "%h", num_oc);
        for(golden_j = 0; golden_j < ((fe_oh + 3) >> 2); golden_j = golden_j + 1) begin
            wait_one_cycle();
            $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - 1 : AXI2F_DATA_WIDTH  - FE_BUF_WIDTH]);
            $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH]);
            $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH]);
            $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH - 1 : 0]);
            axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] <= num_oc[1:0];
            axi2f_raddr[AXI2F_ADDR_WIDTH - 3 : 0] <= num_oc[REG_IC_WIDTH - 1 : 2] * ((fe_oh + 3) >> 2) + golden_j;
            axi2f_ren <= 1;
        end
      end

      wait_one_cycle();
      axi2f_ren = 0;
      moniter_done = 1;
      wait_one_cycle();
      moniter_done = 0;
    end
  end
end

initial begin
  forever @(posedge clk) begin
    axi2f_rdata_golden_r <= axi2f_rdata_golden;
    axi2f_ren_r <= axi2f_ren;
    axi2f_raddr_r <= axi2f_raddr;
  end
end

initial begin
  forever begin
    @(posedge clk) begin
      if(axi2f_ren_r == 1 && (axi2f_rdata_golden_r != axi2f_rdata)) begin
        $display("\033[30;41m mismatch happened at time %0t\033[0m", $time);
        $display("the mismatch in buffer %d", axi2f_raddr_r[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2]);
        $display("the mismatch addr is %d", axi2f_raddr_r[AXI2F_ADDR_WIDTH - 3 : 0]);
        `ifndef RUNALL
          #(`PERIOD*100) $finish;
        `endif
      end
    end
  end
end
*/
/******************************************************************************/
/**************************** moniter layer ***********************************/
/******************************************************************************/
reg [FE_BUF_WIDTH - 1 : 0] fe_buf_layer [5][16][32];
reg [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_r;
integer fe_buf_layer1;
integer fe_buf_layer2;
integer fe_buf_layer3;
integer fe_buf_layer4;
integer fe_buf_layer5;
integer fe_layer_i;
integer fe_layer_j;
reg  [REG_OH_WIDTH     : 0] fe_layer_oh;
reg  [REG_OC_WIDTH - 1 : 0] fe_layer_oc;
reg  [REG_OC_WIDTH - 1 : 0] num_layer_oc;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_w;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c0;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c1;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c2;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c3;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c0_o;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c1_o;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c2_o;
wire [FE_BUF_WIDTH - 1 : 0] fe_buf_layer_c3_o;
wire [REG_OH_WIDTH     : 0] fe_h_golden;
reg  [REG_OH_WIDTH     : 0] fe_h_cnt;
wire [15               : 0] fe_buf_wr_en_o;
event nxt_fe_layer_event;

initial begin
  forever begin
    @(posedge (u_top.layer_start === 1));
      if(u_top.cnt_layer == 1) begin
        -> nxt_fe_layer_event;
      end
  end
end

assign fe_buf_layer_w = fe_buf_layer[0][0][0];
//fe_buf = $fopen( `FE_BUF_FILE ,"r" );
initial begin
  fe_buf_layer1 = $fopen(`FE_LAYER1, "r");
  fe_buf_layer2 = $fopen(`FE_LAYER2, "r");
  fe_buf_layer3 = $fopen(`FE_LAYER3, "r");
  fe_buf_layer4 = $fopen(`FE_LAYER4, "r");
  fe_buf_layer5 = $fopen(`FE_LAYER5, "r");

  forever begin
    @(nxt_fe_layer_event);

    $fscanf(fe_buf_layer1, "%h", fe_layer_oh);
    $fscanf(fe_buf_layer1, "%h", fe_layer_oc);

    for(fe_layer_i = 0; fe_layer_i < (fe_layer_oc); fe_layer_i = fe_layer_i + 1) begin
      $fscanf(fe_buf_layer1, "%h", num_layer_oc);
      for(fe_layer_j = 0; fe_layer_j < fe_layer_oh; fe_layer_j = fe_layer_j + 1) begin
        $fscanf(fe_buf_layer1, "%h", fe_buf_layer_r);
        fe_buf_layer[0][fe_layer_i][fe_layer_j] = fe_buf_layer_r;
      end
    end

    $fscanf(fe_buf_layer2, "%h", fe_layer_oh);
    $fscanf(fe_buf_layer2, "%h", fe_layer_oc);

    for(fe_layer_i = 0; fe_layer_i < (fe_layer_oc); fe_layer_i = fe_layer_i + 1) begin
      $fscanf(fe_buf_layer2, "%h", num_layer_oc);
      for(fe_layer_j = 0; fe_layer_j < fe_layer_oh; fe_layer_j = fe_layer_j + 1) begin
        $fscanf(fe_buf_layer2, "%h", fe_buf_layer_r);
        fe_buf_layer[1][fe_layer_i][fe_layer_j] = fe_buf_layer_r;
      end
    end

    $fscanf(fe_buf_layer3, "%h", fe_layer_oh);
    $fscanf(fe_buf_layer3, "%h", fe_layer_oc);

    for(fe_layer_i = 0; fe_layer_i < (fe_layer_oc); fe_layer_i = fe_layer_i + 1) begin
      $fscanf(fe_buf_layer3, "%h", num_layer_oc);
      for(fe_layer_j = 0; fe_layer_j < fe_layer_oh; fe_layer_j = fe_layer_j + 1) begin
        $fscanf(fe_buf_layer3, "%h", fe_buf_layer_r);
        fe_buf_layer[2][fe_layer_i][fe_layer_j] = fe_buf_layer_r;
      end
    end

    $fscanf(fe_buf_layer4, "%h", fe_layer_oh);
    $fscanf(fe_buf_layer4, "%h", fe_layer_oc);

    for(fe_layer_i = 0; fe_layer_i < (fe_layer_oc); fe_layer_i = fe_layer_i + 1) begin
      $fscanf(fe_buf_layer4, "%h", num_layer_oc);
      for(fe_layer_j = 0; fe_layer_j < fe_layer_oh; fe_layer_j = fe_layer_j + 1) begin
        $fscanf(fe_buf_layer4, "%h", fe_buf_layer_r);
        fe_buf_layer[3][fe_layer_i][fe_layer_j] = fe_buf_layer_r;
      end
    end

    $fscanf(fe_buf_layer5, "%h", fe_layer_oh);
    $fscanf(fe_buf_layer5, "%h", fe_layer_oc);

    for(fe_layer_i = 0; fe_layer_i < (fe_layer_oc); fe_layer_i = fe_layer_i + 1) begin
      $fscanf(fe_buf_layer5, "%h", num_layer_oc);
      for(fe_layer_j = 0; fe_layer_j < fe_layer_oh; fe_layer_j = fe_layer_j + 1) begin
        $fscanf(fe_buf_layer5, "%h", fe_buf_layer_r);
        fe_buf_layer[4][fe_layer_i][fe_layer_j] = fe_buf_layer_r;
      end
    end

    wait_some_cycles();
  end
end

always @(*) begin
  case(u_top.u_pu_top.fe_buf_wr_en_o[3:0])
    4'b0001: fe_h_cnt = 0;
    4'b0010: fe_h_cnt = 1;
    4'b0100: fe_h_cnt = 2;
    4'b1000: fe_h_cnt = 3;
    default: fe_h_cnt = 0;
  endcase
end 

assign fe_h_golden = u_top.u_pu_top.tile_h_cnt_r + fe_h_cnt;

assign fe_buf_layer_c0 = u_top.u_pu_top.fe_buf_wr_en_o != 0 ? fe_buf_layer[u_top.u_pu_top.layer_cnt_r][u_top.u_pu_top.tile_oc_cnt_r][fe_h_golden] : 0;
assign fe_buf_layer_c1 = u_top.u_pu_top.fe_buf_wr_en_o != 0 ? fe_buf_layer[u_top.u_pu_top.layer_cnt_r][u_top.u_pu_top.tile_oc_cnt_r + 1][fe_h_golden] : 0;
assign fe_buf_layer_c2 = u_top.u_pu_top.fe_buf_wr_en_o != 0 ? fe_buf_layer[u_top.u_pu_top.layer_cnt_r][u_top.u_pu_top.tile_oc_cnt_r + 2][fe_h_golden] : 0;
assign fe_buf_layer_c3 = u_top.u_pu_top.fe_buf_wr_en_o != 0 ? fe_buf_layer[u_top.u_pu_top.layer_cnt_r][u_top.u_pu_top.tile_oc_cnt_r + 3][fe_h_golden] : 0;

assign fe_buf_layer_c0_o = u_top.tile_loc[3] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_0_0_o) << ((32 - u_top.u_scheduler.tile_out_w) * 8) :
                           (u_top.tile_loc[2] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_0_0_o) >> ((32 - u_top.u_scheduler.tile_out_w) * 8) << ((32 - u_top.u_scheduler.tile_out_w) * 8) : u_top.u_pu_top.fe_buf_wr_dat_0_0_o);
assign fe_buf_layer_c1_o = u_top.tile_loc[3] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_1_0_o) << ((32 - u_top.u_scheduler.tile_out_w) * 8) :
                           (u_top.tile_loc[2] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_1_0_o) >> ((32 - u_top.u_scheduler.tile_out_w) * 8) << ((32 - u_top.u_scheduler.tile_out_w) * 8) : u_top.u_pu_top.fe_buf_wr_dat_0_0_o);
assign fe_buf_layer_c2_o = u_top.tile_loc[3] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_2_0_o) << ((32 - u_top.u_scheduler.tile_out_w) * 8) :
                           (u_top.tile_loc[2] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_2_0_o) >> ((32 - u_top.u_scheduler.tile_out_w) * 8) << ((32 - u_top.u_scheduler.tile_out_w) * 8) : u_top.u_pu_top.fe_buf_wr_dat_0_0_o);
assign fe_buf_layer_c3_o = u_top.tile_loc[3] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_3_0_o) << ((32 - u_top.u_scheduler.tile_out_w) * 8) :
                           (u_top.tile_loc[2] == 1 ? (u_top.u_pu_top.fe_buf_wr_dat_3_0_o) >> ((32 - u_top.u_scheduler.tile_out_w) * 8) << ((32 - u_top.u_scheduler.tile_out_w) * 8) : u_top.u_pu_top.fe_buf_wr_dat_0_0_o);

assign fe_buf_wr_en_o = (u_top.u_pu_top.lst_h4_bias == 0 || !u_top.u_pu_top.is_tile_lst_h_w) ? u_top.u_pu_top.fe_buf_wr_en_o :
                         {u_top.u_pu_top.fe_buf_wr_en_o[15:12] & (4'b1111 >> (4 - u_top.u_pu_top.lst_h4_bias)),
                          u_top.u_pu_top.fe_buf_wr_en_o[11: 8] & (4'b1111 >> (4 - u_top.u_pu_top.lst_h4_bias)),
                          u_top.u_pu_top.fe_buf_wr_en_o[7 : 4] & (4'b1111 >> (4 - u_top.u_pu_top.lst_h4_bias)),
                          u_top.u_pu_top.fe_buf_wr_en_o[3 : 0] & (4'b1111 >> (4 - u_top.u_pu_top.lst_h4_bias))};

initial begin
  forever begin
    @(posedge clk) begin
      if(fe_buf_wr_en_o != 0 ) begin
        if(fe_buf_layer_c0 !== fe_buf_layer_c0_o) begin
          $display("\033[30;42m mismatch happened at time %0t\033[0m", $time);
          $display("the mismatch layer is %d", u_top.cnt_layer);
          $display("the mismatch in oh %d", fe_h_golden);
          $display("the mismatch in oc %d", u_top.u_pu_top.tile_oc_cnt_r);
          $display("the golden data is %h", fe_buf_layer_c0);
          $display("the output data is %h", fe_buf_layer_c0_o);
          `ifndef RUNALL
          #(`PERIOD*100) $finish;
          `endif
        end
        if(fe_buf_layer_c1 !== fe_buf_layer_c1_o) begin
          $display("\033[30;42m mismatch happened at time %0t\033[0m", $time);
          $display("the mismatch layer is %d", u_top.cnt_layer);
          $display("the mismatch in oh %d", fe_h_golden);
          $display("the mismatch in oc %d", u_top.u_pu_top.tile_oc_cnt_r + 1);
          $display("the golden data is %h", fe_buf_layer_c1);
          $display("the output data is %h", fe_buf_layer_c1_o);
          `ifndef RUNALL
          #(`PERIOD*100) $finish;
          `endif
        end
        if(fe_buf_layer_c2 !== fe_buf_layer_c2_o) begin
          $display("\033[30;42m mismatch happened at time %0t\033[0m", $time);
          $display("the mismatch layer is %d", u_top.cnt_layer);
          $display("the mismatch in oh %d", fe_h_golden);
          $display("the mismatch in oc %d", u_top.u_pu_top.tile_oc_cnt_r + 2);
          $display("the golden data is %h", fe_buf_layer_c2);
          $display("the output data is %h", fe_buf_layer_c2_o);
          `ifndef RUNALL
          #(`PERIOD*100) $finish;
          `endif
        end
        if(fe_buf_layer_c3 !== fe_buf_layer_c3_o) begin
          $display("\033[30;42m mismatch happened at time %0t\033[0m", $time);
          $display("the mismatch layer is %d", u_top.cnt_layer);
          $display("the mismatch in oh %d", fe_h_golden);
          $display("the mismatch in oc %d", u_top.u_pu_top.tile_oc_cnt_r + 3);
          $display("the golden data is %h", fe_buf_layer_c3);
          $display("the output data is %h", fe_buf_layer_c3_o);
          `ifndef RUNALL
          #(`PERIOD*100) $finish;
          `endif
        end
      end
    end
  end
end

/*******************************************************************************/
/********************** Task Definition in Testbench ***************************/
/*******************************************************************************/
//`include "../tb/sub_bench/task.sv"
task wait_some_cycles();
    #(`PERIOD*4);
endtask

task wait_one_cycle();
    #(`PERIOD);
endtask

task wait_half_cycle();
    #(`PERIOD/2);
endtask

task wait_quarter_cycle();
    #(`PERIOD/4);
endtask

task system_rst_n();
    wait_some_cycles();
    rst_n <= 1;
    wait_some_cycles();
    rst_n <= 0;
    wait_some_cycles();
    rst_n <= 1;
endtask

task loading_fe_buf();
//------------------------------------------------
//ih(h)
//ic(h)
//num ic(h)
//ic0 fea0_0 data(256'h)
//ic0 fea0_1 data(256'h)
//ic0 fea0_2 data(256'h)
//ic0 fea0_3 data(256'h)
//...
//ic0 fea0_3 data(256'h) h/4 (fill 0 when h/4 != 0)
//num ic(h)
//ic1 fea1_0 data(256'h)
//...
//-------------------------------------------------
  integer fe_buf;
  integer fe_i;
  integer fe_j;
  reg [REG_IH_WIDTH     : 0] fe_ih;
  reg [REG_IC_WIDTH - 1 : 0] fe_ic;
  reg [REG_IC_WIDTH - 1 : 0] num_ic;
  reg [AXI2F_DATA_WIDTH - 1 : 0]    axi2f_wdata_r    ;

  fe_buf = $fopen( `FE_BUF_FILE ,"r" );

  forever begin
    @(nxt_loading_event);

    $fscanf(fe_buf, "%h", fe_ih);
    $fscanf(fe_buf, "%h", fe_ic);

    for(fe_i = 0; fe_i < (fe_ic); fe_i = fe_i + 1) begin
      $fscanf(fe_buf, "%h", num_ic);
      for(fe_j = 0; fe_j < ((fe_ih + 3) >> 2); fe_j = fe_j + 1) begin
        wait_one_cycle();
        $fscanf(fe_buf, "%h", axi2f_wdata_r[AXI2F_DATA_WIDTH  - 1 : AXI2F_DATA_WIDTH  - FE_BUF_WIDTH]);
        $fscanf(fe_buf, "%h", axi2f_wdata_r[AXI2F_DATA_WIDTH  - FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH]);
        $fscanf(fe_buf, "%h", axi2f_wdata_r[AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH]);
        $fscanf(fe_buf, "%h", axi2f_wdata_r[AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH - 1 : 0]);
        axi2f_wdata <= axi2f_wdata_r;
        axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] <= num_ic[1:0];
        axi2f_waddr[AXI2F_ADDR_WIDTH - 3 : 0] <= num_ic[REG_IC_WIDTH - 1 : 2] * ((fe_ih + 3) >> 2) + fe_j;
        axi2f_wen <= 1;
      end
    end

    wait_one_cycle();
    wait_one_cycle();
    axi2f_wen <= 0;
  end

  $fclose(fe_buf);
endtask

task loading_wt_buf();
//--------------------------------------------------------
//the first line ceil(num of wt line)
//there are 16 wt_data every line, the data arrangement
//is ic0oc0, ic0oc1, ... , ic1oc0, ... , ic3oc3(8'h).
//fill 0 when ic or oc unvalid.
//the vertical sequence is ksize * ksize, ic, oc, h, layer
//--------------------------------------------------------
  integer wt_buf;
  integer i, j, k;
  reg [15 - 1 : 0] num_wt;
  reg [6 - 1 : 0] num_layer;
  reg [WT_BUF_WIDTH - 1  : 0] wt_data_0, wt_data_1, wt_data_2, wt_data_3, wt_data_4, wt_data_5, wt_data_6, wt_data_7;
  reg [WT_BUF_WIDTH - 1  : 0] wt_data_0_r, wt_data_1_r, wt_data_2_r, wt_data_3_r, wt_data_4_r, wt_data_5_r, wt_data_6_r, wt_data_7_r;

  wt_buf = $fopen(`WT_BUF_FILE, "r");

  forever begin
    @(nxt_wt_param_event);

    $fscanf(wt_buf, "%h", num_wt);

    for(i = 0; i < ((num_wt + 7) >> 3); i = i + 1) begin
        wait_one_cycle();
        $fscanf(wt_buf, "%h", wt_data_0);
        $fscanf(wt_buf, "%h", wt_data_1);
        $fscanf(wt_buf, "%h", wt_data_2);
        $fscanf(wt_buf, "%h", wt_data_3);
        $fscanf(wt_buf, "%h", wt_data_4);
        $fscanf(wt_buf, "%h", wt_data_5);
        $fscanf(wt_buf, "%h", wt_data_6);
        $fscanf(wt_buf, "%h", wt_data_7);
        for(k = 0; k < 16; k++) begin
          wt_data_0_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_0[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_1_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_1[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_2_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_2[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_3_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_3[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_4_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_4[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_5_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_5[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_6_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_6[(15-k)*WT_WIDTH +:WT_WIDTH];
          wt_data_7_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_7[(15-k)*WT_WIDTH +:WT_WIDTH];
        end
        axi2w_wdata = {wt_data_0_r, wt_data_1_r, wt_data_2_r, wt_data_3_r, wt_data_4_r, wt_data_5_r, wt_data_6_r, wt_data_7_r};
        axi2w_waddr = i;
        axi2w_wen = 1;
    end

    wait_one_cycle();
    axi2w_wen = 0;
  end

  $fclose(wt_buf);
endtask

task loading_param_buf();
//---------------------------
//ceil(oc/4)*4
//bias,LBM,HBM (16'h*3) h0,oc0
//bias,LBM,HBM (16'h*3) h0,oc1
//bias,LBM,HBM (16'h*3) h0,oc2
//bias,LBM,HBM (16'h*3) h0,oc3
//bias,LBM,HBM (16'h*3) h0,oc4
//...
//...
//ceil(oc/4)*4 next_layer
//...
//----------------------------
  integer param_buf;
  integer i, j;
  reg [6 - 1 : 0] num_layer;
  reg [14:0] num_oc;

  param_buf = $fopen(`PARAM_BUF_FILE, "r");

  forever begin
    @(nxt_wt_param_event);

    $fscanf(param_buf, "%h", num_layer);

    for(j = 0; j < num_layer; j = j + 1) begin

      $fscanf(param_buf, "%h", num_oc);

      for(i = 0; i < ((num_oc + 3) >> 2); i = i + 1) begin
        wait_one_cycle();
        $fscanf(param_buf, "%h", axi2p_wdata[BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH - 1 : 0]);
        $fscanf(param_buf, "%h", axi2p_wdata[2*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH) - 1 : BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH]);
        $fscanf(param_buf, "%h", axi2p_wdata[3*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH) - 1 : 2*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH)]);
        $fscanf(param_buf, "%h", axi2p_wdata[4*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH) - 1 : 3*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH)]);
        axi2p_waddr = j * ((num_oc + 3) >> 2) + i;
        axi2p_wen = 1;
      end
    end

    wait_one_cycle();
    wait_one_cycle();
    axi2p_wen = 0;
  end

  $fclose(param_buf);
endtask

task loading_reg();
//-------------------------
//reg0(32'h)
//reg1(32'h)
//ctrl_reg(32'h)
//...(next layer)
//-------------------------
  integer reg_file;
  integer i;
  reg [14:0] num_layer;

  reg_file = $fopen(`REG_FILE, "r");

  forever begin
    @(nxt_reg_event)
    //for(i = 0; i < num_layer - 1; i = i + 1) begin
      $fscanf(reg_file, "%h", reg0);
      $fscanf(reg_file, "%h", reg1);
      wait_one_cycle();
      $fscanf(reg_file, "%h", ctrl_reg);
    //end
  end

  $fclose(reg_file);
endtask

/*******************************************************************************/
/****************************** dump wave **************************************/
/*******************************************************************************/
`ifdef DUMP_VPD
initial begin
    $display("Dump VPD wave!");
    $vcdpluson();
end
`endif

initial	begin
   $display("Dump fsdb wave!");
   $fsdbDumpfile("tb.fsdb");
   $fsdbDumpvars;
end

endmodule
