/*
    Top Module:  control.v
    Author:      Hao Zhang
    Time:        202307
*/

module ctrl_engine #(
    parameter    REG_IFMH_WIDTH       = 10       ,
    parameter    REG_IFMW_WIDTH       = 10       ,
    parameter    REG_TILEH_WIDTH      = 6        ,
    parameter    REG_TNY_WIDTH        = 6        ,
    parameter    REG_TNX_WIDTH        = 6        ,
    parameter    REG_TLW_WIDTH        = 6        ,
    parameter    REG_TLH_WIDTH        = 6        ,
    parameter    TILE_BASE_W          = 32       ,
    parameter    REG_IH_WIDTH         = 6        ,
    parameter    REG_OH_WIDTH         = 6        ,
    parameter    REG_IW_WIDTH         = 6        ,
    parameter    REG_OW_WIDTH         = 6        ,
    parameter    REG_IC_WIDTH         = 6        ,
    parameter    REG_OC_WIDTH         = 6        ,
    parameter    REG_AF_WIDTH         = 1        ,
    parameter    REG_HBM_SFT_WIDTH    = 6        ,
    parameter    REG_LBM_SFT_WIDTH    = 6        
)
(
    input     wire                                       clk                 ,
    input     wire                                       rst_n               ,
    input     wire    [                  32 - 1 : 0]     ctrl_reg            ,
    output    reg     [                  32 - 1 : 0]     state_reg           ,
    input     wire    [                  32 - 1 : 0]     reg0                ,
    input     wire    [                  32 - 1 : 0]     reg1                ,
    input     wire                                       layer_done          ,
    output    wire                                       layer_start         ,
    output    wire    [                       1 : 0]     stat_ctrl           ,
    output    reg     [                       2 : 0]     cnt_layer           , 
    output    reg                                        tile_switch_r       , // layer active high
    output    reg                                        model_switch_r      , // tile active high
    output    wire                                       tile_switch         , // pulse @negedge tile_switch_r
    output    wire                                       model_switch        , // pulse @negedge model_switch_r
    output    wire                                       model_switch_layer  , // layer active high, last layer in model_switch_r tile
    output    reg                                        nn_proc             , // 0-dndm 1-sr
    output    wire    [        REG_TNX_WIDTH - 1 : 0]    tile_tot_num_x      ,
    output    wire    [         REG_IH_WIDTH - 1 : 0]    tile_in_h           ,
    output    wire    [         REG_OH_WIDTH - 1 : 0]    tile_out_h          ,
    output    wire    [         REG_IW_WIDTH - 1 : 0]    tile_in_w           ,
    output    wire    [         REG_OW_WIDTH - 1 : 0]    tile_out_w          ,
    output    wire    [         REG_IC_WIDTH - 1 : 0]    tile_in_c           ,
    output    wire    [         REG_OC_WIDTH - 1 : 0]    tile_out_c          ,
    output    wire    [                        2 : 0]    ksize               ,
    output    wire    [                        2 : 0]    ksize_nxt           ,
    output    wire    [                        3 : 0]    tile_loc            ,
    output    wire                                       x4_shuffle_vld      ,
    output    wire    [         REG_AF_WIDTH - 1 : 0]    prl_vld             ,
    output    wire    [                        1 : 0]    res_proc_type       ,
    output    wire    [    REG_HBM_SFT_WIDTH - 1 : 0]    pu_hbm_shift        ,
    output    wire    [    REG_LBM_SFT_WIDTH - 1 : 0]    pu_lbm_shift        ,
    output    reg                                        buf_pp_flag         
);

    wire    [   REG_IFMH_WIDTH - 1 : 0]     ifm_h             ;
    wire    [   REG_IFMW_WIDTH - 1 : 0]     ifm_w             ;
    wire    [  REG_TILEH_WIDTH - 1 : 0]     tile_base_h       ;
    wire    [    REG_TNY_WIDTH - 1 : 0]     tile_tot_num_y    ;
    wire    [    REG_TLW_WIDTH - 1 : 0]     tile_last_w       ;
    wire    [    REG_TLH_WIDTH - 1 : 0]     tile_last_h       ;
    wire    [REG_HBM_SFT_WIDTH - 1 : 0]     pu_hbm_shift_dndm ;
    wire    [REG_HBM_SFT_WIDTH - 1 : 0]     pu_hbm_shift_sr   ;
    wire    [REG_LBM_SFT_WIDTH - 1 : 0]     pu_lbm_shift_dndm ;
    wire    [REG_LBM_SFT_WIDTH - 1 : 0]     pu_lbm_shift_sr   ;
    reg     [    REG_TNY_WIDTH - 1 : 0]     tile_cnt_y_0      ; //dndm
    reg     [    REG_TNX_WIDTH - 1 : 0]     tile_cnt_x_0      ; //dndm
    reg     [    REG_TNY_WIDTH - 1 : 0]     tile_cnt_y_1      ; //sr
    reg     [    REG_TNX_WIDTH - 1 : 0]     tile_cnt_x_1      ; //sr
    reg                                     layer_start_d     ;
    reg                                     tile_switch_r_d   ;
    reg                                     model_switch_r_d  ;

