module uart_transmitter (
    input clk,
    input wr_enb,
    input enb,      // Baud rate enable tick
    input rst,
    input [7:0] data_in,
    output reg tx,
    output busy
);

  parameter idle_state  = 2'b00;
  parameter start_state = 2'b01;
  parameter data_state  = 2'b10;
  parameter stop_state  = 2'b11;

  reg [7:0] data;
  reg [2:0] index;
  reg [1:0] state;

  assign busy = (state != idle_state);

  always @(posedge clk) begin
    if (rst) begin
      state <= idle_state;
      tx    <= 1'b1;       // UART line idle is High
      index <= 3'b0;
      data  <= 8'b0;
    end
    else begin
      case (state)
        idle_state: begin
          tx <= 1'b1;      // Ensure line is high in idle
          if (wr_enb) begin
            state <= start_state;
            data  <= data_in;
            index <= 3'b0;
          end
        end

        start_state: begin
          // Wait for baud tick to start driving
          if (enb) begin
            tx    <= 1'b0; // Drive Start Bit (Low)
            state <= data_state;
          end
        end

        data_state: begin
          if (enb) begin
            tx <= data[index]; // Send current bit (LSB first)
            
            if (index == 3'h7) begin
              state <= stop_state;
            end
            else begin
              index <= index + 1'b1; // Non-blocking increment
            end
          end
        end

        stop_state: begin
          if (enb) begin
            tx    <= 1'b1; // Drive Stop Bit (High)
            state <= idle_state; 
          end
        end

        default: begin
          state <= idle_state;
          tx    <= 1'b1;
        end
      endcase
    end
  end

endmodule
