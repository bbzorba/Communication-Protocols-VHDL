library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider_by_100 is
    Port ( CLK : in STD_LOGIC;
           SCLK : out STD_LOGIC;
           DCLK : out STD_LOGIC);
end clock_divider_by_100;

architecture Behavioral of clock_divider_by_100 is

    -- Signal to connect the output of clock_division to the input of clock_quarter_divider
    signal CLK_divided_to_25 : STD_LOGIC;

begin

    -- Instantiate the clock_division entity
    U1: entity work.clock_divider_by_25
        port map (
            CLK => CLK, -- Input clock
            CLK_divided_to_25 => CLK_divided_to_25 -- Output divided clock
        );

    -- Instantiate the clock_quarter_divider entity
    U2: entity work.clock_quarter_divider
        port map (
            CLK => CLK_divided_to_25, -- Use divided clock as input
            SCLK => SCLK, -- Output SCLK
            DCLK => DCLK  -- Output DCLK
        );

end Behavioral;
