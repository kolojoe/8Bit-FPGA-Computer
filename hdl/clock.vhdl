library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity clock_selector is
  generic(
    -- clock_frequency : natural;
    debounce_count : natural;
    slow_clock_count : natural
  );
  port (
    clock : in std_logic; -- Input clock from the board. May be 50MHz
    manual_clock : in std_logic; -- Manual "clock" input from the board. This will be hooked up to a button.
    clock_select : in std_logic; -- The clock selector input from the board.
    clock_out : out std_logic -- The chosen clock output on the board.
  );
end clock_selector;

architecture rtl of clock_selector is

    signal manual_clock_d1 : std_logic;
    signal manual_clock_d2 : std_logic;
    signal debounced_clock : std_logic := '0';
    signal slowed_clock : std_logic := '0';

begin
    -- Clock selection
    clock_out <= slowed_clock when clock_select = '0' else
                    debounced_clock;

    -- This process pipelines the manual clock input such that we have
    -- two registers with the current and previous values of the button press.
    -- While the values are equal we count up on the debounce_clock process
    -- and if they change we reset the debounce_clock and count again.
    manual_clock_pipeline : process(clock, manual_clock) is
    begin
        if rising_edge(clock) then
            manual_clock_d1 <= manual_clock;
            manual_clock_d2 <= manual_clock_d1;
        end if;
    end process manual_clock_pipeline;

    -- This process debounces the user's manual input clock given the
    -- debounce count.
    debounce_clock : process(clock) is
        -- Should consider adding logic to reset the clock_count to 0 when user
        -- selects manual clock
        variable clock_count : natural range 0 to debounce_count := 0;
    begin
        if rising_edge(clock) then
            if manual_clock_d1 /= manual_clock_d2 then -- Reset if the pipeline changes value
                clock_count := 0;
            elsif clock_count = debounce_count then -- Set the debounced_clock finally
                debounced_clock <= manual_clock_d2;
                clock_count := 0;
            else -- Count up when we're not there yet
                clock_count := clock_count + 1;
            end if;
        end if;
    end process debounce_clock;

    -- This process slows the clock down by counting with the main on-board input clock
    -- and flipping the clock after so many counts.
    slow_clock : process(clock) is
        variable slow_count : natural range 0 to slow_clock_count := 0;
    begin
        if rising_edge(clock) then
            if slow_count = slow_clock_count then
                slowed_clock <= not slowed_clock;
                slow_count := 0;
            else
                slow_count := slow_count + 1;
            end if;
        end if;
    end process slow_clock;

end architecture ;