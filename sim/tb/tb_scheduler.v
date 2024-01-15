`timescale 1ns/1ps
module tb_sche_sub;

parameter   IFM_WIDTH    = 8;
parameter   SCH_COL_NUM  = 40;
parameter   WT_WIDTH  = 16;
parameter   PE_COL_NUM = 32;
parameter   PE_ROW_NUM = 4;
parameter   PE_IC_NUM  = 4;
parameter   PE_OC_NUM  = 4;
parameter   ADDR_WIDTH = 10;

reg                            clk;
reg                            rstn;

reg                            tile_switch;
reg                            ctrl2sch_layer_start;
reg      [3              : 0]  cnt_layer;
reg      [3              : 0]  tile_loc;
reg      [3              : 0]  ksize;
reg                            pe2sch_rdy;
reg      [14             : 0]  tile_in_h;
reg      [14             : 0]  tile_out_h;
reg      [14             : 0]  tile_in_w;
reg      [14             : 0]  tile_out_w;
reg      [14             : 0]  tile_in_c;
reg      [14             : 0]  tile_out_c;
reg      [99             : 0]  pu2sch_olp_addr;

wire     [3              : 0]  fe_olp_buf_rd_en;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_0;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_1;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_2;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_3;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_0;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_1;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_2;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_3;
wire [7              : 0]  wt_buf_rd_en;
wire     [ADDR_WIDTH - 1 : 0]  wt_buf_rd_addr;

wire                                  sch2pe_row_done;
wire                                  sch2pe_vld_o;
wire [PE_COL_NUM          - 1 : 0]    mux_col_vld_o;
wire [PE_ROW_NUM          - 1 : 0]    mux_row_vld_o;
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

wire [3:0] k;

initial begin
    clk =1'b0;
    forever #5  clk <= ~clk; 
end
/*
initial begin
    clk <= 1'b0;
    rstn <= 1'b1;
    #22 
    rstn <= 1'b0;
    #17
    rstn <= 1'b1;
    #20
    sch_data_input_0_0 <= 256'h01010101_01010101_01010101_01010101_01010101_01010101_01010101_01010203;
    sch_data_input_0_1 <= 256'h02020202_02020202_02020202_02020202_02020202_02020202_02020202_02010203;
    sch_data_input_0_2 <= 256'h03030303_03030303_03030303_03030303_03030303_03030303_03030303_03010203;
    sch_data_input_0_3 <= 256'h04040404_04040404_04040404_04040404_04040404_04040404_04040404_04010203;
    tile_switch <= 0;
    ctrl2sch_layer_start <= 1;
    pe2sch_rdy <= 1;
    tile_loc <= 0001;
    ksize <= 3;
    tile_in_h <= 10;
    tile_out_h <= 9;
    tile_in_w <= 32;
    tile_out_w <= 32;
    tile_in_c <= 9;
    tile_out_c <= 8;
    pu2sch_olp_addr <= 0;
    #10
    ctrl2sch_layer_start <= 0;
    #2000
    ctrl2sch_layer_start <= 1;
    #10
    ctrl2sch_layer_start <= 0;
    #3000
    $finish;
end*/

// tile_loc == 0010;

initial begin
    clk <= 1'b0;
    rstn <= 1'b1;
    #22 
    rstn <= 1'b0;
    #17
    rstn <= 1'b1;
    #20
    tile_switch <= 0;
    ctrl2sch_layer_start <= 1;
    pe2sch_rdy <= 1;
    tile_loc <= 0010;
    ksize <= 3;
    tile_in_h <= 10;
    tile_out_h <= 9;
    tile_in_w <= 32;
    tile_out_w <= 32;
    tile_in_c <= 9;
    tile_out_c <= 8;
    pu2sch_olp_addr <= 0;
    rstn <= 1'b1;
    #22 
    rstn <= 1'b0;
    #17
    rstn <= 1'b1;
    #10
    ctrl2sch_layer_start <= 0;
    #90
    pe2sch_rdy <= 0;
    #30
    pe2sch_rdy <= 1;
    #2000
    ctrl2sch_layer_start <= 1;
    #10
    ctrl2sch_layer_start <= 0;
    #2000
    $finish;
end

always @(posedge clk)
begin
    sch_data_input_0_0 <= fe_olp_buf_rd_en[3] ? 256'h01010101_01010101_01010101_01010101_01010101_01010101_01010101_01010203 : 0;
    sch_data_input_0_1 <= fe_olp_buf_rd_en[2] ? 256'h02020202_02020202_02020202_02020202_02020202_02020202_02020202_02010203 : 0;
    sch_data_input_0_2 <= fe_olp_buf_rd_en[1] ? 256'h03030303_03030303_03030303_03030303_03030303_03030303_03030303_03010203 : 0;
    sch_data_input_0_3 <= fe_olp_buf_rd_en[0] ? 256'h04040404_04040404_04040404_04040404_04040404_04040404_04040404_04010203 : 0;
end

always @(posedge clk)
begin
    sch_weight_input_0_0 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_0_1 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
    sch_weight_input_0_2 <= wt_buf_rd_addr != 0 ? 32'h1234_5678 : 0;
    sch_weight_input_0_3 <= wt_buf_rd_addr != 0 ? 32'h8765_4321 : 0;
end

// tile_loc == 0000;
/*
initial begin
    clk <= 1'b0;
    rstn <= 1'b1;
    #22 
    rstn <= 1'b0;
    #17
    rstn <= 1'b1;
    #20
    tile_switch <= 0;
    ctrl2sch_layer_start <= 1;
    pe2sch_rdy <= 1;
    tile_loc <= 0000;
    ksize <= 3;
    tile_in_h <= 10;
    tile_out_h <= 8;
    tile_in_w <= 32;
    tile_out_w <= 32;
    tile_in_c <= 8;
    tile_out_c <= 8;
    pu2sch_olp_addr <= 0;
    #10
    ctrl2sch_layer_start <= 0;
    #2000
    ctrl2sch_layer_start <= 1;
    #10
    ctrl2sch_layer_start <= 0;
    #2000
    $finish;
end
*/

scheduler #(
  .IFM_WIDTH    (IFM_WIDTH),
  .SCH_COL_NUM  (SCH_COL_NUM),
  .WT_WIDTH     (WT_WIDTH),
  .PE_COL_NUM   (PE_COL_NUM),
  .PE_ROW_NUM   (PE_ROW_NUM),
  .PE_IC_NUM    (PE_IC_NUM),
  .PE_OC_NUM    (PE_OC_NUM),
  .ADDR_WIDTH   (ADDR_WIDTH)
)
u0_scheduler
(
  .clk(clk),
  .rstn(rstn),

    // ctrl_i
  .tile_switch           (tile_switch),
  .ctrl2sch_layer_start  (ctrl2sch_layer_start),
  .cnt_layer             (cnt_layer),
  .pe2sch_rdy            (pe2sch_rdy),
  .tile_loc              (tile_loc),
  .ksize                 (ksize),
  .tile_in_h             (tile_in_h),
  .tile_out_h            (tile_out_h),
  .tile_in_w             (tile_in_w),
  .tile_out_w            (tile_out_w),
  .tile_in_c             (tile_in_c),
  .tile_out_c            (tile_out_c),
  .pu2sch_olp_addr       (pu2sch_olp_addr),

    //buffer rd
  .fe_olp_buf_rd_en      (fe_olp_buf_rd_en),
  .fe_buf_rd_addr_0      (fe_buf_rd_addr_0),
  .fe_buf_rd_addr_1      (fe_buf_rd_addr_1),
  .fe_buf_rd_addr_2      (fe_buf_rd_addr_2),
  .fe_buf_rd_addr_3      (fe_buf_rd_addr_3),
  .olp_buf_rd_addr_0     (olp_buf_rd_addr_0),
  .olp_buf_rd_addr_1     (olp_buf_rd_addr_1),
  .olp_buf_rd_addr_2     (olp_buf_rd_addr_2),
  .olp_buf_rd_addr_3     (olp_buf_rd_addr_3),
  .wt_buf_rd_en          (wt_buf_rd_en),
  .wt_buf_rd_addr        (wt_buf_rd_addr),

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
   $display("\033[30;41m Hello error!\033[0m");
   $display("\033[30;42m Hello pass!\033[0m");
   $display("\033[30;43m Hello warning!\033[0m");

end

`ifdef GLS_SIM
initial begin
  $sdf_annotate("../../netlist_sim/sdf/TOP.sdf",tb.U_TOP,,"sdf.log","TYPICAL");
end
`endif

endmodule
