module oled #(
    parameter STARTUP_DELAY = 32'd100000000
) (
    input clk,
    output oled_sck,  // d0
    output oled_mosi,  // d1
    output oled_reset,
    output oled_dc,
    output oled_cs  // does not exist on my oled

);
  // state machine, 5 states, 8 bits
  localparam STATE_INIT_POWER = 8'd0;
  localparam STATE_INIT_CMD = 8'd1;
  localparam STATE_SEND = 8'd2;
  localparam STATE_INIT_FINISH = 8'd3;
  localparam STATE_LOAD_DATA = 8'd4;

  reg [32:0] counter = 0;
  reg [2:0] state = 0;

  reg sck = 1;
  reg mosi = 0;
  reg reset = 1;
  reg dc = 1;
  reg cs = 0;

  reg [7:0] data_to_send = 0;
  reg [3:0] bit_num = 0;  // which bit of the current byte, 8 bits in a bytes to len=3
  reg [9:0] pixel_counter = 0;  // which pixel on the screen

  localparam INIT_COMMANDS_SIZE = 23;
  reg [(INIT_COMMANDS_SIZE*8)-1 : 0] init_commands = {
    // display off
    8'hAE,
    // set contrast
    8'h81,
    8'h7F,
    // screen mode, non-inverted
    8'hA6,
    // horizontal addressing mode
    8'h20,
    8'h00,
    // scan direction, normal
    8'hC8,
    // scan line start
    8'h40,
    // address 0
    8'hA1,
    // mux ratio, 64-1=63
    8'hA8,
    8'h3F,
    // display offset: no
    8'hD3,
    8'h00,
    // clock div ratio, default
    8'hD5,
    8'h80,
    // precharge, default
    8'hD9,
    8'h22,
    // vcom deselect level
    8'hDB,
    8'h20,
    8'h8D,
    8'h14,
    8'hA4,
    8'hAF
  };

  reg [7:0] command_index = INIT_COMMANDS_SIZE * 8;

  // wiring
  assign oled_sck = sck;
  assign oled_mosi = mosi;
  assign oled_reset = reset;
  assign oled_dc = dc;
  assign oled_cs = cs;

  // state machine
  always @(posedge clk) begin
    case (state)
      STATE_INIT_POWER: begin
        // reset pulse
        counter <= counter + 1;
        if (counter < STARTUP_DELAY) reset <= 1;
        else if (counter < STARTUP_DELAY * 2) reset <= 0;
        else if (counter < STARTUP_DELAY * 3) reset <= 1;
        else begin
          state   <= STATE_INIT_CMD;
          counter <= 32'b0;
        end
      end

      STATE_INIT_CMD: begin
        dc <= 0;
        // Usually we use the syntax [MSB:LSB] to access memory here we are using [MSB-:LEN] there is also the option with [LSB+:LEN]
        data_to_send <= init_commands[(command_index-1)-:8'd8];
        state <= STATE_SEND;
        bit_num <= 3'd7;  // decrement bit_num
        cs <= 0;
        command_index <= command_index - 8'd8;  // decrement index
      end

      STATE_SEND: begin
        // pull clock low, set the data pin
        if (counter == 32'd0) begin
          sck <= 0;
          mosi <= data_to_send[bit_num];
          counter <= 32'd1;  // reset counter?
        end else begin
          counter <= 32'd0;
          sck <= 1;
          if (bit_num == 0) state <= STATE_INIT_FINISH;  // whole byte sent
          else bit_num <= bit_num - 1;
        end
      end

      STATE_INIT_FINISH: begin
        cs <= 1;
        // commands are done, move to load pixel data
        if (command_index == 0) state <= STATE_LOAD_DATA;
        // there are still commands to be sent
        else
          state <= STATE_INIT_CMD;
      end

      STATE_LOAD_DATA: begin
        pixel_counter <= pixel_counter + 1;
        cs <= 0;
        dc <= 1;
        bit_num <= 3'd7;
        state <= STATE_SEND;

        if (pixel_counter < 127) data_to_send <= 8'b01010111;  // test pattern
        else data_to_send <= 0;
      end
    endcase
  end
endmodule
