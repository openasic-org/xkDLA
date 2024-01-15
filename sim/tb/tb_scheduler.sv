`timescale 1ns/1ps
`define PERIOD  8
`define DISPLAY 0
module tb_scheduler;

parameter   REG_IH_WIDTH = 6  ;
parameter   REG_IW_WIDTH = 6  ;
parameter   REG_IC_WIDTH = 6  ;
parameter   REG_OH_WIDTH = 6  ;
parameter   REG_OW_WIDTH = 9  ;
parameter   REG_OC_WIDTH = 9  ;
parameter   IFM_WIDTH    = 8;
parameter   SCH_COL_NUM  = 36;
parameter   WT_WIDTH  = 16;
parameter   PE_COL_NUM = 32;
parameter   PE_H_NUM = 4;
parameter   PE_IC_NUM  = 4;
parameter   PE_OC_NUM  = 4;
parameter   FE_ADDR_WIDTH = 9  ;
parameter   WT_ADDR_WIDTH = 11 ;
parameter   O_ADDR_WIDTH  = 10 ;
parameter   YOLP_ADDR_WIDTH = 10;
parameter   XYOLP_ADDR_WIDTH = 10;
parameter   P2S_OADDR_WIDTH = 100;
parameter   WIDTH_KSIZE  = 3;
parameter   WIDTH_FEA_X  = 6;
parameter   WIDTH_FEA_Y  = 6;
parameter   LAYER_DEPTH_Y = 20;
parameter   LAYER_DEPTH_X = 20;

parameter  ADDR_WIDTH = 10;
parameter  DATA_WIDTH = 8;

localparam IW = 36;
localparam IH = 12;
localparam IC = 16;
localparam OW = 32;
localparam OH = 10;
localparam OC = 16;
localparam KZ = 5;
localparam LOCAL = 2; //0, center, 1, top, 2, down


reg                            clk;
reg                            rst_n;

reg                            tile_switch;
reg                            ctrl2sch_layer_start;
reg      [3              : 0]  cnt_layer;
reg      [3              : 0]  tile_loc;
reg      [1              : 0]  ksize_i;
reg      [2              : 0]  ksize;
reg                            pe2sch_rdy;
reg      [REG_IH_WIDTH-1 : 0]  tile_in_h           ;
reg      [REG_OH_WIDTH-1 : 0]  tile_out_h          ;
reg      [REG_IW_WIDTH-1 : 0]  tile_in_w           ;
reg      [REG_OW_WIDTH-1 : 0]  tile_out_w          ;
reg      [REG_IC_WIDTH-1 : 0]  tile_in_c           ;
reg      [REG_OC_WIDTH-1 : 0]  tile_out_c          ;
reg      [P2S_OADDR_WIDTH-1: 0]  pu2sch_olp_addr   ;
reg      [WIDTH_FEA_X -1 : 0]  tile_tot_num_x      ;
reg      [3              : 0]  yolp_buf_rd_en_r    ;

wire     [3                 : 0]  fe_olp_buf_rd_en;
wire     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_0    ;
wire     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_1    ;
wire     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_2    ;
wire     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_3    ;
wire     [O_ADDR_WIDTH  - 1 : 0]  xolp_buf_rd_addr_0  ;
wire     [O_ADDR_WIDTH  - 1 : 0]  xolp_buf_rd_addr_1  ;
wire     [O_ADDR_WIDTH  - 1 : 0]  xolp_buf_rd_addr_2  ;
wire     [O_ADDR_WIDTH  - 1 : 0]  xolp_buf_rd_addr_3  ;
wire     [7                 : 0]  wt_buf_rd_en        ;
wire     [WT_ADDR_WIDTH - 1 : 0]  wt_buf_rd_addr      ;
wire     [3                 : 0]  yolp_buf_rd_en      ;
wire     [YOLP_ADDR_WIDTH-1 : 0]  yolp_buf_rd_addr    ;
wire     [3                 : 0]  xyolp_buf0_rd_en    ;
wire     [3                 : 0]  xyolp_buf1_rd_en    ;
wire     [XYOLP_ADDR_WIDTH-1: 0]  xyolp_buf_rd_addr   ;

wire                                  sch2pe_row_start;
wire                                  sch2pe_row_done;
wire                                  sch2pe_vld_o;
wire [PE_COL_NUM          - 1 : 0]    mux_col_vld_o;
wire [PE_H_NUM            - 1 : 0]    mux_row_vld_o;
wire [PE_IC_NUM           - 1 : 0]    mux_array_vld_o;

// interface with scheduler
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_0_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_1_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_2_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_3_3;

reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_0;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_1;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_2;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_0_3;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_0;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_1;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_2;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_1_3;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_0;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_1;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_2;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_2_3;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_0;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_1;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_2;
reg  [WT_WIDTH                - 1 : 0]    sch_weight_input_3_3;

// dat_o
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_0_3;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_1_3;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_2_3;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_3_3;

wire [WT_WIDTH            - 1 : 0]    sch_weight_output_0_0;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_0_1;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_0_2;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_0_3;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_1_0;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_1_1;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_1_2;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_1_3;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_2_0;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_2_1;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_2_2;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_2_3;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_3_0;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_3_1;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_3_2;
wire [WT_WIDTH            - 1 : 0]    sch_weight_output_3_3;

reg     [ ADDR_WIDTH-1:0]   wr_addr;
reg                         wr_en;
reg     [ DATA_WIDTH-1:0]   wr_data[15:0];
reg     [ SCH_COL_NUM * DATA_WIDTH-1:0]   wr_data_w[15:0];
reg     [ ADDR_WIDTH-1:0]   rd_addr[15:0];
reg     [15           :0]   rd_en;
reg     [ SCH_COL_NUM * DATA_WIDTH-1:0]   rd_data[15:0];

reg     [ ADDR_WIDTH-1:0]   wr_addr_olp;
reg                         wr_olp_en;
reg     [ DATA_WIDTH-1:0]   wr_data_olp[15:0];
reg     [ SCH_COL_NUM * DATA_WIDTH-1:0]   wr_data_olp_w[15:0];
reg     [ ADDR_WIDTH-1:0]   rd_addr_olp[15:0];
reg     [15           :0]   rd_olp_en;
reg     [ SCH_COL_NUM * DATA_WIDTH-1:0]   rd_data_olp[15:0];

reg     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_0_r    ;
reg     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_1_r    ;
reg     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_2_r    ;
reg     [FE_ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_3_r    ;

wire [DATA_WIDTH - 1 : 0] out_0 [3:0];
wire [DATA_WIDTH - 1 : 0] out_1 [3:0];
wire [DATA_WIDTH - 1 : 0] out_2 [3:0];
wire [DATA_WIDTH - 1 : 0] out_3 [3:0];
reg [DATA_WIDTH - 1 : 0] ref_out_0 [3:0];
reg [DATA_WIDTH - 1 : 0] ref_out_1 [3:0];
reg [DATA_WIDTH - 1 : 0] ref_out_2 [3:0];
reg [DATA_WIDTH - 1 : 0] ref_out_3 [3:0];

reg  [3:0] olp_rd_r;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_0_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_0_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_0_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_0_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_1_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_1_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_1_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_1_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_2_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_2_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_2_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_2_3;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_3_0;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_3_1;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_3_2;
reg  [SCH_COL_NUM * IFM_WIDTH - 1 : 0]    sch_data_input_olp_3_3;

wire [3:0] k;
genvar gvIdx;

//wire [2:0] u0_scheduler.u0_addr_if.cur_state;
reg  [2:0] pre_state_tb;

// DUT
scheduler #(
  .REG_IH_WIDTH (REG_IH_WIDTH),
  .REG_IW_WIDTH (REG_IW_WIDTH),
  .REG_IC_WIDTH (REG_IC_WIDTH),
  .REG_OH_WIDTH (REG_OH_WIDTH),
  .REG_OW_WIDTH (REG_OW_WIDTH),
  .REG_OC_WIDTH (REG_OC_WIDTH),
  .IFM_WIDTH    (IFM_WIDTH),
  .SCH_COL_NUM  (SCH_COL_NUM),
  .WT_WIDTH     (WT_WIDTH),
  .PE_COL_NUM   (PE_COL_NUM),
  .PE_H_NUM     (PE_H_NUM),
  .PE_IC_NUM    (PE_IC_NUM),
  .PE_OC_NUM    (PE_OC_NUM),
  .FE_ADDR_WIDTH(FE_ADDR_WIDTH),
  .WT_ADDR_WIDTH(WT_ADDR_WIDTH),
  .O_ADDR_WIDTH          (O_ADDR_WIDTH         ),
  .YOLP_ADDR_WIDTH       (YOLP_ADDR_WIDTH      ),
  .XYOLP_ADDR_WIDTH      (XYOLP_ADDR_WIDTH     ),
  .P2S_OADDR_WIDTH       (P2S_OADDR_WIDTH      ),
  .WIDTH_KSIZE           (WIDTH_KSIZE          ),
  .WIDTH_FEA_X           (WIDTH_FEA_X          ),
  .WIDTH_FEA_Y           (WIDTH_FEA_Y          ),
  .LAYER_DEPTH_Y         (LAYER_DEPTH_Y        ),
  .LAYER_DEPTH_X         (LAYER_DEPTH_X        )
)
u0_scheduler
(
  .clk(clk),
  .rst_n(rst_n),

    // ctrl_i
  .tile_switch           (tile_switch),
  .ctrl2sch_layer_start  (ctrl2sch_layer_start),
  .cnt_layer             (cnt_layer),
  .pe2sch_rdy            (pe2sch_rdy),
  .tile_loc              (tile_loc),
  .ksize_i               (ksize_i),
  .tile_in_h             (tile_in_h),
  .tile_out_h            (tile_out_h),
  .tile_in_w             (tile_in_w),
  .tile_out_w            (tile_out_w),
  .tile_in_c             (tile_in_c),
  .tile_out_c            (tile_out_c),
  .pu2sch_olp_addr       (pu2sch_olp_addr),
  .tile_tot_num_x        (tile_tot_num_x),

  //buffer rd
  .fe_olp_buf_rd_en      (fe_olp_buf_rd_en),
  .fe_buf_rd_addr_0      (fe_buf_rd_addr_0),
  .fe_buf_rd_addr_1      (fe_buf_rd_addr_1),
  .fe_buf_rd_addr_2      (fe_buf_rd_addr_2),
  .fe_buf_rd_addr_3      (fe_buf_rd_addr_3),
  .xolp_buf_rd_addr_0    (xolp_buf_rd_addr_0   ),
  .xolp_buf_rd_addr_1    (xolp_buf_rd_addr_1   ),
  .xolp_buf_rd_addr_2    (xolp_buf_rd_addr_2   ),
  .xolp_buf_rd_addr_3    (xolp_buf_rd_addr_3   ),
  .wt_buf_rd_en          (wt_buf_rd_en),
  .wt_buf_rd_addr        (wt_buf_rd_addr),
  .yolp_buf_rd_en        (yolp_buf_rd_en       ),
  .yolp_buf_rd_addr      (yolp_buf_rd_addr     ),
  .xyolp_buf0_rd_en      (xyolp_buf0_rd_en     ),
  .xyolp_buf1_rd_en      (xyolp_buf1_rd_en     ),
  .xyolp_buf_rd_addr     (xyolp_buf_rd_addr    ),

  .sch2pe_row_start      (sch2pe_row_start),
  .sch2pe_row_done(sch2pe_row_done),
  .sch2pe_vld_o(sch2pe_vld_o),
  .mux_col_vld_o(mux_col_vld_o),
  .mux_row_vld_o(mux_row_vld_o),
  .mux_array_vld_o(mux_array_vld_o),

  .sch_data_input_0_0(sch_data_input_0_0),
  .sch_data_input_0_1(sch_data_input_0_1),
  .sch_data_input_0_2(sch_data_input_0_2),
  .sch_data_input_0_3(sch_data_input_0_3),
  .sch_data_input_1_0(sch_data_input_1_0),
  .sch_data_input_1_1(sch_data_input_1_1),
  .sch_data_input_1_2(sch_data_input_1_2),
  .sch_data_input_1_3(sch_data_input_1_3),
  .sch_data_input_2_0(sch_data_input_2_0),
  .sch_data_input_2_1(sch_data_input_2_1),
  .sch_data_input_2_2(sch_data_input_2_2),
  .sch_data_input_2_3(sch_data_input_2_3),
  .sch_data_input_3_0(sch_data_input_3_0),
  .sch_data_input_3_1(sch_data_input_3_1),
  .sch_data_input_3_2(sch_data_input_3_2),
  .sch_data_input_3_3(sch_data_input_3_3),

  .sch_weight_input_0_0(sch_weight_input_0_0),
  .sch_weight_input_0_1(sch_weight_input_0_1),
  .sch_weight_input_0_2(sch_weight_input_0_2),
  .sch_weight_input_0_3(sch_weight_input_0_3),
  .sch_weight_input_1_0(sch_weight_input_1_0),
  .sch_weight_input_1_1(sch_weight_input_1_1),
  .sch_weight_input_1_2(sch_weight_input_1_2),
  .sch_weight_input_1_3(sch_weight_input_1_3),
  .sch_weight_input_2_0(sch_weight_input_2_0),
  .sch_weight_input_2_1(sch_weight_input_2_1),
  .sch_weight_input_2_2(sch_weight_input_2_2),
  .sch_weight_input_2_3(sch_weight_input_2_3),
  .sch_weight_input_3_0(sch_weight_input_3_0),
  .sch_weight_input_3_1(sch_weight_input_3_1),
  .sch_weight_input_3_2(sch_weight_input_3_2),
  .sch_weight_input_3_3(sch_weight_input_3_3),

  .sch_data_output_0_0(sch_data_output_0_0),
  .sch_data_output_0_1(sch_data_output_0_1),
  .sch_data_output_0_2(sch_data_output_0_2),
  .sch_data_output_0_3(sch_data_output_0_3),
  .sch_data_output_1_0(sch_data_output_1_0),
  .sch_data_output_1_1(sch_data_output_1_1),
  .sch_data_output_1_2(sch_data_output_1_2),
  .sch_data_output_1_3(sch_data_output_1_3),
  .sch_data_output_2_0(sch_data_output_2_0),
  .sch_data_output_2_1(sch_data_output_2_1),
  .sch_data_output_2_2(sch_data_output_2_2),
  .sch_data_output_2_3(sch_data_output_2_3),
  .sch_data_output_3_0(sch_data_output_3_0),
  .sch_data_output_3_1(sch_data_output_3_1),
  .sch_data_output_3_2(sch_data_output_3_2),
  .sch_data_output_3_3(sch_data_output_3_3),

  .sch_weight_output_0_0(sch_weight_output_0_0),
  .sch_weight_output_0_1(sch_weight_output_0_1),
  .sch_weight_output_0_2(sch_weight_output_0_2),
  .sch_weight_output_0_3(sch_weight_output_0_3),
  .sch_weight_output_1_0(sch_weight_output_1_0),
  .sch_weight_output_1_1(sch_weight_output_1_1),
  .sch_weight_output_1_2(sch_weight_output_1_2),
  .sch_weight_output_1_3(sch_weight_output_1_3),
  .sch_weight_output_2_0(sch_weight_output_2_0),
  .sch_weight_output_2_1(sch_weight_output_2_1),
  .sch_weight_output_2_2(sch_weight_output_2_2),
  .sch_weight_output_2_3(sch_weight_output_2_3),
  .sch_weight_output_3_0(sch_weight_output_3_0),
  .sch_weight_output_3_1(sch_weight_output_3_1),
  .sch_weight_output_3_2(sch_weight_output_3_2),
  .sch_weight_output_3_3(sch_weight_output_3_3)
);

/******************************************************************************/
/**************************** RAM buffer Generation ***************************/
/******************************************************************************/
generate
    for(gvIdx = 0; gvIdx < 16; gvIdx = gvIdx + 1) begin
        dp_ram #(
            .ADDR_WIDTH  (ADDR_WIDTH),
            .DATA_WIDTH  (SCH_COL_NUM * DATA_WIDTH),
            .DATA_DEPTH  (1024)
        )
        u_dp_ram(
            .clk         (clk),
            .wr_addr     (wr_addr),
            .wr_en       (wr_en),
            .wr_data     (wr_data_w[gvIdx]),
            .rd_addr     (rd_addr[gvIdx]),
            .rd_en       (rd_en[gvIdx]),
            .rd_data     (rd_data[gvIdx])
        );
    end
endgenerate

generate
    for(gvIdx = 0; gvIdx < 16; gvIdx = gvIdx + 1) begin
        dp_ram #(
            .ADDR_WIDTH  (ADDR_WIDTH),
            .DATA_WIDTH  (SCH_COL_NUM * DATA_WIDTH),
            .DATA_DEPTH  (1024)
        )
        u1_dp_ram(
            .clk         (clk),
            .wr_addr     (wr_addr_olp),
            .wr_en       (wr_olp_en),
            .wr_data     (wr_data_olp_w[gvIdx]),
            .rd_addr     (rd_addr_olp[gvIdx]),
            .rd_en       (rd_olp_en[gvIdx]),
            .rd_data     (rd_data_olp[gvIdx])
        );
    end
endgenerate

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    fe_buf_rd_addr_0_r <= 0;
    fe_buf_rd_addr_1_r <= 0;
    fe_buf_rd_addr_2_r <= 0;
    fe_buf_rd_addr_3_r <= 0;
  end
  else begin
    fe_buf_rd_addr_0_r <= fe_buf_rd_addr_0;
    fe_buf_rd_addr_1_r <= fe_buf_rd_addr_1;
    fe_buf_rd_addr_2_r <= fe_buf_rd_addr_2;
    fe_buf_rd_addr_3_r <= fe_buf_rd_addr_3;
  end
end

always @(*)
begin
    rd_en[0] = fe_olp_buf_rd_en[3] ? (fe_buf_rd_addr_0 == {FE_ADDR_WIDTH{1'b1}} ? 0 : 1) : 0;
    rd_en[1] = fe_olp_buf_rd_en[2] ? (fe_buf_rd_addr_1 == {FE_ADDR_WIDTH{1'b1}} ? 0 : 1) : 0;
    rd_en[2] = fe_olp_buf_rd_en[1] ? (fe_buf_rd_addr_2 == {FE_ADDR_WIDTH{1'b1}} ? 0 : 1) : 0;
    rd_en[3] = fe_olp_buf_rd_en[0] ? (fe_buf_rd_addr_3 == {FE_ADDR_WIDTH{1'b1}} ? 0 : 1) : 0;
    rd_addr[0] = fe_buf_rd_addr_0;
    rd_addr[1] = fe_buf_rd_addr_1;
    rd_addr[2] = fe_buf_rd_addr_2;
    rd_addr[3] = fe_buf_rd_addr_3;
    rd_en[4] = rd_en[0]; rd_en[8] = rd_en[0]; rd_en[12] = rd_en[0];
    rd_en[5] = rd_en[1]; rd_en[9] = rd_en[1]; rd_en[13] = rd_en[1];
    rd_en[6] = rd_en[2]; rd_en[10] = rd_en[2]; rd_en[14] = rd_en[2];
    rd_en[7] = rd_en[3]; rd_en[11] = rd_en[3]; rd_en[15] = rd_en[3];
    rd_addr[4] = rd_addr[0]; rd_addr[8] = rd_addr[0]; rd_addr[12] = rd_addr[0];
    rd_addr[5] = rd_addr[1]; rd_addr[9] = rd_addr[1]; rd_addr[13] = rd_addr[1];
    rd_addr[6] = rd_addr[2]; rd_addr[10] = rd_addr[2]; rd_addr[14] = rd_addr[2];
    rd_addr[7] = rd_addr[3]; rd_addr[11] = rd_addr[3]; rd_addr[15] = rd_addr[3];
end

always @(*)
begin
    rd_olp_en[0] = yolp_buf_rd_en[3];
    rd_olp_en[1] = yolp_buf_rd_en[2];
    rd_olp_en[2] = yolp_buf_rd_en[1];
    rd_olp_en[3] = yolp_buf_rd_en[0];
    rd_addr_olp[0] = yolp_buf_rd_addr;
    rd_addr_olp[1] = yolp_buf_rd_addr;
    rd_addr_olp[2] = yolp_buf_rd_addr;
    rd_addr_olp[3] = yolp_buf_rd_addr;
    rd_olp_en[4] = rd_olp_en[0]; rd_olp_en[8] = rd_olp_en[0]; rd_olp_en[12] = rd_olp_en[0];
    rd_olp_en[5] = rd_olp_en[1]; rd_olp_en[9] = rd_olp_en[1]; rd_olp_en[13] = rd_olp_en[1];
    rd_olp_en[6] = rd_olp_en[2]; rd_olp_en[10] = rd_olp_en[2]; rd_olp_en[14] = rd_olp_en[2];
    rd_olp_en[7] = rd_olp_en[3]; rd_olp_en[11] = rd_olp_en[3]; rd_olp_en[15] = rd_olp_en[3];
    rd_addr_olp[4] = rd_addr_olp[0]; rd_addr_olp[8] = rd_addr_olp[0]; rd_addr_olp[12] = rd_addr_olp[0];
    rd_addr_olp[5] = rd_addr_olp[1]; rd_addr_olp[9] = rd_addr_olp[1]; rd_addr_olp[13] = rd_addr_olp[1];
    rd_addr_olp[6] = rd_addr_olp[2]; rd_addr_olp[10] = rd_addr_olp[2]; rd_addr_olp[14] = rd_addr_olp[2];
    rd_addr_olp[7] = rd_addr_olp[3]; rd_addr_olp[11] = rd_addr_olp[3]; rd_addr_olp[15] = rd_addr_olp[3];
end

always @(posedge clk) yolp_buf_rd_en_r <= yolp_buf_rd_en;

always @(*)
begin
  case(yolp_buf_rd_en_r)
    4'b1111: olp_rd_r = 4'b1111;
    4'b0011, 4'b1100: olp_rd_r = 4'b0011;
    default: olp_rd_r = 4'b0000;
  endcase
end

always @(*)
begin
  sch_data_input_olp_0_0 = (yolp_buf_rd_en_r[3] & olp_rd_r[3]) ? rd_data_olp[0] : 0;
  sch_data_input_olp_0_1 = (yolp_buf_rd_en_r[2] & olp_rd_r[2]) ? rd_data_olp[1] : 0;
  sch_data_input_olp_0_2 = (yolp_buf_rd_en_r[1] & olp_rd_r[1]) ? rd_data_olp[2] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[0] : 0);
  sch_data_input_olp_0_3 = (yolp_buf_rd_en_r[0] & olp_rd_r[0]) ? rd_data_olp[3] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[1] : 0);
  sch_data_input_olp_1_0 = (yolp_buf_rd_en_r[3] & olp_rd_r[3]) ? rd_data_olp[4] : 0;
  sch_data_input_olp_1_1 = (yolp_buf_rd_en_r[2] & olp_rd_r[2]) ? rd_data_olp[5] : 0;
  sch_data_input_olp_1_2 = (yolp_buf_rd_en_r[1] & olp_rd_r[1]) ? rd_data_olp[6] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[4] : 0);
  sch_data_input_olp_1_3 = (yolp_buf_rd_en_r[0] & olp_rd_r[0]) ? rd_data_olp[7] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[5] : 0);
  sch_data_input_olp_2_0 = (yolp_buf_rd_en_r[3] & olp_rd_r[3]) ? rd_data_olp[8] : 0;
  sch_data_input_olp_2_1 = (yolp_buf_rd_en_r[2] & olp_rd_r[2]) ? rd_data_olp[9] : 0;
  sch_data_input_olp_2_2 = (yolp_buf_rd_en_r[1] & olp_rd_r[1]) ? rd_data_olp[10] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[8] : 0);
  sch_data_input_olp_2_3 = (yolp_buf_rd_en_r[0] & olp_rd_r[0]) ? rd_data_olp[11] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[9] : 0);
  sch_data_input_olp_3_0 = (yolp_buf_rd_en_r[3] & olp_rd_r[3]) ? rd_data_olp[12] : 0;
  sch_data_input_olp_3_1 = (yolp_buf_rd_en_r[2] & olp_rd_r[2]) ? rd_data_olp[13] : 0;
  sch_data_input_olp_3_2 = (yolp_buf_rd_en_r[1] & olp_rd_r[1]) ? rd_data_olp[14] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[12] : 0);
  sch_data_input_olp_3_3 = (yolp_buf_rd_en_r[0] & olp_rd_r[0]) ? rd_data_olp[15] : (yolp_buf_rd_en_r == 4'b1100 ? rd_data_olp[13] : 0);
end
always @(*)
begin
    sch_data_input_0_0 = olp_rd_r[3] == 1 ? sch_data_input_olp_0_0 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[3] ? (fe_buf_rd_addr_0_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[0]) : 0;
    sch_data_input_0_1 = olp_rd_r[2] == 1 ? sch_data_input_olp_0_1 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[2] ? (fe_buf_rd_addr_1_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[1]) : 0;
    sch_data_input_0_2 = olp_rd_r[1] == 1 ? sch_data_input_olp_0_2 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[1] ? (fe_buf_rd_addr_2_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[2]) : 0;
    sch_data_input_0_3 = olp_rd_r[0] == 1 ? sch_data_input_olp_0_3 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[0] ? (fe_buf_rd_addr_3_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[3]) : 0;
    sch_data_input_1_0 = olp_rd_r[3] == 1 ? sch_data_input_olp_1_0 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[3] ? (fe_buf_rd_addr_0_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[4]) : 0;
    sch_data_input_1_1 = olp_rd_r[2] == 1 ? sch_data_input_olp_1_1 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[2] ? (fe_buf_rd_addr_1_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[5]) : 0;
    sch_data_input_1_2 = olp_rd_r[1] == 1 ? sch_data_input_olp_1_2 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[1] ? (fe_buf_rd_addr_2_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[6]) : 0;
    sch_data_input_1_3 = olp_rd_r[0] == 1 ? sch_data_input_olp_1_3 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[0] ? (fe_buf_rd_addr_3_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[7]) : 0;
    sch_data_input_2_0 = olp_rd_r[3] == 1 ? sch_data_input_olp_2_0 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[3] ? (fe_buf_rd_addr_0_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[8]) : 0;
    sch_data_input_2_1 = olp_rd_r[2] == 1 ? sch_data_input_olp_2_1 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[2] ? (fe_buf_rd_addr_1_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[9]) : 0;
    sch_data_input_2_2 = olp_rd_r[1] == 1 ? sch_data_input_olp_2_2 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[1] ? (fe_buf_rd_addr_2_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[10]) : 0;
    sch_data_input_2_3 = olp_rd_r[0] == 1 ? sch_data_input_olp_2_3 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[0] ? (fe_buf_rd_addr_3_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[11]) : 0;
    sch_data_input_3_0 = olp_rd_r[3] == 1 ? sch_data_input_olp_3_0 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[3] ? (fe_buf_rd_addr_0_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[12]) : 0;
    sch_data_input_3_1 = olp_rd_r[2] == 1 ? sch_data_input_olp_3_1 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[2] ? (fe_buf_rd_addr_1_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[13]) : 0;
    sch_data_input_3_2 = olp_rd_r[1] == 1 ? sch_data_input_olp_3_2 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[1] ? (fe_buf_rd_addr_2_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[14]) : 0;
    sch_data_input_3_3 = olp_rd_r[0] == 1 ? sch_data_input_olp_3_3 :
                         u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r[0] ? (fe_buf_rd_addr_3_r == {FE_ADDR_WIDTH{1'b1}} ? 0 : rd_data[15]) : 0;
end

/******************************************************************************/
/**************************** Clock Value Generation **************************/
/******************************************************************************/
initial begin
    clk = 1'b1;
end

always #(`PERIOD/2) clk = ~clk;

