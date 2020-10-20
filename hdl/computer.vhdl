library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library computer_lib;
use computer_lib.all;

entity computer is
    port (
        CLK : in std_logic;
        RST : in std_logic;
        MANUAL_CLOCK : in std_logic;
        CLOCK_SELECT : in std_logic;
        CLOCK_OUT : out std_logic
    );
end computer;

architecture rtl of computer is

begin

    clock_selector_i : entity computer_lib.clock_selector
    generic map(
        debounce_count => 100,
        slow_clock_count => 20_000_000
    )
    port map(
        clock => CLK,
        manual_clock => MANUAL_CLOCK,
        clock_select => CLOCK_SELECT,
        clock_out => CLOCK_OUT
    );

end architecture;