assign stat_ctrl          = ctrl_reg[1:0]                                                                   ;
assign ifm_h              = reg0[9:0]                                                                       ;
assign ifm_w              = reg0[19:10]                                                                     ;
assign tile_base_h        = reg1[5:0]                                                                       ;
assign tile_tot_num_y     = reg1[11:6]                                                                      ;
assign tile_tot_num_x     = reg1[17:12]                                                                     ;
assign tile_last_w        = reg1[23:18]                                                                     ;
assign tile_last_h        = reg1[29:24]                                                                     ;
assign layer_start        = layer_start_d                                                                   ;
assign tile_switch        = (~tile_switch_r) & tile_switch_r_d                                              ;
assign model_switch       = (~model_switch_r) & model_switch_r_d                                            ;
assign ksize              = (cnt_layer == 1 || cnt_layer == 5) ? 'd5 : 'd3                                  ;
assign ksize_nxt          = (cnt_layer == 4 || cnt_layer == 5) ? 'd5 : 'd3                                  ;
assign x4_shuffle_vld     = (nn_proc == 1 && cnt_layer == 5) ? 1'b0 : 1'b0                                  ;
assign prl_vld            = (cnt_layer == 5) ? 1'b0 : 1'b1                                                  ;
assign res_proc_type      = (cnt_layer == 1) ? 2'b01 :
                            (cnt_layer == 4) ? 2'b10 : 2'b00                                                ;
assign model_switch_layer = (cnt_layer == 5) && model_switch_r                                              ;
assign tile_loc[3]        = (nn_proc == 0 && tile_cnt_x_0 == 0) || (nn_proc == 1 && tile_cnt_x_1 == 0)                                      ; //left
assign tile_loc[2]        = (nn_proc == 0 && tile_cnt_x_0 == tile_tot_num_x - 1) || (nn_proc == 1 && tile_cnt_x_1 == tile_tot_num_x - 1)    ; //right
assign tile_loc[1]        = (nn_proc == 0 && tile_cnt_y_0 == 0) || (nn_proc == 1 && tile_cnt_y_1 == 0)                                      ; //top
assign tile_loc[0]        = (nn_proc == 0 && tile_cnt_y_0 == tile_tot_num_y - 1) || (nn_proc == 1 && tile_cnt_y_1 == tile_tot_num_y - 1)    ; //bottom

assign pu_hbm_shift_dndm  = (cnt_layer == 1) ? 'h18 :
                            (cnt_layer == 2) || (cnt_layer == 3) || (cnt_layer == 4) ? 'h16 :'h19           ;

//assign pu_hbm_shift_sr    = (cnt_layer == 1 || cnt_layer == 2 || cnt_layer == 3) ? 'h17 :
//                            (cnt_layer == 4)                                     ? 'h15 : 'h19              ;  
reg     [REG_HBM_SFT_WIDTH - 1 : 0]     pu_hbm_shift_sr_comb   ;
always @(cnt_layer)begin
    case(cnt_layer)
    3'd1:pu_hbm_shift_sr_comb = 'h16;
    3'd2:pu_hbm_shift_sr_comb = 'h15;
    3'd3:pu_hbm_shift_sr_comb = 'h16;
    3'd4:pu_hbm_shift_sr_comb = 'h14;
    3'd5:pu_hbm_shift_sr_comb = 'h15;
    default:pu_hbm_shift_sr_comb ='h0;
    endcase
end

assign pu_hbm_shift_sr    = pu_hbm_shift_sr_comb                                                            ;  
assign pu_hbm_shift       = nn_proc ? pu_hbm_shift_sr : pu_hbm_shift_dndm                                   ;

assign pu_lbm_shift_dndm  = 'h10                                                                            ; 
assign pu_lbm_shift_sr    = 'h11                                                                            ;
assign pu_lbm_shift       = nn_proc ? pu_lbm_shift_sr : pu_lbm_shift_dndm                                   ;

assign tile_in_c          = (nn_proc == 0 && cnt_layer == 1) ? 'd3 :
                            (nn_proc == 1 && cnt_layer == 1) ? 'd1 : 'd16                                   ;
