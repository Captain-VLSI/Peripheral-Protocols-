module uart_receiver (
    input wire clk,
    input wire rst,
    input wire rx,
    input wire rdy_clr,    
    input wire clk_en,     
    output reg rdy,
    output reg [7:0] data_out
);

    localparam START_STATE = 2'b00;
    localparam DATA_OUT_STATE  = 2'b01; 
    localparam STOP_STATE  = 2'b10;

    reg [1:0] state;       
    reg [3:0] sample;
    reg [3:0] index;
    reg [7:0] temp_register;

    always @(posedge clk) begin
        if (rst) begin
            state <= START_STATE;
            rdy <= 0;
            data_out <= 0;
            sample <= 0;
            index <= 0;
            temp_register <= 0;
        end else begin
            if (rdy_clr)
                rdy <= 0;
          
            if (clk_en) begin
                case (state)
                    START_STATE: begin
                        if (rx == 0 || sample != 0) begin
                            sample <= sample + 1'b1;
                            if (sample == 7) begin
                                if (rx == 0) begin
                                    state <= DATA_OUT_STATE;
                                    sample <= 0;
                                    index <= 0;
                                end else begin
                                    sample <= 0;
                                end
                            end 
                        end
                    end

                    DATA_OUT_STATE: begin
                        sample <= sample + 1'b1;
                        
                        if (sample == 4'h8) begin 
                            temp_register[index] <= rx;
                            index <= index + 1'b1;
                        end

                        if (sample == 15 && index == 8) begin
                            state <= STOP_STATE;
                            sample <= 0;
                        end
                    end

                    STOP_STATE: begin
                        if (sample == 15) begin 
                            state <= START_STATE;
                            data_out <= temp_register;
                            rdy <= 1'b1;
                            sample <= 0;
                        end else begin
                            sample <= sample + 1'b1; 
                        end
                    end

                    default: state <= START_STATE;
                endcase
            end
        end
    end
endmodule
