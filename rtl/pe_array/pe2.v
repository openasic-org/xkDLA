//`define FPGA
module pe2#(
    parameter FEATURE_WD                    = 8,
    parameter WEIGHT_WD                     = 8,
    parameter PE_OUTPUT_WD                  = 18
    )(
    input                                       clk             ,
    input                                       rstn            ,  
    input                                       clr_i           ,
    input   [2 * FEATURE_WD        -1: 0]       pe_row_input    ,
    input   [WEIGHT_WD             -1: 0]       pe_row_weight   ,
    output  [2 * PE_OUTPUT_WD      -1: 0]       pe_row_output   ,
    input   [2                     -1: 0]       pe_col_vld      ,
    input   [1                     -1: 0]       pe_row_vld      ,
    input   [1                     -1: 0]       pe_array_vld
);
// function : pack 2 mac into 1 module


/************************  reg & wire  ********************************/

`ifdef FPGA
reg      signed [36                            -1: 0]       pe_out_r        ;
reg      signed [36                            -1: 0]       pe_out_w        ;
wire     signed [2                             -1: 0]       accum_ena_w     ;
wire     signed [FEATURE_WD + WEIGHT_WD        -1: 0]       prod_w          ;
wire     signed [28                            -1: 0]       dsp_28_i_w      ;
wire     signed [18                            -1: 0]       dsp_18_i_w      ;
wire     signed [36                            -1: 0]       dsp_36_i_w      ;
wire     signed [36                            -1: 0]       dsp_36_o_w      ;
wire     signed [10                            -1: 0]       pe_row_1_w      ;
wire     signed [10                            -1: 0]       pe_row_0_w      ;
wire     signed [1                             -1: 0]       refined_num_w   ;
wire     signed [18                            -1: 0]       pe_row_1_ref_w  ;
wire     signed [8                             -1: 0]       pe_row_weight_w ;



// using dsp to implement a(27 bit) * b(18 bit) + c(48 bit)
assign pe_row_1_w  = pe_row_input[15:8];
assign pe_row_0_w  = pe_row_input[7:0];
assign pe_row_weight_w = pe_row_weight;
assign accum_ena_w = {pe_col_vld[1] & pe_row_vld & pe_array_vld, pe_col_vld[0] & pe_row_vld & pe_array_vld};
assign dsp_28_i_w  = {{2{pe_row_1_w[7]}}, pe_row_1_w, {8{pe_row_0_w[7]}}, {2{pe_row_0_w[7]}}, pe_row_0_w};
//assign dsp_18_i_w  = {{10{pe_row_weight[7]}}, pe_row_weight};
assign refined_num_w = pe_row_0_w[7] ^ pe_row_weight[7];

assign pe_row_1_ref_w = $signed(pe_out_r[35:18]) + refined_num_w;
assign dsp_36_i_w  = {pe_row_1_ref_w,  pe_out_r[17:0]};
// pe2 mul need to be refined
(*use_dsp = "yes"*)assign dsp_36_o_w  = dsp_28_i_w * pe_row_weight_w ;



always @(*) begin
    case(accum_ena_w) 
    2'd0: pe_out_w = pe_out_r;
    2'd1: pe_out_w = {pe_out_r[35:18], dsp_36_o_w[17:0]};
    2'd2: pe_out_w = {dsp_36_o_w[35:18], pe_out_r[17:0]};
    2'd3: pe_out_w = {dsp_36_o_w[35:18], dsp_36_o_w[17:0]};
    endcase
end

always @(posedge clk or negedge rstn) begin
    if(~rstn)
        pe_out_r    <=  'd0;
    else if(clr_i)
        pe_out_r    <=  'd0;
    else 
        pe_out_r    <=  pe_out_w;
end

assign pe_row_output = pe_out_r;



// debug circuit
wire     signed [18                            -1: 0]       pe_debug_1_w      ;
wire     signed [18                            -1: 0]       pe_debug_0_w      ;
wire     signed [18                            -1: 0]       pe_dut_1_w      ;
wire     signed [18                            -1: 0]       pe_dut_0_w      ;


assign  pe_dut_1_w   = dsp_36_o_w[35:18];
assign  pe_dut_0_w   = dsp_36_o_w[17:0];

assign  pe_debug_1_w = pe_row_1_w * pe_row_weight_w;
assign  pe_debug_0_w = pe_row_0_w * pe_row_weight_w;

initial begin
    while (rstn!==0) begin
        @(posedge  clk);
    end
    while (rstn===0) begin
        @(posedge  clk);
    end
    while (1) begin
    if(pe_dut_1_w != pe_debug_1_w) begin
        $display("MISMATCH!!!");
        $display("%d", pe_out_r[35:18]);
        $display("%d  %d  %d  %d", pe_dut_1_w, pe_dut_0_w, pe_debug_1_w, pe_debug_0_w);
        $display("%d  %d", pe_row_1_w, pe_row_weight);
        $display("%d  %d", pe_row_0_w, pe_row_weight);
        $finish();
    end
    @(posedge  clk);
    end
end

`else
pe #(
    .FEATURE_WD                         (FEATURE_WD                                 ),
    .WEIGHT_WD                          (WEIGHT_WD                                  ),
    .PE_OUTPUT_WD                       (PE_OUTPUT_WD                               )
)pe_0(                      
    .clk                                (clk                                        ),
    .rstn                               (rstn                                       ),
    .clr_i                              (clr_i                                      ),
    .pe_row_input                       (pe_row_input[0 +: FEATURE_WD]              ),
    .pe_row_weight                      (pe_row_weight                              ),
    .pe_row_output                      (pe_row_output[0 +: PE_OUTPUT_WD]           ),
    .pe_col_vld                         (pe_col_vld[0]                              ),
    .pe_row_vld                         (pe_row_vld                                 ),
    .pe_array_vld                       (pe_array_vld                               )
);

pe #(
    .FEATURE_WD                         (FEATURE_WD                                 ),
    .WEIGHT_WD                          (WEIGHT_WD                                  ),
    .PE_OUTPUT_WD                       (PE_OUTPUT_WD                               )
)pe_1(                      
    .clk                                (clk                                        ),
    .rstn                               (rstn                                       ),
    .clr_i                              (clr_i                                      ),
    .pe_row_input                       (pe_row_input[FEATURE_WD +: FEATURE_WD]     ),
    .pe_row_weight                      (pe_row_weight                              ),
    .pe_row_output                      (pe_row_output[PE_OUTPUT_WD +: PE_OUTPUT_WD]),
    .pe_col_vld                         (pe_col_vld[1]                              ),
    .pe_row_vld                         (pe_row_vld                                 ),
    .pe_array_vld                       (pe_array_vld                               )
);

`endif

endmodule
