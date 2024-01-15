/*************************************************************************
    > File Name: pu_resi_add_pipe3.v
    > Author: YuhengWei
    > Mail:
    > Created Time: Sun 6 Aug 2023 12:03:22 PM CST
    > Description:
 ************************************************************************/

module  pu_resi_add_pipe_p3 #(
    parameter PE_OUTPUT_WD      = 8    ,
    parameter PE_COL_NUM        = 32    ,
    parameter ACCUM_OUTPUT_WD   = 9    ,
    parameter RESI_WD           = 8    ,
    parameter X_N               = PE_COL_NUM ,
    parameter ACC_WD            = ACCUM_OUTPUT_WD

)(

    input                                                               clk                      ,
    input                                                               rstn                     ,
            
    //  1h 4oc per cycle          
    //  oc_h             
    input                                                               pu_resi_add_p3_vld_i     ,
    output                                                              pu_resi_add_p3_rdy_o     ,                              
    input                                                               is_bypass_i              ,
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     prelu_0_i                  ,  // one row of oc0
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     prelu_1_i                  ,  // one row of oc1
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     prelu_2_i                  ,  // one row of oc2
    input    [PE_OUTPUT_WD * PE_COL_NUM   -1: 0]                     prelu_3_i                  ,  // one row of oc3

    input    [RESI_WD * PE_COL_NUM           -1: 0]                     resi_oc0_i               ,
    input    [RESI_WD * PE_COL_NUM           -1: 0]                     resi_oc1_i               ,
    input    [RESI_WD * PE_COL_NUM           -1: 0]                     resi_oc2_i               ,
    input    [RESI_WD * PE_COL_NUM           -1: 0]                     resi_oc3_i               ,  

    output                                                              pu_resi_add_p3_vld_o     ,
    input                                                               pu_resi_add_p3_rdy_i     ,

    output   [(ACC_WD + 2) * PE_COL_NUM                -1: 0]        resi_oc0_o               ,
    output   [(ACC_WD + 2) * PE_COL_NUM                -1: 0]        resi_oc1_o               ,
    output   [(ACC_WD + 2) * PE_COL_NUM                -1: 0]        resi_oc2_o               ,
    output   [(ACC_WD + 2) * PE_COL_NUM                -1: 0]        resi_oc3_o               

);


//-----------------------------

//  WIRE & REG               

//  

//-----------------------------
    reg                                                                vld_r                 ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         resi_oc0_r            ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         resi_oc1_r            ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         resi_oc2_r            ;
    reg    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]         resi_oc3_r            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc0_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc1_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc2_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc3_w            ;

    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc0_mux_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc1_mux_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc2_mux_w            ;
    wire    [ACCUM_OUTPUT_WD * PE_COL_NUM                -1: 0]        resi_oc3_mux_w            ;

    reg                                                     p0_vld_r                         ;
    wire                                                    p0_rdy_w                         ;
    wire                                                    p0_bc_rdy_w                      ;    
    reg                                                     p1_vld_r                         ;
    wire                                                    p1_rdy_w                         ;
    wire                                                    p1_bc_rdy_w                      ;                                                   
    
    reg    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc0_r            ;
    reg    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc1_r            ;
    reg    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc2_r            ;
    reg    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc3_r            ;

    wire    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc0_w           ; //11 bit
    wire    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc1_w           ;
    wire    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc2_w           ;
    wire    [(ACC_WD + 2) * X_N                -1: 0]        resi_add_256_oc3_w           ; 

genvar i;


//----------------------------------------------------------------------------------------------------------

