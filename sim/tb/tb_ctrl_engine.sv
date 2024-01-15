`timescale 1ns/1ps
`define PERIOD  8

module tb_ctrl_engine;
    parameter    REG_IFMH_WIDTH       = 10                      ;
    parameter    REG_IFMW_WIDTH       = 10                      ;
    parameter    REG_TILEH_WIDTH      = 6                       ;
    parameter    REG_TNY_WIDTH        = 6                       ;
    parameter    REG_TNX_WIDTH        = 6                       ;
    parameter    REG_TLW_WIDTH        = 6                       ;
    parameter    REG_TLH_WIDTH        = 6                       ;
    parameter    TILE_BASE_W          = 32                      ;
    parameter    REG_IH_WIDTH         = 6                       ;
    parameter    REG_OH_WIDTH         = 6                       ;
    parameter    REG_IW_WIDTH         = 6                       ;
    parameter    REG_OW_WIDTH         = 6                       ;
    parameter    REG_IC_WIDTH         = 6                       ;
    parameter    REG_OC_WIDTH         = 6                       ;
    parameter    REG_AF_WIDTH         = 1                       ;
    parameter    REG_HBM_SFT_WIDTH    = 6                       ;
    parameter    REG_LBM_SFT_WIDTH    = 6                       ;

    logic                                 clk                   ;
    logic                                 rst_n                 ;
    logic  [                 32 - 1 : 0]  ctrl_reg              ;
    logic  [                 32 - 1 : 0]  state_reg             ;
    logic  [                 32 - 1 : 0]  reg0                  ;
    logic  [                 32 - 1 : 0]  reg1                  ;
    logic                                 layer_done            ;
    logic                                 layer_start           ;
    logic  [                      1 : 0]  stat_ctrl             ;
    logic  [                      2 : 0]  cnt_layer             ;
    logic                                 tile_switch_r         ;
    logic                                 model_switch_r        ;
    logic                                 tile_switch           ;
    logic                                 model_switch          ;
    logic                                 model_switch_layer    ;
    logic                                 nn_proc               ;
    logic  [      REG_TNX_WIDTH - 1 : 0]  tile_tot_num_x        ;
    logic  [       REG_IH_WIDTH - 1 : 0]  tile_in_h             ;
    logic  [       REG_OH_WIDTH - 1 : 0]  tile_out_h            ;
    logic  [       REG_IW_WIDTH - 1 : 0]  tile_in_w             ;
    logic  [       REG_OW_WIDTH - 1 : 0]  tile_out_w            ;
    logic  [       REG_IC_WIDTH - 1 : 0]  tile_in_c             ;
    logic  [       REG_OC_WIDTH - 1 : 0]  tile_out_c            ;
    logic  [                      2 : 0]  ksize                 ;
    logic  [                      3 : 0]  tile_loc              ;
    logic                                 x4_shuffle_vld        ;
    logic  [       REG_AF_WIDTH - 1 : 0]  prl_vld               ;
    logic  [                      1 : 0]  res_proc_type         ;
    logic  [  REG_HBM_SFT_WIDTH - 1 : 0]  pu_hbm_shift          ;
    logic  [  REG_LBM_SFT_WIDTH - 1 : 0]  pu_lbm_shift          ;
    logic                                 buf_pp_flag           ;

//   logic                                      moniter_done   ;

//   event    nxt_tile_event ;
//   event    nxt_stack_event;
//   event    nxt_reg_event;
//   event    nxt_loading_event;
//   event    nxt_wt_param_event;

/******************************************************************************/
/************************************** DUT ***********************************/
/******************************************************************************/
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
    .tile_loc                      (tile_loc                               ),
    .x4_shuffle_vld                (x4_shuffle_vld                         ),
    .prl_vld                       (prl_vld                                ),
    .res_proc_type                 (res_proc_type                          ),
    .pu_hbm_shift                  (pu_hbm_shift                           ),
    .pu_lbm_shift                  (pu_lbm_shift                           ),
    .buf_pp_flag                   (buf_pp_flag                            )
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
  wait_half_cycle();
  set_reg();
end

