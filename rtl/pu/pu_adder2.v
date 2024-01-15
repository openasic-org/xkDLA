module  pu_adder2#(
    parameter INPUT_WD1       = 20,
    parameter INPUT_WD2       = 16,
    parameter OUTPUT_WD       = 20
)(
    input   [INPUT_WD1  -1 : 0]     op1_i ,
    input   [INPUT_WD2  -1 : 0]     op2_i ,
    output  [OUTPUT_WD  -1 : 0]     acc_o 
);

    wire    [OUTPUT_WD - 1 : 0]      level_0_1_w;
    wire    [OUTPUT_WD - 1 : 0]      level_0_2_w;
    wire    [OUTPUT_WD - 1 : 0]      level_1_1_w;


    /*************** dbg signals ****************/
    wire                            mon_overflow1;

    

    //assign level_0_1_w = {{(OUTPUT_WD - INPUT_WD2){1'b0}},op1_i };
    //assign level_0_2_w = {{(OUTPUT_WD - INPUT_WD2){1'b0}},op2_i };
    assign level_0_1_w = {{(OUTPUT_WD - INPUT_WD1){op1_i[INPUT_WD1 - 1]}}, op1_i};
    assign level_0_2_w = {{(OUTPUT_WD - INPUT_WD2){op2_i[INPUT_WD2 - 1]}}, op2_i};

    assign {mon_overflow1, level_1_1_w} = { {level_0_1_w[OUTPUT_WD-1]}, level_0_1_w} + {{level_0_1_w[OUTPUT_WD-1]}, level_0_2_w}    ;


    assign acc_o = level_1_1_w;

   endmodule