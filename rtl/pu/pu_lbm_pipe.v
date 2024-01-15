/*************************************************************************
    > File Name: pu_lbm_pipe.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:   combine prelu & requant 
 ************************************************************************/

module  pu_lbm_pipe #(
    parameter LBM_IN_WD         = 11    ,
    parameter LBM_PARAM_WD     = 16     ,  
    parameter LBM_MUL_WD       = 27    , 
    parameter LBM_OUT_WD        = 8     ,
    parameter PE_COL_NUM        = 32    
)(

    input                                                                  clk                         ,
    input                                                                  rstn                        ,

    //  1h 4oc per cycles
    //  oc_h
    input                                                                   lbm_vld_i                   ,
    output                                                                  lbm_rdy_o                   ,        

    input    [5                                   -1: 0]                   pu_lbm_shift_i              ,   
    input                                                                  is_bypass_i                ,                   
                
    input    [LBM_IN_WD * PE_COL_NUM               -1: 0]                  lbm_oc0_i                  ,  // one row of oc0
    input    [LBM_IN_WD * PE_COL_NUM               -1: 0]                  lbm_oc1_i                  ,  // one row of oc1
    input    [LBM_IN_WD * PE_COL_NUM               -1: 0]                  lbm_oc2_i                  ,  // one row of oc2
    input    [LBM_IN_WD * PE_COL_NUM               -1: 0]                  lbm_oc3_i                  ,  // one row of oc3
            
    input    [LBM_PARAM_WD                         -1: 0]                  lbm_para_oc0_i              ,
    input    [LBM_PARAM_WD                         -1: 0]                  lbm_para_oc1_i              ,
    input    [LBM_PARAM_WD                         -1: 0]                  lbm_para_oc2_i              ,
    input    [LBM_PARAM_WD                         -1: 0]                  lbm_para_oc3_i              ,  

    output                                                                  lbm_vld_o                   ,
    input                                                                   lbm_rdy_i                   ,
 
    output   [LBM_OUT_WD  * PE_COL_NUM              -1: 0]                 lbm_oc0_o                   ,
    output   [LBM_OUT_WD  * PE_COL_NUM              -1: 0]                 lbm_oc1_o                   ,
    output   [LBM_OUT_WD  * PE_COL_NUM              -1: 0]                 lbm_oc2_o                   ,
    output   [LBM_OUT_WD  * PE_COL_NUM              -1: 0]                 lbm_oc3_o               

);


//-----------------------------

//  WIRE & REG               

//  

