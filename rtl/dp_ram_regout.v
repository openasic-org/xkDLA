module dp_ram_regout #(
    parameter   KNOB_REGOUT   = 0,
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
    output  wire     [ DATA_WIDTH-1:0]   rd_data
);

reg [ DATA_WIDTH-1:0]   data_buf [ DATA_DEPTH-1:0];
reg [DATA_WIDTH + DATA_WIDTH * KNOB_REGOUT - 1 : 0] data_dly_r;

always@(posedge clk) begin
    if (wr_en) begin
        data_buf[wr_addr] <= wr_data;
    end
end

always @(posedge clk) begin
    if (rd_en) begin
        data_dly_r <= {data_dly_r ,data_buf[rd_addr]};
    end
    else begin
        data_dly_r <= data_dly_r;
    end
end

assign rd_data = data_dly_r[DATA_WIDTH + DATA_WIDTH * KNOB_REGOUT - 1 : DATA_WIDTH * KNOB_REGOUT];

endmodule