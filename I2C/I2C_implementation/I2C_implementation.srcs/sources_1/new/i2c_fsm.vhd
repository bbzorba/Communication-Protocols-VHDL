library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_write is
    Port ( 
        CLK    : in  STD_LOGIC;
        RESET  : in  STD_LOGIC;
        WRT_EN : in  STD_LOGIC;
        SCLK   : out STD_LOGIC;
        SDA    : inout STD_LOGIC
    );
end i2c_write;

architecture Behavioral of i2c_write is

    type state is (ST_IDLE, ST0_START, ST1_TX_SLAVE_ADDR, ST2_ACK1, ST3_TX_REG_ADDR, ST4_ACK2, ST5_TX_DATA, ST6_ACK3, ST7_STOP);
    signal present_state, next_state: state;
    signal DCLK: std_logic; -- Use for timing state transitions
    constant data: std_logic_vector(7 downto 0) := "11101100";
    constant slave_address: std_logic_vector(7 downto 0) := "11101100"; -- With write flag
    constant reg_address: std_logic_vector(7 downto 0) := "11101100";

    constant max_length: natural := 8;
    constant max_delay: natural := 8;

    signal data_index: natural range 0 to max_length - 1 := 0;
    signal timer: natural range 0 to max_delay := 0;
    signal ack_bits: std_logic_vector(2 downto 0);

begin

    U0: entity work.clock_divider_by_100
        port map (
            CLK => CLK,
            SCLK => open,  -- Remove this signal from the clock divider
            DCLK => DCLK
        );

    -- next state logic
    process(CLK, RESET)
    begin
        if (RESET = '1') then
            present_state <= ST_IDLE;
            data_index <= 0;
            timer <= 0;
        elsif rising_edge(CLK) then  -- Use DCLK for timing
            if (data_index = timer - 1) then
                present_state <= next_state;
                data_index <= 0;
            else
                data_index <= data_index + 1;
            end if;
        end if;

        -- Capture ACK bits during specific states
        if (present_state = ST2_ACK1) then
            ack_bits(0) <= SDA;
        elsif (present_state = ST4_ACK2) then
            ack_bits(1) <= SDA;
        elsif (present_state = ST6_ACK3) then
            ack_bits(2) <= SDA;
        end if;
    end process;

    -- FSM for state transitions and SCLK/SDA control
    process(present_state, WRT_EN, CLK)
    begin
        case present_state is
            when ST_IDLE =>
                SCLK <= '1';  -- Idle state: Keep SCLK high
                SDA <= '1';            -- SDA idle high
                timer <= 1;            -- Small delay
                if(WRT_EN = '1') then
                    next_state <= ST0_START;
                else
                    next_state <= ST_IDLE;
                end if;
                
            when ST0_START =>
                SCLK <= '1';  -- Keep SCLK high for start
                SDA <= DCLK;            -- Start condition (SDA low)
                timer <= 1;
                next_state <= ST1_TX_SLAVE_ADDR;
                
            when ST1_TX_SLAVE_ADDR =>
                SCLK <= CLK;  -- Toggle SCLK to clock out bits
                SDA <= slave_address(7 - data_index);  -- Send slave address
                timer <= 8;
                next_state <= ST2_ACK1;
                
            when ST2_ACK1 =>
                SCLK <= CLK;  -- Toggle SCLK for ACK
                SDA <= 'Z';  -- Release SDA to allow slave to ACK
                timer <= 1;
                next_state <= ST3_TX_REG_ADDR;
            
            when ST3_TX_REG_ADDR =>
                SCLK <= CLK;  -- Toggle SCLK to clock out bits
                SDA <= reg_address(7 - data_index);  -- Send register address
                timer <= 8;
                next_state <= ST4_ACK2;
            
            when ST4_ACK2 =>
                SCLK <= CLK;  -- Toggle SCLK for ACK
                SDA <= 'Z';  -- Release SDA to allow slave to ACK
                timer <= 1;
                next_state <= ST5_TX_DATA;
                
            when ST5_TX_DATA =>
                SCLK <= CLK;  -- Toggle SCLK to clock out bits
                SDA <= data(7 - data_index);  -- Send data
                timer <= 8;
                next_state <= ST6_ACK3;
                
            when ST6_ACK3 =>
                SCLK <= CLK;  -- Toggle SCLK for ACK
                SDA <= 'Z';  -- Release SDA to allow slave to ACK
                timer <= 1;
                next_state <= ST7_STOP;
                
            when ST7_STOP =>
                SCLK <= '1';  -- Set SCLK high for stop
                SDA <= not DCLK;            -- SDA high (stop condition)
                timer <= 1;
                next_state <= ST_IDLE;

        end case;
    end process;


end Behavioral;
