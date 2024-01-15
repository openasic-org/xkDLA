/*************************************************************************
    > File Name: pu_bias_add_pipe1.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:
 ************************************************************************/

module  pu_bias_add_pipe1 #(
    parameter PE_OUTPUT_WD      = 20    ,
    parameter BIAS_WD           = 16    ,
    parameter PE_COL_NUM        = 32    ,
    parameter ACCUM_OUTPUT_WD   = 20    

)(

    input                                                  clk                      ,
    input                                                  rstn                     ,

    //  1h 4oc per cycles
    //  oc_h
    input                                                  pu_accum_bias_p1_vld_i   ,
    output                                                 pu_accum_bias_p1_rdy_o   ,                              
    
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]        acc_0_i                  ,  // one row of oc0
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]        acc_1_i                  ,  // one row of oc1
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]        acc_2_i                  ,  // one row of oc2
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]        acc_3_i                  ,  // one row of oc3

    input    [BIAS_WD                        -1: 0]        bias_oc0_i               ,
    input    [BIAS_WD                        -1: 0]        bias_oc1_i               ,
    input    [BIAS_WD                        -1: 0]        bias_oc2_i               ,
    input    [BIAS_WD                        -1: 0]        bias_oc3_i               ,  

    output                                                 pu_accum_bias_p1_vld_o   ,
    input                                                  pu_accum_bias_p1_rdy_i   ,

    output   [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc0_o               ,
    output   [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc1_o               ,
    output   [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc2_o               ,
    output   [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc3_o               

);


//-----------------------------

//  WIRE & REG               

//  

//-----------------------------
    reg                                                                vld_r                 ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         conv_oc0_r            ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         conv_oc1_r            ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         conv_oc2_r            ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         conv_oc3_r            ;
 
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc0_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc1_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc2_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        conv_oc3_w            ;





genvar i;


//----------------------------------------------------------------------------------------------------------

//                       ADD BIAS TO ONE ROW OF OC0

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC0

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(BIAS_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc0(
            .op1_i(acc_0_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]            ) ,
            .op2_i(bias_oc0_i                                                                           ) ,      //fanout to 32 adder2
            .acc_o(conv_oc0_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate


//----------------------------------------------------------------------------------------------------------

//                       ADD BIAS TO ONE ROW OF OC1

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC1

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(BIAS_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc1(
            .op1_i(acc_1_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]            ) ,
            .op2_i(bias_oc1_i                                                                           ) ,      //fanout to 32 adder2
            .acc_o(conv_oc1_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       ADD BIAS TO ONE ROW OF OC2

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC2

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(BIAS_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc2(
            .op1_i(acc_2_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]            ) ,
            .op2_i(bias_oc2_i                                                                           ) ,      //fanout to 32 adder2
            .acc_o(conv_oc2_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       ADD BIAS TO ONE ROW OF OC3

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC3

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(BIAS_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc3(
            .op1_i(acc_3_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]            ) ,
            .op2_i(bias_oc3_i                                                                           ) ,      //fanout to 32 adder2
            .acc_o(conv_oc3_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate



// bubble collapse

assign pu_accum_bias_p1_rdy_o = ~vld_r | pu_accum_bias_p1_rdy_i ;

always@(posedge clk or negedge rstn) begin
    if(~rstn)begin
        vld_r <= 'b0;
    end
    else if(~vld_r | pu_accum_bias_p1_rdy_i )begin
        vld_r <= pu_accum_bias_p1_vld_i;
    end
end

always @(posedge clk) begin
    if(pu_accum_bias_p1_rdy_o && pu_accum_bias_p1_vld_i)begin
        conv_oc0_r <= conv_oc0_w        ;
        conv_oc1_r <= conv_oc1_w        ;
        conv_oc2_r <= conv_oc2_w        ;
        conv_oc3_r <= conv_oc3_w        ;  
    end
end


assign pu_accum_bias_p1_vld_o = vld_r ;

assign  conv_oc0_o = conv_oc0_r       ;
assign  conv_oc1_o = conv_oc1_r       ;
assign  conv_oc2_o = conv_oc2_r       ;
assign  conv_oc3_o = conv_oc3_r       ; 



endmodule