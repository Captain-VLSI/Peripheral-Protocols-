module baud_rate_generator (
    input clk,
    input rst,       
    output tx_enb,
    output rx_enb
);

  // Tx counts to 5208 (Needs 13 bits: 2^13 = 8192)
  reg [12:0] tx_counter;
  
  // Rx counts to 325 (Needs 9 bits: 2^9 = 512) -- FIXED from [2:0]
  reg [8:0]  rx_counter; 

  // --- TX Counter Logic ---
  always @(posedge clk) begin
    if (rst) begin
      tx_counter <= 13'd0;
    end
    else begin
      if (tx_counter == 13'd5208)
        tx_counter <= 13'd0;
      else
        tx_counter <= tx_counter + 1'b1; 
    end
  end

  // RX Counter Logic (16x Baud) 
  always @(posedge clk) begin
    if (rst) begin
      rx_counter <= 9'd0;
    end
    else begin
      if (rx_counter == 9'd325)
        rx_counter <= 9'd0;
      else
        rx_counter <= rx_counter + 1'b1;
    end
  end

  /
  // Generate a single-cycle HIGH pulse when counter hits the limit
  assign tx_enb = (tx_counter == 13'd5208) ? 1'b1 : 1'b0;
  assign rx_enb = (rx_counter == 9'd325)   ? 1'b1 : 1'b0;

endmodule
