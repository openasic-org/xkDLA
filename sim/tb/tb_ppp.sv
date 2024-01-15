`timescale 1ns/1ps





module tb_ppp;

parameter   IMAGE_WIDTH             = 'd1024;
parameter   IMGW_WIDTH              = 'd11;
parameter   IMGH_WIDTH              = 'd11;
parameter   ISP_DATA_WIDTH          = 'd32 * 'd8 *'d3;
parameter   ISP_ADDR_WIDTH          = 'd10;
parameter   DLA_ADDR_WIDTH          = 'd10;
parameter   DLA_DATA_WIDTH          = 'd32 * 'd8 * 'd4;
parameter   DATA_WIDTH              = 'd32 * 'd8;
parameter   ADDR_WIDTH              = 'd10;
parameter   DATA_DEPTH              = 'd256;
parameter   CLK_FULL                = 'd10;
parameter   CLK_HALF                = 'd5;



reg                                                   rst_n          ;
reg                                                   clk            ;
reg   [IMGW_WIDTH             -1: 0]                  img_width_i    ;
reg   [IMGH_WIDTH             -1: 0]                  img_height_i   ;
// 
reg                                                   top_start_i    ;
// isp - ppp interface
reg                                                   isp_rchn_i     ;
reg                                                   isp_resp_i     ;
wire                                                  isp_rdy_o      ;
reg                                                   isp_done_i     ;
wire  [ISP_DATA_WIDTH             -1: 0]              isp_rdata_o    ;
reg   [ISP_ADDR_WIDTH             -1: 0]              isp_raddr_i    ;
reg                                                   isp_ren_i      ;
reg   [ISP_DATA_WIDTH             -1: 0]              isp_wdata_i    ;
reg   [ISP_ADDR_WIDTH             -1: 0]              isp_waddr_i    ;
reg                                                   isp_wen_i      ;
reg                                                   isp_wchn_i     ;
// dla - ppp interface
reg                                                   dla_resp_i     ;
wire                                                  dla_rdy_o      ;
reg                                                   dla_done_i     ;
wire  [DLA_DATA_WIDTH             -1: 0]              dla_rdata_o    ;
reg   [DLA_ADDR_WIDTH             -1: 0]              dla_raddr_i    ;
reg                                                   dla_ren_i      ;
reg   [DLA_DATA_WIDTH             -1: 0]              dla_wdata_i    ;
reg   [DLA_ADDR_WIDTH             -1: 0]              dla_waddr_i    ;
reg                                                   dla_wen_i      ;


ppp_top #(
    .DLA_DATA_WIDTH                                      (DLA_DATA_WIDTH),
    .DLA_ADDR_WIDTH                                      (DLA_ADDR_WIDTH),
    .ISP_DATA_WIDTH                                      (ISP_DATA_WIDTH),
    .ISP_ADDR_WIDTH                                      (ISP_ADDR_WIDTH),
    .DATA_WIDTH                                          (DATA_WIDTH),
    .ADDR_WIDTH                                          (ADDR_WIDTH),
    .DATA_DEPTH                                          (DATA_DEPTH)
) u_ppp_top(
.clk                                (clk),
.rst_n                              (rst_n),
.img_width_i                        (img_width_i),
.img_height_i                       (img_height_i),
.top_start_i                        (top_start_i),
.isp_resp_i                         (isp_resp_i),
.isp_rdy_o                          (isp_rdy_o),
.isp_done_i                         (isp_done_i),
.isp_wdata_i                        (isp_wdata_i),
.isp_wen_i                          (isp_wen_i),
.isp_waddr_i                        (isp_waddr_i),
.isp_wchn_i                         (isp_wchn_i),
.isp_rdata_o                        (isp_rdata_o),
.isp_ren_i                          (isp_ren_i),
.isp_raddr_i                        (isp_raddr_i),
.isp_rchn_i                         (isp_rchn_i),
.dla_resp_i                         (dla_resp_i),
.dla_rdy_o                          (dla_rdy_o),
.dla_done_i                         (dla_done_i),
.dla_wdata_i                        (dla_wdata_i),
.dla_wen_i                          (dla_wen_i),
.dla_waddr_i                        (dla_waddr_i),
.dla_rdata_o                        (dla_rdata_o),
.dla_ren_i                          (dla_ren_i),
.dla_raddr_i                        (dla_raddr_i)
);

event isp_write_event;

initial begin
    ISP_WRITE;
end

task ISP_WRITE;
    integer  tile_i;
    integer  row_i;
    reg [768   -1: 0] data;
    reg [8      -1: 0] pix_dat;
begin
   forever begin
    @(isp_write_event);
    for(tile_i = 0; tile_i < 32; tile_i = tile_i + 1) begin
        for(row_i = 0; row_i < 32; row_i = row_i + 1) begin
            pix_dat = tile_i[7:0];
            data = {96{pix_dat}};
            @(negedge clk);
            isp_wen_i = 1'b1;
            isp_wdata_i = data;
            isp_waddr_i = {row_i[4:0], tile_i[4:0]};
        end
    end
    @(negedge clk);
    isp_wen_i = 1'b0;
    isp_done_i = 1'b1;
    @(negedge clk);
    isp_done_i = 1'b0;
   end 
end
endtask

event dla_read_event;

initial begin
    DLA_READ;
end

task DLA_READ;
    integer  tile_i;
    integer  row_i;
    reg [1024   -1: 0] check_data;
    reg [8      -1: 0] pix_dat;
begin
   forever begin
    @(dla_read_event);
    for(tile_i = 0; tile_i < 32; tile_i = tile_i + 1) begin
        for(row_i = 0; row_i < 8; row_i = row_i + 1) begin
            pix_dat = tile_i[7:0];
            check_data = {32{pix_dat}};
            @(negedge clk);
            dla_ren_i = 1'b1;
            dla_raddr_i = {2'b00,tile_i[4:0], row_i[2:0]};
            check_data = {128{pix_dat}};
            @(negedge clk);
            if(check_data != dla_rdata_o)   begin
                $display("MISMATCH!\n");
                $finish();
            end
        end
    end
    @(negedge clk);
    dla_wen_i = 1'b0;
    dla_done_i = 1'b1;
    @(negedge clk);
    dla_done_i = 1'b0;
   end 
end
endtask



initial begin
    clk = 1'b0;
    forever #5 clk <= ~clk;
end


initial begin
    rst_n  = 1'b0;
    #(CLK_FULL * 5) ;
    @(negedge clk);
    rst_n  = 1'b1;
end

// data 
initial begin
    img_height_i = 'd32;
    img_width_i  = 'd1024;
    isp_done_i = 'd0;
    dla_done_i = 'd0;
    isp_wen_i  = 'd0;
    isp_ren_i  = 'd0;
    isp_wchn_i = 'd1;
    isp_rchn_i = 'd1;
    dla_wen_i  = 'd0;
    dla_ren_i  = 'd0;
    #(CLK_FULL * 5) ;
    @(negedge clk);
    @(negedge clk);
    //start
    top_start_i = 'd1;
    @(negedge clk);
    top_start_i = 'd0;
    // ISP WRITE EVENT
    @(negedge clk);
    ->isp_write_event;
    @(posedge isp_done_i);
    // DLA READ EVENT
    @(negedge clk);
    ->dla_read_event;
    @(posedge dla_done_i);
    #(10 * CLK_FULL);
    $display("PASS !!!!!!!\n");
    $finish();
end


initial	begin
   $display("Dump fsdb wave!");
   $fsdbDumpfile("tb.fsdb");	    
   $fsdbDumpvars;
end

initial	begin
   $display("\033[30;41m Hello error!\033[0m");
   $display("\033[30;42m Hello pass!\033[0m");
   $display("\033[30;43m Hello warning!\033[0m");

end

endmodule