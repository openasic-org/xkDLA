/*************************************************************************
    > File Name: pe.v
    > Author: kehongbo
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:
 ************************************************************************/


//------------------------------------------------------------------------------
  //
  //  Modified       : 2023-8-13 by WYH
  //  Description    : add signed  number proc

  
//------------------------------------------------------------------------------
module pe#(
    parameter FEATURE_WD                    = 8,
    parameter WEIGHT_WD                     = 8,
    parameter PE_OUTPUT_WD                  = 18
    )
    (
    input                                   clk             ,
    input                                   rstn            ,  
    input                                   clr_i           ,
    input   signed [FEATURE_WD        -1: 0]       pe_row_input    ,
    input   signed [WEIGHT_WD         -1: 0]       pe_row_weight   ,
    output  [PE_OUTPUT_WD      -1: 0]       pe_row_output   ,
    input   [1                  -1: 0]      pe_col_vld      ,
    input   [1                  -1: 0]      pe_row_vld      ,
    input   [1                  -1: 0]      pe_array_vld
);

reg      signed [PE_OUTPUT_WD                   -1: 0]      pe_out_r    ;
wire                                                        accum_ena_w ;
(*use_dsp = "yes"*)wire     signed [PE_OUTPUT_WD         : 0]      prod_w      ;

assign accum_ena_w                               = pe_col_vld & pe_row_vld & pe_array_vld;
assign prod_w                    =  pe_row_input * pe_row_weight + pe_out_r;
always @(posedge clk or negedge rstn) begin
    if(!rstn)   begin
            pe_out_r    <=  'd0               ;
    end
    else begin
        if(clr_i)
            pe_out_r    <=  'd0               ;
        else if(accum_ena_w)
            pe_out_r    <=  prod_w;
    end
end

assign pe_row_output = pe_out_r;


endmodule