always @(posedge clk) pre_state_tb <= u0_scheduler.u0_addr_if.cur_state;

always @(posedge clk)
begin
    sch_weight_input_0_0 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_0_1 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_0_2 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_0_3 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_1_0 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_1_1 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_1_2 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_1_3 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_2_0 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_2_1 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_2_2 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_2_3 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_3_0 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_3_1 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_3_2 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_3_3 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
end

/*******************************************************************************/
/******************************* Test Flow Generation **************************/
/*******************************************************************************/
initial begin
    system_rst_n();
    wait_some_cycles();
    loading_fea_ram();
    wait_half_cycle();
    loading_olp_ram();
    cnt_layer = 0;
    tile_switch = 0;
    pu2sch_olp_addr = 0;
    if(LOCAL == 0)
      tile_center();
    else if(LOCAL == 1)
      tile_top();
    else
      tile_down();
    #20000;
    //tile_top();
    #20000;
    //tile_down();
    #2000;
    $display("Simulation Done!");
    $finish;
end

if (`DISPLAY) begin
    always@(posedge clk) begin
        if(pre_state_tb != u0_scheduler.u0_addr_if.cur_state)
            $display("cur_state: %0d", u0_scheduler.u0_addr_if.cur_state);
    end

    //always @(posedge clk) if(rd_data[0] != 0) $display("input_00: %0d", rd_addr[0]);
end
initial begin
    //$randomize;
    pe2sch_rdy = 1;
    for (int i = 0; i < 10; i++) begin
        #($urandom_range(10,1000)) @(negedge clk) pe2sch_rdy = 0;
        if(`DISPLAY) begin
            $display("pe2sch_rdy = %d", pe2sch_rdy);
            $display("time when pe2sch_rdy == 0 at time %0t", $time);
        end
        wait_one_cycle();
        pe2sch_rdy = 1;
    end
