module uart_top (
    input  wire clk,
    input  wire rst,
    input  wire rx,          // External Serial Input
    input  wire wr_en,       // User button to send
    input  wire [7:0] din,   // User switches for data
    input  wire rdy_clr,     // User acknowledge
    output wire tx,          // External Serial Output
    output wire busy,        // LED 1
    output wire rdy,         // LED 2
    output wire [7:0] dout   // LEDs 3-10
);

    wire tx_tick;
    wire rx_tick;

    // 1. Baud Rate Generator
    // Matches your module: input clk, rst, output tx_enb, rx_enb
    baud_rate_generator baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .tx_enb(tx_tick),
        .rx_enb(rx_tick)
    );

    // 2. UART Transmitter
    // Matches your module: clk, wr_enb, enb, rst, data_in, tx, busy
    uart_transmitter tx_inst (
        .clk(clk),
        .rst(rst),         // <--- This was missing before!
        .wr_enb(wr_en),
        .enb(tx_tick),
        .data_in(din),
        .tx(tx),
        .busy(busy)
    );

    // 3. UART Receiver
    // Matches your module: clk, rst, rx, rdy_clr, clk_en, rdy, data_out
    uart_receiver rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rdy_clr(rdy_clr),
        .clk_en(rx_tick),
        .rdy(rdy),
        .data_out(dout)
    );

endmodule
