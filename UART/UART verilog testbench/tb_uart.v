module uart_top_tb;

  reg clk;
  reg rst;
  reg [7:0] data_in;
  reg wr_en;
  
  wire tx;
  wire rdy;
  reg rdy_clr;
  wire [7:0] dout;
  wire busy;

  uart_top dut (
      .clk(clk),
      .rst(rst),
      .rx(tx),         
      .wr_en(wr_en),
      .din(data_in),
      .rdy_clr(rdy_clr),
      .tx(tx),
      .busy(busy),
      .rdy(rdy),
      .dout(dout)
  );

  initial begin
    {clk, rst, data_in, rdy_clr, wr_en} = 0; 
  end

  always #5 clk = ~clk;

  task send_byte (input [7:0] din);
    begin
      @(negedge clk);
      data_in = din;
      wr_en = 1'b1;

      @(negedge clk);
      wr_en = 1'b0;
    end
  endtask

  task clear_ready;
    begin
      rdy_clr = 1'b1;
      @(negedge clk);
      rdy_clr = 1'b0;
    end
  endtask


  initial begin
   
    @(negedge clk);
    rst = 1'b1;
    @(negedge clk);
    rst = 1'b0;

    send_byte(8'h41);
    
    wait(busy); 

    wait(!busy);
    wait(rdy);
    
    $display("Time: %0t | Sent: 41 | Received: %h", $time, dout);
    clear_ready;

    #100;

    send_byte(8'h55);
    
    wait(busy);
    wait(!busy);
    wait(rdy);
    
    $display("Time: %0t | Sent: 55 | Received: %h", $time, dout);
    clear_ready;

    #400 $finish;
  end

endmodule
