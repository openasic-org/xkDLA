// ************************************************************* //
// module : pe array
// author : kehongbo
// last update : 2023/7/10
// 
// ************************************************************* //


//------------------------------------------------------------------------------
  //
  //  Modified       : 2023-8-4 by WYH
  //  Description    : add handshake logic

  
//------------------------------------------------------------------------------
//(*DONT_TOUCH = "yes"*)
module pe_array#(
    parameter FEATURE_WD                            = 8,
    parameter WEIGHT_WD                             = 8,
    parameter PE_COL_NUM                            = 32,
    parameter PE_OUTPUT_WD                          = 18,
    parameter PE_ROW_INPUT_WD                       = FEATURE_WD * PE_COL_NUM,
    parameter PE_ROW_OUTPUT_WD                      = PE_OUTPUT_WD * PE_COL_NUM,
    parameter PE_GRP_NUM                            = 4,
    parameter PE_ROW_NUM                            = 16
)
(
    input                                          clk,
    input                                          rstn,   
    input                                          sch2pe_row_start,     

    
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_0_h_0, 
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_0_h_1,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_0_h_2,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_0_h_3,     
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_1_h_0,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_1_h_1,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_1_h_2,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_1_h_3,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_2_h_0,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_2_h_1,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_2_h_2,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_2_h_3,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_3_h_0,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_3_h_1,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_3_h_2,
    input   [PE_ROW_INPUT_WD           -1: 0]      pe_row_input_ic_3_h_3,    //each fanout to 4(oc) PE, keep in KxK cycles
    


    
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_0_oc_0,    //fanout to 32(w) x 4(h) PE
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_0_oc_1,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_0_oc_2,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_0_oc_3,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_1_oc_0,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_1_oc_1,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_1_oc_2,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_1_oc_3,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_2_oc_0,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_2_oc_1,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_2_oc_2,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_2_oc_3,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_3_oc_0,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_3_oc_1,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_3_oc_2,
    input   [WEIGHT_WD                 -1: 0]      pe_row_weight_ic_3_oc_3,     

    
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_0_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_0_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_0_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_0_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_1_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_1_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_1_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_1_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_2_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_2_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_2_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_2_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_3_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_3_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_3_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_0_oc_3_h_3,


    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_0_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_0_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_0_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_0_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_1_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_1_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_1_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_1_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_2_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_2_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_2_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_2_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_3_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_3_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_3_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_1_oc_3_h_3,

    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_0_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_0_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_0_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_0_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_1_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_1_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_1_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_1_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_2_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_2_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_2_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_2_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_3_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_3_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_3_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_2_oc_3_h_3,

    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_0_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_0_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_0_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_0_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_1_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_1_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_1_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_1_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_2_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_2_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_2_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_2_h_3,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_3_h_0,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_3_h_1,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_3_h_2,
    output   [PE_ROW_OUTPUT_WD         -1: 0]      pe_row_output_ic_3_oc_3_h_3,
    
    input   [PE_COL_NUM                -1: 0]      pe_col_vld,
    input   [PE_ROW_NUM                -1: 0]      pe_row_vld,
    input   [PE_GRP_NUM                -1: 0]      pe_array_vld,     
    
    input                                          sch2pe_vld,
    output                                         pe2sch_rdy,
    output                                         pe2pu_vld,
    input                                          pu2pe_rdy,      
    input                                          sch2pe_row_done              
    
);

/************************ wire & reg *******************************/
wire                                                     start          ;
wire                                                     pe_clr_w       ;   
reg                                                      cur_state_r    ;
reg                                                      nxt_state_w    ;               
reg   [4 -1 : 0]                                         pe_ic_vld_pipe_p0   ;



/************************  pe_array ********************************/
genvar i;


/************************  control  ********************************/
assign      start      = sch2pe_vld & pe2sch_rdy;                    //TODO:
    

localparam                          ACCUM      =  1'b0      ,       
                                    PE_DONE    =  1'b1      ;        

always @(posedge clk or negedge rstn)begin

    if(~rstn)begin
        cur_state_r <= 'd0;
    end
    else begin
        cur_state_r <= nxt_state_w;
    end
end

            
always@(*)begin
    case(cur_state_r)

        ACCUM:  if(sch2pe_row_done) nxt_state_w = PE_DONE   ;
                else                nxt_state_w = ACCUM     ;
        PE_DONE:if(pu2pe_rdy)       nxt_state_w = ACCUM     ;
                else                nxt_state_w = PE_DONE   ;
        default:
                                    nxt_state_w = 'd0 ;
    endcase
