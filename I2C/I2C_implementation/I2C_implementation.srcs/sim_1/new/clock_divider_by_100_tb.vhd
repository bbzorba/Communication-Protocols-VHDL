library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_clock_divier_by_100 is
end tb_clock_divier_by_100;

architecture Behavioral of tb_clock_divier_by_100 is

    -- Signal declarations for testbench
    signal CLK : STD_LOGIC := '0';
    signal SCLK : STD_LOGIC;
    signal DCLK : STD_LOGIC;
    
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock period

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: entity work.clock_divier_by_100
        port map (
            CLK => CLK,   -- Input clock (100 MHz)
            SCLK => SCLK, -- Output SCLK
            DCLK => DCLK  -- Output DCLK
        );

    -- Clock generation process (100 MHz)
    clk_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_process;

    -- Monitor SCLK and DCLK to check the division
    monitor_process : process
    begin
        wait for 1000 * CLK_PERIOD; -- Wait for enough time to see the output clocks stabilize
        report "Simulation finished" severity note;
        wait;
    end process monitor_process;

end Behavioral;
