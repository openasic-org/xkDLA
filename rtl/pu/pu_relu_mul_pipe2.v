/*************************************************************************
    > File Name: pu_relu_mul_pipe2.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:
 ************************************************************************/

module  pu_relu_mul_pipe2 #(
    parameter RELU_IN_WD        = 24    ,
    parameter RELU_OUT_WD       = 24    ,
    parameter PE_COL_NUM        = 32    ,
    parameter RELU_PARAM_WD     = 8    
)(

    input                                                                  clk                         ,
    input                                                                  rstn                        ,

    //  1h 4oc per cycles
    //  oc_h
    input                                                                   pu_relu_mul_p2_vld_i        ,
    output                                                                  pu_relu_mul_p2_rdy_o        ,                              
                
    input    [RELU_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc0_i                  ,  // one row of oc0
    input    [RELU_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc1_i                  ,  // one row of oc1
    input    [RELU_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc2_i                  ,  // one row of oc2
    input    [RELU_IN_WD * PE_COL_NUM               -1: 0]                  conv_oc3_i                  ,  // one row of oc3
            
    input    [RELU_PARAM_WD                         -1: 0]                  relu_para_oc0_i             ,
    input    [RELU_PARAM_WD                         -1: 0]                  relu_para_oc1_i             ,
    input    [RELU_PARAM_WD                         -1: 0]                  relu_para_oc2_i             ,
    input    [RELU_PARAM_WD                         -1: 0]                  relu_para_oc3_i             ,  

    output                                                                  pu_relu_mul_p2_vld_o        ,
    input                                                                   pu_relu_mul_p2_rdy_i        ,
 
    output   [RELU_OUT_WD  * PE_COL_NUM              -1: 0]                 prelu_oc0_o                 ,
    output   [RELU_OUT_WD  * PE_COL_NUM              -1: 0]                 prelu_oc1_o                 ,
    output   [RELU_OUT_WD  * PE_COL_NUM              -1: 0]                 prelu_oc2_o                 ,
    output   [RELU_OUT_WD  * PE_COL_NUM              -1: 0]                 prelu_oc3_o               

);


//-----------------------------

//  WIRE & REG               

//  

//-----------------------------
    reg                                                               vld_r                      ;

    reg     [RELU_OUT_WD  * PE_COL_NUM                -1: 0]          prelu_oc0_r                ;
    reg     [RELU_OUT_WD  * PE_COL_NUM                -1: 0]          prelu_oc1_r                ;
    reg     [RELU_OUT_WD  * PE_COL_NUM                -1: 0]          prelu_oc2_r                ;
    reg     [RELU_OUT_WD  * PE_COL_NUM                -1: 0]          prelu_oc3_r                ;
 
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_oc0_w                ;
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_oc1_w                ;
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_oc2_w                ;
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_oc3_w                ;

    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_mul_oc0_w            ;
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_mul_oc1_w            ;
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_mul_oc2_w            ;
    wire    [RELU_OUT_WD * PE_COL_NUM                 -1: 0]          prelu_mul_oc3_w            ;
 




genvar i;


//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC0

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC0

        pu_mul #(
            .INPUT_WD1(RELU_IN_WD       ),
            .INPUT_WD2(RELU_PARAM_WD    ),
            .OUTPUT_WD(RELU_OUT_WD      )
        )
        pu_relu_mul_oc0(
            .op1_i(conv_oc0_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD -: RELU_IN_WD]               ) ,
            .op2_i(relu_para_oc0_i                                                                      ) ,      //fanout to 32 mul
            .mul_o(prelu_mul_oc0_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]       )
        );
        assign prelu_oc0_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] = conv_oc0_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD]                       ? 
                                                                                            prelu_mul_oc0_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] :
                                                                                            conv_oc0_i[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]      ;

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC1

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC1

        pu_mul #(
            .INPUT_WD1(RELU_IN_WD       ),
            .INPUT_WD2(RELU_PARAM_WD    ),
            .OUTPUT_WD(RELU_OUT_WD      )
        )
        pu_relu_mul_oc1(
            .op1_i(conv_oc1_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD -: RELU_IN_WD]               ) ,
            .op2_i(relu_para_oc1_i                                                                      ) ,      //fanout to 32 mul
            .mul_o(prelu_mul_oc1_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]       )
        );
        assign prelu_oc1_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] = conv_oc1_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD]                       ? 
                                                                                            prelu_mul_oc1_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] :
                                                                                            conv_oc1_i[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]      ;

    end

endgenerate


//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC2

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC2

        pu_mul #(
            .INPUT_WD1(RELU_IN_WD       ),
            .INPUT_WD2(RELU_PARAM_WD    ),
            .OUTPUT_WD(RELU_OUT_WD      )
        )
        pu_relu_mul_oc2(
            .op1_i(conv_oc2_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD -: RELU_IN_WD]               ) ,
            .op2_i(relu_para_oc2_i                                                                      ) ,      //fanout to 32 mul
            .mul_o(prelu_mul_oc2_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]       )
        );
        assign prelu_oc2_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] = conv_oc2_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD]                       ? 
                                                                                            prelu_mul_oc2_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] :
                                                                                            conv_oc2_i[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]      ;

    end

endgenerate


//----------------------------------------------------------------------------------------------------------

//                       PRELU TO ONE ROW OF OC3

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC3

        pu_mul #(
            .INPUT_WD1(RELU_IN_WD       ),
            .INPUT_WD2(RELU_PARAM_WD    ),
            .OUTPUT_WD(RELU_OUT_WD      )
        )
        pu_relu_mul_oc3(
            .op1_i(conv_oc3_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD -: RELU_IN_WD]               ) ,
            .op2_i(relu_para_oc3_i                                                                      ) ,      //fanout to 32 mul
            .mul_o(prelu_mul_oc3_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]       )
        );
        assign prelu_oc3_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] = conv_oc3_i[PE_COL_NUM * RELU_IN_WD - 1 - i * RELU_IN_WD]                       ? 
                                                                                            prelu_mul_oc3_w[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD] :
                                                                                            conv_oc3_i[PE_COL_NUM * RELU_OUT_WD - 1 - i * RELU_OUT_WD -: RELU_OUT_WD]      ;

    end

endgenerate




// bubble collapse

assign pu_relu_mul_p2_rdy_o = ~vld_r | pu_relu_mul_p2_rdy_i ;

always@(posedge clk or negedge rstn) begin
    if(~rstn)begin
        vld_r <= 'b0;
    end
    else if(~vld_r | pu_relu_mul_p2_rdy_i )begin
        vld_r <= pu_relu_mul_p2_vld_i ;
    end
end

always @(posedge clk) begin
    if(pu_relu_mul_p2_rdy_o && pu_relu_mul_p2_vld_i )begin
        prelu_oc0_r <= prelu_oc0_w        ;
        prelu_oc1_r <= prelu_oc1_w        ;
        prelu_oc2_r <= prelu_oc2_w        ;
        prelu_oc3_r <= prelu_oc3_w        ;  
    end
end


assign pu_relu_mul_p2_vld_o = vld_r              ;
  
assign  prelu_oc0_o          = prelu_oc0_r       ;
assign  prelu_oc1_o          = prelu_oc1_r       ;
assign  prelu_oc2_o          = prelu_oc2_r       ;
assign  prelu_oc3_o          = prelu_oc3_r       ; 



endmodule