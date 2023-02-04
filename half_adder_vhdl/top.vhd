library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    btn1 : in std_logic;
    btn2 : in std_logic;

    led[0] : out std_logic;
    led[1] : out std_logic;
  ) ;
end top;

architecture rtl of top is
    --signal a,b,c,d : std_logic;

    component half_adder is
        port (
            i_bit1  : in std_logic;
            i_bit2  : in std_logic;
            --
            o_sum   : out std_logic;
            o_carry : out std_logic
            );
    end component;
    
    begin
        hf : half_adder port map (
            i_bit1 => btn1,
            i_bit2 => btn2,

            o_sum => led[0],
            o_carry => led[1}
        );

end rtl;
