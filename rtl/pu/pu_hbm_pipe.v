/*************************************************************************
    > File Name: pu_hbm_pipe.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:   combine prelu & requant 
 ************************************************************************/

module  pu_hbm_pipe #(
    parameter HBM_IN_WD         = 20    ,
    parameter HBM_PARAM_WD     = 16     ,  
    parameter HBM_MUL_WD       = 36    , 
    parameter HBM_OUT_WD        = 8     ,
    parameter PE_COL_NUM        = 32    
)(

    input                                                                  clk                         ,
    input                                                                  rstn                        ,

    //  1h 4oc per cycles
    //  oc_h
    input                                                                   hbm_vld_i                   ,
    output                                                                  hbm_rdy_o                   ,   
    input  [4 -1 : 0]                                                       layer_cnt_i                 ,

    input    [6                                    -1: 0]                   pu_hbm_shift_i              ,        
    input                                                                   pu_prelu_en_i               ,              
                
    input    [HBM_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc0_i                  ,  // one row of oc0
    input    [HBM_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc1_i                  ,  // one row of oc1
    input    [HBM_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc2_i                  ,  // one row of oc2
    input    [HBM_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc3_i                  ,  // one row of oc3
            
    input    [HBM_PARAM_WD                         -1: 0]                  hbm_para_oc0_i              ,
    input    [HBM_PARAM_WD                         -1: 0]                  hbm_para_oc1_i              ,
    input    [HBM_PARAM_WD                         -1: 0]                  hbm_para_oc2_i              ,
    input    [HBM_PARAM_WD                         -1: 0]                  hbm_para_oc3_i              ,  

    output                                                                  hbm_vld_o                   ,
    input                                                                   hbm_rdy_i                   ,
 
    output   [HBM_OUT_WD  * PE_COL_NUM              -1: 0]                 hbm_oc0_o                   ,
    output   [HBM_OUT_WD  * PE_COL_NUM              -1: 0]                 hbm_oc1_o                   ,
    output   [HBM_OUT_WD  * PE_COL_NUM              -1: 0]                 hbm_oc2_o                   ,
    output   [HBM_OUT_WD  * PE_COL_NUM              -1: 0]                 hbm_oc3_o               

);


//-----------------------------

//  WIRE & REG               

//  

//-----------------------------


    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          hbm_mul_oc0_w            ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          hbm_mul_oc1_w            ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          hbm_mul_oc2_w            ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          hbm_mul_oc3_w            ;

    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             prelu_mux_c_0_w                 ;
    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             prelu_mux_c_1_w                 ;
    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             prelu_mux_c_2_w                 ;
    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             prelu_mux_c_3_w                 ;

    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             pipe_00_c_0_dat_r              ;
    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             pipe_00_c_1_dat_r              ; 
    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             pipe_00_c_2_dat_r              ; 
    reg     [HBM_IN_WD * PE_COL_NUM               -1: 0]             pipe_00_c_3_dat_r              ;                                                                
 
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_0_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_1_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_2_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_3_dat_w                ;

    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_0_dat_r                ;
    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_1_dat_r                ;
    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_2_dat_r                ;
    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_3_dat_r                ;

    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_0_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_1_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_2_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_3_dat_w                ;

    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_0_dat_r                ;
    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_1_dat_r                ;
    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_2_dat_r                ;
    reg     [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_3_dat_r                ;

    wire    [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_0_dat_w                ;
    wire    [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_1_dat_w                ;
    wire    [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_2_dat_w                ;
    wire    [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_3_dat_w                ;

    reg     [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_0_dat_r                ;
    reg     [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_1_dat_r                ;
    reg     [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_2_dat_r                ;
    reg     [HBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_3_dat_r                ;
genvar i;


generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:IN_MUX_0_3
        always @(*)begin
            if(pu_prelu_en_i)begin
                prelu_mux_c_0_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc0_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: 1] ? 'd0 : conv_oc0_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
                prelu_mux_c_1_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc1_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: 1] ? 'd0 : conv_oc1_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
                prelu_mux_c_2_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc2_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: 1] ? 'd0 : conv_oc2_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
                prelu_mux_c_3_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc3_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: 1] ? 'd0 : conv_oc3_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
          
            end
            else begin
                prelu_mux_c_0_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc0_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
                prelu_mux_c_1_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc1_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
                prelu_mux_c_2_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc2_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];
                prelu_mux_c_3_w[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD] = conv_oc3_i[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD];

             end
        end
    end
endgenerate

//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC0

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC0

        pu_mul #(
            .INPUT_WD1(HBM_IN_WD       ),
            .INPUT_WD2(HBM_PARAM_WD    ),
            .OUTPUT_WD(HBM_MUL_WD      )
        )
        pu_relu_mul_oc0(
            .op1_i(pipe_00_c_0_dat_r[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD]                  ) ,
            .op2_i(hbm_para_oc0_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(hbm_mul_oc0_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]            )
        );
        assign pipe_0_c_0_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] = hbm_mul_oc0_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] ;

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC1

//----------------------------------------------------------------------------------------------------------
generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC1

        pu_mul #(
            .INPUT_WD1(HBM_IN_WD       ),
            .INPUT_WD2(HBM_PARAM_WD    ),
            .OUTPUT_WD(HBM_MUL_WD      )
        )
        pu_relu_mul_oc1(
            .op1_i(pipe_00_c_1_dat_r[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD]                  ) ,
            .op2_i(hbm_para_oc1_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(hbm_mul_oc1_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]            )
        );
        assign pipe_0_c_1_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] = hbm_mul_oc1_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] ;

    end

endgenerate



//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC2

//----------------------------------------------------------------------------------------------------------
generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC2

        pu_mul #(
            .INPUT_WD1(HBM_IN_WD       ),
            .INPUT_WD2(HBM_PARAM_WD    ),
            .OUTPUT_WD(HBM_MUL_WD      )
        )
        pu_relu_mul_oc2(
            .op1_i(pipe_00_c_2_dat_r[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD]                  ) ,
            .op2_i(hbm_para_oc2_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(hbm_mul_oc2_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]            )
        );
        assign pipe_0_c_2_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] =  hbm_mul_oc2_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] ;

    end

