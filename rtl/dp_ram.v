module dp_ram #(
    parameter   ADDR_WIDTH    = 10,
    parameter   DATA_WIDTH    = 256,
    parameter   DATA_DEPTH    = 1024
)(
    input   wire                         clk,
    input   wire     [ ADDR_WIDTH-1:0]   wr_addr,
    input   wire                         wr_en,
    input   wire     [ DATA_WIDTH-1:0]   wr_data,
    input   wire     [ ADDR_WIDTH-1:0]   rd_addr,
    input   wire                         rd_en,
    output  reg      [ DATA_WIDTH-1:0]   rd_data
);

reg [ DATA_WIDTH-1:0]   data_buf [ DATA_DEPTH-1:0];

always@(posedge clk) begin
    if (wr_en) begin
        data_buf[wr_addr] <= wr_data;
    end
end

always @(posedge clk) begin
    if (rd_en) begin
        rd_data <= data_buf[rd_addr];
    end
    else begin
        rd_data <= rd_data;
    end
end

endmodule