// uart example from https://learn.lushaylabs.com/tang-nano-series/
// mirac gulgonul - 2023
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
  localparam RX_STATE_IDLE = 0;
  localparam RX_STATE_START_BIT = 1;
  localparam RX_STATE_READ_WAIT = 2;
  localparam RX_STATE_READ = 3;
  localparam RX_STATE_STOP_BIT = 5;

  // receive state machine with 5 states
  // idle, start bit, read wait, read, stop bit
  reg [3:0] rx_state = 0;  // 6 states
  reg [12:0] rx_counter = 0;  // counting clock pulses
  reg [2:0] rx_bit_number = 0;  // how many bits read
  reg [7:0] data_in = 0;  // store the byte to be received
  reg byte_ready = 0;  // flag, high when data is ready

  // uart receive
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
        rx_counter <= rx_counter + 1;
        if ((rx_counter + 1) == DELAY_FRAMES) begin
          rx_state <= RX_STATE_READ;
        end
      end

      RX_STATE_READ: begin
        rx_counter <= 1;
        // append received to data array
        data_in <= {uart_rx, data_in[7:1]};
        rx_bit_number <= rx_bit_number + 1;
        // try 'd7 instead?
        if (rx_bit_number == 3'b111) rx_state <= RX_STATE_STOP_BIT;
        else rx_state <= RX_STATE_READ_WAIT;
      end

      RX_STATE_STOP_BIT: begin
        rx_counter <= rx_counter + 1;
        if ((rx_counter + 1) == DELAY_FRAMES) begin
          rx_state   <= RX_STATE_IDLE;
          rx_counter <= 0;
          byte_ready <= 1;
        end
      end
    endcase
  end

  // display received byte on leds
  always @(posedge clk) begin
    if (byte_ready) begin
      led <= ~data_in[5:0];
    end
  end
endmodule
