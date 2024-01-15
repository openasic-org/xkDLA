/*************************************************************************
    > File Name: pu_requant_pipe4.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:
 ************************************************************************/


//  TODO:    need multiplier
module  pu_requant_pipe4 #(
    parameter PE_OUTPUT_WD      = 24    ,
    parameter PE_COL_NUM        = 32    ,
    parameter REQUANT_PARM_WD   = 8     ,
    parameter REQUANT_WD        = 8     

)(

    input                                                               clk                      ,
    input                                                               rstn                     ,
            
    //  1h 4oc per cycles             
    //  oc_h             
    input                                                               pu_requant_p4_vld_i      ,
    output                                                              pu_requant_p4_rdy_o      ,                              
                
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     requant_oc0_i                  ,  // one row of oc0
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     requant_oc1_i                  ,  // one row of oc1
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     requant_oc2_i                  ,  // one row of oc2
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     requant_oc3_i                  ,  // one row of oc3

    input    [REQUANT_PARM_WD             -1: 0]                     parm_oc0_i               ,
    input    [REQUANT_PARM_WD             -1: 0]                     parm_oc1_i               ,
    input    [REQUANT_PARM_WD             -1: 0]                     parm_oc2_i               ,
    input    [REQUANT_PARM_WD             -1: 0]                     parm_oc3_i               ,  

    output                                                              pu_requant_p4_vld_o     ,
    input                                                               pu_requant_p4_rdy_i     ,

    output   [REQUANT_WD * PE_COL_NUM                -1: 0]          requant_oc0_o              ,
    output   [REQUANT_WD * PE_COL_NUM                -1: 0]          requant_oc1_o              ,
    output   [REQUANT_WD * PE_COL_NUM                -1: 0]          requant_oc2_o              ,
    output   [REQUANT_WD * PE_COL_NUM                -1: 0]          requant_oc3_o              

);


//-----------------------------

//  WIRE & REG               

//  

//-----------------------------
    reg                                                           vld_r                    ;
    reg    [REQUANT_WD * PE_COL_NUM                -1: 0]         requant_oc0_r            ;
    reg    [REQUANT_WD * PE_COL_NUM                -1: 0]         requant_oc1_r            ;
    reg    [REQUANT_WD * PE_COL_NUM                -1: 0]         requant_oc2_r            ;
    reg    [REQUANT_WD * PE_COL_NUM                -1: 0]         requant_oc3_r            ;
    wire    [REQUANT_WD * PE_COL_NUM                -1: 0]        requant_oc0_w            ;
    wire    [REQUANT_WD * PE_COL_NUM                -1: 0]        requant_oc1_w            ;
    wire    [REQUANT_WD * PE_COL_NUM                -1: 0]        requant_oc2_w            ;
    wire    [REQUANT_WD * PE_COL_NUM                -1: 0]        requant_oc3_w            ;





genvar i;


//----------------------------------------------------------------------------------------------------------

//                       REQUANT TO 8BIT FOR ONE ROW OF OC0 1 2 3

//             TODO:

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC0

       assign requant_oc0_w[PE_COL_NUM * REQUANT_WD - 1 - i * REQUANT_WD -: REQUANT_WD] = requant_oc0_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: REQUANT_WD] ;   //reduce to 8bit
       assign requant_oc1_w[PE_COL_NUM * REQUANT_WD - 1 - i * REQUANT_WD -: REQUANT_WD] = requant_oc1_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: REQUANT_WD] ;   //reduce to 8bit
       assign requant_oc2_w[PE_COL_NUM * REQUANT_WD - 1 - i * REQUANT_WD -: REQUANT_WD] = requant_oc2_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: REQUANT_WD] ;   //reduce to 8bit
       assign requant_oc3_w[PE_COL_NUM * REQUANT_WD - 1 - i * REQUANT_WD -: REQUANT_WD] = requant_oc3_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: REQUANT_WD] ;   //reduce to 8bit

    end

endgenerate




// bubble collapse

assign pu_requant_p4_rdy_o = ~vld_r | pu_requant_p4_rdy_i ;

always@(posedge clk or negedge rstn) begin
    if(~rstn)begin
        vld_r <= 'b0;
    end
    else if(~vld_r | pu_requant_p4_rdy_i )begin
        vld_r <= pu_requant_p4_vld_i  ;
    end
end

always @(posedge clk) begin
    if(pu_requant_p4_rdy_o && pu_requant_p4_vld_i )begin
        requant_oc0_r <= requant_oc0_w        ;
        requant_oc1_r <= requant_oc1_w        ;
        requant_oc2_r <= requant_oc2_w        ;
        requant_oc3_r <= requant_oc3_w        ;  
    end

end


assign  pu_requant_p4_vld_o = vld_r        ;

assign  requant_oc0_o = requant_oc0_r      ;
assign  requant_oc1_o = requant_oc1_r      ;
assign  requant_oc2_o = requant_oc2_r      ;
assign  requant_oc3_o = requant_oc3_r      ;


endmodule