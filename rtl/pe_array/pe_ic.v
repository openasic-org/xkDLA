/*************************************************************************
    > File Name: pe_ic.v
    > Author: kehongbo
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description: 4 oc x 4 h PEs 
 ************************************************************************/
module pe_ic#(
    parameter FEATURE_WD                    = 8,
    parameter WEIGHT_WD                     = 8,
    parameter PE_COL_NUM                    = 32,
    parameter PE_ROW_NUM                    = 16,
    parameter PE_OUTPUT_WD                  = 24,
    parameter PE_ROW_INPUT_WD               = 256,
    parameter PE_ROW_OUTPUT_WD              = 768
)(
    input                                                        clk,
    input                                                        rstn,
    input                                                        clr_i,
    // pe_row_input_ic_h
    input    [PE_ROW_INPUT_WD           -1: 0]                   pe_row_input_0_0, 
    input    [PE_ROW_INPUT_WD           -1: 0]                   pe_row_input_0_1,
    input    [PE_ROW_INPUT_WD           -1: 0]                   pe_row_input_0_2,
    input    [PE_ROW_INPUT_WD           -1: 0]                   pe_row_input_0_3,
    // pe_row_weight_ic_oc    
    input    [WEIGHT_WD                 -1: 0]                   pe_row_weight_0_0,
    input    [WEIGHT_WD                 -1: 0]                   pe_row_weight_0_1,
    input    [WEIGHT_WD                 -1: 0]                   pe_row_weight_0_2,
    input    [WEIGHT_WD                 -1: 0]                   pe_row_weight_0_3,
    // pe_row_outpu_oc_h
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_0_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_0_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_0_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_0_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_1_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_1_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_1_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_1_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_2_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_2_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_2_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_2_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_3_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_3_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_3_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]                    pe_row_output_3_3,


    // 
    input   [PE_COL_NUM                -1: 0]                    pe_col_vld,
    input                                                        pe_array_vld,
    input   [PE_ROW_NUM                -1: 0]                    pe_row_vld
    );

