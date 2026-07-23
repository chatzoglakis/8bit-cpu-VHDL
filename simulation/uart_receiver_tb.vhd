library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uart_receiver_tb is
end uart_receiver_tb;

architecture Behavioral of uart_receiver_tb is

signal clk     : std_logic;
signal rx      : std_logic;
signal rx_data : std_logic_vector (7 downto 0);
signal rx_done : std_logic;
signal i: integer range 0 to 7 := 0;

constant ClkPeriod : time := 10 ns; 

begin

    dut: entity work.uart_receiver
        port map (
            clk => clk,
            rx => rx,
            rx_data => rx_data,
            rx_done => rx_done
        );

    clk_proc: process
    begin
        clk <= '0';
        wait for ClkPeriod / 2;
        clk <= '1';
        wait for ClkPeriod / 2;
    end process;

    stimuli: process
    begin
        --initialization
        rx <= '1';
        wait for 100 ns;
        --start bit
        rx <= '0';
        wait for 20 ns;

        --sending number 11011110
        for i in 0 to 7 loop
            if i = 0 or i = 5 then
                rx <= '0';
            else
                rx <= '1';
            end if;
            wait for 20 ns;
        end loop;

        wait until rx_done = '1';
        assert rx_data = "11011110" report "data not received properly" severity error;
    end process;

end Behavioral;
