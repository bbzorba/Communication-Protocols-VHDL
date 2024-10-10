library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_master_write_FSM is
    generic(
        data_length : natural := 8
    );
    Port ( 
        CLK, RST, TX_EN : in std_logic;
        data : in std_logic_vector(data_length - 1 downto 0);
        MOSI, SS, SCLK: out std_logic);
end SPI_master_write_FSM;

architecture Behavioral of SPI_master_write_FSM is

type state is (ST_IDLE, ST_TX_BIT7, ST_TX_BIT6, ST_TX_BIT5, ST_TX_BIT4, ST_TX_BIT3, ST_TX_BIT2, ST_TX_BIT1, ST_TX_BIT0);
signal present_state, next_state: state;

begin
    
    --next state logic process
    process(CLK, RST)
    begin
    
        if (RST = '1') then
            present_state <= ST_IDLE;
        elsif (CLK'event and CLK = '0') then
            present_state <= next_state;
        end if;
    end process;
    
    --SPI machine process
    process (CLK, present_state)
    begin
        case present_state is
        
            when ST_IDLE =>
                SS <= '1';
                SCLK <= '0';
                MOSI <= 'X';
                if (TX_EN = '1') then
                    next_state <= ST_TX_BIT7;
                else
                    next_state <= ST_IDLE;
                end if;
                
            when ST_TX_BIT7 =>
                SS <= '0';
                MOSI <= data(7);
                next_state <= ST_TX_BIT6;
                
            when ST_TX_BIT6 =>
                SS <= '0';
                MOSI <= data(6);
                next_state <= ST_TX_BIT5;
                
            when ST_TX_BIT5 =>
                SS <= '0';
                MOSI <= data(5);
                next_state <= ST_TX_BIT4;
            
            when ST_TX_BIT4 =>
                SS <= '0';
                MOSI <= data(4);
                next_state <= ST_TX_BIT3;
                
            when ST_TX_BIT3 =>
                SS <= '0';
                MOSI <= data(3);
                next_state <= ST_TX_BIT2;
            
            when ST_TX_BIT2 =>
                SS <= '0';
                MOSI <= data(2);
                next_state <= ST_TX_BIT1;
            
            when ST_TX_BIT1 =>
                SS <= '0';
                MOSI <= data(1);
                next_state <= ST_TX_BIT0;
            
            when ST_TX_BIT0 =>
                SS <= '0';
                MOSI <= data(0);
                next_state <= ST_IDLE;
            
        end case;
    end process;
    
end Behavioral;
