/*************************************************************************
    > File Name: pu_ic_add_pipe0.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:
 ************************************************************************/



module  pu_ic_add_pipe0 #(
    parameter PE_OUTPUT_WD      = 18,
    parameter PE_COL_NUM        = 32,
    parameter ACC_OUTPUT_WD   = 20
)(

    // from pe_array  ic_oc_h
    input                                                  clk                      ,
    input                                                  rstn                     ,
    //input   [4                                 -1: 0]      pu_channel_vld_i         ,
    input                                                  pu_accum_ic_p0_vld_i     ,
    output                                                 pu_accum_ic_p0_rdy_o     ,                              
    
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_0_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_0_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_0_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_0_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_1_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_1_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_1_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_1_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_2_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_2_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_2_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_2_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_3_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_3_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_3_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_0_3_3_i        ,


    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_0_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_0_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_0_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_0_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_1_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_1_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_1_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_1_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_2_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_2_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_2_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_2_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_3_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_3_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_3_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_1_3_3_i        ,

    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_0_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_0_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_0_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_0_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_1_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_1_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_1_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_1_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_2_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_2_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_2_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_2_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_3_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_3_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_3_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_2_3_3_i        ,

    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_0_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_0_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_0_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_0_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_1_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_1_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_1_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_1_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_2_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_2_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_2_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_2_3_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_3_0_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_3_1_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_3_2_i        ,
    input   [PE_OUTPUT_WD * PE_COL_NUM         -1: 0]      pe_row_rf_3_3_3_i        ,


    // output oc - h
    output                                                 pu_accum_ic_p0_vld_o     ,
    input                                                  pu_accum_ic_p0_rdy_i     ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_0_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_1_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_2_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_3_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_0_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_1_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_2_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_3_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_0_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_1_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_2_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_3_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_0_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_1_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_2_o              ,
    output   [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_3_o              
);


//-----------------------------

//  WIRE & REG               

//   oc - h

//-----------------------------
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_0_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_1_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_2_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_0_3_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_0_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_1_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_2_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_1_3_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_0_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_1_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_2_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_2_3_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_0_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_1_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_2_w              ;
    wire        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]        accum_3_3_w              ;

    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_0_0_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_0_1_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_0_2_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_0_3_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_1_0_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_1_1_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_1_2_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_1_3_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_2_0_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_2_1_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_2_2_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_2_3_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_3_0_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_3_1_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_3_2_r              ;
    reg        [ACC_OUTPUT_WD * PE_COL_NUM   -1: 0]         accum_3_3_r              ;
    reg                                                       vld_r                    ;



genvar i;

//----------------------------------------------------------------------------------------------------------

//                       OC0   H 0 -3

//----------------------------------------------------------------------------------------------------------

//-----  oc0 h0------

generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC0_H0

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_0_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_0_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_0_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_0_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_0_0_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc0 h1------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC0_H1

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_0_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_0_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_0_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_0_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_0_1_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc0 h2------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC0_H2

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_0_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_0_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_0_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_0_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_0_2_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc0 h3------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:ADD_ROW_OC0_H3

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_0_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_0_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_0_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_0_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_0_3_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate



//----------------------------------------------------------------------------------------------------------

//                       OC1   H 0 -3

//----------------------------------------------------------------------------------------------------------

//-----  oc1 h0------

generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC1_H0

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_1_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_1_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_1_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_1_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_1_0_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc1 h1------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC1_H1

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_1_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_1_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_1_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_1_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_1_1_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc1 h2------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC1_H2

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_1_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_1_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_1_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_1_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_1_2_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc1 h3------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC1_H3

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_1_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_1_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_1_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_1_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_1_3_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate


//----------------------------------------------------------------------------------------------------------

//                       OC2   H 0 -3

//----------------------------------------------------------------------------------------------------------

//-----  oc2 h0------

generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC2_H0

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_2_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_2_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_2_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_2_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_2_0_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc2 h1------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC2_H1

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_2_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_2_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_2_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_2_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_2_1_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc2 h2------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC2_H2

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_2_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_2_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_2_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_2_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_2_2_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc2 h3------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC2_H3

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_2_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_2_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_2_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_2_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_2_3_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate


//----------------------------------------------------------------------------------------------------------

//                       OC3   H 0 -3

//----------------------------------------------------------------------------------------------------------

//-----  oc3 h0------

generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC3_H0

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_3_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_3_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_3_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_3_0_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_3_0_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc3 h1------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC3_H1

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_3_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_3_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_3_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_3_1_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_3_1_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc3 h2------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC3_H2

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_3_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_3_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_3_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_3_2_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_3_2_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate

//-----  oc3 h3------
generate 
    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:ADD_ROW_OC3_H3

        pu_adder4 #(
            .PE_OUTPUT_WD(PE_OUTPUT_WD       ),
            .ACCUM_WD    (ACC_OUTPUT_WD    ) 
        )  pu_adder_u(
            .pe_rf_ic1_i(pe_row_rf_0_3_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic2_i(pe_row_rf_1_3_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic3_i(pe_row_rf_2_3_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .pe_rf_ic4_i(pe_row_rf_3_3_3_i[PE_OUTPUT_WD * PE_COL_NUM - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]),
            .accum_o    (      accum_3_3_w[ACC_OUTPUT_WD * PE_COL_NUM - 1 - i * ACC_OUTPUT_WD -: ACC_OUTPUT_WD])
        );

    end
endgenerate


//  pipe  bubble collapse

assign pu_accum_ic_p0_rdy_o = ~vld_r | pu_accum_ic_p0_rdy_i ;     
assign pu_accum_ic_p0_vld_o = vld_r                         ;
always @(posedge clk or negedge rstn)begin
    if(~rstn) begin
        vld_r <= 1'b0;
    end
    else if(pu_accum_ic_p0_rdy_o) begin
        vld_r <= pu_accum_ic_p0_vld_i ;
    end
end

always @(posedge clk)begin

    if(pu_accum_ic_p0_rdy_o && pu_accum_ic_p0_vld_i) begin
        accum_0_0_r <= accum_0_0_w;
        accum_0_1_r <= accum_0_1_w;
        accum_0_2_r <= accum_0_2_w;
        accum_0_3_r <= accum_0_3_w;
        accum_1_0_r <= accum_1_0_w;
        accum_1_1_r <= accum_1_1_w;
        accum_1_2_r <= accum_1_2_w;
        accum_1_3_r <= accum_1_3_w;
        accum_2_0_r <= accum_2_0_w;
        accum_2_1_r <= accum_2_1_w;
        accum_2_2_r <= accum_2_2_w;
        accum_2_3_r <= accum_2_3_w;
        accum_3_0_r <= accum_3_0_w;
        accum_3_1_r <= accum_3_1_w;
        accum_3_2_r <= accum_3_2_w;
        accum_3_3_r <= accum_3_3_w;
    end
end

    assign      accum_0_0_o =   accum_0_0_r ;
    assign      accum_0_1_o =   accum_0_1_r ;
    assign      accum_0_2_o =   accum_0_2_r ;
    assign      accum_0_3_o =   accum_0_3_r ;
    assign      accum_1_0_o =   accum_1_0_r ;
    assign      accum_1_1_o =   accum_1_1_r ;
    assign      accum_1_2_o =   accum_1_2_r ;
    assign      accum_1_3_o =   accum_1_3_r ;
    assign      accum_2_0_o =   accum_2_0_r ;
    assign      accum_2_1_o =   accum_2_1_r ;
    assign      accum_2_2_o =   accum_2_2_r ;
    assign      accum_2_3_o =   accum_2_3_r ;
    assign      accum_3_0_o =   accum_3_0_r ;
    assign      accum_3_1_o =   accum_3_1_r ;
    assign      accum_3_2_o =   accum_3_2_r ;
    assign      accum_3_3_o =   accum_3_3_r ;
    
endmodule