//-----------------------------


    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          lbm_mul_oc0_w                   ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          lbm_mul_oc1_w                   ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          lbm_mul_oc2_w                   ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          lbm_mul_oc3_w                   ;

 
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_0_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_1_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_2_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_3_dat_w                ;

    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_0_dat_r                ;
    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_1_dat_r                ;
    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_2_dat_r                ;
    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_0_c_3_dat_r                ;

    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_0_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_1_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_2_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_3_dat_w                ;

    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_0_dat_r                ;
    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_1_dat_r                ;
    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_2_dat_r                ;
    reg     [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_3_dat_r                ;

    wire    [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_0_dat_w                ;
    wire    [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_1_dat_w                ;
    wire    [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_2_dat_w                ;
    wire    [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_3_dat_w                ;

    reg     [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_0_dat_r                ;
    reg     [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_1_dat_r                ;
    reg     [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_2_dat_r                ;
    reg     [LBM_OUT_WD * PE_COL_NUM                 -1: 0]          pipe_2_c_3_dat_r                ;
genvar i;


//----------------------------------------------------------------------------------------------------------

//                      LBM MUL

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:MUL_OC0

        pu_mul #(
            .INPUT_WD1(LBM_IN_WD       ),
            .INPUT_WD2(LBM_PARAM_WD    ),
            .OUTPUT_WD(LBM_MUL_WD      )
        )
        pu_lbm_mul_oc0(
            .op1_i(lbm_oc0_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]                   ) ,
            .op2_i(lbm_para_oc0_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(lbm_mul_oc0_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]            )
        );
       // assign pipe_0_c_0_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = lbm_oc0_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD]                    ? 
       //                                                                                         {{LBM_PARAM_WD{1'b1}}, lbm_oc0_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]   }  :
       //                                                                                          lbm_mul_oc0_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] ;

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                      LBM MUL

//----------------------------------------------------------------------------------------------------------
generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:MUL_OC1

        pu_mul #(
            .INPUT_WD1(LBM_IN_WD       ),
            .INPUT_WD2(LBM_PARAM_WD    ),
            .OUTPUT_WD(LBM_MUL_WD      )
        )
        pu_lbm_mul_oc1(
            .op1_i(lbm_oc1_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]                   ) ,
            .op2_i(lbm_para_oc1_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(lbm_mul_oc1_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]            )
        );
       // assign pipe_0_c_1_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = lbm_oc1_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD]                    ? 
       //                                                                                         {{LBM_PARAM_WD{1'b1}}, lbm_oc1_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]   }  :
       //                                                                                          lbm_mul_oc1_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] ;

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                        LBM MUL

//----------------------------------------------------------------------------------------------------------
generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:MUL_OC2

        pu_mul #(
            .INPUT_WD1(LBM_IN_WD       ),
            .INPUT_WD2(LBM_PARAM_WD    ),
            .OUTPUT_WD(LBM_MUL_WD      )
        )
        pu_lbm_mul_oc2(
            .op1_i(lbm_oc2_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]                   ) ,
            .op2_i(lbm_para_oc2_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(lbm_mul_oc2_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]            )
        );
        //assign pipe_0_c_2_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = lbm_oc2_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD]                    ? 
        //                                                                                        {{LBM_PARAM_WD{1'b1}}, lbm_oc2_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]   }  :
        //                                                                                         lbm_mul_oc2_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] ;
    end
endgenerate



//----------------------------------------------------------------------------------------------------------

//                       LBM MUL

//----------------------------------------------------------------------------------------------------------
generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:MUL_OC3

        pu_mul #(
            .INPUT_WD1(LBM_IN_WD       ),
            .INPUT_WD2(LBM_PARAM_WD    ),
            .OUTPUT_WD(LBM_MUL_WD      )
        )
        pu_lbm_mul_oc3(
            .op1_i(lbm_oc3_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]                   ) ,
            .op2_i(lbm_para_oc3_i                                                                       ) ,      //fanout to 32 mul
            .mul_o(lbm_mul_oc3_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]            )
        );
        //assign pipe_0_c_3_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = lbm_oc3_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD]                    ? 
        //                                                                                        {{LBM_PARAM_WD{1'b1}}, lbm_oc3_i[PE_COL_NUM * LBM_IN_WD - 1 - i * LBM_IN_WD -: LBM_IN_WD]   }  :
        //                                                                                         lbm_mul_oc3_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] ;

    end

endgenerate   

    assign pipe_0_c_0_dat_w = lbm_mul_oc0_w ;
    assign pipe_0_c_1_dat_w = lbm_mul_oc1_w ;
    assign pipe_0_c_2_dat_w = lbm_mul_oc2_w ;
    assign pipe_0_c_3_dat_w = lbm_mul_oc3_w ;

//control path
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


assign  lbm_rdy_o    = pipe_0_rdy_w ;
assign  pipe_0_vld_w = lbm_vld_i    ;


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

assign lbm_vld_o    = pipe_3_vld_w ;
assign pipe_3_rdy_w = lbm_rdy_i    ;


