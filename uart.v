`default_nettype none

module uart #(
    parameter DELAY_FRAMES = 234  // 27MHz at 115_200 baudrate 
) (
    input clk,
    input uart_rx,
    output uart_tx,
    output reg [5:0] led,
    input btn1

);

  localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);

  // receive state machine with 5 states
  // idle, start bit, read wait, read, stop bit
  reg [3:0] rx_state = 0;  // 6 states
  reg [12:0] rx_counter = 0;  // counting clock pulses
  reg [2:0] rx_bit_number = 0;  // how many bits read
  reg [7:0] dataIn = 0;  // store the byte to be received
  reg byte_ready = 0;  // flag, high when data is ready

  always @(posedge clk) begin
    case (rx_state)  // state machine case switch

      RX_STATE_IDLE: begin
        if (uart_rx == 0) begin
          rx_state <= RX_STATE_START_BIT;  // move to startbit state
          rx_counter <= 1;  // init counter
          rx_bit_number <= 0;  // 0 bits data read
          byte_ready <= 0;  // data not ready
        end
      end

      RX_STATE_START_BIT: begin
        if (rx_counter == HALF_DELAY_WAIT) begin
          rx_state   <= RX_STATE_READ_WAIT;
          rx_counter <= 1;
        end else rx_counter <= rx_counter + 1;
      end

      RX_STATE_READ_WAIT: begin

      end

    endcase

  end

endmodule