endgenerate


//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC3

//----------------------------------------------------------------------------------------------------------
generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC3

        pu_mul #(
            .INPUT_WD1(HBM_IN_WD       ),
            .INPUT_WD2(HBM_PARAM_WD    ),
            .OUTPUT_WD(HBM_MUL_WD      )
        )
        pu_relu_mul_oc3(
            .op1_i(pipe_00_c_3_dat_r[PE_COL_NUM * HBM_IN_WD - 1 - i * HBM_IN_WD -: HBM_IN_WD]                  ) ,
            .op2_i(hbm_para_oc3_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(hbm_mul_oc3_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]            )
        );
        assign pipe_0_c_3_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] =   hbm_mul_oc3_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] ; 

    end

endgenerate


//control path
wire      pipe_00_vld_w ;
reg       pipe_00_vld_r ;
wire      pipe_00_rdy_w ;

wire      pipe_0_vld_w ;
reg       pipe_0_vld_r ;
wire      pipe_0_rdy_w ;

wire      pipe_1_vld_w ;
reg       pipe_1_vld_r ;
wire      pipe_1_rdy_w ;

wire      pipe_2_vld_w ;
reg       pipe_2_vld_r ;
wire      pipe_2_rdy_w ;

wire      pipe_3_vld_w ;
wire      pipe_3_rdy_w ;

assign hbm_rdy_o     = pipe_00_rdy_w ;
assign pipe_00_vld_w = hbm_vld_i     ;
always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        pipe_00_vld_r <= 1'b0;
    end
    else if(pipe_00_rdy_w)begin
        pipe_00_vld_r <= pipe_00_vld_w;
    end
end
assign pipe_00_rdy_w = ~pipe_0_vld_w | pipe_0_rdy_w ;
assign pipe_0_vld_w  = pipe_00_vld_r ;


always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        pipe_0_vld_r <= 1'b0;
    end
    else if(pipe_0_rdy_w)begin
        pipe_0_vld_r <= pipe_0_vld_w ;
    end
end

assign pipe_0_rdy_w = ~pipe_1_vld_w | pipe_1_rdy_w ;
assign pipe_1_vld_w = pipe_0_vld_r ;

always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        pipe_1_vld_r <= 1'b0;
    end
    else if(pipe_1_rdy_w)begin
        pipe_1_vld_r <= pipe_1_vld_w ;
    end
end
assign pipe_1_rdy_w = ~pipe_2_vld_w | pipe_2_rdy_w ;
assign pipe_2_vld_w = pipe_1_vld_r ;

always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        pipe_2_vld_r <= 1'b0;
    end
    else if(pipe_2_rdy_w)begin
        pipe_2_vld_r <= pipe_2_vld_w ;
    end
end
assign pipe_2_rdy_w = ~pipe_3_vld_w | pipe_3_rdy_w ;
assign pipe_3_vld_w = pipe_2_vld_r ;

assign hbm_vld_o    = pipe_3_vld_w ;
assign pipe_3_rdy_w = hbm_rdy_i    ;


// data path

