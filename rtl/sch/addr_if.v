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
module addr_if
#(
  parameter   REG_IH_WIDTH = 5  ,
  parameter   REG_IW_WIDTH = 6  ,
  parameter   REG_IC_WIDTH = 6  ,
  parameter   REG_OH_WIDTH = 5  ,
  parameter   REG_OW_WIDTH = 6  ,
  parameter   REG_OC_WIDTH = 6  ,
  parameter   IFM_WIDTH    = 8  ,
  parameter   SCH_COL_NUM  = 36 ,
  parameter   WT_WIDTH     = 16 ,
  parameter   PE_COL_NUM   = 32 ,
  parameter   PE_H_NUM     = 4  ,
  parameter   PE_IC_NUM    = 4  ,
  parameter   PE_OC_NUM    = 4  ,
  parameter   FE_ADDR_WIDTH = 9  ,
  parameter   WT_ADDR_WIDTH = 11 ,
  parameter   X_ADDR_WIDTH  = 10 ,
  parameter   Y_ADDR_WIDTH  = 10 ,
  parameter   XY_ADDR_WIDTH = 10 ,
  parameter   P2S_OADDR_WIDTH = 100,
  parameter   WIDTH_KSIZE   = 3 ,
  parameter   WIDTH_FEA_X   = 6 ,
  parameter   WIDTH_FEA_Y   = 6 ,
  parameter   Y_L234_DEPTH  = 64,
  parameter   X_L234_DEPTH  = 32,
  parameter   XY_L234_DEPTH = 34
)
(
  rst_n               ,
  clk                 ,

  //interface with scheduler
  //input
  tile_switch         ,
  ctrl2sch_layer_start,
  cnt_layer           ,
  tile_loc            ,
  ksize               ,
  pe2sch_rdy          ,
  tile_in_h           ,
  tile_out_h          ,
  tile_in_w           ,
  tile_out_w          ,
  tile_in_c           ,
  tile_out_c          ,
  model_switch        ,
  nn_proc             ,
  tile_tot_num_x      ,

  //output
  sch2fe_ren          ,
  sch2fe_raddr_0      ,
  sch2fe_raddr_1      ,
  sch2fe_raddr_2      ,
  sch2fe_raddr_3      ,
  sch2x_raddr_0       ,
  sch2x_raddr_1       ,
  sch2x_raddr_2       ,
  sch2x_raddr_3       ,
  wt_buf_rd_en        ,
  wt_buf_rd_addr      ,
  sch2y_ren           ,
  sch2y_raddr         ,
  sch2xy_evn_ren      ,
  sch2xy_odd_ren      ,
  sch2xy_raddr_evn    ,
  sch2xy_raddr_odd    ,

  //interface with sche_sub
  //output
  row_start           ,
  row_done            ,
//  sch2pe_vld          ,
//  mux_col_vld         ,
//  mux_row_vld         ,
//  mux_array_vld       ,
  cnt_ksize           ,
  cur_state_o         ,
  tile_state_o        ,
  addr_offset         ,
  cnt_y_o             ,
  num_y_o             ,
  tile_out_h_w_o      ,
  cnt_curf_o
);

// fsm state
localparam      IDLE      = 3'd0;
localparam      ADDR_INIT = 3'd1;
localparam      ADDR_PLUS = 3'd2;
localparam      IC_PLUS4  = 3'd3;
localparam      OC_PLUS4  = 3'd4;
localparam      NEXT_ROW4 = 3'd5;