assign tile_out_c         = (nn_proc == 0 && cnt_layer == 5) ? 'd3 : 'd16                                   ;
assign tile_in_w          = (tile_loc[3] == 1) ? ((cnt_layer == 1) ? TILE_BASE_W     :
                                                  (cnt_layer == 2) ? TILE_BASE_W - 2 :
                                                  (cnt_layer == 3) ? TILE_BASE_W - 3 :
                                                  (cnt_layer == 4) ? TILE_BASE_W - 4 : TILE_BASE_W - 5) :
                            (tile_loc[2] == 1) ? ((cnt_layer == 1) ? tile_last_w     :
                                                  (cnt_layer == 2) ? tile_last_w + 2 :
                                                  (cnt_layer == 3) ? tile_last_w + 3 :
                                                  (cnt_layer == 4) ? tile_last_w + 4 : tile_last_w + 5) : TILE_BASE_W;
assign tile_out_w         = (tile_loc[3] == 1) ? ((cnt_layer == 1) ? TILE_BASE_W - 2 :
                                                  (cnt_layer == 2) ? TILE_BASE_W - 3 :
                                                  (cnt_layer == 3) ? TILE_BASE_W - 4 :
                                                  (cnt_layer == 4) ? TILE_BASE_W - 5 : TILE_BASE_W - 7) :
                            (tile_loc[2] == 1) ? ((cnt_layer == 1) ? tile_last_w + 2 :
                                                  (cnt_layer == 2) ? tile_last_w + 3 :
                                                  (cnt_layer == 3) ? tile_last_w + 4 :
                                                  (cnt_layer == 4) ? tile_last_w + 5 : tile_last_w + 7) : TILE_BASE_W;
assign tile_in_h          = (tile_loc[1] == 1) ? ((cnt_layer == 1) ? tile_base_h     :
                                                  (cnt_layer == 2) ? tile_base_h - 2 :
                                                  (cnt_layer == 3) ? tile_base_h - 3 :
                                                  (cnt_layer == 4) ? tile_base_h - 4 : tile_base_h - 5) :
                            (tile_loc[0] == 1) ? ((cnt_layer == 1) ? tile_last_h     :
                                                  (cnt_layer == 2) ? tile_last_h + 2 :
                                                  (cnt_layer == 3) ? tile_last_h + 3 :
                                                  (cnt_layer == 4) ? tile_last_h + 4 : tile_last_h + 5) : tile_base_h;
