module  pu_mul#(
    parameter INPUT_WD1      = 20,
    parameter INPUT_WD2      = 16,
    parameter OUTPUT_WD      = 36
)(
    input   signed [INPUT_WD1  -1 : 0]     op1_i ,
    input          [INPUT_WD2  -1 : 0]     op2_i ,
    output  signed [OUTPUT_WD  -1 : 0]     mul_o  
);
    wire signed  [INPUT_WD2 : 0]                 op2_w;
    assign op2_w = {1'b0, op2_i};
    assign mul_o = op1_i * op2_w;

/*
    wire   [INPUT_WD1 + INPUT_WD2 - 1 : 0]   unsigned_mul_w ;
    wire   [OUTPUT_WD             - 1 : 0]   shift_mul_w    ;

    wire   [OUTPUT_WD             - 1 : 0]   signed_mul_w   ;

    wire   [INPUT_WD1             - 1 : 0]   op1_w ;
    wire   [INPUT_WD2             - 1 : 0]   op2_w ;

    assign op1_w = op1_i[INPUT_WD1 - 1] ? ( ~op1_i + 'd1 ) : op1_i ;
   // assign op2_w = op2_i[INPUT_WD2 - 1] ? ( ~op2_i + 'd1 ) : op2_i ;  

   // requant factor is unsigned 
   assign op2_w = op2_i;


   
    assign unsigned_mul_w = op1_w * op2_w  ;
    assign shift_mul_w    = unsigned_mul_w[0+:OUTPUT_WD] ;

    assign signed_mul_w   = (op1_i[INPUT_WD1 - 1] )? (~shift_mul_w +'d1) : shift_mul_w ;




    assign mul_o = signed_mul_w ;
*/

   endmodule