// finish
initial begin
  wait(state_reg == 32'h00000001);
  #(`PERIOD*1000) $display("Simulation DONE!");
  $finish;
end

initial begin
  #(`PERIOD*1000000) $display("Simulation Timeout!");
  $finish;
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
    @(!rst_n)
      layer_done <= 0;
  end
end

initial begin
  forever begin
    @(posedge u_ctrl_engine.layer_start);
      wait_some_cycles();
      layer_done <= 1;
      wait_one_cycle();
      layer_done <= 0;
      end
  end

/*
initial begin
    #(`PERIOD*1010) -> nxt_loading_event;
end*/

// initial begin
//     #(`PERIOD*30) -> nxt_loading_event;
// end

// //nxt_wt_param_event

// initial begin
//     #(`PERIOD*40) -> nxt_wt_param_event;
// end


// // nxt_reg_event
// initial begin
//   forever begin
//     @(posedge u_top.layer_done);
//       -> nxt_reg_event;
//   end
// end

// initial begin
//     #(`PERIOD*1000) -> nxt_reg_event;
// end


/******************************************************************************/
/********************************** moniter ***********************************/
/******************************************************************************/
// integer golden_buf;
// integer golden_i;
// integer golden_j;
// reg [REG_IH_WIDTH     : 0] fe_oh;
// reg [REG_IC_WIDTH - 1 : 0] fe_oc;
// reg [REG_OH_WIDTH - 1 : 0] golden_oh;
// reg [REG_OC_WIDTH - 1 : 0] golden_oc;
// reg [REG_OC_WIDTH - 1 : 0] num_oc;
// reg [AXI2F_DATA_WIDTH - 1 : 0]    axi2f_rdata_golden;
// reg [AXI2F_DATA_WIDTH - 1 : 0]    axi2f_rdata_golden_r;
// reg [AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_raddr_r;
// reg  axi2f_ren_r;
// reg  moniter_done;
// reg  lst_tile_done_r;
// reg  lst_tile_done_r2;
// wire lst_tile_done;
// reg  layer_done_r;
// //reg [AXI2F_ADDR_WIDTH - 1 : 0]    axi2f_raddr_golden;

// always @(posedge clk or negedge rst_n)
// begin
//   if(!rst_n) lst_tile_done_r <= 0;
//   else if(reg0 == 32'hffffffff && reg1 == 32'hffffffff && ctrl_reg == 32'h00000001)
//              lst_tile_done_r <= 1;
// end

// always @(posedge clk) lst_tile_done_r2 <= lst_tile_done_r;
// always @(posedge clk) layer_done_r <= u_top.u_fe_buf.layer_done;

// assign lst_tile_done = lst_tile_done_r2 ^ lst_tile_done_r;

// initial begin
//   forever begin
//     wait((layer_done_r && u_top.u_ctrl_engine.tile_switch) || lst_tile_done) begin
//       golden_buf = $fopen(`GOLDEN_BUF_FILE ,"r" );

//       $fscanf(golden_buf, "%d", fe_oc);
//       $fscanf(golden_buf, "%d", fe_oh);

//       for(golden_i = 0; golden_i < (((fe_oc + 3) >> 2) << 2); golden_i = golden_i + 1) begin
//         $fscanf(golden_buf, "%d", num_oc);
//         for(golden_j = 0; golden_j < ((fe_oh + 3) >> 2); golden_j = golden_j + 1) begin
//             wait_one_cycle();
//             $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - 1 : AXI2F_DATA_WIDTH  - FE_BUF_WIDTH]);
//             $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH]);
//             $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH]);
//             $fscanf(golden_buf, "%h", axi2f_rdata_golden[AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH - 1 : 0]);
//             axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] = num_oc[1:0];
//             axi2f_raddr[AXI2F_ADDR_WIDTH - 3 : 0] = num_oc[REG_IC_WIDTH - 1 : 2] * ((fe_oh + 3) >> 2) + golden_j;
//             axi2f_ren = 1;
//         end
//       end

//       wait_one_cycle();
//       axi2f_ren = 0;
//       moniter_done = 1;
//       wait_one_cycle();
//       moniter_done = 0;
//     end
//   end
// end

// initial begin
//   forever @(posedge clk) begin
//     axi2f_rdata_golden_r <= axi2f_rdata_golden;
//     axi2f_ren_r <= axi2f_ren;
//     axi2f_raddr_r <= axi2f_raddr;
//   end
// end

// initial begin
//   forever begin
//     @(posedge clk) begin
//       if(axi2f_ren_r == 1 && (axi2f_rdata_golden_r != axi2f_rdata)) begin
//         $display("\033[30;41m mismatch happened at time %0t\033[0m", $time);
//         $display("the mismatch in buffer %d", axi2f_raddr_r[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2]);
//         $display("the mismatch addr is %d", axi2f_raddr_r[AXI2F_ADDR_WIDTH - 3 : 0]);
//         //#(`PERIOD*100) $finish;
//       end
//     end
//   end
// end

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

task set_reg();
    ctrl_reg <= 32'h00000002;
    wait_one_cycle();
    ctrl_reg <= 32'h00000000;
    wait_some_cycles();
    // reg0 <= 32'h0000a028; //40*40
    // reg1 <= 32'h082020a0;
    reg0 <= 32'h000873C0; //960*540
    reg1 <= 32'h1C01F460;
    wait_one_cycle();
    ctrl_reg <= 32'h00000003;
    wait_one_cycle();
    ctrl_reg <= 32'h00000000;
endtask

// task loading_fe_buf();
// //------------------------------------------------
// //ih(h)
// //ic(h)
// //num ic(h)
// //ic0 fea0_0 data(256'h)
// //ic0 fea0_1 data(256'h)
// //ic0 fea0_2 data(256'h)
// //ic0 fea0_3 data(256'h)
// //...
// //ic0 fea0_3 data(256'h) h/4 (fill 0 when h/4 != 0)
// //num ic(h)
// //ic1 fea1_0 data(256'h)
// //...
// //-------------------------------------------------
//   integer fe_buf;
//   integer fe_i;
//   integer fe_j;
//   reg [REG_IH_WIDTH     : 0] fe_ih;
//   reg [REG_IC_WIDTH - 1 : 0] fe_ic;
//   reg [REG_IC_WIDTH - 1 : 0] num_ic;

//   fe_buf = $fopen( `FE_BUF_FILE ,"r" );

//   forever begin
//     @(nxt_loading_event);

//     $fscanf(fe_buf, "%d", fe_ih);
//     $fscanf(fe_buf, "%d", fe_ic);

//     for(fe_i = 0; fe_i < (((fe_ic + 3) >> 2) << 2); fe_i = fe_i + 1) begin
//       $fscanf(fe_buf, "%d", num_ic);
//       for(fe_j = 0; fe_j < ((fe_ih + 3) >> 2); fe_j = fe_j + 1) begin
//         wait_one_cycle();
//         $fscanf(fe_buf, "%h", axi2f_wdata[AXI2F_DATA_WIDTH  - 1 : AXI2F_DATA_WIDTH  - FE_BUF_WIDTH]);
//         $fscanf(fe_buf, "%h", axi2f_wdata[AXI2F_DATA_WIDTH  - FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH]);
//         $fscanf(fe_buf, "%h", axi2f_wdata[AXI2F_DATA_WIDTH  - 2*FE_BUF_WIDTH - 1 : AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH]);
//         $fscanf(fe_buf, "%h", axi2f_wdata[AXI2F_DATA_WIDTH  - 3*FE_BUF_WIDTH - 1 : 0]);
//         axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] <= num_ic[1:0];
//         axi2f_waddr[AXI2F_ADDR_WIDTH - 3 : 0] <= num_ic[REG_IC_WIDTH - 1 : 2] * ((fe_ih + 3) >> 2) + fe_j;
//         axi2f_wen = 1;
//       end
//     end

//     wait_one_cycle();
//     axi2f_wen = 0;
//   end

//   $fclose(fe_buf);
// endtask

// task loading_wt_buf();
// //--------------------------------------------------------
// //the first line ceil(num of wt line)
// //there are 16 wt_data every line, the data arrangement
// //is ic0oc0, ic0oc1, ... , ic1oc0, ... , ic3oc3(8'h).
// //fill 0 when ic or oc unvalid.
// //the vertical sequence is ksize * ksize, ic, oc, h, layer
// //--------------------------------------------------------
//   integer wt_buf;
//   integer i, j, k;
//   reg [15 - 1 : 0] num_wt;
//   reg [6 - 1 : 0] num_layer;
//   reg [WT_BUF_WIDTH - 1  : 0] wt_data_0, wt_data_1, wt_data_2, wt_data_3, wt_data_4, wt_data_5, wt_data_6, wt_data_7;
//   reg [WT_BUF_WIDTH - 1  : 0] wt_data_0_r, wt_data_1_r, wt_data_2_r, wt_data_3_r, wt_data_4_r, wt_data_5_r, wt_data_6_r, wt_data_7_r;

//   wt_buf = $fopen(`WT_BUF_FILE, "r");

//   forever begin
//     @(nxt_wt_param_event);

//     $fscanf(wt_buf, "%h", num_wt);

//     for(i = 0; i < ((num_wt + 7) >> 3); i = i + 1) begin
//         wait_one_cycle();
//         $fscanf(wt_buf, "%h", wt_data_0);
//         $fscanf(wt_buf, "%h", wt_data_1);
//         $fscanf(wt_buf, "%h", wt_data_2);
//         $fscanf(wt_buf, "%h", wt_data_3);
//         $fscanf(wt_buf, "%h", wt_data_4);
//         $fscanf(wt_buf, "%h", wt_data_5);
//         $fscanf(wt_buf, "%h", wt_data_6);
//         $fscanf(wt_buf, "%h", wt_data_7);
//         for(k = 0; k < 16; k++) begin
//           wt_data_0_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_0[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_1_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_1[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_2_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_2[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_3_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_3[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_4_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_4[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_5_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_5[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_6_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_6[(15-k)*WT_WIDTH +:WT_WIDTH];
//           wt_data_7_r[k*WT_WIDTH +:WT_WIDTH] = wt_data_7[(15-k)*WT_WIDTH +:WT_WIDTH];
//         end
//         axi2w_wdata = {wt_data_0_r, wt_data_1_r, wt_data_2_r, wt_data_3_r, wt_data_4_r, wt_data_5_r, wt_data_6_r, wt_data_7_r};
//         axi2w_waddr = i;
//         axi2w_wen = 1;
//     end

//     wait_one_cycle();
//     axi2w_wen = 0;
//   end

//   $fclose(wt_buf);
// endtask

// task loading_param_buf();
// //---------------------------
// //ceil(oc/4)*4
// //bias,LBM,HBM (16'h*3) h0,oc0
// //bias,LBM,HBM (16'h*3) h0,oc1
// //bias,LBM,HBM (16'h*3) h0,oc2
// //bias,LBM,HBM (16'h*3) h0,oc3
// //bias,LBM,HBM (16'h*3) h0,oc4
// //...
// //...
// //ceil(oc/4)*4 next_layer
// //...
// //----------------------------
//   integer param_buf;
//   integer i, j;
//   reg [6 - 1 : 0] num_layer;
//   reg [14:0] num_oc;

//   param_buf = $fopen(`PARAM_BUF_FILE, "r");

//   forever begin
//     @(nxt_wt_param_event);

//     $fscanf(param_buf, "%h", num_layer);

//     for(j = 0; j < num_layer; j = j + 1) begin

//       $fscanf(param_buf, "%d", num_oc);

//       for(i = 0; i < ((num_oc + 3) >> 2); i = i + 1) begin
//         wait_one_cycle();
//         $fscanf(param_buf, "%h", axi2p_wdata[BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH - 1 : 0]);
//         $fscanf(param_buf, "%h", axi2p_wdata[2*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH) - 1 : BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH]);
//         $fscanf(param_buf, "%h", axi2p_wdata[3*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH) - 1 : 2*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH)]);
//         $fscanf(param_buf, "%h", axi2p_wdata[4*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH) - 1 : 3*(BIAS_DATA_WIDTH+HBM_DATA_WIDTH+LBM_DATA_WIDTH)]);
//         axi2p_waddr = j * ((num_oc + 3) >> 2) + i;
//         axi2p_wen = 1;
//       end
//     end

//     wait_one_cycle();
//     axi2p_wen = 0;
//   end

//   $fclose(param_buf);
// endtask

// task loading_reg();
// //-------------------------
// //reg0(32'h)
// //reg1(32'h)
// //ctrl_reg(32'h)
// //...(next layer)
// //-------------------------
//   integer reg_file;
//   integer i;
//   reg [14:0] num_layer;

//   reg_file = $fopen(`REG_FILE, "r");

//   forever begin
//     @(nxt_reg_event)
//     //for(i = 0; i < num_layer - 1; i = i + 1) begin
//       $fscanf(reg_file, "%h", reg0);
//       $fscanf(reg_file, "%h", reg1);
//       wait_one_cycle();
//       $fscanf(reg_file, "%h", ctrl_reg);
//     //end
//   end

//   $fclose(reg_file);
// endtask

/*******************************************************************************/
/****************************** dump wave **************************************/
/*******************************************************************************/
`ifdef DUMP_VPD
initial begin
    $display("Dump VPD wave!");
    $vcdpluson();
end
`endif

initial begin
   $display("Dump fsdb wave!");
   $fsdbDumpfile("tb.fsdb");
   $fsdbDumpvars;
end

endmodule
