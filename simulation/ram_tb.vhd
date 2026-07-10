library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram_tb is
end ram_tb;

architecture Behavioral of ram_tb is

signal clk: STD_LOGIC;
signal address: STD_LOGIC_VECTOR(7 downto 0);
signal we: STD_LOGIC; --write enable
signal data_in: STD_LOGIC_VECTOR(7 downto 0);
signal data_out: STD_LOGIC_VECTOR(7 downto 0);
constant clkPeriod: time := 10 ns;

begin

    dut: entity work.ram
        port map (
            clk => clk,
            address => address,
            we => we,
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
        address <= x"00";
        data_in <= x"32";
        we <= '1';
        wait for 10 ns;
        assert data_out = x"32" report "Failed to write at address 0x00" severity error;
        wait for 90 ns;

        report "TESTING WRITE ENABLE";
        address <= x"00";
        data_in <= x"33";
        we <= '0';
        wait for 10 ns;
        assert data_out /= x"33" report "Write enable not working" severity error;
        wait for 90 ns;
    end process;

end Behavioral;