genvar i;
`ifdef FPGA
/************************  row_0 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin: oc0_row0
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_0(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_0[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_0[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]   ),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]                                            ),
            .pe_row_vld             (pe_row_vld[0]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_1 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin: oc0_row1
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_1(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_1[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_1[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]   ),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]                                            ),
            .pe_row_vld             (pe_row_vld[1]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_2 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc0_row2
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_2(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_2[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_2[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]   ),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]                                            ),
            .pe_row_vld             (pe_row_vld[2]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_3 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc0_row3
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_3(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_3[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_3[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]   ),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]                                            ),
            .pe_row_vld             (pe_row_vld[3]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_4 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc1_row0
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_4(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_0[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]        ),
            .pe_row_weight          (pe_row_weight_0_1                                                  ),
            .pe_row_output          (pe_row_output_1_0[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]   ),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]                                            ),
            .pe_row_vld             (pe_row_vld[4]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_5 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc1_row1
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_5(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_1[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_1),
            .pe_row_output          (pe_row_output_1_1[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[5]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_6 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc1_row2
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_6(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_2[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_1),
            .pe_row_output          (pe_row_output_1_2[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[6]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_7 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc1_row3
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_7(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_3[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_1),
            .pe_row_output          (pe_row_output_1_3[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[7]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_8 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc2_row0
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_8(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_0[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_0[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[8]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_9 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc2_row1
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_9(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_1[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_1[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[9]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_10 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc2_row2
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_10(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_2[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_2[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[10]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_11 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc2_row3
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_11(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_3[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_3[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[11]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_12 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc3_row0
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_12(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_0[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_0[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[12]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_13 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc3_row1
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_13(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_1[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_1[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[13]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_14 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc3_row2
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_14(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_2[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_2[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[14]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_15 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM / 2 ; i = i + 1) begin:oc3_row3
        pe2 #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_15(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_3[(i + 1)*FEATURE_WD*2 - 1 : i*FEATURE_WD*2]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_3[(i + 1)*PE_OUTPUT_WD*2 - 1 : i*PE_OUTPUT_WD*2]),
            .pe_col_vld             (pe_col_vld[2*i+1 : 2*i]),
            .pe_row_vld             (pe_row_vld[15]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

`else
/************************  row_0 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin: oc0_row0
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_0(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_0[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_0[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]   ),
            .pe_col_vld             (pe_col_vld[i]                                                      ),
            .pe_row_vld             (pe_row_vld[0]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_1 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin: oc0_row1
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_1(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_1[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_1[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]   ),
            .pe_col_vld             (pe_col_vld[i]                                                      ),
            .pe_row_vld             (pe_row_vld[1]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_2 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc0_row2
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_2(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_2[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_2[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]   ),
            .pe_col_vld             (pe_col_vld[i]                                                      ),
            .pe_row_vld             (pe_row_vld[2]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_3 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc0_row3
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_3(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_3[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]        ),
            .pe_row_weight          (pe_row_weight_0_0                                                  ),
            .pe_row_output          (pe_row_output_0_3[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]   ),
            .pe_col_vld             (pe_col_vld[i]                                                      ),
            .pe_row_vld             (pe_row_vld[3]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_4 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc1_row0
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_4(
            .clk                    (clk                                                                ),
            .rstn                   (rstn                                                               ),
            .clr_i                  (clr_i                                                              ),
            .pe_row_input           (pe_row_input_0_0[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]        ),
            .pe_row_weight          (pe_row_weight_0_1                                                  ),
            .pe_row_output          (pe_row_output_1_0[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]   ),
            .pe_col_vld             (pe_col_vld[i]                                                      ),
            .pe_row_vld             (pe_row_vld[4]                                                      ),
            .pe_array_vld           (pe_array_vld                                                       )
        );
    end
endgenerate

/************************  row_5 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc1_row1
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_5(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_1[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_1),
            .pe_row_output          (pe_row_output_1_1[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[5]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_6 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc1_row2
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_6(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_2[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_1),
            .pe_row_output          (pe_row_output_1_2[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[6]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_7 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc1_row3
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_7(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_3[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_1),
            .pe_row_output          (pe_row_output_1_3[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[7]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_8 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc2_row0
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_8(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_0[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_0[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[8]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_9 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc2_row1
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_9(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_1[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_1[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[9]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_10 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc2_row2
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_10(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_2[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_2[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[10]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_11 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc2_row3
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_11(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_3[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_2),
            .pe_row_output          (pe_row_output_2_3[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[11]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_12 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc3_row0
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_12(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_0[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_0[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[12]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_13 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc3_row1
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_13(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_1[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_1[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[13]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_14 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc3_row2
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_14(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_2[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_2[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[14]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate

/************************  row_15 ***********************************/
generate
    for(i = 0; i < PE_COL_NUM; i = i + 1) begin:oc3_row3
        pe #(
            .FEATURE_WD             (FEATURE_WD                                                         ),
            .WEIGHT_WD              (WEIGHT_WD                                                          ),
            .PE_OUTPUT_WD           (PE_OUTPUT_WD                                                       )
        )
        pe_row_15(
            .clk                    (clk),
            .rstn                   (rstn),
            .clr_i                  (clr_i),
            .pe_row_input           (pe_row_input_0_3[(i + 1) * FEATURE_WD - 1 : i * FEATURE_WD]),
            .pe_row_weight          (pe_row_weight_0_3),
            .pe_row_output          (pe_row_output_3_3[(i + 1) * PE_OUTPUT_WD - 1 : i * PE_OUTPUT_WD]),

            .pe_col_vld             (pe_col_vld[i]),
            .pe_row_vld             (pe_row_vld[15]),
            .pe_array_vld           (pe_array_vld)
        );
    end
endgenerate
`endif 
endmodule