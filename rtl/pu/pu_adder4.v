module  pu_adder4#(
    parameter PE_OUTPUT_WD  = 18,
    parameter ACCUM_WD      = 20
)(
    input   [PE_OUTPUT_WD  -1 : 0] pe_rf_ic1_i,
    input   [PE_OUTPUT_WD  -1 : 0] pe_rf_ic2_i,
    input   [PE_OUTPUT_WD  -1 : 0] pe_rf_ic3_i,
    input   [PE_OUTPUT_WD  -1 : 0] pe_rf_ic4_i,
    output  [ACCUM_WD      -1 : 0] accum_o
);

    wire    [ACCUM_WD - 1 : 0]      level_0_1_w;
    wire    [ACCUM_WD - 1 : 0]      level_0_2_w;
    wire    [ACCUM_WD - 1 : 0]      level_0_3_w;
    wire    [ACCUM_WD - 1 : 0]      level_1_1_w;

    /*************** dbg signals ****************/
    wire                            mon_overflow1;
    wire                            mon_overflow2;
    wire                            mon_overflow3;
    wire                            mon_overflow4;

    assign {level_0_1_w} = { {(ACCUM_WD - PE_OUTPUT_WD){pe_rf_ic1_i[PE_OUTPUT_WD - 1]}}, pe_rf_ic1_i} + {{(ACCUM_WD - PE_OUTPUT_WD){pe_rf_ic2_i[PE_OUTPUT_WD - 1]}}, pe_rf_ic2_i}    ;
    assign {level_0_2_w} = { {(ACCUM_WD - PE_OUTPUT_WD){pe_rf_ic3_i[PE_OUTPUT_WD - 1]}}, pe_rf_ic3_i} + {{(ACCUM_WD - PE_OUTPUT_WD){pe_rf_ic4_i[PE_OUTPUT_WD - 1]}}, pe_rf_ic4_i}    ;

    assign {level_1_1_w} = {level_0_1_w} + {level_0_2_w}    ;

    assign accum_o = level_1_1_w;

   endmodule