end
assign                              pe2sch_rdy = cur_state_r == ACCUM   ;
assign                              pe2pu_vld  = cur_state_r == PE_DONE ;
assign                              pe_clr_w   = pe2pu_vld & pu2pe_rdy  ;  
/*
assign                              pe2pu_c_vld = pe2pu_vld ? pe_ic_vld_pipe_p0 : 4'b0000;

always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        pe_ic_vld_pipe_p0 <= 4'b0000;
    end
    else if(pe_clr_w)begin
        pe_ic_vld_pipe_p0 <= 4'b0000;
    end
    else begin
        pe_ic_vld_pipe_p0 <= pe_array_vld ;
    end
end
*/
        


/************************  ic_0 ***********************************/

    pe_ic #(
        .FEATURE_WD             (FEATURE_WD                         ),
        .WEIGHT_WD              (WEIGHT_WD                          ),
        .PE_COL_NUM             (PE_COL_NUM                         ),
        .PE_ROW_NUM             (PE_ROW_NUM                         ),
        .PE_OUTPUT_WD           (PE_OUTPUT_WD                       ),
        .PE_ROW_INPUT_WD        (PE_ROW_INPUT_WD                    ),
        .PE_ROW_OUTPUT_WD       (PE_ROW_OUTPUT_WD                   )
    )
    pe_chn_0(
        .clk                    (clk                                ),
        .rstn                   (rstn                               ),
        .clr_i                  (pe_clr_w                           ),
        .pe_row_input_0_0       (pe_row_input_ic_0_h_0                   ),      
        .pe_row_input_0_1       (pe_row_input_ic_0_h_1                   ),
        .pe_row_input_0_2       (pe_row_input_ic_0_h_2                   ),
        .pe_row_input_0_3       (pe_row_input_ic_0_h_3                   ),
        .pe_row_weight_0_0      (pe_row_weight_ic_0_oc_0[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_1      (pe_row_weight_ic_0_oc_1[WEIGHT_WD -1 : 0]),       
        .pe_row_weight_0_2      (pe_row_weight_ic_0_oc_2[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_3      (pe_row_weight_ic_0_oc_3[WEIGHT_WD -1 : 0]),
        .pe_row_output_0_0      (pe_row_output_ic_0_oc_0_h_0              ),
        .pe_row_output_0_1      (pe_row_output_ic_0_oc_0_h_1              ),
        .pe_row_output_0_2      (pe_row_output_ic_0_oc_0_h_2              ),
        .pe_row_output_0_3      (pe_row_output_ic_0_oc_0_h_3              ),
        .pe_row_output_1_0      (pe_row_output_ic_0_oc_1_h_0              ),      
        .pe_row_output_1_1      (pe_row_output_ic_0_oc_1_h_1              ),
        .pe_row_output_1_2      (pe_row_output_ic_0_oc_1_h_2              ),
        .pe_row_output_1_3      (pe_row_output_ic_0_oc_1_h_3              ),
        .pe_row_output_2_0      (pe_row_output_ic_0_oc_2_h_0              ),
        .pe_row_output_2_1      (pe_row_output_ic_0_oc_2_h_1              ),
        .pe_row_output_2_2      (pe_row_output_ic_0_oc_2_h_2              ),
        .pe_row_output_2_3      (pe_row_output_ic_0_oc_2_h_3              ),
        .pe_row_output_3_0      (pe_row_output_ic_0_oc_3_h_0              ),
        .pe_row_output_3_1      (pe_row_output_ic_0_oc_3_h_1              ),
        .pe_row_output_3_2      (pe_row_output_ic_0_oc_3_h_2              ),
        .pe_row_output_3_3      (pe_row_output_ic_0_oc_3_h_3              ),
        .pe_col_vld             (pe_col_vld                               ),
        .pe_row_vld             (pe_row_vld                               ),
        .pe_array_vld           (pe_array_vld[0] & pe2sch_rdy             )
    );

/************************  ic_1 ***********************************/

    pe_ic #(
        .FEATURE_WD             (FEATURE_WD),
        .WEIGHT_WD              (WEIGHT_WD),
        .PE_COL_NUM             (PE_COL_NUM),
        .PE_ROW_NUM             (PE_ROW_NUM),
        .PE_OUTPUT_WD           (PE_OUTPUT_WD),
        .PE_ROW_INPUT_WD        (PE_ROW_INPUT_WD),
        .PE_ROW_OUTPUT_WD       (PE_ROW_OUTPUT_WD)
    )
    pe_chn_1(
        .clk                    (clk),
        .rstn                   (rstn),
        .clr_i                  (pe_clr_w                           ),
        .pe_row_input_0_0       (pe_row_input_ic_1_h_0              ),
        .pe_row_input_0_1       (pe_row_input_ic_1_h_1              ),
        .pe_row_input_0_2       (pe_row_input_ic_1_h_2              ),
        .pe_row_input_0_3       (pe_row_input_ic_1_h_3              ),
        
        
        .pe_row_weight_0_0      (pe_row_weight_ic_1_oc_0[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_1      (pe_row_weight_ic_1_oc_1[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_2      (pe_row_weight_ic_1_oc_2[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_3      (pe_row_weight_ic_1_oc_3[WEIGHT_WD -1 : 0]),
        .pe_row_output_0_0      (pe_row_output_ic_1_oc_0_h_0              ),
        .pe_row_output_0_1      (pe_row_output_ic_1_oc_0_h_1              ),
        .pe_row_output_0_2      (pe_row_output_ic_1_oc_0_h_2              ),
        .pe_row_output_0_3      (pe_row_output_ic_1_oc_0_h_3              ),
        .pe_row_output_1_0      (pe_row_output_ic_1_oc_1_h_0              ),
        .pe_row_output_1_1      (pe_row_output_ic_1_oc_1_h_1              ),
        .pe_row_output_1_2      (pe_row_output_ic_1_oc_1_h_2              ),
        .pe_row_output_1_3      (pe_row_output_ic_1_oc_1_h_3              ),
        .pe_row_output_2_0      (pe_row_output_ic_1_oc_2_h_0              ),
        .pe_row_output_2_1      (pe_row_output_ic_1_oc_2_h_1              ),
        .pe_row_output_2_2      (pe_row_output_ic_1_oc_2_h_2              ),
        .pe_row_output_2_3      (pe_row_output_ic_1_oc_2_h_3              ),
        .pe_row_output_3_0      (pe_row_output_ic_1_oc_3_h_0              ),
        .pe_row_output_3_1      (pe_row_output_ic_1_oc_3_h_1              ),
        .pe_row_output_3_2      (pe_row_output_ic_1_oc_3_h_2              ),
        .pe_row_output_3_3      (pe_row_output_ic_1_oc_3_h_3              ),
        .pe_col_vld             (pe_col_vld                               ),
        .pe_row_vld             (pe_row_vld                               ),
        .pe_array_vld           (pe_array_vld[1] & pe2sch_rdy)
    );


/************************  ic_2 ***********************************/

    pe_ic #(
        .FEATURE_WD             (FEATURE_WD),
        .WEIGHT_WD              (WEIGHT_WD),
        .PE_COL_NUM             (PE_COL_NUM),
        .PE_ROW_NUM             (PE_ROW_NUM),
        .PE_OUTPUT_WD           (PE_OUTPUT_WD),
        .PE_ROW_INPUT_WD        (PE_ROW_INPUT_WD),
        .PE_ROW_OUTPUT_WD       (PE_ROW_OUTPUT_WD)
        )
    pe_chn_2(
        .clk                    (clk                                      ),
        .rstn                   (rstn                                     ),
        .clr_i                  (pe_clr_w                                 ),
        .pe_row_input_0_0       (pe_row_input_ic_2_h_0                    ),
        .pe_row_input_0_1       (pe_row_input_ic_2_h_1                    ),
        .pe_row_input_0_2       (pe_row_input_ic_2_h_2                    ),
        .pe_row_input_0_3       (pe_row_input_ic_2_h_3                    ),
        .pe_row_weight_0_0      (pe_row_weight_ic_2_oc_0[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_1      (pe_row_weight_ic_2_oc_1[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_2      (pe_row_weight_ic_2_oc_2[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_3      (pe_row_weight_ic_2_oc_3[WEIGHT_WD -1 : 0]),
        .pe_row_output_0_0      (pe_row_output_ic_2_oc_0_h_0              ),
        .pe_row_output_0_1      (pe_row_output_ic_2_oc_0_h_1              ),
        .pe_row_output_0_2      (pe_row_output_ic_2_oc_0_h_2              ),
        .pe_row_output_0_3      (pe_row_output_ic_2_oc_0_h_3              ),
        .pe_row_output_1_0      (pe_row_output_ic_2_oc_1_h_0              ),
        .pe_row_output_1_1      (pe_row_output_ic_2_oc_1_h_1              ),
        .pe_row_output_1_2      (pe_row_output_ic_2_oc_1_h_2              ),
        .pe_row_output_1_3      (pe_row_output_ic_2_oc_1_h_3              ),
        .pe_row_output_2_0      (pe_row_output_ic_2_oc_2_h_0              ),
        .pe_row_output_2_1      (pe_row_output_ic_2_oc_2_h_1              ),
        .pe_row_output_2_2      (pe_row_output_ic_2_oc_2_h_2              ),
        .pe_row_output_2_3      (pe_row_output_ic_2_oc_2_h_3              ),
        .pe_row_output_3_0      (pe_row_output_ic_2_oc_3_h_0              ),
        .pe_row_output_3_1      (pe_row_output_ic_2_oc_3_h_1              ),
        .pe_row_output_3_2      (pe_row_output_ic_2_oc_3_h_2              ),
        .pe_row_output_3_3      (pe_row_output_ic_2_oc_3_h_3              ),
        .pe_col_vld             (pe_col_vld                               ),
        .pe_row_vld             (pe_row_vld                               ),
        .pe_array_vld           (pe_array_vld[2] & pe2sch_rdy             )
    );


/************************  ic_3 ***********************************/

    pe_ic #(
        .FEATURE_WD             (FEATURE_WD),
        .WEIGHT_WD              (WEIGHT_WD),
        .PE_COL_NUM             (PE_COL_NUM),
        .PE_ROW_NUM             (PE_ROW_NUM),
        .PE_OUTPUT_WD           (PE_OUTPUT_WD),
        .PE_ROW_INPUT_WD        (PE_ROW_INPUT_WD),
        .PE_ROW_OUTPUT_WD       (PE_ROW_OUTPUT_WD)
    )
    pe_chn_3(
        .clk                    (clk                                      ),
        .rstn                   (rstn                                     ),
        .clr_i                  (pe_clr_w                                 ),
        .pe_row_input_0_0       (pe_row_input_ic_3_h_0                    ),
        .pe_row_input_0_1       (pe_row_input_ic_3_h_1                    ),
        .pe_row_input_0_2       (pe_row_input_ic_3_h_2                    ),
        .pe_row_input_0_3       (pe_row_input_ic_3_h_3                    ),
        .pe_row_weight_0_0      (pe_row_weight_ic_3_oc_0[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_1      (pe_row_weight_ic_3_oc_1[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_2      (pe_row_weight_ic_3_oc_2[WEIGHT_WD -1 : 0]),
        .pe_row_weight_0_3      (pe_row_weight_ic_3_oc_3[WEIGHT_WD -1 : 0]),
        .pe_row_output_0_0      (pe_row_output_ic_3_oc_0_h_0              ),
        .pe_row_output_0_1      (pe_row_output_ic_3_oc_0_h_1              ),
        .pe_row_output_0_2      (pe_row_output_ic_3_oc_0_h_2              ),
        .pe_row_output_0_3      (pe_row_output_ic_3_oc_0_h_3              ),
        .pe_row_output_1_0      (pe_row_output_ic_3_oc_1_h_0              ),
        .pe_row_output_1_1      (pe_row_output_ic_3_oc_1_h_1              ),
        .pe_row_output_1_2      (pe_row_output_ic_3_oc_1_h_2              ),
        .pe_row_output_1_3      (pe_row_output_ic_3_oc_1_h_3              ),
        .pe_row_output_2_0      (pe_row_output_ic_3_oc_2_h_0              ),
        .pe_row_output_2_1      (pe_row_output_ic_3_oc_2_h_1              ),
        .pe_row_output_2_2      (pe_row_output_ic_3_oc_2_h_2              ),
        .pe_row_output_2_3      (pe_row_output_ic_3_oc_2_h_3              ),
        .pe_row_output_3_0      (pe_row_output_ic_3_oc_3_h_0              ),
        .pe_row_output_3_1      (pe_row_output_ic_3_oc_3_h_1              ),
        .pe_row_output_3_2      (pe_row_output_ic_3_oc_3_h_2              ),
        .pe_row_output_3_3      (pe_row_output_ic_3_oc_3_h_3              ),
        .pe_col_vld             (pe_col_vld                               ),
        .pe_row_vld             (pe_row_vld                               ),
        .pe_array_vld           (pe_array_vld[3] & pe2sch_rdy             )
    );


endmodule