end

/*******************************************************************************/
/******************************* Output flow check *****************************/
/*******************************************************************************/
reg rd_eb;
wire rd_eb_kz1;
wire [3:0]row_vld;
wire [7:0] rf_r_0_0,rf_r_0_1, rf_r_0_2, rf_r_0_3;
wire [7:0] rf_r_1_0,rf_r_1_1, rf_r_1_2, rf_r_1_3;
wire [7:0] rf_r_2_0,rf_r_2_1, rf_r_2_2, rf_r_2_3;
wire [7:0] rf_r_3_0,rf_r_3_1, rf_r_3_2, rf_r_3_3;
reg [3:0] fe_olp_buf_rd_en_r;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) fe_olp_buf_rd_en_r <= 0;
  else if(u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r != 0)
    fe_olp_buf_rd_en_r <= u0_scheduler.u0_sche_sub.fe_olp_buf_rd_en_r;
  else fe_olp_buf_rd_en_r <= 0;
end

assign rd_eb = (fe_olp_buf_rd_en_r != 0 || u0_scheduler.u0_sche_sub.olp_buf_rd_en_r == 1);
assign rd_eb_kz1 = rd_eb && u0_scheduler.u0_sche_sub.pe2sch_rdy_pre;

assign row_vld = u0_scheduler.u0_sche_sub.mux_row_vld_o;
assign rf_r_0_0 = u0_scheduler.u0_sche_sub.rf_r_0_0[0];
assign rf_r_0_1 = u0_scheduler.u0_sche_sub.rf_r_0_1[0];
assign rf_r_0_2 = u0_scheduler.u0_sche_sub.rf_r_0_2[0];
assign rf_r_0_3 = u0_scheduler.u0_sche_sub.rf_r_0_3[0];
assign rf_r_1_0 = u0_scheduler.u0_sche_sub.rf_r_1_0[0];
assign rf_r_1_1 = u0_scheduler.u0_sche_sub.rf_r_1_1[0];
assign rf_r_1_2 = u0_scheduler.u0_sche_sub.rf_r_1_2[0];
assign rf_r_1_3 = u0_scheduler.u0_sche_sub.rf_r_1_3[0];
assign rf_r_2_0 = u0_scheduler.u0_sche_sub.rf_r_2_0[0];
assign rf_r_2_1 = u0_scheduler.u0_sche_sub.rf_r_2_1[0];
assign rf_r_2_2 = u0_scheduler.u0_sche_sub.rf_r_2_2[0];
assign rf_r_2_3 = u0_scheduler.u0_sche_sub.rf_r_2_3[0];
assign rf_r_3_0 = u0_scheduler.u0_sche_sub.rf_r_3_0[0];
assign rf_r_3_1 = u0_scheduler.u0_sche_sub.rf_r_3_1[0];
assign rf_r_3_2 = u0_scheduler.u0_sche_sub.rf_r_3_2[0];
assign rf_r_3_3 = u0_scheduler.u0_sche_sub.rf_r_3_3[0];