assign tile_out_h         = (tile_loc[1] == 1) ? ((cnt_layer == 1) ? tile_base_h - 2 :
                                                  (cnt_layer == 2) ? tile_base_h - 3 :
                                                  (cnt_layer == 3) ? tile_base_h - 4 :
                                                  (cnt_layer == 4) ? tile_base_h - 5 : tile_base_h - 7) :
                            (tile_loc[0] == 1) ? ((cnt_layer == 1) ? tile_last_h + 2 :
                                                  (cnt_layer == 2) ? tile_last_h + 3 :
                                                  (cnt_layer == 3) ? tile_last_h + 4 :
                                                  (cnt_layer == 4) ? tile_last_h + 5 : tile_last_h + 7) : tile_base_h;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        tile_cnt_x_0 <= 0;
    else if(nn_proc == 0 && layer_done && tile_switch_r)
        tile_cnt_x_0 <= (tile_cnt_x_0 == tile_tot_num_x - 1) ? 0 : tile_cnt_x_0 + 1;
    else
        tile_cnt_x_0 <= tile_cnt_x_0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        tile_cnt_y_0 <= 0;
    else if(nn_proc == 0 && layer_done && tile_switch_r)
        tile_cnt_y_0 <= (tile_cnt_x_0 == tile_tot_num_x - 1) ? tile_cnt_y_0 + 1 : tile_cnt_y_0;
    else
        tile_cnt_y_0 <= tile_cnt_y_0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        tile_cnt_x_1 <= 0;
    else if(nn_proc == 1 && layer_done && tile_switch_r)
        tile_cnt_x_1 <= (tile_cnt_x_1 == tile_tot_num_x - 1) ? 0 : tile_cnt_x_1 + 1;
    else
        tile_cnt_x_1 <= tile_cnt_x_1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        tile_cnt_y_1 <= 0;
    else if(nn_proc == 1 && layer_done && tile_switch_r)
        tile_cnt_y_1 <= (tile_cnt_x_1 == tile_tot_num_x - 1) ? tile_cnt_y_1 + 1 : tile_cnt_y_1;
    else
        tile_cnt_y_1 <= tile_cnt_y_1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        tile_switch_r <= 0;
    else if(layer_done && cnt_layer == 4)
        tile_switch_r <= 1;
    else if(layer_done && cnt_layer == 5)
        tile_switch_r <= 0;
    else
        tile_switch_r <= tile_switch_r;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        model_switch_r <= 0;
    else if(layer_done && cnt_layer == 5 && (((tile_cnt_x_0 == tile_tot_num_x - 2) && ((tile_cnt_y_0[0] == 1) || (tile_cnt_y_0 == tile_tot_num_y - 1))) || ((tile_cnt_x_1 == tile_tot_num_x - 2) && ((tile_cnt_y_1[0] == 1) || (tile_cnt_y_1 == tile_tot_num_y - 1)))))
        model_switch_r <= 1;
    else if(layer_done && cnt_layer == 5 && (((tile_cnt_x_0 == tile_tot_num_x - 1) && ((tile_cnt_y_0[0] == 1) || (tile_cnt_y_0 == tile_tot_num_y - 1))) || ((tile_cnt_x_1 == tile_tot_num_x - 1) && ((tile_cnt_y_1[0] == 1) || (tile_cnt_y_1 == tile_tot_num_y - 1)))))
        model_switch_r <= 0;
    else
        model_switch_r <= model_switch_r;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        layer_start_d <= 0;
    else if(cnt_layer == 5 && tile_cnt_x_1 == tile_tot_num_x - 1 && tile_cnt_y_1 == tile_tot_num_y - 1)
        layer_start_d <= 0;
    else
        layer_start_d <= (ctrl_reg[1:0] == 2'b11) || layer_done;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        tile_switch_r_d  <= 0;
        model_switch_r_d <= 0;
    end
    else begin
        tile_switch_r_d  <= tile_switch_r;
        model_switch_r_d <= model_switch_r;
    end
end

always@(posedge clk or negedge rst_n)begin //layer_cnt 1 ~ 5
    if(!rst_n)
        cnt_layer <= 1;
    else if(layer_done && tile_switch_r)
        cnt_layer <= 1;
    else if(layer_done && !tile_switch_r)
        cnt_layer <= cnt_layer + 1;
    else
        cnt_layer <= cnt_layer;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        nn_proc <= 0;
    else if(layer_done && model_switch_layer)
        nn_proc <= ~nn_proc;
    else
        nn_proc <= nn_proc;
end
 //modify when tb
/*
always@(posedge clk or negedge rst_n)begin		
    if(!rst_n)		
        nn_proc <= 0;		
    else if(layer_done && model_switch_layer)		
        nn_proc <= 1;		
    else		
        nn_proc <= 1;		
end*/
// top dla fsm
localparam  IDLE = 1'b0;
localparam  CMPT = 1'b1;

reg    cur_state;
reg    next_state;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cur_state <= IDLE;
    else
        cur_state <= next_state;
end

always@(*)begin
    case(cur_state)
        IDLE:begin
            if(ctrl_reg[1:0] == 2'b11)
                next_state = CMPT;
            else 
                next_state = IDLE;
        end
        CMPT:begin
            if(ctrl_reg[1:0] == 2'b01 || ((tile_cnt_x_1 == tile_tot_num_x - 1) && (tile_cnt_y_1 == tile_tot_num_y - 1) && (cnt_layer == 5) && layer_done))
                next_state = IDLE;
            else 
                next_state = CMPT;
        end
        default:
                next_state = IDLE;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state_reg[1:0]  <= 2'b01;
    else
        case(next_state)
            IDLE:begin
                state_reg[1:0] <= 2'b01;
            end
            CMPT:begin
                state_reg[1:0] <= 2'b11;
            end
            default:begin
                state_reg[1:0] <= 2'b01;
            end
        endcase
end

// weight & param buf ping-pong fsm
localparam    A0      = 2'b00;
localparam    SP0_A1  = 2'b01;
localparam    A0_SP1  = 2'b11;

reg  [1:0]    cur_state_0;
reg  [1:0]    next_state_0;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cur_state_0 <= A0;
    else
        cur_state_0 <= next_state_0;
end

always@(*)begin
    case(cur_state_0)
        A0:begin
            if(stat_ctrl == 2'b10)
                next_state_0 = SP0_A1;
            else 
                next_state_0 = A0;
        end
        SP0_A1:begin
            if(layer_done && model_switch_layer)
                next_state_0 = A0_SP1;
            else
                next_state_0 = SP0_A1;
        end
        A0_SP1:begin
            if(layer_done && model_switch_layer)
                next_state_0 = SP0_A1;
            else
                next_state_0 = A0_SP1;
        end
        default:
            next_state_0 = A0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        buf_pp_flag <= 0;
    else begin
        case(cur_state_0)
            A0:
                buf_pp_flag <= 0;
            SP0_A1:
                buf_pp_flag <= 1;
            A0_SP1:
                buf_pp_flag <= 0;
            default:
                buf_pp_flag <= 0;
        endcase
    end
end

endmodule