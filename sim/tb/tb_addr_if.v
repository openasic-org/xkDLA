`timescale 1ns/1ps
module tb_addr_if;

parameter   IFM_WIDTH    = 8;
parameter   SCH_COL_NUM  = 40;
parameter   WT_WIDTH  = 16;
parameter   PE_COL_NUM = 32;
parameter   PE_ROW_NUM = 4;
parameter   PE_IC_NUM  = 4;
parameter   PE_OC_NUM  = 4;
parameter   ADDR_WIDTH = 10;

reg                                rstn;
reg                                clk;
// ctrl_i
reg                 stack_switch;
reg                 ctrl2sch_tile_start;
reg                 pe2sch_rdy;
reg  [3:0]          tile_loc;
reg  [3:0]          ksize;
reg  [14:0]         tile_in_h;
reg  [14:0]         tile_out_h;
reg  [14:0]         tile_in_w;
reg  [14:0]         tile_out_w;
reg  [14:0]         tile_in_c;
reg  [14:0]         tile_out_c;
reg  [99:0]         pu2sch_olp_addr;


// rd addr
wire [3:0]  fe_olp_buf_rd_en;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_0;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_1;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_2;
wire [ADDR_WIDTH - 1 : 0]  fe_buf_rd_addr_3;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_0;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_1;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_2;
wire [ADDR_WIDTH - 1 : 0]  olp_buf_rd_addr_3;
wire [7              : 0]  wt_buf_rd_en;
wire [ADDR_WIDTH - 1 : 0]  wt_buf_rd_addr;

wire                       row_done;
wire                       sch2pe_vld;
wire [PE_COL_NUM - 1 : 0]  mux_col_vld;
wire [PE_ROW_NUM - 1 : 0]  mux_row_vld;
wire [PE_IC_NUM  - 1 : 0]  mux_array_vld;
wire     [3              : 0]  cnt_ksize_r;
wire [2              : 0]  cur_state_r;
wire [2              : 0]  addr_offset_r;



initial begin
    clk =1'b0;
    forever #5  clk <= ~clk; 
end

initial begin
    clk <= 1'b0;
    rstn <= 1'b1;
    #22 
    rstn <= 1'b0;
    #17
    rstn <= 1'b1;
    #20
    stack_switch <= 0;
    ctrl2sch_tile_start <= 1;
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
    ctrl2sch_tile_start <= 0;
    #2000
    ctrl2sch_tile_start <= 1;
    #10
    ctrl2sch_tile_start <= 0;
    #2000
    $finish;
end

// tile_loc == 0010;
/*
initial begin
    clk <= 1'b0;
    rstn <= 1'b1;
    #22 
    rstn <= 1'b0;
    #17
    rstn <= 1'b1;
    #20
    stack_switch <= 0;
    ctrl2sch_tile_start <= 1;
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
    #10
    ctrl2sch_tile_start <= 0;
    #2000
    ctrl2sch_tile_start <= 1;
    #10
    ctrl2sch_tile_start <= 0;
    #2000
    $finish;
end*/

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
    stack_switch <= 0;
    ctrl2sch_tile_start <= 1;
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
    ctrl2sch_tile_start <= 0;
    #2000
    ctrl2sch_tile_start <= 1;
    #10
    ctrl2sch_tile_start <= 0;
    #2000
    $finish;
end
*/


addr_if #(
  .IFM_WIDTH    (8),
  .SCH_COL_NUM  (40),
  .WT_WIDTH     (16),
  .PE_COL_NUM   (32),
  .PE_ROW_NUM   (4),
  .PE_IC_NUM    (4),
  .PE_OC_NUM    (4),
  .ADDR_WIDTH   (10)
)
u0_addr_if
(
  .rstn    (rstn),
  .clk     (clk),

  // ctrl_i
  .stack_switch          (stack_switch),
  .ctrl2sch_tile_start   (ctrl2sch_tile_start),
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

  .row_done              (row_done),
  .sch2pe_vld            (sch2pe_vld),
  .mux_col_vld           (mux_col_vld),
  .mux_row_vld           (mux_row_vld),
  .mux_array_vld         (mux_array_vld),
  .cnt_ksize_r           (cnt_ksize_r),
  .cur_state_r           (cur_state_r),
  .addr_offset_r         (addr_offset_r)
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
