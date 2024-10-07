library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider_by_25 is
    Port ( CLK : in STD_LOGIC;
           CLK_divided_to_25 : out STD_LOGIC);
end clock_divider_by_25;

architecture Behavioral of clock_divider_by_25 is

    signal counter: natural range 0 to 11 := 0; -- Initialize counter to 0
    signal clock_output: std_logic := '0';      -- Initialize clock_output to '0'

begin
    process(CLK)
    begin
        if(rising_edge(CLK)) then
            counter <= counter + 1;
            if (counter = 11) then
                clock_output <= not clock_output;
                counter <= 0;
            end if;
        end if;
    end process;
    CLK_divided_to_25 <= clock_output;

end Behavioral;