// data path
always @(posedge clk)begin
    if(pipe_0_vld_w & pipe_0_rdy_w)
    begin
            pipe_0_c_0_dat_r <= is_bypass_i ? {{(LBM_MUL_WD - LBM_IN_WD) * PE_COL_NUM{1'b0}}, lbm_oc0_i} : pipe_0_c_0_dat_w ;
            pipe_0_c_1_dat_r <= is_bypass_i ? {{(LBM_MUL_WD - LBM_IN_WD) * PE_COL_NUM{1'b0}}, lbm_oc1_i}  :pipe_0_c_1_dat_w ; 
            pipe_0_c_2_dat_r <= is_bypass_i ? {{(LBM_MUL_WD - LBM_IN_WD) * PE_COL_NUM{1'b0}}, lbm_oc2_i}  :pipe_0_c_2_dat_w ; 
            pipe_0_c_3_dat_r <= is_bypass_i ? {{(LBM_MUL_WD - LBM_IN_WD) * PE_COL_NUM{1'b0}}, lbm_oc3_i}  :pipe_0_c_3_dat_w ; 
    end
end


generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_0
        ArithmeticShift#(
            .DATA_WD(LBM_MUL_WD   )            
        ) shift_c0_u
        (
            .data_i (pipe_0_c_0_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .shift_i(pu_lbm_shift_i                                                              ),
            .data_o (pipe_1_c_0_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD])

        );
    end
endgenerate

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_1
        ArithmeticShift#(
            .DATA_WD(LBM_MUL_WD   )            
        )shift_c1_u
        (
            .data_i (pipe_0_c_1_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .shift_i(pu_lbm_shift_i                                                              ),
            .data_o (pipe_1_c_1_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD])

        );
    end
endgenerate

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_2
        ArithmeticShift#(
            .DATA_WD(LBM_MUL_WD   )           
        )shift_c2_u
        (
            .data_i (pipe_0_c_2_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .shift_i(pu_lbm_shift_i                                                              ),
            .data_o (pipe_1_c_2_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD])

        );
    end
endgenerate

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : Shift_C_3
        ArithmeticShift#(
            .DATA_WD(LBM_MUL_WD   )            
        )shift_c3_u
        (
            .data_i (pipe_0_c_3_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .shift_i(pu_lbm_shift_i                                                              ),
            .data_o (pipe_1_c_3_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD])

        );
    end
endgenerate

//SUB 128
//TODO: cut path between shift and sub

// SUB 128
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_0_sub_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_1_sub_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_2_sub_dat_w                ;
    wire    [LBM_MUL_WD * PE_COL_NUM                 -1: 0]          pipe_1_c_3_sub_dat_w                ;

generate 
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1 ) begin : SUB_C_0_3
        assign pipe_1_c_0_sub_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = $signed(pipe_1_c_0_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]) - $signed('d128);
        assign pipe_1_c_1_sub_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = $signed(pipe_1_c_1_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]) - $signed('d128);
        assign pipe_1_c_2_sub_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = $signed(pipe_1_c_2_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]) - $signed('d128);
        assign pipe_1_c_3_sub_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD] = $signed(pipe_1_c_3_dat_w[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]) - $signed('d128);

    end
endgenerate




always @(posedge clk)begin
    if(pipe_1_vld_w & pipe_1_rdy_w)
    begin
        pipe_1_c_0_dat_r <= is_bypass_i ? pipe_0_c_0_dat_r : pipe_1_c_0_sub_dat_w ;
        pipe_1_c_1_dat_r <= is_bypass_i ? pipe_0_c_1_dat_r : pipe_1_c_1_sub_dat_w ;
        pipe_1_c_2_dat_r <= is_bypass_i ? pipe_0_c_2_dat_r : pipe_1_c_2_sub_dat_w ;
        pipe_1_c_3_dat_r <= is_bypass_i ? pipe_0_c_3_dat_r : pipe_1_c_3_sub_dat_w ;
    end
end

generate
    for(i = 0 ; i < PE_COL_NUM ; i = i + 1)begin:Clip_C_0_3
        ArithmeticClip#(
            .DATA_WD(LBM_MUL_WD )      ,
            .CLIP_WD(LBM_OUT_WD ) 
        )clip_c0_u
        (
            .data_i(pipe_1_c_0_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .data_o(pipe_2_c_0_dat_w[PE_COL_NUM * LBM_OUT_WD - 1 - i * LBM_OUT_WD -: LBM_OUT_WD])
        );

        ArithmeticClip#(
            .DATA_WD(LBM_MUL_WD )      ,
            .CLIP_WD(LBM_OUT_WD ) 
        )clip_c1_u
        (
            .data_i(pipe_1_c_1_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .data_o(pipe_2_c_1_dat_w[PE_COL_NUM * LBM_OUT_WD - 1 - i * LBM_OUT_WD -: LBM_OUT_WD])
        );

        ArithmeticClip#(
            .DATA_WD(LBM_MUL_WD )      ,
            .CLIP_WD(LBM_OUT_WD ) 
        )clip_c2_u
        (
            .data_i(pipe_1_c_2_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .data_o(pipe_2_c_2_dat_w[PE_COL_NUM * LBM_OUT_WD - 1 - i * LBM_OUT_WD -: LBM_OUT_WD])
        );

        ArithmeticClip#(
            .DATA_WD(LBM_MUL_WD )      ,
            .CLIP_WD(LBM_OUT_WD ) 
        )clip_c3_u
        (
            .data_i(pipe_1_c_3_dat_r[PE_COL_NUM * LBM_MUL_WD - 1 - i * LBM_MUL_WD -: LBM_MUL_WD]),
            .data_o(pipe_2_c_3_dat_w[PE_COL_NUM * LBM_OUT_WD - 1 - i * LBM_OUT_WD -: LBM_OUT_WD])
        );
    end
endgenerate


always @(posedge clk)begin
    if(pipe_2_vld_w & pipe_2_rdy_w)
    begin
        pipe_2_c_0_dat_r <= is_bypass_i ? pipe_1_c_0_dat_r[PE_COL_NUM * LBM_OUT_WD - 1 : 0] : pipe_2_c_0_dat_w ;
        pipe_2_c_1_dat_r <= is_bypass_i ? pipe_1_c_1_dat_r[PE_COL_NUM * LBM_OUT_WD - 1 : 0] : pipe_2_c_1_dat_w ;
        pipe_2_c_2_dat_r <= is_bypass_i ? pipe_1_c_2_dat_r[PE_COL_NUM * LBM_OUT_WD - 1 : 0] : pipe_2_c_2_dat_w ;
        pipe_2_c_3_dat_r <= is_bypass_i ? pipe_1_c_3_dat_r[PE_COL_NUM * LBM_OUT_WD - 1 : 0] : pipe_2_c_3_dat_w ;
    end
end

assign lbm_oc0_o = pipe_2_c_0_dat_r ;
assign lbm_oc1_o = pipe_2_c_1_dat_r ;
assign lbm_oc2_o = pipe_2_c_2_dat_r ;
assign lbm_oc3_o = pipe_2_c_3_dat_r ;


endmodule


/*
module ArithmeticShift#(
    parameter DATA_WD  =  32            ,
    parameter SHIFT_WD = clog2(DATA_WD)
)
(
    input    [DATA_WD - 1 : 0]   data_i ,
    input    [SHIFT_WD -1 : 0]   shift_i,
    output   [DATA_WD - 1 : 0]   data_o

);


    wire   [DATA_WD - 1 : 0] sft_dat_w [SHIFT_WD - 1 : 0] ;

    genvar i ;
    generate 
    for(i = 0 ; i  < SHIFT_WD ; i = i + 1)begin: sft_levl

        if(i ==0)begin
            assign sft_dat_w[0] = shishift_ift[0] ? (data_i >>> (1<<i)) : data_i ;
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

    assign neg_clip_data_w =  (& data_i[DATA_WD - 2 : CLIP_WD - 1]) ? {1'b1 : data_i[CLIP_WD - 2 : 0]} : 8'b10000000 ;
    assign pos_clip_data_w =  (| data_i[DATA_WD - 2 : CLIP_WD - 1]) ? 8'b01111111 : {1'b0 : data_i[CLIP_WD - 2 : 0]} ;

    assign data_o = data_i[DATA_WD - 1] ? pos_clip_data_w : neg_clip_data_w ;


endmodule





function integer clog2;

input [16 -1 : 0]  data ;

begin
        if(data < 2 )
        clog2 = 1;
        else if(data < 4)
        clog2 = 2;
        else if(data < 8)
        clog2 = 3;
        else if(data < 16)
        clog2 = 4;
        else if(data < 32)
        clog2 = 5;
        else if(data < 64)
        clog2 = 6;
        else if(data < 128)
        clog2 = 7;
        else if(data < 256)
        clog2 = 8;
        else if(data < 512)
        clog2 = 9;
        else if(data < 1024)
        clog2 = 10;
        else if(data < 2048)
        clog2 = 11;
        else if(data < 4096)
        clog2 = 12;
        else if(data < 16'h2000)
        clog2 = 13;
        else if(data < 16'h4000)
        clog2 = 14;
        else if(data < 16'h8000)
        clog2 = 15;
        else 
        clog2 = 16;
end
endfunction
*/