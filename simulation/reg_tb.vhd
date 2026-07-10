library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity reg_tb is
end reg_tb;

architecture Behavioral of reg_tb is

constant clkPeriod: time := 10 ns;

signal clk:  STD_LOGIC;
signal en:  STD_LOGIC;
signal clear:  STD_LOGIC;
signal data_in:  STD_LOGIC_VECTOR(7 downto 0);
signal data_out:  STD_LOGIC_VECTOR(7 downto 0);

begin
    dut: entity work.reg
        port map(
            clk => clk,
            en => en,
            clear => clear,
            data_in => data_in,
            data_out => data_out
        );

    clk_proc: process
    begin
        clk <= '0';
        wait for clkPeriod / 2;
        clk <= '1';
        wait for clkPeriod / 2;
    end process;

    stimuli: process
    begin
        report "TESTING RAM WRITE AND READ";
        clear <= '0';
        data_in <= x"32";
        en <= '1';
        wait for 10 ns;
        assert data_out = x"32" report "Failed to write" severity error;
        wait for 90 ns;

        report "TESTING WRITE ENABLE";
        data_in <= x"33";
        en <= '0';
        wait for 10 ns;
        assert data_out /= x"33" report "Write enable not working" severity error;
        wait for 90 ns;

        report "TESTING CLEAR SIGNAL";
        clear <= '1';
        en <= '1';
        wait for 10 ns;
        assert data_out = x"00" report "Clear signal not working" severity error;
        wait for 90 ns;
        
        wait;
    end process;
end Behavioral;