input                            clk                 ;
input                            rst_n               ;
//interface with scheduler
input                            tile_switch         ;
input                            ctrl2sch_layer_start;
input      [2              : 0]  cnt_layer           ;
input      [3              : 0]  tile_loc            ;
input      [WIDTH_KSIZE -1 : 0]  ksize               ;
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
output reg [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_0   ;
output reg [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_1   ;
output reg [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_2   ;
output reg [FE_ADDR_WIDTH - 1 : 0]  sch2fe_raddr_3   ;
output reg [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_0    ;
output reg [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_1    ;
output reg [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_2    ;
output reg [X_ADDR_WIDTH  - 1 : 0]  sch2x_raddr_3    ;
output reg [7                 : 0]  wt_buf_rd_en     ;
output     [WT_ADDR_WIDTH - 1 : 0]  wt_buf_rd_addr   ;
output     [3                 : 0]  sch2y_ren        ;
output     [Y_ADDR_WIDTH-1    : 0]  sch2y_raddr      ;
output     [3                 : 0]  sch2xy_evn_ren   ;
output     [3                 : 0]  sch2xy_odd_ren   ;
output     [XY_ADDR_WIDTH-1   : 0]  sch2xy_raddr_evn ;
output     [XY_ADDR_WIDTH-1   : 0]  sch2xy_raddr_odd ;

// interface with sche_sub
output                           row_start           ;
output                           row_done            ;
//output reg                       sch2pe_vld          ;
//output reg [PE_COL_NUM - 1 : 0]  mux_col_vld         ;
//output reg [PE_H_NUM   - 1 : 0]  mux_row_vld         ;
//output reg [PE_IC_NUM  - 1 : 0]  mux_array_vld       ;
output     [WIDTH_KSIZE -1 : 0]  cnt_ksize           ;
output     [2              : 0]  cur_state_o         ;
output                           tile_state_o        ;
output reg [2              : 0]  addr_offset         ;
output     [REG_IH_WIDTH-2 : 0]  cnt_y_o             ;
output     [REG_OH_WIDTH-2 : 0]  num_y_o             ;
output     [REG_IH_WIDTH   : 0]  tile_out_h_w_o      ;
output     [REG_IC_WIDTH-2 : 0]  cnt_curf_o          ;

//------------------ reg -----------------------//
reg        [2              : 0]  cur_state           ;
reg        [2              : 0]  nxt_state           ;
reg                              tile_state          ;
reg                              tile_state_r        ;
//base addr offset and rd of fea_buf and xolp_buf
reg        [X_ADDR_WIDTH-1 : 0]  addr_base           ;
reg        [3              : 0]  sch2fe_ren_r        ;
//base addr and rd of yolp_buf
reg        [Y_ADDR_WIDTH-1 : 0] addr_yolp_base       ;
reg        [3              : 0] sch2y_ren_r          ;
//base addr and rd of xyolp_buf
reg        [XY_ADDR_WIDTH-1: 0] addr_xyolp_base_evn  ;
reg        [XY_ADDR_WIDTH-1: 0] addr_xyolp_base_odd  ;
reg        [3              : 0] sch2xy_ren_r         ;

reg        [Y_ADDR_WIDTH-1 : 0] addr_yolp_layer      ;
reg        [X_ADDR_WIDTH-1 : 0] addr_xolp_layer      ;
reg        [XY_ADDR_WIDTH-1: 0] addr_xyolp_layer     ;

reg        [X_ADDR_WIDTH-1 : 0]  addr_ic_r           ;
reg        [1              : 0]  over_load           ;

reg        [2              : 0]  cnt_layer_r         ;
reg        [WIDTH_KSIZE -1 : 0]  cnt_ksize           ;
reg        [WIDTH_KSIZE -1 : 0]  cnt_ksize_y         ;
reg        [REG_IC_WIDTH-2 : 0]  cnt_curf            ;
reg        [REG_OC_WIDTH-2 : 0]  cnt_kurf            ;
reg        [REG_IH_WIDTH-2 : 0]  cnt_y               ;
reg        [WT_ADDR_WIDTH+2: 0]  cnt_wt_addr         ;
reg        [WT_ADDR_WIDTH+2: 0]  cnt_wt_addr_r       ;
reg        [WIDTH_FEA_X    : 0]  cnt_yolp_dndm       ;
reg        [WIDTH_FEA_X    : 0]  cnt_yolp_sr         ;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc0;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc1;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc0_l1  ;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc1_l1  ;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc0_l234;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc1_l234;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc0_l5  ;
reg        [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_proc1_l5  ;

reg        [X_ADDR_WIDTH-1 : 0]  num_y_curf_r        ;
reg                              row_start_r         ;

// wire of addr_xyolp
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc0;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc1;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc0;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc1;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc0_L1   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc0_L234 ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc0_L5   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc1_L1   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc1_L234 ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc1_L5   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc0_L1   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc0_L234 ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc0_L5   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc1_L1   ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc1_L234 ;
reg        [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc1_L5   ;

reg        [3              : 0]  tile_loc_r          ;
reg        [3              : 0]  tile_loc_pre        ;

//------------------- wire ----------------------//
//base addr and rd of xyolp_buf
wire       [3              : 0]  sch2xy_evn_ren_w    ;
wire       [3              : 0]  sch2xy_odd_ren_w    ;

wire       [REG_IC_WIDTH-2 : 0]  num_curf_i          ;
wire       [REG_OC_WIDTH-2 : 0]  num_kurf_o          ;
wire       [REG_IH_WIDTH-2 : 0]  num_y_i             ;
wire       [3              : 0]  padding_num         ;

wire       [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile      ;
wire       [Y_ADDR_WIDTH-1 : 0]  addr_yolp_tile_w    ;

// wire of addr_xyolp
wire       [WIDTH_FEA_X    : 0]  cnt_yolp            ;

wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn ;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_end_w ;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd ;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_end_w ;

wire                             add_cnt_ksize       ;
wire                             end_cnt_ksize       ;
wire                             add_cnt_ksize_y     ;
wire                             end_cnt_ksize_y     ;
wire                             add_cnt_curf        ;
wire                             end_cnt_curf        ;
wire                             add_cnt_kurf        ;
wire                             end_cnt_kurf        ;
wire                             add_cnt_y           ;
wire                             end_cnt_y           ;
wire                             end_cnt_layer       ;
wire                             add_cnt_fea_x       ;
wire                             end_cnt_fea_x       ;
wire                             add_cnt_fea_y       ;
wire                             end_cnt_fea_y       ;
wire                             add_cnt_wt_addr     ;
wire                             end_cnt_wt_addr     ;
wire                             add_cnt_yolp_dndm   ;
wire                             end_cnt_yolp_dndm   ;
wire                             add_cnt_yolp_sr     ;
wire                             end_cnt_yolp_sr     ;
wire                             add_addr_yolp_tile  ;
wire                             end_addr_yolp_tile  ;
wire                             add_addr_xyolp_tile_evn;
wire                             end_addr_xyolp_tile_evn;
wire                             add_addr_xyolp_tile_odd;
wire                             end_addr_xyolp_tile_odd;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc0_w;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_odd_proc1_w;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc0_w;
wire       [XY_ADDR_WIDTH-1: 0]  addr_xyolp_tile_evn_proc1_w;

wire      [REG_IH_WIDTH   : 0]   tile_in_h_w         ;
wire      [REG_IH_WIDTH   : 0]   tile_out_h_w         ;

/******************************************************************************/
/*********************************** FSM design *******************************/
/******************************************************************************/
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cur_state <= IDLE;
  else if(pe2sch_rdy)
    cur_state <= nxt_state;
  else
    cur_state <= cur_state;
end

assign cur_state_o = cur_state;

//-------------- fsm trans --------------//
always @(*)
begin
  nxt_state = IDLE;
  case(cur_state)
    IDLE:  begin
      if(ctrl2sch_layer_start)
        nxt_state = ADDR_INIT;
      else
        nxt_state = IDLE;
    end
    ADDR_INIT: begin
      if(end_cnt_y)
        nxt_state = IDLE;
      else if(ksize == 1 && end_cnt_kurf)
        nxt_state = NEXT_ROW4;
      else if(ksize == 1 && end_cnt_curf)
        nxt_state = OC_PLUS4;
      else if(ksize == 1 && end_cnt_ksize)
        nxt_state = IC_PLUS4;
      else if(end_cnt_ksize)
        nxt_state = ADDR_PLUS;
      else
        nxt_state = ADDR_INIT;
    end
    ADDR_PLUS: begin
      if(end_cnt_y)
        nxt_state = IDLE;
      else if(end_cnt_kurf)
        nxt_state = NEXT_ROW4;
      else if(end_cnt_curf)
        nxt_state = OC_PLUS4;
      else if(end_cnt_ksize_y)
        nxt_state = IC_PLUS4;
      else
        nxt_state = ADDR_PLUS;
    end
    IC_PLUS4: begin
      if(end_cnt_y)
        nxt_state = IDLE;
      else if(ksize == 1 && end_cnt_kurf)
        nxt_state = NEXT_ROW4;
      else if(ksize == 1 && end_cnt_curf)
        nxt_state = OC_PLUS4;
      else if(ksize == 1 && end_cnt_ksize)
        nxt_state = IC_PLUS4;
      else if(end_cnt_ksize)
        nxt_state = ADDR_PLUS;
      else
        nxt_state = IC_PLUS4;
    end
    OC_PLUS4: begin
      if(end_cnt_y)
        nxt_state = IDLE;
      else if(ksize == 1 && end_cnt_kurf)
        nxt_state = NEXT_ROW4;
      else if(ksize == 1 && end_cnt_curf)
        nxt_state = OC_PLUS4;
      else if(ksize == 1 && end_cnt_ksize)
        nxt_state = IC_PLUS4;
      else if(end_cnt_ksize)
        nxt_state = ADDR_PLUS;
      else
        nxt_state = OC_PLUS4;
    end
    NEXT_ROW4: begin
      if(end_cnt_y)
        nxt_state = IDLE;
      else if(ksize == 1 && end_cnt_kurf)
        nxt_state = NEXT_ROW4;
      else if(ksize == 1 && end_cnt_curf)
        nxt_state = OC_PLUS4;
      else if(ksize == 1 && end_cnt_ksize)
        nxt_state = IC_PLUS4;
      else if(end_cnt_ksize)
        nxt_state = ADDR_PLUS;
      else
        nxt_state = NEXT_ROW4;
    end
  endcase
end

//-------------- cal addr_base --------------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_base <= 0;
  else begin
    case(nxt_state)
      IDLE: addr_base <= 0;
      ADDR_INIT: begin
        if((cnt_ksize == 0) && pe2sch_rdy) begin
          if(tile_loc[1] == 1 && ksize != 1)
            addr_base <= {X_ADDR_WIDTH{1'b1}};
          else
            addr_base <= ksize == 1 ? 0 : {X_ADDR_WIDTH{1'b1}};
        end
      end
      ADDR_PLUS: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy) begin
          if((tile_loc[0] == 1) && ((cnt_y + 1) * 4  + cnt_ksize_y > tile_in_h_w - 1))
            addr_base <= {X_ADDR_WIDTH{1'b1}};
          else if((cur_state == IC_PLUS4 || cur_state == ADDR_INIT || cur_state == OC_PLUS4 || cur_state == NEXT_ROW4)
                 && (ksize != 1))
            addr_base <= (addr_base + 1 + addr_ic_r);
          else if((cur_state == ADDR_INIT || cur_state == IC_PLUS4 || cur_state == OC_PLUS4) && cnt_y == 0
            ||(addr_offset == 1 || (addr_offset == 4 && sch2fe_ren_r == 4'b1111)))
            addr_base <= addr_base + 1;
        end
      end
      IC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy) begin
          if(ksize != 1 && cnt_y == 0)
            addr_base <= {X_ADDR_WIDTH{1'b1}};
          else if(ksize != 1)
            addr_base <=  num_y_curf_r + cnt_y - 1;
          else
            addr_base <= (cur_state == IC_PLUS4 ? addr_base - cnt_y : 0) +
                         (cur_state == ADDR_PLUS ? num_y_curf_r : num_y_i) + cnt_y;
        end
      end
      OC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          addr_base <= cnt_y - (ksize != 1);
      end
      NEXT_ROW4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          addr_base <=  cnt_y + 1 - (ksize != 1);
      end
      default: begin
        addr_base <= 0;
      end
    endcase
  end
end

//---------------- cal addr_offset --------------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_offset <= 0;
  else begin
    case(nxt_state)
      IDLE:
        addr_offset <= 0;
      ADDR_INIT: begin
        if((cnt_ksize == 0) && pe2sch_rdy) begin
          if(tile_loc[1] == 1 && ksize != 1)
            addr_offset <= padding_num;
          else
            addr_offset <= ksize == 1 ? 4 : ksize - 1;
        end
      end
      ADDR_PLUS: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy) begin
          if((tile_loc[0] == 1) && ((cnt_y + 1) * 4  + cnt_ksize_y > tile_in_h_w - 1))
            addr_offset <= 4;
          else if(((cur_state == ADDR_INIT || cur_state == IC_PLUS4 || cur_state == OC_PLUS4) && cnt_y == 0)
            ||(sch2fe_ren_r == 4'b1111))
            addr_offset <= addr_offset;
          else if(addr_offset == 1 || (addr_offset == 4 && sch2fe_ren_r == 4'b1111))
            addr_offset <= 4;
          else
            addr_offset <= addr_offset - 1;
        end
      end
      IC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy) begin
          if((tile_loc[1] == 1 && ksize != 1))
            addr_offset <= padding_num;
          else
            addr_offset <= ksize == 1 ? 4 : ksize - 1;
        end
      end
      OC_PLUS4, NEXT_ROW4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          addr_offset <= (tile_loc[1] == 1 & ksize != 1) ? padding_num : (ksize == 1 ? 4 : ksize - 1);
      end
      default: addr_offset <= 0;
    endcase
  end
end

//--------------- cal sch2fe_ren_r -----------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    sch2fe_ren_r <= 0;
  else begin
    case(nxt_state)
      IDLE: sch2fe_ren_r <= 0;
      ADDR_INIT: begin
        if((cnt_ksize == 0) && pe2sch_rdy)
            sch2fe_ren_r <= tile_loc[1] == 1 ? 4'b1111 : (4'b1111 << (ksize - 1));
      end
      ADDR_PLUS: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy) begin
          if((tile_loc[0] == 1) && ((cnt_y + 1) * 4  + cnt_ksize_y > tile_in_h_w - 1))
            sch2fe_ren_r <= 4'b1000;
          else if((cur_state == IC_PLUS4 || cur_state == ADDR_INIT || cur_state == OC_PLUS4 || cur_state == NEXT_ROW4)
                 && (ksize != 1))
            sch2fe_ren_r <= 4'b0001 << (addr_offset > 0 ? addr_offset - 1 : addr_offset); // to avoid addr_offset - 1 < 0
          else if(addr_offset == 1 || (addr_offset == 4 && sch2fe_ren_r == 4'b1111))
            sch2fe_ren_r <= 4'b1000;
          else
            sch2fe_ren_r <= ((sch2fe_ren_r >> 1) | sch2fe_ren_r) - sch2fe_ren_r;
        end
      end
      IC_PLUS4, OC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          sch2fe_ren_r <= 4'b1111 << ((tile_loc[1] == 0 && cnt_y == 0) ? (ksize - 1) : 0);
      end
      NEXT_ROW4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          sch2fe_ren_r <= 4'b1111;
      end
      default: sch2fe_ren_r <= 0;
    endcase
  end
end

//---------------- cal addr_yolp_base ------------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_base <= 0;
  else begin
    case(nxt_state)
      IDLE: addr_yolp_base <= 0;
      ADDR_INIT: begin
        if(((cnt_ksize == 0) && pe2sch_rdy) && (tile_loc[1] == 0 && ksize != 1))begin
          addr_yolp_base <= addr_yolp_tile;
        end
      end
      ADDR_PLUS, NEXT_ROW4: addr_yolp_base <= addr_yolp_base;
      IC_PLUS4: begin
        if(((cnt_ksize == ksize - 1) && pe2sch_rdy) && (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0))
          addr_yolp_base <= (cnt_curf[0] == 0 && ksize == 3) ? addr_yolp_base : addr_yolp_base + 1;
      end
      OC_PLUS4: begin
        if(((cnt_ksize == ksize - 1) && pe2sch_rdy) && (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0))
          addr_yolp_base <= addr_yolp_tile;
      end
      default: begin
        addr_yolp_base <= 0;
      end
    endcase
  end
end

//---------------- cal sch2y_ren_r ------------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    sch2y_ren_r <= 0;
  else begin
    case(nxt_state)
      IDLE, NEXT_ROW4: sch2y_ren_r <= 0;
      ADDR_INIT: begin
        if((cnt_ksize == 0) && pe2sch_rdy)
          sch2y_ren_r <= (tile_loc[1] == 0 && ksize != 1) ? (ksize == 3 ? 4'b1100 : 4'b1111) : 0;
      end
      ADDR_PLUS: sch2y_ren_r <= 0;
      IC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          sch2y_ren_r <= (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0) ?
                (ksize == 3 ? (cnt_curf[0] == 0 ? 4'b0011 : 4'b1100) : 4'b1111) : 0;
      end
      OC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          sch2y_ren_r <= (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0) ? (ksize == 3 ? 4'b1100 : 4'b1111) : 0;
      end
      default: sch2y_ren_r <= 0;
    endcase
  end
end

//------------ cal addr_xyolp_base and xyolp_buf_rd_en_w ------------//
//---------------- cal addr_xyolp_base ------------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    addr_xyolp_base_evn <= 0;
    addr_xyolp_base_odd <= 0;
  end
  else begin
    case(nxt_state)
      IDLE: begin
        addr_xyolp_base_evn <= 0;
        addr_xyolp_base_odd <= 0;
      end
      ADDR_INIT: begin
        if(((cnt_ksize == 0) && pe2sch_rdy) && (tile_loc[1] == 0 && ksize != 1) && cur_state != ADDR_INIT)begin
          addr_xyolp_base_evn <= addr_xyolp_tile_evn;
          //addr_xyolp_base_odd <= addr_xyolp_tile_odd - (ksize == 3 ? (num_curf_i + 1) >> 1 : num_curf_i);
          addr_xyolp_base_odd <= addr_xyolp_tile_odd;
        end
      end
      ADDR_PLUS, NEXT_ROW4: begin
        addr_xyolp_base_evn <= addr_xyolp_base_evn;
        addr_xyolp_base_odd <= addr_xyolp_base_odd;
      end
      IC_PLUS4: begin
        if(((cnt_ksize == ksize - 1) && pe2sch_rdy) && (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0)) begin
          addr_xyolp_base_evn <= (cnt_curf[0] == 0 && ksize == 3) ? addr_xyolp_base_evn : addr_xyolp_base_evn + 1;
          addr_xyolp_base_odd <= (cnt_curf[0] == 0 && ksize == 3) ? addr_xyolp_base_odd : addr_xyolp_base_odd + 1;
        end
      end
      OC_PLUS4: begin
        if(((cnt_ksize == ksize - 1) && pe2sch_rdy) && (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0)) begin
          addr_xyolp_base_evn <= addr_xyolp_tile_evn;
          //addr_xyolp_base_odd <= addr_xyolp_tile_odd - (ksize == 3 ? (num_curf_i + 1) >> 1 : num_curf_i);
          addr_xyolp_base_odd <= addr_xyolp_tile_odd;
        end
      end
      default: begin
        addr_xyolp_base_evn <= 0;
        addr_xyolp_base_odd <= 0;
      end
    endcase
  end
end

//---------------- cal sch2xy_ren_r ------------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    sch2xy_ren_r <= 0;
  else begin
    case(nxt_state)
      IDLE, NEXT_ROW4: sch2xy_ren_r <= 0;
      ADDR_INIT: begin
        if((cnt_ksize == 0) && pe2sch_rdy)
          sch2xy_ren_r <= (tile_loc[1] == 0 && ksize != 1) ? (ksize == 3 ? 4'b1100 : 4'b1111) : 0;
      end
      ADDR_PLUS: sch2xy_ren_r <= 0;
      IC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          sch2xy_ren_r <= (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0) ?
                (ksize == 3 ? (cnt_curf[0] == 0 ? 4'b0011 : 4'b1100) : 4'b1111) : 0;
      end
      OC_PLUS4: begin
        if((cnt_ksize == ksize - 1) && pe2sch_rdy)
          sch2xy_ren_r <= (tile_loc[1] == 0 && ksize != 1 && cnt_y == 0) ? (ksize == 3 ? 4'b1100 : 4'b1111) : 0;
      end
      default: sch2xy_ren_r <= 0;
    endcase
  end
end

assign sch2xy_evn_ren_w = (tile_loc[1] == 1 || (tile_state == 0 && tile_loc[2] == 1)) ? 0 : sch2xy_ren_r;
assign sch2xy_odd_ren_w = (tile_loc[1] == 1 || tile_loc[3] == 1 || (tile_state == 1 && tile_loc[2] == 1)) ? 0 : sch2xy_ren_r;

//------------ cal tile_state (the read xyolp_buf in every row) -----//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    tile_state <= 0;
  else if(tile_loc[1] == 1 || tile_loc[3] == 1)
    tile_state <= 0;
  else if(tile_switch)
    tile_state <= ~tile_state;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_ic_r <= 0;
  else if(nxt_state == IC_PLUS4 && cur_state == ADDR_PLUS && (ksize != 1) && cnt_y == 0)
    addr_ic_r <= num_y_i * (cnt_curf + 1) + cnt_y;
  else if(cur_state == IC_PLUS4)
    addr_ic_r <= addr_ic_r;
  else
    addr_ic_r <= 0;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    over_load <= 0;
  else if(pe2sch_rdy) begin
    if(tile_loc[2] == 1 && tile_in_w == 0)
      over_load <= 3;
    else if(nxt_state == NEXT_ROW4 && cur_state == ADDR_PLUS)
      over_load <= ((cnt_y + 2) * 4 > tile_in_h_w) ? (cnt_y + 2) * 4 - tile_in_h_w : 0;
    else if((nxt_state == IC_PLUS4 || nxt_state == OC_PLUS4) && cur_state == ADDR_PLUS)
      over_load <= ((cnt_y + 1) * 4 > tile_in_h_w) ? (cnt_y + 1) * 4 - tile_in_h_w : 0;
    else if(nxt_state == ADDR_PLUS)
      over_load <= ((cnt_y + 1) * 4 + cnt_ksize_y + 1 > tile_in_h_w + (tile_loc[1] == 1 && ksize != 1 ? padding_num : 0)) ?  3 : 0;
    else
      over_load <= 0;
  end
end

/******************************************************************************/
/******************************* Counter design *******************************/
/******************************************************************************/
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_ksize <= 0;
  else if(add_cnt_ksize) begin
    if(end_cnt_ksize)
      cnt_ksize <= 0;
    else
      cnt_ksize <= cnt_ksize + 1;
  end
  else
    cnt_ksize <= cnt_ksize;
end

assign add_cnt_ksize = cur_state != IDLE && pe2sch_rdy == 1;
assign end_cnt_ksize = add_cnt_ksize && (cnt_ksize == ksize - 1);

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_ksize_y <= 0;
  else if(end_cnt_layer)
    cnt_ksize_y <= 0;
  else if(end_cnt_ksize_y)
      cnt_ksize_y <= 0;
  else if(add_cnt_ksize_y)
      cnt_ksize_y <= cnt_ksize_y + 1;
end

assign add_cnt_ksize_y = end_cnt_ksize && pe2sch_rdy == 1;
assign end_cnt_ksize_y = add_cnt_ksize_y && (cnt_ksize_y == ksize - 1);

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_curf <= 0;
  else if(end_cnt_layer)
    cnt_curf <= 0;
  else if(add_cnt_curf) begin
    if(end_cnt_curf)
      cnt_curf <= 0;
    else
      cnt_curf <= cnt_curf + 1;
  end
  else
    cnt_curf <= cnt_curf;
end

assign add_cnt_curf = end_cnt_ksize_y && end_cnt_ksize && pe2sch_rdy == 1;
assign end_cnt_curf = add_cnt_curf && (cnt_curf == num_curf_i - 1);

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_kurf <= 0;
  else if(end_cnt_layer)
    cnt_kurf <= 0;
  else if(add_cnt_kurf) begin
    if(end_cnt_kurf)
      cnt_kurf <= 0;
    else
      cnt_kurf <= cnt_kurf + 1;
  end
  else
    cnt_kurf <= cnt_kurf;
end

assign add_cnt_kurf = end_cnt_ksize_y && end_cnt_ksize && end_cnt_curf && pe2sch_rdy;
assign end_cnt_kurf = add_cnt_kurf && (cnt_kurf == num_kurf_o - 1);

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_y <= 0;
  else if(end_cnt_layer)
    cnt_y <= 0;
  else if(add_cnt_y) begin
    if(end_cnt_y)
      cnt_y <= 0;
    else
      cnt_y <= cnt_y + 1;
  end
  else
    cnt_y <= cnt_y;
end

assign add_cnt_y = end_cnt_ksize_y && end_cnt_ksize && end_cnt_curf && end_cnt_kurf && pe2sch_rdy;
assign end_cnt_y = add_cnt_y && (cnt_y == num_y_o - 1);

assign end_cnt_layer = (tile_switch == 1);

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_wt_addr <= 0;
  else if(end_cnt_wt_addr)
    cnt_wt_addr <= 0;
  else if(add_cnt_y && !end_cnt_y)
    cnt_wt_addr <= cnt_wt_addr_r;
  else if(add_cnt_wt_addr)
    cnt_wt_addr <= cnt_wt_addr + 1;
  else
    cnt_wt_addr <= cnt_wt_addr;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_wt_addr_r <= 0;
  else if(cur_state == ADDR_INIT && cnt_ksize == 1'b0)
    cnt_wt_addr_r <= cnt_wt_addr;
end

assign add_cnt_wt_addr = (cur_state != IDLE) && pe2sch_rdy == 1;
assign end_cnt_wt_addr = tile_switch;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_yolp_dndm <= 0;
  else if(tile_loc_r[1] == 1 && nn_proc == 0)
    cnt_yolp_dndm <= 0;
  else if(end_cnt_yolp_dndm)
    cnt_yolp_dndm <= 0;
  else if(add_cnt_yolp_dndm)
    cnt_yolp_dndm <= cnt_yolp_dndm + 1;
end

assign add_cnt_yolp_dndm = (tile_switch == 1) && (nn_proc == 0);// && tile_loc[1] == 0;
assign end_cnt_yolp_dndm = add_cnt_yolp_dndm && (cnt_yolp_dndm == tile_tot_num_x);

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_yolp_sr <= 0;
  else if(tile_loc_r[1] == 1 && nn_proc == 1)
    cnt_yolp_sr <= 0;
  else if(end_cnt_yolp_sr)
    cnt_yolp_sr <= 0;
  else if(add_cnt_yolp_sr)
    cnt_yolp_sr <= cnt_yolp_sr + 1;
end

assign add_cnt_yolp_sr = (tile_switch == 1) && (nn_proc == 1);// && tile_loc[1] == 0;
assign end_cnt_yolp_sr = add_cnt_yolp_sr && (cnt_yolp_sr == tile_tot_num_x);

/******************************************************************************/
/*********************************** other design *****************************/
/******************************************************************************/

//----------------------------- addr_yolp_tile design ------------------------//
// 1. addr_yolp_tile : the base addr without addr related to Layer and ic
// 2. the proc0 or proc1 means dndm or sr
// 3. the L1, L234, L5 mean layer 1,2,3,4,5. calculate base ksize, if ksize == 3, split
//    one addr to left and right, so two tile plus one if ksize == 3, becase layer 1
//    ic < 4, so every add_addr_yolp_tile +1, and layer 2,3,4 ksize == 3, ic == 16,
//    so every add_addr_yolp_tile +2, because every addr can store 8 ic. and l5 every
//    add_addr_yolp_tile +4(ksize == 5, ic == 16)

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_tile_proc0_l1 <= 0;
  else if(nn_proc == 1)
    addr_yolp_tile_proc0_l1 <= addr_yolp_tile_proc0_l1;
  else if(end_addr_yolp_tile)
    addr_yolp_tile_proc0_l1 <= (tile_loc[1] == 1) ? 0 : 1; // the initial addr is 1, return 1 when not top tile
  else if(add_addr_yolp_tile)                              // and -1 in the later process
    addr_yolp_tile_proc0_l1 <= addr_yolp_tile_proc0_l1 + 1;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_tile_proc1_l1 <= 0;
  else if(nn_proc == 0)
    addr_yolp_tile_proc1_l1 <= addr_yolp_tile_proc1_l1;
  else if(end_addr_yolp_tile)
    addr_yolp_tile_proc1_l1 <= (tile_loc[1] == 1) ? 0 : 1;
  else if(add_addr_yolp_tile)
    addr_yolp_tile_proc1_l1 <= addr_yolp_tile_proc1_l1 + 1;
end


always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_tile_proc0_l234 <= 0;
  else if(nn_proc == 1)
    addr_yolp_tile_proc0_l234 <= addr_yolp_tile_proc0_l234;
  else if(end_addr_yolp_tile)
    addr_yolp_tile_proc0_l234 <= (tile_loc[1] == 1) ? 0 : 2;
  else if(add_addr_yolp_tile)
    addr_yolp_tile_proc0_l234 <= addr_yolp_tile_proc0_l234 + 2;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_tile_proc1_l234 <= 0;
  else if(nn_proc == 0)
    addr_yolp_tile_proc1_l234 <= addr_yolp_tile_proc1_l234;
  else if(end_addr_yolp_tile)
    addr_yolp_tile_proc1_l234 <= (tile_loc[1] == 1) ? 0 : 2;
  else if(add_addr_yolp_tile)
    addr_yolp_tile_proc1_l234 <= addr_yolp_tile_proc1_l234 + 2;
end


always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_tile_proc0_l5 <= 0;
  else if(nn_proc == 1)
    addr_yolp_tile_proc0_l5 <= addr_yolp_tile_proc0_l5;
  else if(end_addr_yolp_tile)
    addr_yolp_tile_proc0_l5 <= (tile_loc[1] == 1) ? 0 : 4;
  else if(add_addr_yolp_tile)
    addr_yolp_tile_proc0_l5 <= addr_yolp_tile_proc0_l5 + 4;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_tile_proc1_l5 <= 0;
  else if(nn_proc == 0)
    addr_yolp_tile_proc1_l5 <= addr_yolp_tile_proc1_l5;
  else if(end_addr_yolp_tile)
    addr_yolp_tile_proc1_l5 <= (tile_loc[1] == 1) ? 0 : 4;
  else if(add_addr_yolp_tile)
    addr_yolp_tile_proc1_l5 <= addr_yolp_tile_proc1_l5 + 4;
end


always @(*) begin
  case(cnt_layer)
    3'b001: addr_yolp_tile_proc0 = addr_yolp_tile_proc0_l1;
    3'b010, 3'b011, 3'b100: addr_yolp_tile_proc0 = addr_yolp_tile_proc0_l234 - 1;
    //3'b101: addr_yolp_tile_proc0 = cur_state == IDLE ? addr_yolp_tile_proc0_l1 : addr_yolp_tile_proc0_l5 - 3;
    3'b101: addr_yolp_tile_proc0 = addr_yolp_tile_proc0_l5 - 3;
    default: addr_yolp_tile_proc0 = addr_yolp_tile_proc0_l1;
  endcase
end

always @(*) begin
  case(cnt_layer)
    3'b001: addr_yolp_tile_proc1 = addr_yolp_tile_proc1_l1;
    3'b010, 3'b011, 3'b100: addr_yolp_tile_proc1 = addr_yolp_tile_proc1_l234 - 1;
    //3'b101: addr_yolp_tile_proc1 = cur_state == IDLE ? addr_yolp_tile_proc1_l1 : addr_yolp_tile_proc1_l5 - 3;
    3'b101: addr_yolp_tile_proc1 = addr_yolp_tile_proc1_l5 - 3;
    default: addr_yolp_tile_proc1 = addr_yolp_tile_proc1_l1;
  endcase
end

assign cnt_yolp = nn_proc ? cnt_yolp_sr : cnt_yolp_dndm;
//assign add_addr_yolp_tile = tile_switch == 1 && tile_loc_pre[1] == 0;
assign add_addr_yolp_tile = tile_switch == 1 && tile_loc[1] == 0;
assign end_addr_yolp_tile = (tile_loc[1] == 1) || ((cnt_yolp == tile_tot_num_x) && tile_switch);

assign addr_yolp_tile_w = nn_proc == 0 ? addr_yolp_tile_proc0 : addr_yolp_tile_proc1;
// we need know the later addr_yolp_tile in current tile, so some condition, we will +1 for addr
assign addr_yolp_tile = addr_yolp_tile_w > 0 ? (cur_state == IDLE && cnt_layer_r == 5 ? (addr_yolp_tile_w == tile_tot_num_x + 1 ? 0 : addr_yolp_tile_w) : addr_yolp_tile_w - 1) : 0;


always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    cnt_layer_r <= 0;
  else
    cnt_layer_r <= cnt_layer;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    tile_loc_r <= 0;
  else
    tile_loc_r <= tile_loc;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    tile_loc_pre <= 0;
  else if(tile_loc_r != tile_loc)
    tile_loc_pre <= tile_loc_r;
end


//------------------------------- addr_xyolp_tile design ------------------------------//

// ====================================================================================
// 1. addr_xyolp_tile : the base addr without addr related to Layer and ic
// 2. the proc0 or proc1 means dndm or sr
// 3. evn and odd means evn buffer and odd buffer, the first tile of one feature write
//    data into evn buffer, addr == 0
// 4. the L1, L234, L5 mean layer 1,2,3,4,5. calculate base ksize, if ksize == 3, split
//    one addr to left and right, so two tile plus one if ksize == 3
// ====================================================================================

//****************************** evn *****************************/
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc0_L1 <= 0;
  else if(nn_proc == 1) //unchange if sr
    addr_xyolp_tile_evn_proc0_L1 <= addr_xyolp_tile_evn_proc0_L1;
  else if(end_addr_xyolp_tile_evn) //return rd addr to 0
    addr_xyolp_tile_evn_proc0_L1 <= 0;
  else if(add_addr_xyolp_tile_evn) //add ic/4 every tile, num_curf_i == floor(ic/4)
    addr_xyolp_tile_evn_proc0_L1 <= addr_xyolp_tile_evn_proc0_L1 + 1;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc0_L234 <= 0;
  else if(nn_proc == 1)
    addr_xyolp_tile_evn_proc0_L234 <= addr_xyolp_tile_evn_proc0_L234;
  else if(end_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc0_L234 <= 0;
  else if(add_addr_xyolp_tile_evn) 
    // add ic/8 every tile, num_curf_i == floor(ic/4)
    // because one addr can store 2 ic
    addr_xyolp_tile_evn_proc0_L234 <= addr_xyolp_tile_evn_proc0_L234 + 2;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc0_L5 <= 0;
  else if(nn_proc == 1)
    addr_xyolp_tile_evn_proc0_L5 <= addr_xyolp_tile_evn_proc0_L5;
  else if(end_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc0_L5 <= 0;
  else if(add_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc0_L5 <= addr_xyolp_tile_evn_proc0_L5 + 4;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc1_L1 <= 0;
  else if(nn_proc == 0) //unchange if sr
    addr_xyolp_tile_evn_proc1_L1 <= addr_xyolp_tile_evn_proc1_L1;
  else if(end_addr_xyolp_tile_evn) //return rd addr to 0
    addr_xyolp_tile_evn_proc1_L1 <= 0;
  else if(add_addr_xyolp_tile_evn) //add ic/4 every tile, num_curf_i == floor(ic/4)
    addr_xyolp_tile_evn_proc1_L1 <= addr_xyolp_tile_evn_proc1_L1 + 1;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc1_L234 <= 0;
  else if(nn_proc == 0)
    addr_xyolp_tile_evn_proc1_L234 <= addr_xyolp_tile_evn_proc1_L234;
  else if(end_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc1_L234 <= 0;
  else if(add_addr_xyolp_tile_evn) 
    // add ic/8 every tile, num_curf_i == floor(ic/4)
    // because one addr can store 2 ic
    addr_xyolp_tile_evn_proc1_L234 <= addr_xyolp_tile_evn_proc1_L234 + 2;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc1_L5 <= 0;
  else if(nn_proc == 0)
    addr_xyolp_tile_evn_proc1_L5 <= addr_xyolp_tile_evn_proc1_L5;
  else if(end_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc1_L5 <= 0;
  else if(add_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc1_L5 <= addr_xyolp_tile_evn_proc1_L5 + 4;
end

always @(*) begin
  case(cnt_layer)
    3'b001: begin
      addr_xyolp_tile_evn_proc0 = addr_xyolp_tile_evn_proc0_L1;
      addr_xyolp_tile_evn_proc1 = addr_xyolp_tile_evn_proc1_L1;
    end
    3'b010, 3'b011, 3'b100: begin
      addr_xyolp_tile_evn_proc0 = addr_xyolp_tile_evn_proc0_L234;
      addr_xyolp_tile_evn_proc1 = addr_xyolp_tile_evn_proc1_L234;
    end
    3'b101: begin
      addr_xyolp_tile_evn_proc0 = addr_xyolp_tile_evn_proc0_L5;
      addr_xyolp_tile_evn_proc1 = addr_xyolp_tile_evn_proc1_L5;
    end
    default: begin
      addr_xyolp_tile_evn_proc0 = addr_xyolp_tile_evn_proc0_L1;
      addr_xyolp_tile_evn_proc1 = addr_xyolp_tile_evn_proc1_L1;
    end
  endcase
end

assign add_addr_xyolp_tile_evn = (tile_switch == 1 && tile_state == 1); //start add from tile11
assign end_addr_xyolp_tile_evn = (tile_loc[1] == 1) || (add_addr_xyolp_tile_evn && (addr_xyolp_tile_evn_end_w == (tile_tot_num_x >> 1))); //end if tile cnt add to (n >> 1)

assign addr_xyolp_tile_evn_proc0_w = (cnt_layer == 1 && add_addr_xyolp_tile_evn == 1) ? (addr_xyolp_tile_evn_proc0_L1 == (tile_tot_num_x >> 1) ? 0 : addr_xyolp_tile_evn_proc0 + 1) : addr_xyolp_tile_evn_proc0;
assign addr_xyolp_tile_evn_proc1_w = (cnt_layer == 1 && add_addr_xyolp_tile_evn == 1) ? (addr_xyolp_tile_evn_proc1_L1 == (tile_tot_num_x >> 1) ? 0 : addr_xyolp_tile_evn_proc1 + 1) : addr_xyolp_tile_evn_proc1;

assign addr_xyolp_tile_evn_end_w = nn_proc == 0 ? addr_xyolp_tile_evn_proc0 : addr_xyolp_tile_evn_proc1;
assign addr_xyolp_tile_evn = nn_proc == 0 ? addr_xyolp_tile_evn_proc0_w : addr_xyolp_tile_evn_proc1_w;

/*********************** odd *********************************/
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc0_L1 <= 0;
  else if(nn_proc == 1) //unchange if dndm
    addr_xyolp_tile_odd_proc0_L1 <= addr_xyolp_tile_odd_proc0_L1;
  else if(end_addr_xyolp_tile_odd) //return rd addr to 0
    addr_xyolp_tile_odd_proc0_L1 <= 0;
  else if(add_addr_xyolp_tile_odd) //add ic/4 every tile, num_curf_i == floor(ic/4)
    addr_xyolp_tile_odd_proc0_L1 <= addr_xyolp_tile_odd_proc0_L1 + 1;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc0_L234 <= 0;
  else if(nn_proc == 1)
    addr_xyolp_tile_odd_proc0_L234 <= addr_xyolp_tile_odd_proc0_L234;
  else if(end_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc0_L234 <= 0;
  else if(add_addr_xyolp_tile_odd) 
    // add ic/8 every tile, num_curf_i == floor(ic/4)
    // because one addr can store 2 ic
    addr_xyolp_tile_odd_proc0_L234 <= addr_xyolp_tile_odd_proc0_L234 + 2;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc0_L5 <= 0;
  else if(nn_proc == 1)
    addr_xyolp_tile_odd_proc0_L5 <= addr_xyolp_tile_odd_proc0_L5;
  else if(end_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc0_L5 <= 0;
  else if(add_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc0_L5 <= addr_xyolp_tile_odd_proc0_L5 + 4;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc1_L1 <= 0;
  else if(nn_proc == 0) //unchange if sr
    addr_xyolp_tile_odd_proc1_L1 <= addr_xyolp_tile_odd_proc1_L1;
  else if(end_addr_xyolp_tile_odd) //return rd addr to 0
    addr_xyolp_tile_odd_proc1_L1 <= 0;
  else if(add_addr_xyolp_tile_odd) //add ic/4 every tile, num_curf_i == floor(ic/4)
    addr_xyolp_tile_odd_proc1_L1 <= addr_xyolp_tile_odd_proc1_L1 + 1;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc1_L234 <= 0;
  else if(nn_proc == 0)
    addr_xyolp_tile_odd_proc1_L234 <= addr_xyolp_tile_odd_proc1_L234;
  else if(end_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc1_L234 <= 0;
  else if(add_addr_xyolp_tile_odd) 
    // add ic/8 every tile, num_curf_i == floor(ic/4)
    // because one addr can store 2 ic
    addr_xyolp_tile_odd_proc1_L234 <= addr_xyolp_tile_odd_proc1_L234 + 2;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc1_L5 <= 0;
  else if(nn_proc == 0)
    addr_xyolp_tile_odd_proc1_L5 <= addr_xyolp_tile_odd_proc1_L5;
  else if(end_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc1_L5 <= 0;
  else if(add_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc1_L5 <= addr_xyolp_tile_odd_proc1_L5 + 4;
end

always @(*) begin
  case(cnt_layer)
    3'b001: begin
      addr_xyolp_tile_odd_proc0 = addr_xyolp_tile_odd_proc0_L1;
      addr_xyolp_tile_odd_proc1 = addr_xyolp_tile_odd_proc1_L1;
    end
    3'b010, 3'b011, 3'b100: begin
      addr_xyolp_tile_odd_proc0 = addr_xyolp_tile_odd_proc0_L234;
      addr_xyolp_tile_odd_proc1 = addr_xyolp_tile_odd_proc1_L234;
    end
    3'b101: begin
      addr_xyolp_tile_odd_proc0 = addr_xyolp_tile_odd_proc0_L5;
      addr_xyolp_tile_odd_proc1 = addr_xyolp_tile_odd_proc1_L5;
    end
    default: begin
      addr_xyolp_tile_odd_proc0 = addr_xyolp_tile_odd_proc0_L1;
      addr_xyolp_tile_odd_proc1 = addr_xyolp_tile_odd_proc1_L1;
    end
  endcase
end
// ===================================================================================================
// the logic addr_xyolp_tilr return to 0
// ----------------------------------------------------------------------------------------------------
// the odd condition , e.g tile_tot_num_x == 5
//      ____      ____           ____      ____           ____
// ____|    |____|    |____|____|    |____|    |____|____|    |____  -> tile_state_r/tile_state
//     | <- 0 -> | <- 1 -> |    | <- 2 -> | <- 0 -> |          ->(the addr of odd buffer)
// |   <-      line0   ->  |    <-   line1     ->   |          -> num of tile
// ----------------------------------------------------------------------------------------------------
// the evn condition , e.g tile_tot_num_x == 6
//      ____      ____      ____      ____      ____      ____      ____
// ____|    |____|    |____|    |____|    |____|    |____|    |____|    |____  > tile_state_r/tile_state
//     | <- 0 -> | <- 1 -> |    2    | <- 3 -> | <- 0 -> |         | <- 0 -> | ->(the addr of odd buffer)
// |   <-      line0   ->       |    <-   line2     ->   |          -> num of tile
// ----------------------------------------------------------------------------------------------------
// so the add condition
// 1. tile_switch == 1
// 2. not the left tile of the second line for the odd condition, (tile_loc_pre[1] != 1)
//    not the left tile for the evn condition, because have been +1 in right tile of last line
//    tile_state_r == 0
// 3. not the right tile for the odd condition, but evn condition, tile_state_r == 1 && lst tile, 
// ===================================================================================================


assign add_addr_xyolp_tile_odd = (tile_loc_r[1] == 0) && (tile_switch == 1) && ((tile_state_r == 1 && tile_loc_r[2] == 1)
                                 || ((tile_state_r == 1'b0) && (tile_tot_num_x[0] == 1 ? (tile_loc_pre[1] != 1 && tile_loc_r[2] != 1) : (tile_loc_r[3] != 1)))); //start add from tile11
assign end_addr_xyolp_tile_odd = (tile_loc[1] == 1) || (add_addr_xyolp_tile_odd && addr_xyolp_tile_odd_end_w == (tile_tot_num_x >> 1)); //end if tile top or addr return to 0

assign addr_xyolp_tile_odd_proc0_w = cnt_layer == 1 && add_addr_xyolp_tile_odd == 1 ?
                                 (addr_xyolp_tile_odd_proc0_L1 == (tile_tot_num_x >> 1) ? 0 : addr_xyolp_tile_odd_proc0_L1 + 1)
                                 : addr_xyolp_tile_odd_proc0;
assign addr_xyolp_tile_odd_proc1_w = cnt_layer == 1 && add_addr_xyolp_tile_odd == 1 ?
                                  (addr_xyolp_tile_odd_proc1_L1 == (tile_tot_num_x >> 1) ? 0 : addr_xyolp_tile_odd_proc1_L1 + 1)
                                  :addr_xyolp_tile_odd_proc1;

assign addr_xyolp_tile_odd_end_w = nn_proc == 0 ? addr_xyolp_tile_odd_proc0 : addr_xyolp_tile_odd_proc1;

assign addr_xyolp_tile_odd = nn_proc == 0 ? addr_xyolp_tile_odd_proc0_w : addr_xyolp_tile_odd_proc1_w;
/*
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc0 <= 0;
  else if(nn_proc == 1)
    addr_xyolp_tile_evn_proc0 <= addr_xyolp_tile_evn_proc0;
  else if(end_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc0 <= 0;
  else if(add_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc0 <= addr_xyolp_tile_evn_proc0 + (ksize == 3 ? (num_curf_i + 1) >> 1 : num_curf_i);
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_evn_proc1 <= 0;
  else if(nn_proc == 0)
    addr_xyolp_tile_evn_proc1 <= addr_xyolp_tile_odd_proc1;
  else if(end_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc1 <= 0;
  else if(add_addr_xyolp_tile_evn)
    addr_xyolp_tile_evn_proc1 <= addr_xyolp_tile_evn_proc1 + (ksize == 3 ? (num_curf_i + 1) >> 1 : num_curf_i);
end

assign add_addr_xyolp_tile_evn = (tile_switch == 1 && tile_state == 1);
assign end_addr_xyolp_tile_evn = (tile_loc[1] == 1) || (cnt_yolp - 1 == tile_tot_num_x);

assign addr_xyolp_tile_evn = nn_proc == 0 ? addr_xyolp_tile_evn_proc0 : addr_xyolp_tile_evn_proc1;


always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc0 <= 0;
  else if(nn_proc == 1)
    addr_xyolp_tile_odd_proc0 <= addr_xyolp_tile_evn_proc0;
  else if(end_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc0 <= 0;
  else if(add_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc0 <= addr_xyolp_tile_odd_proc0 + (ksize == 3 ? (num_curf_i + 1) >> 1 : num_curf_i);
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_tile_odd_proc1 <= 0;
  else if(nn_proc == 0)
    addr_xyolp_tile_odd_proc1 <= addr_xyolp_tile_odd_proc1;
  else if(end_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc1 <= 0;
  else if(add_addr_xyolp_tile_odd)
    addr_xyolp_tile_odd_proc1 <= addr_xyolp_tile_odd_proc1 + (ksize == 3 ? (num_curf_i + 1) >> 1 : num_curf_i);
end

assign add_addr_xyolp_tile_odd = (tile_switch == 1 && tile_state == 0);
assign end_addr_xyolp_tile_odd = (tile_loc[1] == 1) || (cnt_yolp - 1 == tile_tot_num_x);

assign addr_xyolp_tile_odd = nn_proc == 0 ? addr_xyolp_tile_odd_proc0 : addr_xyolp_tile_odd_proc1;
*/

//--------------- addr cnt layer ---------------//
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_yolp_layer <= 0;
  else if(cnt_layer == 0 || cnt_layer == 1 || cnt_layer == 2)
    addr_yolp_layer <= 0;
  else if(ctrl2sch_layer_start)
    addr_yolp_layer <= addr_yolp_layer + Y_L234_DEPTH;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xyolp_layer <= 0;
  else if(cnt_layer == 0 || cnt_layer == 1 || cnt_layer == 2)
    addr_xyolp_layer <= 0;
  else if(ctrl2sch_layer_start)
    addr_xyolp_layer <= addr_xyolp_layer + XY_L234_DEPTH;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    addr_xolp_layer <= 0;
  //else if(cnt_layer == 0)
  else if(cnt_layer == 0 || cnt_layer == 1 || cnt_layer == 2)
    addr_xolp_layer <= 0;
  else if(ctrl2sch_layer_start)
    addr_xolp_layer <= addr_xolp_layer + X_L234_DEPTH;
end

/******************************************************************************/
/*************************** interface output to sche_sub *********************/
/******************************************************************************/
assign row_start = row_start_r == 1 && sch2fe_ren != 0;
//assign row_done  = end_cnt_curf;
assign row_done  = end_cnt_curf && cur_state != IDLE;
/*
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    sch2pe_vld <= 0;
  else if(cur_state != IDLE)
    sch2pe_vld <= 1;
  else
    sch2pe_vld <= 0;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    mux_col_vld <= 0;
  else if(cur_state != IDLE) begin
    if(tile_loc[3] == 1)
      mux_col_vld <= 32'hffff_ffff >> (32 - tile_out_w);//{{tile_out_w{1'b1}},1'b1};
    else if(tile_loc[2] == 1)
      mux_col_vld <= 32'hffff_ffff << (32 - tile_out_w);
    else
      mux_col_vld <= 32'hffff_ffff;
  end
  else
    mux_col_vld <= 32'h0;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    mux_row_vld <= 0;
  else if(cur_state != IDLE) begin
    if(cnt_y == (num_y_o - 1) && tile_out_h_w[1:0] != 0)
      mux_row_vld <= 4'b1111 << (4 - tile_out_h_w[1:0]);
    else
      mux_row_vld <= 4'b1111;
  end
  else
    mux_row_vld <= 4'h0;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    mux_array_vld <= 0;
  else if(cur_state != IDLE) begin
    if(cnt_curf == (num_curf_i - 1) && tile_in_c[1:0] != 0)
      mux_array_vld <= 4'b1111 << (4 - tile_in_c[1:0]);
    else
      mux_array_vld <= 4'b1111;
  end
  else
    mux_array_vld <= 4'h0;
end*/

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    tile_state_r <= 0;
  else
    tile_state_r <= tile_state;
end


/******************************************************************************/
/******************** interface output to scheduler ***************************/
/******************************************************************************/
assign tile_state_o   = tile_state  ;
assign cnt_y_o        = cnt_y       ;
assign tile_out_h_w_o = tile_out_h_w;
assign cnt_curf_o     = cnt_curf    ;

//---------------- rd en ----------------//
assign sch2fe_ren     = cnt_ksize == 0 ? sch2fe_ren_r     : 4'b0000;
assign sch2y_ren      = cnt_ksize == 0 ? sch2y_ren_r      : 4'b0000;
assign sch2xy_evn_ren = cnt_ksize == 0 ? sch2xy_evn_ren_w : 4'b0000;
assign sch2xy_odd_ren = cnt_ksize == 0 ? sch2xy_odd_ren_w : 4'b0000;

//------------------- fea buf addr ------------//
always @(*)
begin
  sch2fe_raddr_0 = addr_base;
  sch2fe_raddr_1 = addr_base;
  sch2fe_raddr_2 = addr_base;
  sch2fe_raddr_3 = addr_base;
  case(addr_offset)
    1: begin
      sch2fe_raddr_0 = over_load > (cur_state != ADDR_PLUS && tile_loc[0] == 1 ? 0 : 2) ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + 1;
      sch2fe_raddr_1 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + 1;
      sch2fe_raddr_2 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + 1;
      sch2fe_raddr_3 = over_load > (cur_state != ADDR_PLUS && tile_loc[0] == 1 ? 1 : 2) ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
    end
    2: begin
      sch2fe_raddr_0 = over_load > (cur_state != ADDR_PLUS && tile_loc[0] == 1 ? 1 : 2) ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + 1;
      sch2fe_raddr_1 = over_load > (cur_state != ADDR_PLUS && tile_loc[0] == 1 ? 0 : 2) ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + 1;
      sch2fe_raddr_2 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
      sch2fe_raddr_3 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
    end
    3: begin
      sch2fe_raddr_0 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + 1;
      sch2fe_raddr_1 = over_load > (cur_state != ADDR_PLUS && tile_loc[0] == 1 ? 1 : 2) ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
      sch2fe_raddr_2 = over_load > (cur_state != ADDR_PLUS && tile_loc[0] == 1 ? 0 : 2) ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
      sch2fe_raddr_3 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
    end
    4: begin
      sch2fe_raddr_0 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
      sch2fe_raddr_1 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
      sch2fe_raddr_2 = over_load > 1 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
      sch2fe_raddr_3 = over_load > 0 ? {FE_ADDR_WIDTH{1'b1}} : addr_base;
    end
  endcase
end

//--------------- xolp buf read addr -----------//
always @(*)
begin
  sch2x_raddr_0 = addr_base;
  sch2x_raddr_1 = addr_base;
  sch2x_raddr_2 = addr_base;
  sch2x_raddr_3 = addr_base;
  case(addr_offset)
    1: begin
      sch2x_raddr_0 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + addr_xolp_layer + 1;
      sch2x_raddr_1 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + addr_xolp_layer + 1;
      sch2x_raddr_2 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + addr_xolp_layer + 1;
      sch2x_raddr_3 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
    end
    2: begin
      sch2x_raddr_0 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + addr_xolp_layer + 1;
      sch2x_raddr_1 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + addr_xolp_layer + 1;
      sch2x_raddr_2 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
      sch2x_raddr_3 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
    end
    3: begin
      sch2x_raddr_0 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + (cur_state == IC_PLUS4 ? addr_ic_r : 0) + addr_xolp_layer + 1;
      sch2x_raddr_1 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
      sch2x_raddr_2 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
      sch2x_raddr_3 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
    end
    4: begin
      sch2x_raddr_0 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
      sch2x_raddr_1 = over_load > 2 ? {FE_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
      sch2x_raddr_2 = over_load > 1 ? {X_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
      sch2x_raddr_3 = over_load > 0 ? {X_ADDR_WIDTH{1'b1}} : addr_base + addr_xolp_layer;
    end
  endcase
end

//--------------- yolp and xyolp buf read addr -------------//
assign sch2y_raddr = addr_yolp_base + addr_yolp_layer;
assign sch2xy_raddr_evn = addr_xyolp_base_evn + addr_xyolp_layer;
assign sch2xy_raddr_odd = addr_xyolp_base_odd + addr_xyolp_layer;

assign wt_buf_rd_addr = cnt_wt_addr >> 3;

always@(*)
begin
  wt_buf_rd_en = 0;
  case(cnt_wt_addr[2:0])
    0: wt_buf_rd_en = 8'b1000_0000;
    1: wt_buf_rd_en = 8'b0100_0000;
    2: wt_buf_rd_en = 8'b0010_0000;
    3: wt_buf_rd_en = 8'b0001_0000;
    4: wt_buf_rd_en = 8'b0000_1000;
    5: wt_buf_rd_en = 8'b0000_0100;
    6: wt_buf_rd_en = 8'b0000_0010;
    7: wt_buf_rd_en = 8'b0000_0001;
  endcase
end

// -----------------------------------------------------//
assign tile_in_h_w = tile_in_h + (tile_loc[1] == 1 ? 0 : ksize - 1);
assign tile_out_h_w = tile_out_h;
assign num_curf_i  = (tile_in_c >> 2) + (|tile_in_c[1:0]);
assign num_kurf_o  = (tile_out_c >> 2) + (|tile_out_c[1:0]);
//assign num_y_i     = (tile_in_h_w >> 2) + (|tile_in_h_w[1:0]);
assign num_y_i     = 8;
assign num_y_o     = (tile_out_h_w >> 2) + (|tile_out_h_w[1:0]);
assign padding_num = ksize >> 1;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    num_y_curf_r <= 0;
  else if(cur_state == ADDR_INIT)
    num_y_curf_r <= num_y_i;
  else if(end_cnt_curf)
    num_y_curf_r <= num_y_i;
  else if(add_cnt_curf)
    num_y_curf_r <= num_y_curf_r + num_y_i;
  else
    num_y_curf_r <= num_y_curf_r;
end

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    row_start_r <= 1;
  else if(row_done)
    row_start_r <= 1;
  else if(row_start_r == 1 && sch2fe_ren != 0)
    row_start_r <= 0;
  else
    row_start_r <= row_start_r;
end

endmodule