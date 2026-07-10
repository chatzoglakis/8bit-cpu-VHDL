library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity display_driver is
    port(
        clk: in STD_LOGIC;
        data: in STD_LOGIC_VECTOR(7 downto 0);
        seg: out STD_LOGIC_VECTOR(6 downto 0);
        digit_sel: out STD_LOGIC
    );
end display_driver;

architecture Behavioral of display_driver is

signal bin: STD_LOGIC_VECTOR(3 downto 0);
signal bin0: std_logic_vector(3 downto 0);
signal bin1: std_logic_vector(3 downto 0);
signal cnt: STD_LOGIC_VECTOR(0 downto 0);

begin
    counter: entity work.counter
        generic map(G_BITS => 1)
        port map(
            clk => clk,
            rst => '0',
            en => '1',
            cnt => cnt
            );
    
    --split data for each display
    bin0 <= data(3 downto 0);
    bin1 <= data(7 downto 4);

    select_display: process (cnt)
    begin
        if cnt = "0" then
            bin <= bin0;
            digit_sel <= '0';
        else
            bin <= bin1;
            digit_sel <= '1'; 
        end if;
    end process;

    bin2seg: entity work.bin2seg
     port map(
        sw => bin,
        seg => seg
    );
    
end Behavioral;
