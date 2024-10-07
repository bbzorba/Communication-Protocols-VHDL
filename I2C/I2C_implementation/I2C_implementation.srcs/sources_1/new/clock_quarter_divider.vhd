library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_quarter_divider is
    Port ( CLK : in STD_LOGIC;
           SCLK : out STD_LOGIC;
           DCLK: out STD_LOGIC);
end clock_quarter_divider;

architecture Behavioral of clock_quarter_divider is
    signal sclk_temp : std_logic := '0';  -- Initialize to '0'
    signal dclk_temp : std_logic := '0';  -- Initialize to '0'
    signal counter : natural range 0 to 3 := 0; -- Initialize counter to 0

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            counter <= counter + 1;
            case counter is
                when 0 =>
                    sclk_temp <= '0';
                    dclk_temp <= '1';
                when 1 =>
                    sclk_temp <= '1';
                    dclk_temp <= '1';
                when 2 =>
                    sclk_temp <= '1';
                    dclk_temp <= '0';
                when 3 =>
                    sclk_temp <= '0';
                    dclk_temp <= '0';
                    counter <= 0;  -- Reset counter after full cycle
                when others =>
                    counter <= 0; -- Safety fallback
            end case;
        end if;
    end process;

    -- Assign the temporary signals to the output ports
    SCLK <= sclk_temp;
    DCLK <= dclk_temp;

end Behavioral;