always @(posedge clk)begin
    if(pipe_00_vld_w & pipe_00_rdy_w)
    begin
            pipe_00_c_0_dat_r <= prelu_mux_c_0_w ;
            pipe_00_c_1_dat_r <= prelu_mux_c_1_w ; 
            pipe_00_c_2_dat_r <= prelu_mux_c_2_w ; 
            pipe_00_c_3_dat_r <= prelu_mux_c_3_w ; 
    end
end

always @(posedge clk)begin
    if(pipe_0_vld_w & pipe_0_rdy_w)
    begin
            pipe_0_c_0_dat_r <= pipe_0_c_0_dat_w ;
            pipe_0_c_1_dat_r <= pipe_0_c_1_dat_w ; 
            pipe_0_c_2_dat_r <= pipe_0_c_2_dat_w ; 
            pipe_0_c_3_dat_r <= pipe_0_c_3_dat_w ; 
    end
end


generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_0
        ArithmeticShift#(
            .DATA_WD(HBM_MUL_WD   )            
        ) shift_c0_u
        (
            .data_i (pipe_0_c_0_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .shift_i(pu_hbm_shift_i                                                              ),
            .data_o (pipe_1_c_0_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD])

        );
    end
endgenerate

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_1
        ArithmeticShift#(
            .DATA_WD(HBM_MUL_WD   )            
        )shift_c1_u
        (
            .data_i (pipe_0_c_1_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .shift_i(pu_hbm_shift_i                                                              ),
            .data_o (pipe_1_c_1_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD])

        );
    end
endgenerate

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_2
        ArithmeticShift#(
            .DATA_WD(HBM_MUL_WD   )           
        )shift_c2_u
        (
            .data_i (pipe_0_c_2_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .shift_i(pu_hbm_shift_i                                                              ),
            .data_o (pipe_1_c_2_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD])

        );
    end
endgenerate

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_3
        ArithmeticShift#(
            .DATA_WD(HBM_MUL_WD   )            
        ) shift_c3_u
        (
            .data_i (pipe_0_c_3_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .shift_i(pu_hbm_shift_i                                                              ),
            .data_o (pipe_1_c_3_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD])

        );
    end
endgenerate

//TODO: cut path between shift and sub

// SUB 128
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_0_sub_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_1_sub_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_2_sub_dat_w                ;
    wire    [HBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_3_sub_dat_w                ;

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : SUB_C_0_3
        assign pipe_1_c_0_sub_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] = layer_cnt_i == 4'd4 ? $signed(pipe_1_c_0_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128) : $signed(pipe_1_c_0_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128);
        assign pipe_1_c_1_sub_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] = layer_cnt_i == 4'd4 ? $signed(pipe_1_c_1_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128) : $signed(pipe_1_c_1_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128);
        assign pipe_1_c_2_sub_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] = layer_cnt_i == 4'd4 ? $signed(pipe_1_c_2_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128) : $signed(pipe_1_c_2_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128);
        assign pipe_1_c_3_sub_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD] = layer_cnt_i == 4'd4 ? $signed(pipe_1_c_3_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128) : $signed(pipe_1_c_3_dat_w[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]) - $signed('d128);

    end
endgenerate




always @(posedge clk)begin
    if(pipe_1_vld_w & pipe_1_rdy_w)
    begin
        pipe_1_c_0_dat_r <= pipe_1_c_0_sub_dat_w ;
        pipe_1_c_1_dat_r <= pipe_1_c_1_sub_dat_w ;
        pipe_1_c_2_dat_r <= pipe_1_c_2_sub_dat_w ;
        pipe_1_c_3_dat_r <= pipe_1_c_3_sub_dat_w ;
    end
end

generate
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1)begin:Clip_C_0_3
        ArithmeticClip#(
            .DATA_WD(HBM_MUL_WD )      ,
            .CLIP_WD(HBM_OUT_WD ) 
        )clip_c0_u
        (
            .data_i(pipe_1_c_0_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .data_o(pipe_2_c_0_dat_w[PE_COL_NUM * HBM_OUT_WD - 1 - i * HBM_OUT_WD -: HBM_OUT_WD])
        );

        ArithmeticClip#(
            .DATA_WD(HBM_MUL_WD )      ,
            .CLIP_WD(HBM_OUT_WD ) 
        )clip_c1_u
        (
            .data_i(pipe_1_c_1_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .data_o(pipe_2_c_1_dat_w[PE_COL_NUM * HBM_OUT_WD - 1 - i * HBM_OUT_WD -: HBM_OUT_WD])
        );

        ArithmeticClip#(
            .DATA_WD(HBM_MUL_WD )      ,
            .CLIP_WD(HBM_OUT_WD ) 
        )clip_c2_u
        (
            .data_i(pipe_1_c_2_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .data_o(pipe_2_c_2_dat_w[PE_COL_NUM * HBM_OUT_WD - 1 - i * HBM_OUT_WD -: HBM_OUT_WD])
        );

        ArithmeticClip#(
            .DATA_WD(HBM_MUL_WD )      ,
            .CLIP_WD(HBM_OUT_WD ) 
        )clip_c3_u
        (
            .data_i(pipe_1_c_3_dat_r[PE_COL_NUM * HBM_MUL_WD - 1 - i * HBM_MUL_WD -: HBM_MUL_WD]),
            .data_o(pipe_2_c_3_dat_w[PE_COL_NUM * HBM_OUT_WD - 1 - i * HBM_OUT_WD -: HBM_OUT_WD])
        );
    end
