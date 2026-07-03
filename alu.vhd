library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity alu is
    port(
        a: in STD_LOGIC_VECTOR(7 downto 0);
        b: in STD_LOGIC_VECTOR(7 downto 0);
        subtraction: in STD_LOGIC;
        ash: in STD_LOGIC;
        op: in STD_LOGIC_VECTOR(2 downto 0);
        f: out STD_LOGIC_VECTOR(7 downto 0)
    );
end alu;

architecture Behavioral of alu is

begin
    process(all)
    begin
        case op is
        when "000" => 
                    if subtraction = '0' then
                        f <= STD_LOGIC_VECTOR(signed(a) + signed(b)); -- addition
                    else
                        f <= STD_LOGIC_VECTOR(signed(a) + (signed(not(b))) + 1); -- subtraction
                    end if;

        when "001" => f <= a nand b;
        when "010" => f <= a and b;
        when "011" => f <= a or b;
        when "100" => f <= a xor b; 
        when "101" => f <= a(6 downto 0) & '0'; --shift left
        when "110" => 
                    if ash = '0' then
                        f <= '0' & a(7 downto 1); -- logical shift right
                    else
                        f <= a(7) & a(7 downto 1); -- arithmetic shift right
                    end if;

        when "111" => f <= not(a);
        when others => f <= (others => '0');
        
    end case;
        
    end process;

end Behavioral;