assign out_0[0] = u0_scheduler.u0_sche_sub.mux_array_vld_o[3] ? rf_r_0_0 : 0;
assign out_0[1] = u0_scheduler.u0_sche_sub.mux_array_vld_o[3] ? rf_r_0_1 : 0;
assign out_0[2] = u0_scheduler.u0_sche_sub.mux_array_vld_o[3] ? rf_r_0_2 : 0;
assign out_0[3] = u0_scheduler.u0_sche_sub.mux_array_vld_o[3] ? rf_r_0_3 : 0;
assign out_1[0] = u0_scheduler.u0_sche_sub.mux_array_vld_o[2] ? rf_r_1_0 : 0;
assign out_1[1] = u0_scheduler.u0_sche_sub.mux_array_vld_o[2] ? rf_r_1_1 : 0;
assign out_1[2] = u0_scheduler.u0_sche_sub.mux_array_vld_o[2] ? rf_r_1_2 : 0;
assign out_1[3] = u0_scheduler.u0_sche_sub.mux_array_vld_o[2] ? rf_r_1_3 : 0;
assign out_2[0] = u0_scheduler.u0_sche_sub.mux_array_vld_o[1] ? rf_r_2_0 : 0;
assign out_2[1] = u0_scheduler.u0_sche_sub.mux_array_vld_o[1] ? rf_r_2_1 : 0;
assign out_2[2] = u0_scheduler.u0_sche_sub.mux_array_vld_o[1] ? rf_r_2_2 : 0;
assign out_2[3] = u0_scheduler.u0_sche_sub.mux_array_vld_o[1] ? rf_r_2_3 : 0;
assign out_3[0] = u0_scheduler.u0_sche_sub.mux_array_vld_o[0] ? rf_r_3_0 : 0;
assign out_3[1] = u0_scheduler.u0_sche_sub.mux_array_vld_o[0] ? rf_r_3_1 : 0;
assign out_3[2] = u0_scheduler.u0_sche_sub.mux_array_vld_o[0] ? rf_r_3_2 : 0;
assign out_3[3] = u0_scheduler.u0_sche_sub.mux_array_vld_o[0] ? rf_r_3_3 : 0;

