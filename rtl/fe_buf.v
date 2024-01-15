/*
    Top Module:  fe_buf.v
    Author:      Hao Zhang
    Time:        202307
*/

module fe_buf#(
    parameter    FE_ADDR_WIDTH       = 6                ,
    parameter    FE_BUF_DEPTH        = 32               ,
    parameter    FE_BUF_WIDTH        = 32*8             ,
    parameter    AXI2F_DATA_WIDTH    = 1024             ,
    parameter    AXI2F_ADDR_WIDTH    = FE_ADDR_WIDTH + 2, // 2 bit MSB for buf-grouping: 00:_0_x/01:_1_x/10:_2_x/11:_3_x grp
    parameter    KNOB_REGOUT         = 0
)
(
    input   wire     clk                                                    ,
    input   wire     rst_n                                                  ,
    // control
    input   wire                                           layer_done       ,
    input   wire                                           tile_switch_r    ,
    input   wire     [                      1 : 0]         stat_ctrl        ,
    // axi
    input   wire     [   AXI2F_ADDR_WIDTH - 1 : 0]         axi2f_waddr      ,
    input   wire                                           axi2f_wen        ,
    input   wire     [   AXI2F_DATA_WIDTH - 1 : 0]         axi2f_wdata      ,
    input   wire     [   AXI2F_ADDR_WIDTH - 1 : 0]         axi2f_raddr      ,
    input   wire                                           axi2f_ren        ,
    output  wire     [   AXI2F_DATA_WIDTH - 1 : 0]         axi2f_rdata      ,
    // buf_rd
    input   wire     [                  4 - 1 : 0]         sch2fe_ren       ,
    input   wire     [      FE_ADDR_WIDTH - 1 : 0]         sch2fe_raddr_0   ,   //_x_0 grp
    input   wire     [      FE_ADDR_WIDTH - 1 : 0]         sch2fe_raddr_1   ,   //_x_1 grp
    input   wire     [      FE_ADDR_WIDTH - 1 : 0]         sch2fe_raddr_2   ,   //_x_2 grp
    input   wire     [      FE_ADDR_WIDTH - 1 : 0]         sch2fe_raddr_3   ,   //_x_3 grp
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_0_0 , //_c_row
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_0_1 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_0_2 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_0_3 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_1_0 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_1_1 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_1_2 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_1_3 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_2_0 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_2_1 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_2_2 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_2_3 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_3_0 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_3_1 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_3_2 ,
    output  wire     [       FE_BUF_WIDTH - 1 : 0]         fe2sch_rdata_3_3 ,
    // buf_wr
    input   wire     [                 16 - 1 : 0]         pu2fe_wen        ,
    input   wire     [      FE_ADDR_WIDTH - 1 : 0]         pu2fe_waddr      ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_0_0  , //_c_row
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_0_1  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_0_2  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_0_3  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_1_0  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_1_1  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_1_2  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_1_3  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_2_0  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_2_1  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_2_2  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_2_3  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_3_0  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_3_1  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_3_2  ,
    input   wire     [       FE_BUF_WIDTH - 1 : 0]         pu2fe_wdata_3_3  
);

    localparam                         ROW_GRP_NUM  = 4;
    localparam                         CH_GRP_NUM   = 4;

    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe0_waddr;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe0_wen;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe0_wdata;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe0_raddr;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe0_ren;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe0_rdata;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe1_waddr;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe1_wen;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe1_wdata;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe1_raddr;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe1_ren;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe1_rdata;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2_waddr;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2_wen;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2_wdata;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2_raddr;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2_ren;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2_rdata;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    axi2f_waddr_w;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    axi2f_wen_w;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    axi2f_wdata_w;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    axi2f_raddr_w;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    axi2f_ren_w;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    axi2f_rdata_w;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    pu2fe_wdata_w;
    wire    [ FE_ADDR_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    sch2fe_raddr_w;
    wire    [               CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    sch2fe_ren_w;
    wire    [  FE_BUF_WIDTH*CH_GRP_NUM*ROW_GRP_NUM - 1 : 0]    fe2sch_rdata_w;
    reg     [                                    2 - 1 : 0]    axi2f_raddr_d;

// 3-ping-pong fsm
localparam    A0        = 3'b000;
localparam    S0_P1_A2  = 3'b001;
localparam    P0_S1_A2  = 3'b010;
localparam    P0_A1_S2  = 3'b011;
localparam    A0_P1_S2  = 3'b100;
localparam    S0_A1_P2  = 3'b101;
localparam    A0_S1_P2  = 3'b110;

reg    [2:0]    cur_state;
reg    [2:0]    next_state;
reg    [2:0]    axi2f_flag;
reg    [2:0]    pu2f_flag;
reg    [2:0]    sch2f_flag;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cur_state <= A0;
    else
        cur_state <= next_state;
end

always@(*)begin
    case(cur_state)
        A0:begin
            if(stat_ctrl == 2'b11)
                next_state = S0_P1_A2;
            else 
                next_state = A0;
        end
        S0_P1_A2:begin
            if(layer_done && !tile_switch_r)
                next_state = P0_S1_A2;
            else if(layer_done && tile_switch_r) 
                next_state = P0_A1_S2;
            else
                next_state = S0_P1_A2;
        end
        P0_S1_A2:begin
            if(layer_done && !tile_switch_r)
                next_state = S0_P1_A2;
            else if(layer_done && tile_switch_r) 
                next_state = A0_P1_S2;
            else
                next_state = P0_S1_A2;
        end
        P0_A1_S2:begin
            if(layer_done && !tile_switch_r)
                next_state = S0_A1_P2;
            else if(layer_done && tile_switch_r) 
                next_state = A0_S1_P2;
            else
                next_state = P0_A1_S2;
        end
        A0_P1_S2:begin
            if(layer_done && !tile_switch_r)
                next_state = A0_S1_P2;
            else if(layer_done && tile_switch_r) 
                next_state = S0_A1_P2;
            else
                next_state = A0_P1_S2;
        end
        S0_A1_P2:begin
            if(layer_done && !tile_switch_r)
                next_state = P0_A1_S2;
            else if(layer_done && tile_switch_r) 
                next_state = P0_S1_A2;
            else
                next_state = S0_A1_P2;
        end
        A0_S1_P2:begin
            if(layer_done && !tile_switch_r)
                next_state = A0_P1_S2;
            else if(layer_done && tile_switch_r) 
                //next_state = P0_A1_S2;
                next_state = S0_P1_A2;
            else
                //next_state = S0_P1_A2;
                next_state = A0_S1_P2;
        end
        default:
            next_state = A0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        axi2f_flag <= 0;
        pu2f_flag  <= 0;
        sch2f_flag <= 0;
    end
    else begin
        case(cur_state)
            A0:
                axi2f_flag <= 3'b001;
            S0_P1_A2:begin
                axi2f_flag <= 3'b100;
                pu2f_flag  <= 3'b010;
                sch2f_flag <= 3'b001;
            end
            P0_S1_A2:begin
                axi2f_flag <= 3'b100;
                pu2f_flag  <= 3'b001;
                sch2f_flag <= 3'b010;
            end
            P0_A1_S2:begin
                axi2f_flag <= 3'b010;
                pu2f_flag  <= 3'b001;
                sch2f_flag <= 3'b100;
            end
            A0_P1_S2:begin
                axi2f_flag <= 3'b001;
                pu2f_flag  <= 3'b010;
                sch2f_flag <= 3'b100;
            end
            S0_A1_P2:begin
                axi2f_flag <= 3'b010;
                pu2f_flag  <= 3'b100;
                sch2f_flag <= 3'b001;
            end
            A0_S1_P2:begin
                axi2f_flag <= 3'b001;
                pu2f_flag  <= 3'b100;
                sch2f_flag <= 3'b010;
            end
            default:begin
                axi2f_flag <= 0;
                pu2f_flag  <= 0;
                sch2f_flag <= 0;
            end
        endcase
    end
end

//input & output data-pack for 16 sub-bufs in 1 ping-pong buf
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        axi2f_raddr_d <= 0;
    else
        axi2f_raddr_d <= axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2];
end

assign fe2sch_rdata_0_0 = fe2sch_rdata_w[ 1*FE_BUF_WIDTH - 1 :  0*FE_BUF_WIDTH];
assign fe2sch_rdata_0_1 = fe2sch_rdata_w[ 2*FE_BUF_WIDTH - 1 :  1*FE_BUF_WIDTH];
assign fe2sch_rdata_0_2 = fe2sch_rdata_w[ 3*FE_BUF_WIDTH - 1 :  2*FE_BUF_WIDTH];
assign fe2sch_rdata_0_3 = fe2sch_rdata_w[ 4*FE_BUF_WIDTH - 1 :  3*FE_BUF_WIDTH];
assign fe2sch_rdata_1_0 = fe2sch_rdata_w[ 5*FE_BUF_WIDTH - 1 :  4*FE_BUF_WIDTH];
assign fe2sch_rdata_1_1 = fe2sch_rdata_w[ 6*FE_BUF_WIDTH - 1 :  5*FE_BUF_WIDTH];
assign fe2sch_rdata_1_2 = fe2sch_rdata_w[ 7*FE_BUF_WIDTH - 1 :  6*FE_BUF_WIDTH];
assign fe2sch_rdata_1_3 = fe2sch_rdata_w[ 8*FE_BUF_WIDTH - 1 :  7*FE_BUF_WIDTH];
assign fe2sch_rdata_2_0 = fe2sch_rdata_w[ 9*FE_BUF_WIDTH - 1 :  8*FE_BUF_WIDTH];
assign fe2sch_rdata_2_1 = fe2sch_rdata_w[10*FE_BUF_WIDTH - 1 :  9*FE_BUF_WIDTH];
assign fe2sch_rdata_2_2 = fe2sch_rdata_w[11*FE_BUF_WIDTH - 1 : 10*FE_BUF_WIDTH];
assign fe2sch_rdata_2_3 = fe2sch_rdata_w[12*FE_BUF_WIDTH - 1 : 11*FE_BUF_WIDTH];
assign fe2sch_rdata_3_0 = fe2sch_rdata_w[13*FE_BUF_WIDTH - 1 : 12*FE_BUF_WIDTH];
assign fe2sch_rdata_3_1 = fe2sch_rdata_w[14*FE_BUF_WIDTH - 1 : 13*FE_BUF_WIDTH];
assign fe2sch_rdata_3_2 = fe2sch_rdata_w[15*FE_BUF_WIDTH - 1 : 14*FE_BUF_WIDTH];
assign fe2sch_rdata_3_3 = fe2sch_rdata_w[16*FE_BUF_WIDTH - 1 : 15*FE_BUF_WIDTH];
assign axi2f_waddr_w  = {(CH_GRP_NUM*ROW_GRP_NUM){axi2f_waddr[FE_ADDR_WIDTH - 1 : 0]}};
assign axi2f_wen_w    = (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{axi2f_wen}}} :
                        (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{axi2f_wen}},
                                                                                               {ROW_GRP_NUM{1'b0}}} :
                        (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{axi2f_wen}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}}} :
                        (axi2f_waddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b11) ? {{ROW_GRP_NUM{axi2f_wen}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}}} : 0;