//                       ADD RESI TO ONE ROW OF OC0

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1 )begin:OC0

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(RESI_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc0(
            .op1_i(prelu_0_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]          ) ,
            .op2_i(resi_oc0_i[PE_COL_NUM * RESI_WD     - 1 - i * RESI_WD      -: RESI_WD]               ) ,    
            .acc_o(resi_oc0_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       ADD RESI TO ONE ROW OF OC1

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC1
    
        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(RESI_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc1(
            .op1_i(prelu_1_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]          ) ,
            .op2_i(resi_oc1_i[PE_COL_NUM * RESI_WD     - 1 - i * RESI_WD      -: RESI_WD]               ) ,    
            .acc_o(resi_oc1_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       ADD RESI TO ONE ROW OF OC2

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC2

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(RESI_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc2(
            .op1_i(prelu_2_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]          ) ,
            .op2_i(resi_oc2_i[PE_COL_NUM * RESI_WD     - 1 - i * RESI_WD      -: RESI_WD]               ) ,    
            .acc_o(resi_oc2_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate

//----------------------------------------------------------------------------------------------------------

//                       ADD RESI TO ONE ROW OF OC3

//----------------------------------------------------------------------------------------------------------

generate 

    for(i = 0; i < PE_COL_NUM; i = i + 1)begin:OC3

        pu_adder2 #(
            .INPUT_WD1(PE_OUTPUT_WD       ),
            .INPUT_WD2(RESI_WD            ),
            .OUTPUT_WD(ACCUM_OUTPUT_WD    )
        )
        pu_adder_oc3(
            .op1_i(prelu_3_i[PE_COL_NUM * PE_OUTPUT_WD - 1 - i * PE_OUTPUT_WD -: PE_OUTPUT_WD]          ) ,
            .op2_i(resi_oc3_i[PE_COL_NUM * RESI_WD     - 1 - i * RESI_WD      -: RESI_WD]               ) ,    
            .acc_o(resi_oc3_w[PE_COL_NUM * ACCUM_OUTPUT_WD - 1 - i * ACCUM_OUTPUT_WD -: ACCUM_OUTPUT_WD])
        );

    end

endgenerate



// bubble collapse

wire   pipe_vld  ;
wire   pipe_rdy  ;
assign pipe_vld = pu_resi_add_p3_vld_i ;
assign pu_resi_add_p3_rdy_o = pipe_rdy ;


assign pipe_rdy    = p0_bc_rdy_w           ;
assign p0_bc_rdy_w = ~p0_vld_r || p0_rdy_w ;

always@(posedge clk or negedge rstn) begin
    if(~rstn)begin
        p0_vld_r <= 1'b0;
    end
    else if(p0_bc_rdy_w)begin
        p0_vld_r <= pipe_vld  ;
    end
end



always @(posedge clk) begin
    if(pipe_vld && p0_bc_rdy_w )begin
        resi_oc0_r <= is_bypass_i ? prelu_0_i : resi_oc0_w        ;
        resi_oc1_r <= is_bypass_i ? prelu_1_i : resi_oc1_w        ;
        resi_oc2_r <= is_bypass_i ? prelu_2_i : resi_oc2_w        ;
        resi_oc3_r <= is_bypass_i ? prelu_3_i : resi_oc3_w        ;  
    end
end
assign p0_rdy_w = p1_bc_rdy_w  ;




generate 
    for(i = 0 ; i < 32 ; i = i + 1)begin : add256_c_0_3
        assign resi_add_256_oc0_w[X_N * (ACC_WD + 2) - 1 - i * (ACC_WD + 2) -: (ACC_WD + 2)] = $signed(resi_oc0_r[X_N * ACC_WD - 1 - i * ACC_WD -: ACC_WD]) + $signed(11'd256);
        assign resi_add_256_oc1_w[X_N * (ACC_WD + 2) - 1 - i * (ACC_WD + 2) -: (ACC_WD + 2)] = $signed(resi_oc1_r[X_N * ACC_WD - 1 - i * ACC_WD -: ACC_WD]) + $signed(11'd256);
        assign resi_add_256_oc2_w[X_N * (ACC_WD + 2) - 1 - i * (ACC_WD + 2) -: (ACC_WD + 2)] = $signed(resi_oc2_r[X_N * ACC_WD - 1 - i * ACC_WD -: ACC_WD]) + $signed(11'd256);
        assign resi_add_256_oc3_w[X_N * (ACC_WD + 2) - 1 - i * (ACC_WD + 2) -: (ACC_WD + 2)] = $signed(resi_oc3_r[X_N * ACC_WD - 1 - i * ACC_WD -: ACC_WD]) + $signed(11'd256);
 
    end
endgenerate

assign p1_bc_rdy_w = ~p1_vld_r || p1_rdy_w ;
always @(posedge clk or negedge rstn)begin
    if(~rstn)begin
        p1_vld_r <= 1'b0;
    end
    else if(p1_bc_rdy_w)begin
        p1_vld_r <= p0_vld_r ;
    end
end
always @(posedge clk)begin
    if(p1_bc_rdy_w && p0_vld_r)begin
        resi_add_256_oc0_r <= is_bypass_i ? {{32{2'b0}}, resi_oc0_r} : resi_add_256_oc0_w ;
        resi_add_256_oc1_r <= is_bypass_i ? {{32{2'b0}}, resi_oc1_r} : resi_add_256_oc1_w ;
        resi_add_256_oc2_r <= is_bypass_i ? {{32{2'b0}}, resi_oc2_r} : resi_add_256_oc2_w ;
        resi_add_256_oc3_r <= is_bypass_i ? {{32{2'b0}}, resi_oc3_r} : resi_add_256_oc3_w ;
    end
end
assign p1_rdy_w                     = pu_resi_add_p3_rdy_i ;
assign pu_resi_add_p3_vld_o         = p1_vld_r ;







//
assign  resi_oc0_o = resi_add_256_oc0_r       ;
assign  resi_oc1_o = resi_add_256_oc1_r       ;
assign  resi_oc2_o = resi_add_256_oc2_r       ;
assign  resi_oc3_o = resi_add_256_oc3_r       ;


endmodule