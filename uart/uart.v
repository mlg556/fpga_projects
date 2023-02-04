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

  // RECEIVE
  localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);
  localparam RX_STATE_IDLE = 0;
  localparam RX_STATE_START_BIT = 1;
  localparam RX_STATE_READ_WAIT = 2;
  localparam RX_STATE_READ = 3;
  localparam RX_STATE_STOP_BIT = 4;

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

  // TRANSMIT
  reg [3:0] tx_state = 0;
  reg [24:0] tx_counter = 0;  // for clock edge, timing
  reg [7:0] data_out = 0;
  reg tx_pin_register = 1;
  reg [2:0] tx_memory_loc = 0;
  reg [3:0] tx_byte_counter = 0;

  assign uart_tx = tx_pin_register;

  // 12 cells of 8 bit fake memory
  localparam MEMORY_LENGTH = 12;
  reg [7:0] test_memory[MEMORY_LENGTH-1:0];

  initial begin
    test_memory[0]  = "H";
    test_memory[1]  = "e";
    test_memory[2]  = "l";
    test_memory[3]  = "l";
    test_memory[4]  = "o";
    test_memory[5]  = " ";
    test_memory[6]  = "t";
    test_memory[7]  = "h";
    test_memory[8]  = "e";
    test_memory[9]  = "r";
    test_memory[10] = "e";
    test_memory[11] = "!";
  end

  localparam TX_STATE_IDLE = 0;
  localparam TX_STATE_START_BIT = 1;
  localparam TX_STATE_WRITE = 2;
  localparam TX_STATE_STOP_BIT = 3;
  localparam TX_STATE_DEBOUNCE = 4;

  /*
  The idle state waits for the button to be pressed (which will make it go low) at which point we will move to the start bit state. If the button is not pressed we set the uart_tx to be high as in UART we have a high idle state.
  */
  always @(posedge clk) begin
    case (tx_state)
      TX_STATE_IDLE: begin
        if (btn1 == 0) begin
          tx_state <= TX_STATE_START_BIT;
          tx_counter <= 0;
          tx_byte_counter <= 0;
        end else tx_pin_register <= 1;
      end

      /*
      The start bit is a low signal for DELAY_FRAMES, once reached we put the next byte we need to send into dataOut and reset the txBitNumber back to 0.
      */
      TX_STATE_START_BIT: begin
        tx_pin_register <= 0;
        // refactor to:
        // if ((tx_counter < DELAY_FRAMES))
        if ((tx_counter + 1) == DELAY_FRAMES) begin
          tx_state <= TX_STATE_WRITE;
          data_out <= test_memory[tx_byte_counter];
          tx_memory_loc <= 0;
          tx_counter <= 0;
        end else tx_counter <= tx_counter + 1;
      end

      /*
      The write state is very similar, except instead of setting the tx pin to low, we set it to the current bit of the current byte. When the frame is over we check if we are already on the last bit, if so we go to the stop bit state, otherwise we increment the bit number and keep the current state of TX_STATE_WRITE.
      */
      TX_STATE_WRITE: begin
        tx_pin_register <= data_out[tx_memory_loc];
        if ((tx_counter + 1) == DELAY_FRAMES) begin
          if (tx_memory_loc == 3'b111) begin
            tx_state <= TX_STATE_STOP_BIT;
          end else begin
            tx_state <= TX_STATE_WRITE;
            tx_memory_loc <= tx_memory_loc + 1;
          end
          tx_counter <= 0;
        end else tx_counter <= tx_counter + 1;
      end

      /*
      The stop bit is a high output bit, after waiting DELAY_FRAMES we check if there are any other bytes to send, if there are, we go back to send another start bit and the cycle will repeat for the next byte. If not we go to the debounce state.
      */
      TX_STATE_STOP_BIT: begin
        tx_pin_register <= 1;
        if ((tx_counter + 1) == DELAY_FRAMES) begin
          if (tx_byte_counter == MEMORY_LENGTH - 1) begin
            tx_state <= TX_STATE_DEBOUNCE;
          end else begin
            tx_byte_counter <= tx_byte_counter + 1;
            tx_state <= TX_STATE_START_BIT;
          end
          tx_counter <= 0;
        end else tx_counter <= tx_counter + 1;
      end

      TX_STATE_DEBOUNCE: begin
        // 27_000_000 -> 1000 ms delay
        // 5*270_000 -> 50 ms delay
        if (tx_counter == 5 * 270_000) begin
          if (btn1 == 1) tx_state <= TX_STATE_IDLE;
        end else tx_counter <= tx_counter + 1;
      end
    endcase
  end
endmodule
