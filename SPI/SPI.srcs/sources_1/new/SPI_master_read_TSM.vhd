library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_master_read_TSM is
    generic(
        data_length : natural := 24
    );
    Port (
        CLK, RST, RD_EN, MISO : in std_logic;
        data : inout std_logic_vector(7 downto 0);
        ADDR : in std_logic_vector(data_length - 1 downto 0);
        MOSI, SS, SCLK : out std_logic);
end SPI_master_read_TSM;

architecture Behavioral of SPI_master_read_TSM is

type state is (ST_IDLE, ST0_TX_RD, ST1_TX_ADDR, ST2_RX_DATA);
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
    process (RD_EN, present_state, data_index)
    begin
        case present_state is
        
            when ST_IDLE =>
                timer <= 1;
                SS <= '1';
                SCLK <= '0';
                MOSI <= 'X';
                if (RD_EN = '1') then
                    next_state <= ST0_TX_RD;
                else
                    next_state <= ST_IDLE;
                end if;
                
            when ST0_TX_RD =>
                timer <= 8;
                SS <= '0';
                SCLK <= CLK;
                MOSI <= data(7 - data_index);
                next_state <= ST1_TX_ADDR;
                
            when ST1_TX_ADDR =>
                timer <= 24;
                SS <= '0';
                SCLK <= CLK;
                MOSI <= ADDR(23 - data_index);
                next_state <= ST2_RX_DATA;
            
            when ST2_RX_DATA =>
                timer <= 8;
                SS <= '0';
                SCLK <= CLK;
                data(7 - data_index) <= MISO;
                
        end case;
    end process;

end Behavioral;