initial begin
integer j;
integer fd_out_0, fd_out_1, fd_out_2, fd_out_3;

fd_out_0 = $fopen("../tv/file/out_0", "r");
fd_out_1 = $fopen("../tv/file/out_1", "r");
fd_out_2 = $fopen("../tv/file/out_2", "r");
fd_out_3 = $fopen("../tv/file/out_3", "r");

if(KZ == 1) begin
    $fscanf(fd_out_0, "%d", ref_out_0[0]);
    $fscanf(fd_out_0, "%d", ref_out_0[1]);
    $fscanf(fd_out_0, "%d", ref_out_0[2]);
    $fscanf(fd_out_0, "%d", ref_out_0[3]);
    $fscanf(fd_out_1, "%d", ref_out_1[0]);
    $fscanf(fd_out_1, "%d", ref_out_1[1]);
    $fscanf(fd_out_1, "%d", ref_out_1[2]);
    $fscanf(fd_out_1, "%d", ref_out_1[3]);
    $fscanf(fd_out_2, "%d", ref_out_2[0]);
    $fscanf(fd_out_2, "%d", ref_out_2[1]);
    $fscanf(fd_out_2, "%d", ref_out_2[2]);
    $fscanf(fd_out_2, "%d", ref_out_2[3]);
    $fscanf(fd_out_3, "%d", ref_out_3[0]);
    $fscanf(fd_out_3, "%d", ref_out_3[1]);
    $fscanf(fd_out_3, "%d", ref_out_3[2]);
    $fscanf(fd_out_3, "%d", ref_out_3[3]);
