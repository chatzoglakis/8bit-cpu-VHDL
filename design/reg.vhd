library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
    generic (DATA_WIDTH: integer := 8);
    port (
        clk: in STD_LOGIC;
        en: in STD_LOGIC;
        rst: in STD_LOGIC;
        data_in: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        data_out: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end reg;

architecture Behavioral of reg is

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data_out <= (others => '0');
            elsif en = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;
    
end Behavioral;