endgenerate


always @(posedge clk)begin
    if(pipe_2_vld_w & pipe_2_rdy_w)
    begin
        pipe_2_c_0_dat_r <= pipe_2_c_0_dat_w ;
        pipe_2_c_1_dat_r <= pipe_2_c_1_dat_w ;
        pipe_2_c_2_dat_r <= pipe_2_c_2_dat_w ;
        pipe_2_c_3_dat_r <= pipe_2_c_3_dat_w ;
    end
end

assign hbm_oc0_o = pipe_2_c_0_dat_r ;
assign hbm_oc1_o = pipe_2_c_1_dat_r ;
assign hbm_oc2_o = pipe_2_c_2_dat_r ;
assign hbm_oc3_o = pipe_2_c_3_dat_r ;


endmodule



module ArithmeticShift#(
    parameter DATA_WD  =  32            ,
    parameter SHIFT_WD = $clog2(DATA_WD)
)
(
    input  signed   [DATA_WD - 1 : 0]   data_i ,
    input           [SHIFT_WD -1 : 0]   shift_i,
    output signed  [DATA_WD - 1 : 0]   data_o

);

    wire signed  [DATA_WD - 1 : 0] data_w ;
    wire signed  [DATA_WD - 1 : 0] sft_dat_w [SHIFT_WD - 1 : 0] ;

    assign data_w = data_i + $signed(1<<(shift_i - 'd1));

    genvar i ;
    generate 
    for(i = 0 ; i  < SHIFT_WD ; i = i + 1)begin: sft_levl

        if(i ==0)begin
            assign sft_dat_w[0] = shift_i[0] ? (data_w >>> (1<<i)) : data_w ;
        end
        else begin
            assign sft_dat_w[i] = shift_i[i] ? ( sft_dat_w[i - 1] >>> (1<<i) ) : sft_dat_w[i - 1 ];
        end
    end
    endgenerate

    assign data_o = sft_dat_w[SHIFT_WD - 1] ;


endmodule

module ArithmeticClip#(
    parameter DATA_WD  =  32            ,
    parameter CLIP_WD  =  8 
)
(
    input    [DATA_WD - 1 : 0]   data_i ,
    output   [CLIP_WD - 1 : 0]   data_o

);


    wire    [CLIP_WD - 1 : 0]   pos_clip_data_w ;
    wire    [CLIP_WD - 1 : 0]   neg_clip_data_w ;

    assign neg_clip_data_w =  (& data_i[DATA_WD - 2 : CLIP_WD - 1]) ? {1'b1 , data_i[CLIP_WD - 2 : 0]} : 8'b10000000 ;
    assign pos_clip_data_w =  (| data_i[DATA_WD - 2 : CLIP_WD - 1]) ? 8'b01111111 : {1'b0 , data_i[CLIP_WD - 2 : 0]} ;

    assign data_o = data_i[DATA_WD - 1] ? neg_clip_data_w : pos_clip_data_w ;


endmodule





// function integer clog2;

// input [16 -1 : 0]  data ;

// begin
//         if(data < 2 )
//         clog2 = 1;
//         else if(data < 4)
//         clog2 = 2;
//         else if(data < 8)
//         clog2 = 3;
//         else if(data < 16)
//         clog2 = 4;
//         else if(data < 32)
//         clog2 = 5;
//         else if(data < 64)
//         clog2 = 6;
//         else if(data < 128)
//         clog2 = 7;
//         else if(data < 256)
//         clog2 = 8;
//         else if(data < 512)
//         clog2 = 9;
//         else if(data < 1024)
//         clog2 = 10;
//         else if(data < 2048)
//         clog2 = 11;
//         else if(data < 4096)
//         clog2 = 12;
//         else if(data < 16'h2000)
//         clog2 = 13;
//         else if(data < 16'h4000)
//         clog2 = 14;
//         else if(data < 16'h8000)
//         clog2 = 15;
//         else 
//         clog2 = 16;
// end
// endfunction
