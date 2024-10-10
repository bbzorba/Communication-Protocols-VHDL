library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_master_write_TSM is
    generic(
        data_length : natural := 8
    );
    Port (
        CLK, RST, TX_EN : in std_logic;
        data : in std_logic_vector(data_length - 1 downto 0);
        MOSI, SS, SCLK : out std_logic);
end SPI_master_write_TSM;

architecture Behavioral of SPI_master_write_TSM is

type state is (ST_IDLE, ST_TX);
signal present_state, next_state : state;

signal timer : natural range 0 to data_length - 1;
signal data_index : natural range 0 to data_length - 1;

begin

    --next state logic process
    process(CLK, RST)
    begin
    
        if (RST = '1') then
            present_state <= ST_IDLE;
            data_index <= 0;
        elsif (CLK'event and CLK = '0') then
            if (data_index = timer -1) then
                present_state <= next_state;
                data_index <= 0;
            else
                data_index <= data_index + 1;
            end if;
        end if;
    end process;
    
     --SPI machine process
    process (CLK, present_state)
    begin
        case present_state is
        
            when ST_IDLE =>
                timer <= 1;
                SS <= '1';
                SCLK <= '0';
                MOSI <= 'X';
                if (TX_EN = '1') then
                    next_state <= ST_TX;
                else
                    next_state <= ST_IDLE;
                end if;
                
            when ST_TX =>
                timer <= 8;
                SS <= '0';
                SCLK <= CLK;
                MOSI <= data(7 - data_index);
                next_state <= ST_IDLE;
            
        end case;
    end process;

end Behavioral;
