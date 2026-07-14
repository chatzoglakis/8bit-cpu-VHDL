--This testbench is used to test the fibonacci program

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_top_tb is
end cpu_top_tb;

architecture Behavioral of cpu_top_tb is
signal clk       : std_logic;
signal seg       : std_logic_vector (6 downto 0);
signal digit_sel : std_logic;
signal btn_in    : std_logic;
signal rst_btn_in: std_logic;
signal n: integer := 0;

constant clkPeriod : time := 10 ns;

begin
    dut: entity work.cpu_top
        port map(
            clk => clk,
            seg => seg,
            digit_sel => digit_sel,
            btn_in => btn_in,
            rst_btn_in => rst_btn_in
            );

    clk_process: process
    begin
        clk <= '0';
        wait for clkPeriod / 2;
        clk <= '1';
        wait for clkPeriod / 2;
    end process;

    stimuli: process
    begin
        rst_btn_in <= '1';
        btn_in <= '0';
        wait for 30 ns;
        rst_btn_in <= '0';
        for n in 0 to 100 loop
            btn_in <= '0';
            wait for 500 ns;
            btn_in <= '1';
            wait for 500 ns;
        end loop; 
        
    end process;

end Behavioral;