assign axi2f_wdata_w  = {CH_GRP_NUM{axi2f_wdata}};
//assign axi2f_wdata_w  = {CH_GRP_NUM{axi2f_wdata[0 +: (AXI2F_DATA_WIDTH >> 2)],axi2f_wdata[(AXI2F_DATA_WIDTH >> 2) +: (AXI2F_DATA_WIDTH >> 2)],axi2f_wdata[(AXI2F_DATA_WIDTH >> 2)*2 +: (AXI2F_DATA_WIDTH >> 2)],
//                        axi2f_wdata[(AXI2F_DATA_WIDTH >> 2)*3 +: (AXI2F_DATA_WIDTH >> 2)]}};
assign axi2f_raddr_w  = {(CH_GRP_NUM*ROW_GRP_NUM){axi2f_raddr[FE_ADDR_WIDTH - 1 : 0]}};
assign axi2f_ren_w    = (axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b00) ? {{ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{axi2f_ren}}} :
                        (axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b01) ? {{ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{axi2f_ren}},
                                                                                               {ROW_GRP_NUM{1'b0}}} :
                        (axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b10) ? {{ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{axi2f_ren}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}}} :
                        (axi2f_raddr[AXI2F_ADDR_WIDTH - 1 : AXI2F_ADDR_WIDTH - 2] == 2'b11) ? {{ROW_GRP_NUM{axi2f_ren}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}},
                                                                                               {ROW_GRP_NUM{1'b0}}} : 0;
assign axi2f_rdata    = (axi2f_raddr_d == 2'b00) ? axi2f_rdata_w[1*AXI2F_DATA_WIDTH - 1 : 0*AXI2F_DATA_WIDTH] :
                        (axi2f_raddr_d == 2'b01) ? axi2f_rdata_w[2*AXI2F_DATA_WIDTH - 1 : 1*AXI2F_DATA_WIDTH] :
                        (axi2f_raddr_d == 2'b10) ? axi2f_rdata_w[3*AXI2F_DATA_WIDTH - 1 : 2*AXI2F_DATA_WIDTH] :
                                                   axi2f_rdata_w[4*AXI2F_DATA_WIDTH - 1 : 3*AXI2F_DATA_WIDTH] ;
assign pu2fe_wdata_w  = {pu2fe_wdata_3_3, pu2fe_wdata_3_2, pu2fe_wdata_3_1, pu2fe_wdata_3_0,
                         pu2fe_wdata_2_3, pu2fe_wdata_2_2, pu2fe_wdata_2_1, pu2fe_wdata_2_0,
                         pu2fe_wdata_1_3, pu2fe_wdata_1_2, pu2fe_wdata_1_1, pu2fe_wdata_1_0,
                         pu2fe_wdata_0_3, pu2fe_wdata_0_2, pu2fe_wdata_0_1, pu2fe_wdata_0_0};
assign sch2fe_raddr_w = {CH_GRP_NUM{sch2fe_raddr_3, sch2fe_raddr_2, sch2fe_raddr_1, sch2fe_raddr_0}};
assign sch2fe_ren_w   = {CH_GRP_NUM{sch2fe_ren}};
//assign sch2fe_ren_w   = {CH_GRP_NUM{sch2fe_ren[0],sch2fe_ren[1],sch2fe_ren[2],sch2fe_ren[3]}};

// buffer_wr & buffer_rd
assign fe0_waddr = (  pu2f_flag == 3'b001) ? {(ROW_GRP_NUM*CH_GRP_NUM){pu2fe_waddr}} : axi2f_waddr_w;
assign fe0_wen   = (  pu2f_flag == 3'b001) ? pu2fe_wen :
                   ( axi2f_flag == 3'b001) ? axi2f_wen_w : 0;
assign fe0_wdata = (  pu2f_flag == 3'b001) ? pu2fe_wdata_w : axi2f_wdata_w;
assign fe0_raddr = ( sch2f_flag == 3'b001) ? sch2fe_raddr_w : axi2f_raddr_w;
assign fe0_ren   = ( sch2f_flag == 3'b001) ? sch2fe_ren_w :
                   ( axi2f_flag == 3'b001) ? axi2f_ren_w : 0;
assign fe1_waddr = (  pu2f_flag == 3'b010) ? {(ROW_GRP_NUM*CH_GRP_NUM){pu2fe_waddr}} : axi2f_waddr_w;
assign fe1_wen   = (  pu2f_flag == 3'b010) ? pu2fe_wen :
                   ( axi2f_flag == 3'b010) ? axi2f_wen_w : 0;
assign fe1_wdata = (  pu2f_flag == 3'b010) ? pu2fe_wdata_w : axi2f_wdata_w;
assign fe1_raddr = ( sch2f_flag == 3'b010) ? sch2fe_raddr_w : axi2f_raddr_w;
assign fe1_ren   = ( sch2f_flag == 3'b010) ? sch2fe_ren_w :
                   ( axi2f_flag == 3'b010) ? axi2f_ren_w : 0;
assign fe2_waddr = (  pu2f_flag == 3'b100) ? {(ROW_GRP_NUM*CH_GRP_NUM){pu2fe_waddr}} : axi2f_waddr_w;
assign fe2_wen   = (  pu2f_flag == 3'b100) ? pu2fe_wen :
                   ( axi2f_flag == 3'b100) ? axi2f_wen_w : 0;
assign fe2_wdata = (  pu2f_flag == 3'b100) ? pu2fe_wdata_w : axi2f_wdata_w;
assign fe2_raddr = ( sch2f_flag == 3'b100) ? sch2fe_raddr_w : axi2f_raddr_w;
assign fe2_ren   = ( sch2f_flag == 3'b100) ? sch2fe_ren_w :
                   ( axi2f_flag == 3'b100) ? axi2f_ren_w : 0;
assign fe2sch_rdata_w = ( sch2f_flag == 3'b001) ? fe0_rdata :
                        ( sch2f_flag == 3'b010) ? fe1_rdata : fe2_rdata;
assign axi2f_rdata_w  = ( axi2f_flag == 3'b001) ? fe0_rdata :
                        ( axi2f_flag == 3'b010) ? fe1_rdata : fe2_rdata;

// feature ping-pong buffer instantiation
genvar  idx_inst;

generate
    for(idx_inst = 0; idx_inst < CH_GRP_NUM * ROW_GRP_NUM; idx_inst = idx_inst + 1)begin: buf_inst
        dp_ram_regout #(
            .KNOB_REGOUT                    (KNOB_REGOUT),
            .ADDR_WIDTH                     (FE_ADDR_WIDTH),
            .DATA_WIDTH                     (FE_BUF_WIDTH),
            .DATA_DEPTH                     (FE_BUF_DEPTH)
        )
        u_fe0_buf(
            .clk                            (clk),
            .wr_addr                        (fe0_waddr[(idx_inst+1)*FE_ADDR_WIDTH - 1 : idx_inst*FE_ADDR_WIDTH]),
            .wr_en                          (fe0_wen[idx_inst]),
            .wr_data                        (fe0_wdata[(idx_inst+1)*FE_BUF_WIDTH - 1 : idx_inst*FE_BUF_WIDTH]),
            .rd_addr                        (fe0_raddr[(idx_inst+1)*FE_ADDR_WIDTH - 1 : idx_inst*FE_ADDR_WIDTH]),
            .rd_en                          (fe0_ren[idx_inst]),
            .rd_data                        (fe0_rdata[(idx_inst+1)*FE_BUF_WIDTH - 1 : idx_inst*FE_BUF_WIDTH])
        );
        dp_ram_regout #(
            .KNOB_REGOUT                    (KNOB_REGOUT),
            .ADDR_WIDTH                     (FE_ADDR_WIDTH),
            .DATA_WIDTH                     (FE_BUF_WIDTH),
            .DATA_DEPTH                     (FE_BUF_DEPTH)
        )
        u_fe1_buf(
            .clk                            (clk),
            .wr_addr                        (fe1_waddr[(idx_inst+1)*FE_ADDR_WIDTH - 1 : idx_inst*FE_ADDR_WIDTH]),
            .wr_en                          (fe1_wen[idx_inst]),
            .wr_data                        (fe1_wdata[(idx_inst+1)*FE_BUF_WIDTH - 1 : idx_inst*FE_BUF_WIDTH]),
            .rd_addr                        (fe1_raddr[(idx_inst+1)*FE_ADDR_WIDTH - 1 : idx_inst*FE_ADDR_WIDTH]),
            .rd_en                          (fe1_ren[idx_inst]),
            .rd_data                        (fe1_rdata[(idx_inst+1)*FE_BUF_WIDTH - 1 : idx_inst*FE_BUF_WIDTH])
        );
        dp_ram_regout #(
            .KNOB_REGOUT                    (KNOB_REGOUT),
            .ADDR_WIDTH                     (FE_ADDR_WIDTH),
            .DATA_WIDTH                     (FE_BUF_WIDTH),
            .DATA_DEPTH                     (FE_BUF_DEPTH)
        )
        u_fe2_buf(
            .clk                            (clk),
            .wr_addr                        (fe2_waddr[(idx_inst+1)*FE_ADDR_WIDTH - 1 : idx_inst*FE_ADDR_WIDTH]),
            .wr_en                          (fe2_wen[idx_inst]),
            .wr_data                        (fe2_wdata[(idx_inst+1)*FE_BUF_WIDTH - 1 : idx_inst*FE_BUF_WIDTH]),
            .rd_addr                        (fe2_raddr[(idx_inst+1)*FE_ADDR_WIDTH - 1 : idx_inst*FE_ADDR_WIDTH]),
            .rd_en                          (fe2_ren[idx_inst]),
            .rd_data                        (fe2_rdata[(idx_inst+1)*FE_BUF_WIDTH - 1 : idx_inst*FE_BUF_WIDTH])
        );
    end
endgenerate

endmodule