end

    for (j = 0; j < ((IH + 3) >> 2) * (((OC + 3) >> 2)) * (((IC + 3) >> 2) * 4) * KZ * 4; j++) begin
        if(KZ != 1) begin
            @(posedge rd_eb) begin
                $fscanf(fd_out_0, "%d", ref_out_0[0]);
                $fscanf(fd_out_0, "%d", ref_out_0[1]);
                $fscanf(fd_out_0, "%d", ref_out_0[2]);
                $fscanf(fd_out_0, "%d", ref_out_0[3]);
                $fscanf(fd_out_1, "%d", ref_out_1[0]);
                $fscanf(fd_out_1, "%d", ref_out_1[1]);
                $fscanf(fd_out_1, "%d", ref_out_1[2]);
                $fscanf(fd_out_1, "%d", ref_out_1[3]);
                $fscanf(fd_out_2, "%d", ref_out_2[0]);
                $fscanf(fd_out_2, "%d", ref_out_2[1]);
                $fscanf(fd_out_2, "%d", ref_out_2[2]);
                $fscanf(fd_out_2, "%d", ref_out_2[3]);
                $fscanf(fd_out_3, "%d", ref_out_3[0]);
                $fscanf(fd_out_3, "%d", ref_out_3[1]);
                $fscanf(fd_out_3, "%d", ref_out_3[2]);
                $fscanf(fd_out_3, "%d", ref_out_3[3]);
            end
        end
        else begin
            @(posedge clk) begin
                if(rd_eb_kz1) begin
                    $fscanf(fd_out_0, "%d", ref_out_0[0]);
                    $fscanf(fd_out_0, "%d", ref_out_0[1]);
                    $fscanf(fd_out_0, "%d", ref_out_0[2]);
                    $fscanf(fd_out_0, "%d", ref_out_0[3]);
                    $fscanf(fd_out_1, "%d", ref_out_1[0]);
                    $fscanf(fd_out_1, "%d", ref_out_1[1]);
                    $fscanf(fd_out_1, "%d", ref_out_1[2]);
                    $fscanf(fd_out_1, "%d", ref_out_1[3]);
                    $fscanf(fd_out_2, "%d", ref_out_2[0]);
                    $fscanf(fd_out_2, "%d", ref_out_2[1]);
                    $fscanf(fd_out_2, "%d", ref_out_2[2]);
                    $fscanf(fd_out_2, "%d", ref_out_2[3]);
                    $fscanf(fd_out_3, "%d", ref_out_3[0]);
                    $fscanf(fd_out_3, "%d", ref_out_3[1]);
                    $fscanf(fd_out_3, "%d", ref_out_3[2]);
                    $fscanf(fd_out_3, "%d", ref_out_3[3]);
                end
            end
        end
    end
$fclose(fd_out_0);
$fclose(fd_out_1);
$fclose(fd_out_2);
$fclose(fd_out_3);
end

initial begin
    forever begin
        if(KZ != 1) begin
            @(negedge rd_eb)
                if({out_0[0], out_0[1], out_0[2], out_0[3]} != {ref_out_0[0], ref_out_0[1], ref_out_0[2], ref_out_0[3]})
                    $display("\033[30;41m mismatch happened at time %0t, mismatch in buffer 0\033[0m", $time);
                if({out_1[0], out_1[1], out_1[2], out_1[3]} != {ref_out_1[0], ref_out_1[1], ref_out_1[2], ref_out_1[3]})
                    $display("\033[30;42m mismatch happened at time %0t, mismatch in buffer 1\033[0m", $time);
                if({out_2[0], out_2[1], out_2[2], out_2[3]} != {ref_out_2[0], ref_out_2[1], ref_out_2[2], ref_out_2[3]})
                    $display("\033[30;43m mismatch happened at time %0t, mismatch in buffer 2\033[0m", $time);
                if({out_3[0], out_3[1], out_3[2], out_3[3]} != {ref_out_3[0], ref_out_3[1], ref_out_3[2], ref_out_3[3]})
                    $display("\033[30;45m mismatch happened at time %0t, mismatch in buffer 3\033[0m", $time);
        end
        else begin
            @(negedge clk)
                if(rd_eb_kz1) begin
                    if({out_0[0], out_0[1], out_0[2], out_0[3]} != {ref_out_0[0], ref_out_0[1], ref_out_0[2], ref_out_0[3]})
                        $display("\033[30;41m mismatch happened at time %0t, mismatch in buffer 0\033[0m", $time);
                    if({out_1[0], out_1[1], out_1[2], out_1[3]} != {ref_out_1[0], ref_out_1[1], ref_out_1[2], ref_out_1[3]})
                        $display("\033[30;42m mismatch happened at time %0t, mismatch in buffer 1\033[0m", $time);
                    if({out_2[0], out_2[1], out_2[2], out_2[3]} != {ref_out_2[0], ref_out_2[1], ref_out_2[2], ref_out_2[3]})
                        $display("\033[30;43m mismatch happened at time %0t, mismatch in buffer 2\033[0m", $time);
                    if({out_3[0], out_3[1], out_3[2], out_3[3]} != {ref_out_3[0], ref_out_3[1], ref_out_3[2], ref_out_3[3]})
                        $display("\033[30;45m mismatch happened at time %0t, mismatch in buffer 3\033[0m", $time);
                end
        end
    end
end



