// uart testbench example from lushay labs
// mirac gulgonul - 2023

// test module has no inputs/outputs
// instantiates the module to be tested, in this case uart
// and makes the required connections

module test ();
  reg clk = 0;
  reg uart_rx = 1;
  wire uart_tx;
  wire [5:0] led;
  reg btn = 1;

  uart #(8'd8) u (
      clk,
      uart_rx,
      uart_tx,
      led,
      btn
  );

  /*
  The #number (#1) is a special simulation syntax from iverilog that allows
  us to delay something by a certain number of time frames.
  By saying each time interval the clock alternates, we are saying the clock
  cycle is 2 time units (1 high cycle and 1 low cycle is 1 clock cycle).
  So this loop will wait 1 time unit and toggle the clock register.
  */
  always #1 clk = ~clk;

  initial begin
    $display("Starting UART RX");
    $monitor("LED Value %b", led);

    #10 uart_rx = 0;  // start bit
    #16 uart_rx = 1;  // bit 1
    #16 uart_rx = 0;  // bit 2
    #16 uart_rx = 0;  // bit 3
    #16 uart_rx = 0;  // bit 4
    #16 uart_rx = 0;  // bit 5
    #16 uart_rx = 1;  // bit 6
    #16 uart_rx = 1;  // bit 7
    #16 uart_rx = 0;  // bit 8
    #16 uart_rx = 1;  // stop bit
    #1000 $finish;
  end

  initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, test);
  end

endmodule
