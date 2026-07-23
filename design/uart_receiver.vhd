library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_receiver is
    port(
        clk: in STD_LOGIC;
        rx: in STD_LOGIC;
        rx_data: out STD_LOGIC_VECTOR(7 downto 0);
        rx_done: out STD_LOGIC
    );
end uart_receiver;

architecture Behavioral of uart_receiver is

type state_type is (IDLE, RECEIVE_START_BIT, RECEIVE_DATA, RECEIVE_STOP_BIT);
signal current_state: state_type;

constant CLK_FREQ : integer := 125_000_000;
constant BAUDRATE : integer := 9_600;        -- Baud rate (9600 Bd)

-- Number of clock cycles per bit period for baud rate timing
constant MAX : integer := 2;-- 2 for simulation
                            -- CLK_FREQ / BAUDRATE for implementation

signal baud_count: integer range 0 to MAX-1 := 0;  
signal curr_bit_index: integer range 0 to 7 := 0;
signal shift_reg: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin
    p_receiver: process(clk)
    begin
        if rising_edge(clk) then
            rx_done <= '0';

            case current_state is

                when IDLE =>
                    curr_bit_index <= 0;
                    baud_count <= 0;

                    if rx = '0' then
                        current_state <= RECEIVE_START_BIT;
                    end if;

                when RECEIVE_START_BIT =>
                    --Wait exactly HALF a baud period to sample in the middle of the bit
                    --This shifts the sampling point perfectly into the middle of the bit instead of the end, eliminating timing issues in the next states
                    if baud_count = (MAX / 2) - 1 then
                        current_state <= RECEIVE_DATA;
                        baud_count <= 0;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when RECEIVE_DATA =>
                    if baud_count = MAX - 1 then
                        baud_count <= 0;
                        shift_reg <= rx & shift_reg(7 downto 1);

                        if curr_bit_index = 7 then
                            current_state <= RECEIVE_STOP_BIT;
                        else
                            curr_bit_index <= curr_bit_index + 1;
                        end if;

                    else
                        baud_count <= baud_count + 1;
                    end if;
                
                when RECEIVE_STOP_BIT =>

                    if baud_count = MAX - 1 then
                        current_state <= IDLE;
                        rx_data <= shift_reg;
                        rx_done <= '1';
                    else
                        baud_count <= baud_count + 1; 
                    end if;

                when others => current_state <= IDLE;
            end case;
        end if;

    end process;
                    

end Behavioral;