//******************** test output ********************//
wire [2:0] mux;
reg  detect_out;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_3;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_3;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_3;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_0;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_1;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_2;
wire [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_3;

reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_0_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_1_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_2_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_0_3_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_0_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_1_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_2_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_1_3_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_0_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_1_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_2_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_2_3_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_0_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_1_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_2_r;
reg  [PE_COL_NUM * IFM_WIDTH  - 1 : 0]    sch_data_output_ref_3_3_r;

assign mux = u0_scheduler.u0_sche_sub.mux_sel;

generate
    for(gvIdx = 0; gvIdx < PE_COL_NUM; gvIdx = gvIdx + 1) begin
      assign sch_data_output_ref_0_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_0_0[mux + gvIdx];
      assign sch_data_output_ref_0_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_0_1[mux + gvIdx];
      assign sch_data_output_ref_0_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_0_2[mux + gvIdx];
      assign sch_data_output_ref_0_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_0_3[mux + gvIdx];
      assign sch_data_output_ref_1_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_1_0[mux + gvIdx];
      assign sch_data_output_ref_1_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_1_1[mux + gvIdx];
      assign sch_data_output_ref_1_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_1_2[mux + gvIdx];
      assign sch_data_output_ref_1_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_1_3[mux + gvIdx];
      assign sch_data_output_ref_2_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_2_0[mux + gvIdx];
      assign sch_data_output_ref_2_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_2_1[mux + gvIdx];
      assign sch_data_output_ref_2_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_2_2[mux + gvIdx];
      assign sch_data_output_ref_2_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_2_3[mux + gvIdx];
      assign sch_data_output_ref_3_0[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_3_0[mux + gvIdx];
      assign sch_data_output_ref_3_1[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_3_1[mux + gvIdx];
      assign sch_data_output_ref_3_2[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_3_2[mux + gvIdx];
      assign sch_data_output_ref_3_3[(gvIdx+1)*IFM_WIDTH - 1 : gvIdx * IFM_WIDTH] = u0_scheduler.u0_sche_sub.rf_r_3_3[mux + gvIdx];
    end
endgenerate


always @(posedge clk) begin
    if(u0_scheduler.u0_hanshake_sche2pe.sch2pe_vld_i && pe2sch_rdy) begin
        sch_data_output_ref_0_0_r <= sch_data_output_ref_0_0;
        sch_data_output_ref_0_1_r <= sch_data_output_ref_0_1;
        sch_data_output_ref_0_2_r <= sch_data_output_ref_0_2;
        sch_data_output_ref_0_3_r <= sch_data_output_ref_0_3;
        sch_data_output_ref_1_0_r <= sch_data_output_ref_1_0;
        sch_data_output_ref_1_1_r <= sch_data_output_ref_1_1;
        sch_data_output_ref_1_2_r <= sch_data_output_ref_1_2;
        sch_data_output_ref_1_3_r <= sch_data_output_ref_1_3;
        sch_data_output_ref_2_0_r <= sch_data_output_ref_2_0;
        sch_data_output_ref_2_1_r <= sch_data_output_ref_2_1;
        sch_data_output_ref_2_2_r <= sch_data_output_ref_2_2;
        sch_data_output_ref_2_3_r <= sch_data_output_ref_2_3;
        sch_data_output_ref_3_0_r <= sch_data_output_ref_3_0;
        sch_data_output_ref_3_1_r <= sch_data_output_ref_3_1;
        sch_data_output_ref_3_2_r <= sch_data_output_ref_3_2;
        sch_data_output_ref_3_3_r <= sch_data_output_ref_3_3;
    end
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) detect_out <= 0;
  else if(u0_scheduler.ctrl2sch_layer_start) detect_out <= 1;
  else if(u0_scheduler.tile_switch) detect_out <= 0;
end

initial begin
    forever begin
        //if(detect_out) begin
        @(posedge (clk && detect_out)) begin
            if(u0_scheduler.sch_data_output_0_0 != sch_data_output_ref_0_0_r) begin
                $display("mismatch in output_0_0, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_0_1 != sch_data_output_ref_0_1_r) begin
                $display("mismatch in output_0_1, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_0_2 != sch_data_output_ref_0_2_r) begin
                $display("mismatch in output_0_2, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_0_2 != sch_data_output_ref_0_2_r) begin
                $display("mismatch in output_0_2, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_0_3 != sch_data_output_ref_0_3_r) begin
                $display("mismatch in output_0_3, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_1_0 != sch_data_output_ref_1_0_r) begin
                $display("mismatch in output_1_0, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_1_1 != sch_data_output_ref_1_1_r) begin
                $display("mismatch in output_1_1, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_1_2 != sch_data_output_ref_1_2_r) begin
                $display("mismatch in output_1_2, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_1_3 != sch_data_output_ref_1_3_r) begin
                $display("mismatch in output_1_3, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_2_0 != sch_data_output_ref_2_0_r) begin
                $display("mismatch in output_2_0, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_2_1 != sch_data_output_ref_2_1_r) begin
                $display("mismatch in output_2_1, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_2_2 != sch_data_output_ref_2_2_r) begin
                $display("mismatch in output_2_2, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_2_3 != sch_data_output_ref_2_3_r) begin
                $display("mismatch in output_2_3, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_3_0 != sch_data_output_ref_3_0_r) begin
                $display("mismatch in output_3_0, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_3_1 != sch_data_output_ref_3_1_r) begin
                $display("mismatch in output_3_1, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_3_2 != sch_data_output_ref_3_2_r) begin
                $display("mismatch in output_3_2, the time at %0t", $time);
            end
            if(u0_scheduler.sch_data_output_3_3 != sch_data_output_ref_3_3_r) begin
                $display("mismatch in output_3_3, the time at %0t", $time);
            end
        end
    end
end

/*******************************************************************************/
/********************** Task Definition in Testbench ***************************/
/*******************************************************************************/
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
    rst_n = 1;
    wait_some_cycles();
    rst_n = 0;
    wait_some_cycles();
    rst_n = 1;
endtask

task ksize_gen();
    //ksize = $urandom_range(1,9);
    ksize_i = (KZ - 1) >> 1;
    ksize = KZ;
endtask

task loading_fea_ram();
  integer i,j,k;
  integer fd_00,fd_01,fd_02,fd_03;
  integer fd_10,fd_11,fd_12,fd_13;
  integer fd_20,fd_21,fd_22,fd_23;
  integer fd_30,fd_31,fd_32,fd_33;

  //genvar gvidx;
  fd_00 = $fopen("../tv/file/fe_00", "r");
  fd_01 = $fopen("../tv/file/fe_01", "r");
  fd_02 = $fopen("../tv/file/fe_02", "r");
  fd_03 = $fopen("../tv/file/fe_03", "r");
  fd_10 = $fopen("../tv/file/fe_10", "r");
  fd_11 = $fopen("../tv/file/fe_11", "r");
  fd_12 = $fopen("../tv/file/fe_12", "r");
  fd_13 = $fopen("../tv/file/fe_13", "r");
  fd_20 = $fopen("../tv/file/fe_20", "r");
  fd_21 = $fopen("../tv/file/fe_21", "r");
  fd_22 = $fopen("../tv/file/fe_22", "r");
  fd_23 = $fopen("../tv/file/fe_23", "r");
  fd_30 = $fopen("../tv/file/fe_30", "r");
  fd_31 = $fopen("../tv/file/fe_31", "r");
  fd_32 = $fopen("../tv/file/fe_32", "r");
  fd_33 = $fopen("../tv/file/fe_33", "r");
  for(i = 0; i < ((IH + 3) >> 2) * ((IC + 3) >> 2); i++) begin
    wait_one_cycle();
    $fscanf(fd_00, "%d", wr_data[0]);
    $fscanf(fd_01, "%d", wr_data[1]);
    $fscanf(fd_02, "%d", wr_data[2]);
    $fscanf(fd_03, "%d", wr_data[3]);
    $fscanf(fd_10, "%d", wr_data[4]);
    $fscanf(fd_11, "%d", wr_data[5]);
    $fscanf(fd_12, "%d", wr_data[6]);
    $fscanf(fd_13, "%d", wr_data[7]);
    $fscanf(fd_20, "%d", wr_data[8]);
    $fscanf(fd_21, "%d", wr_data[9]);
    $fscanf(fd_22, "%d", wr_data[10]);
    $fscanf(fd_23, "%d", wr_data[11]);
    $fscanf(fd_30, "%d", wr_data[12]);
    $fscanf(fd_31, "%d", wr_data[13]);
    $fscanf(fd_32, "%d", wr_data[14]);
    $fscanf(fd_33, "%d", wr_data[15]);
    for(j = 0; j < 16; j++) begin
        wr_data_w[j] = { wr_data[j] + 9'd35 ,
                      wr_data[j] + 9'd34, wr_data[j] + 9'd33, wr_data[j] + 9'd32, wr_data[j] + 9'd31, wr_data[j] + 9'd30,
                      wr_data[j] + 9'd29, wr_data[j] + 9'd28, wr_data[j] + 9'd28, wr_data[j] + 9'd26, wr_data[j] + 9'd25,
                      wr_data[j] + 9'd24, wr_data[j] + 9'd23, wr_data[j] + 9'd22, wr_data[j] + 9'd21, wr_data[j] + 9'd20,
                      wr_data[j] + 9'd19, wr_data[j] + 9'd18, wr_data[j] + 9'd17, wr_data[j] + 9'd16, wr_data[j] + 9'd15,
                      wr_data[j] + 9'd14, wr_data[j] + 9'd13, wr_data[j] + 9'd12, wr_data[j] + 9'd11, wr_data[j] + 9'd10,
                      wr_data[j] + 9'd9,  wr_data[j] + 9'd8,  wr_data[j] + 9'd7,  wr_data[j] + 9'd6,  wr_data[j] + 9'd5,
                      wr_data[j] + 9'd4,  wr_data[j] + 9'd3,  wr_data[j] + 9'd2,  wr_data[j] + 9'd1,  wr_data[j]};
    end
    wr_addr = i;
    wr_en = 1;
    if(`DISPLAY) begin
        $display("data = %0d\n", wr_data[1]);
        $display("wr_addr = %0d\n", wr_addr);
    end
  end

  wait_some_cycles();
  wr_en = 0;
  $fclose(fd_00);
  $fclose(fd_01);
  $fclose(fd_02);
  $fclose(fd_03);
  $fclose(fd_10);
  $fclose(fd_11);
  $fclose(fd_12);
  $fclose(fd_13);
  $fclose(fd_20);
  $fclose(fd_21);
  $fclose(fd_22);
  $fclose(fd_23);
  $fclose(fd_30);
  $fclose(fd_31);
  $fclose(fd_32);
  $fclose(fd_33);
endtask

task loading_olp_ram();
  integer i,j,k;
  integer olp_00,olp_01,olp_02,olp_03;
  integer olp_10,olp_11,olp_12,olp_13;
  integer olp_20,olp_21,olp_22,olp_23;
  integer olp_30,olp_31,olp_32,olp_33;

  //genvar gvidx;
  olp_00 = $fopen("../tv/file/olp_00", "r");
  olp_01 = $fopen("../tv/file/olp_01", "r");
  olp_02 = $fopen("../tv/file/olp_02", "r");
  olp_03 = $fopen("../tv/file/olp_03", "r");
  olp_10 = $fopen("../tv/file/olp_10", "r");
  olp_11 = $fopen("../tv/file/olp_11", "r");
  olp_12 = $fopen("../tv/file/olp_12", "r");
  olp_13 = $fopen("../tv/file/olp_13", "r");
  olp_20 = $fopen("../tv/file/olp_20", "r");
  olp_21 = $fopen("../tv/file/olp_21", "r");
  olp_22 = $fopen("../tv/file/olp_22", "r");
  olp_23 = $fopen("../tv/file/olp_23", "r");
  olp_30 = $fopen("../tv/file/olp_30", "r");
  olp_31 = $fopen("../tv/file/olp_31", "r");
  olp_32 = $fopen("../tv/file/olp_32", "r");
  olp_33 = $fopen("../tv/file/olp_33", "r");
  for(i = 0; i < (((IC+3) >> 2) >> (KZ == 3 ? 1 : 0)); i++) begin
    wait_one_cycle();
    $fscanf(olp_00, "%d", wr_data_olp[0]);
    $fscanf(olp_01, "%d", wr_data_olp[1]);
    $fscanf(olp_02, "%d", wr_data_olp[2]);
    $fscanf(olp_03, "%d", wr_data_olp[3]);
    $fscanf(olp_10, "%d", wr_data_olp[4]);
    $fscanf(olp_11, "%d", wr_data_olp[5]);
    $fscanf(olp_12, "%d", wr_data_olp[6]);
    $fscanf(olp_13, "%d", wr_data_olp[7]);
    $fscanf(olp_20, "%d", wr_data_olp[8]);
    $fscanf(olp_21, "%d", wr_data_olp[9]);
    $fscanf(olp_22, "%d", wr_data_olp[10]);
    $fscanf(olp_23, "%d", wr_data_olp[11]);
    $fscanf(olp_30, "%d", wr_data_olp[12]);
    $fscanf(olp_31, "%d", wr_data_olp[13]);
    $fscanf(olp_32, "%d", wr_data_olp[14]);
    $fscanf(olp_33, "%d", wr_data_olp[15]);
    for(j = 0; j < 16; j++) begin
        wr_data_olp_w[j] = { wr_data_olp[j] + 9'd35 ,
                      wr_data_olp[j] + 9'd34, wr_data_olp[j] + 9'd33, wr_data_olp[j] + 9'd32, wr_data_olp[j] + 9'd31, wr_data_olp[j] + 9'd30,
                      wr_data_olp[j] + 9'd29, wr_data_olp[j] + 9'd28, wr_data_olp[j] + 9'd28, wr_data_olp[j] + 9'd26, wr_data_olp[j] + 9'd25,
                      wr_data_olp[j] + 9'd24, wr_data_olp[j] + 9'd23, wr_data_olp[j] + 9'd22, wr_data_olp[j] + 9'd21, wr_data_olp[j] + 9'd20,
                      wr_data_olp[j] + 9'd19, wr_data_olp[j] + 9'd18, wr_data_olp[j] + 9'd17, wr_data_olp[j] + 9'd16, wr_data_olp[j] + 9'd15,
                      wr_data_olp[j] + 9'd14, wr_data_olp[j] + 9'd13, wr_data_olp[j] + 9'd12, wr_data_olp[j] + 9'd11, wr_data_olp[j] + 9'd10,
                      wr_data_olp[j] + 9'd9,  wr_data_olp[j] + 9'd8,  wr_data_olp[j] + 9'd7,  wr_data_olp[j] + 9'd6,  wr_data_olp[j] + 9'd5,
                      wr_data_olp[j] + 9'd4,  wr_data_olp[j] + 9'd3,  wr_data_olp[j] + 9'd2,  wr_data_olp[j] + 9'd1,  wr_data_olp[j]};
    end
    wr_addr_olp = i;
    wr_olp_en = 1;
    if(`DISPLAY) begin
        $display("data_olp = %0d\n", wr_data_olp[1]);
        $display("wr_addr_olp = %0d\n", wr_addr_olp);
    end
  end

  wait_some_cycles();
  wr_en = 0;
  $fclose(olp_00);
  $fclose(olp_01);
  $fclose(olp_02);
  $fclose(olp_03);
  $fclose(olp_10);
  $fclose(olp_11);
  $fclose(olp_12);
  $fclose(olp_13);
  $fclose(olp_20);
  $fclose(olp_21);
  $fclose(olp_22);
  $fclose(olp_23);
  $fclose(olp_30);
  $fclose(olp_31);
  $fclose(olp_32);
  $fclose(olp_33);
endtask

task layer_switch();
    ctrl2sch_layer_start = 1;
    wait_one_cycle();
    ctrl2sch_layer_start = 0;
endtask

task tile_size();
    /*tile_in_h = $urandom_range(10,20);
    if(tile_loc == 4'b0000)
        tile_out_h = tile_in_h;
    else if(tile_loc == 4'b0001 || tile_loc == 4'b0010)
        tile_out_h = tile_in_h - (ksize >> 1);
    tile_in_c = $urandom_range(1,20);
    tile_out_c = $urandom_range(1,20);
    tile_in_w = 32;
    tile_out_w = 32;*/
    tile_in_h = IH;
    tile_in_c = IC;
    tile_in_w = IW;
    tile_out_h = OH;
    tile_out_c = OC;
    tile_out_w = OW;
endtask

task tile_top();
    tile_loc = 4'b0010;
    ksize_gen();
    tile_size();
    layer_switch();
    if(`DISPLAY)
      display_all_input();
endtask

task tile_down();
    tile_loc = 4'b0001;
    ksize_gen();
    tile_size();
    layer_switch();
    if(`DISPLAY)
        display_all_input();
endtask

task tile_center();
    tile_loc = 4'b1000;
    ksize_gen();
    tile_size();
    layer_switch();
    if(`DISPLAY)
        display_all_input();
endtask

task detection();
    if(pre_state_tb != u0_scheduler.u0_addr_if.cur_state)
        $display("cur_state: %0d", u0_scheduler.u0_addr_if.cur_state);
endtask

task display_all_input();
    $display("tile_switch = %0d", tile_switch);
    $display("ctrl2sch_layer_start = %0d", ctrl2sch_layer_start);
    $display("pe2sch_rdy = %0d", pe2sch_rdy);
    $display("ksize = %0d", ksize);
    $display("local = %0d", tile_loc);
    $display("tile_in_h = %0d", tile_in_h);
    $display("tile_out_h = %0d", tile_out_h);
    $display("tile_in_w = %0d", tile_in_w);
    $display("tile_out_w = %0d", tile_out_w);
    $display("tile_in_c = %0d", tile_in_c);
    $display("tile_out_c = %0d", tile_out_c);
endtask

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

initial	begin
   //$display("\033[30;41m Hello error!\033[0m");
   //$display("\033[30;42m Hello pass!\033[0m");
   //$display("\033[30;43m Hello warning!\033[0m");
end

endmodule
