// axi_lite_basic_io.sv

`default_nettype none

module axi_lite_basic_io # (
    parameter int BASE_ADDRESS = 32'hC000_0000,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int STRB_WIDTH = DATA_WIDTH / 8
)(
    /* AXI Lite Slave Interface */
    input   logic                       s_axi_aclk,
    input   logic                       s_axi_aresetn,

    input   logic                       s_axi_awvalid,
    output  logic                       s_axi_awready,
    input   logic   [ADDR_WIDTH-1:0]    s_axi_awaddr,

    input   logic                       s_axi_wvalid,
    output  logic                       s_axi_wready,
    input   logic   [DATA_WIDTH-1:0]    s_axi_wdata,
    input   logic   [STRB_WIDTH-1:0]    s_axi_wstrb,

    output  logic                       s_axi_bvalid,
    input   logic                       s_axi_bready,
    output  logic   [1:0]               s_axi_bresp,

    input   logic                       s_axi_arvalid,
    output  logic                       s_axi_arready,
    input   logic   [ADDR_WIDTH-1:0]    s_axi_araddr,

    output  logic                       s_axi_rvalid,
    input   logic                       s_axi_rready,
    output  logic   [DATA_WIDTH-1:0]    s_axi_rdata,
    output  logic   [1:0]               s_axi_rresp,

    /* Basic IO PHY */
    output  logic   [7:0]               o_leds,
    input   logic   [7:0]               i_switches,
    input   logic   [4:0]               i_buttons
);


// button and switch debouncing
logic [7:0] switches_debounced;
logic [4:0] buttons_debounced;
debouncer # (
    .DATA_WIDTH (13),
    .CNTR_WIDTH (20)
) u_DEBOUNCE_SWITCH (
    .clk        (s_axi_aclk),
    .rst_n      (s_axi_aresetn),
    .i_async    ({i_buttons, i_switches}),
    .o_data     ({buttons_debounced, switches_debounced})
);

// memory mapped axi-lite
localparam int LedsOffset = 'h0;
localparam int SwitchesOffset = 'h4;
localparam int ButtonsOffset = 'h8;

logic                   we;
logic [ADDR_WIDTH-1:0]  waddr;
logic [DATA_WIDTH-1:0]  wdata;
logic                   waddr_invalid = 0;
logic                   re;
logic [ADDR_WIDTH-1:0]  raddr;
logic [DATA_WIDTH-1:0]  rdata = 0;
logic                   raddr_invalid;

s_axi_lite_mm # (
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
) u_MM_IF (
    .s_axi_aclk         (s_axi_aclk),
    .s_axi_aresetn      (s_axi_aresetn),
    .s_axi_awvalid      (s_axi_awvalid),
    .s_axi_awready      (s_axi_awready),
    .s_axi_awaddr       (s_axi_awaddr),
    .s_axi_wvalid       (s_axi_wvalid),
    .s_axi_wready       (s_axi_wready),
    .s_axi_wdata        (s_axi_wdata),
    .s_axi_wstrb        (s_axi_wstrb),
    .s_axi_bvalid       (s_axi_bvalid),
    .s_axi_bready       (s_axi_bready),
    .s_axi_bresp        (s_axi_bresp),
    .s_axi_arvalid      (s_axi_arvalid),
    .s_axi_arready      (s_axi_arready),
    .s_axi_araddr       (s_axi_araddr),
    .s_axi_rvalid       (s_axi_rvalid),
    .s_axi_rready       (s_axi_rready),
    .s_axi_rdata        (s_axi_rdata),
    .s_axi_rresp        (s_axi_rresp),
    .o_we               (we),
    .o_waddr            (waddr),
    .o_wdata            (wdata),
    .i_waddr_invalid    (waddr_invalid),
    .o_re               (re),
    .o_raddr            (raddr),
    .i_rdata            (rdata),
    .i_raddr_invalid    (raddr_invalid)
);

// write decoder
logic [7:0] leds = 8'h0;
assign o_leds = leds;

always_ff @(posedge s_axi_aclk) begin
    if (we) begin
        unique case (waddr)
            BASE_ADDRESS + LedsOffset: begin
                leds <= wdata[7:0];
                waddr_invalid <= 1'b0;
            end

            default: begin
               leds <= leds;
               waddr_invalid <= 1'b1;
            end
        endcase
    end

    if (!s_axi_aresetn) begin
        leds <= 8'h0;
        waddr_invalid <= 0;
    end
end

// read decoder
always_comb begin
    raddr_invalid = 0;
    rdata = 0;
    if (re) begin
        unique case (raddr)
            BASE_ADDRESS + LedsOffset: begin
                rdata = {{(DATA_WIDTH-8){1'b0}}, leds};
            end

            BASE_ADDRESS + SwitchesOffset: begin
                rdata = {{(DATA_WIDTH-8){1'b0}}, switches_debounced};
            end

            BASE_ADDRESS + ButtonsOffset: begin
                rdata = {{{(DATA_WIDTH-5)}{1'b0}}, buttons_debounced};
            end

            default: begin
                rdata = {(DATA_WIDTH){1'b0}};
                raddr_invalid = 1;
            end
        endcase
    end
end

endmodule
