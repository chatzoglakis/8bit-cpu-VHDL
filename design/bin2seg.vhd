library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bin2seg is
    port(
        sw: in STD_LOGIC_VECTOR(3 downto 0);
        seg: out STD_LOGIC_VECTOR(6 downto 0)
    );
end bin2seg;

architecture Behavioral of bin2seg is

begin
    process (sw)
    begin

        case sw is
            when x"0" => seg <= b"1000000";
            when x"1" => seg <= b"1111001";
            when x"2" => seg <= b"0100100";
            when x"3" => seg <= b"0110000";
            when x"4" => seg <= b"0011001";
            when x"5" => seg <= b"0010010";
            when x"6" => seg <= b"0000010";
            when x"7" => seg <= b"1111000";
            when x"8" => seg <= b"0000000";
            when x"9" => seg <= b"0010000";
            when x"A" => seg <= b"0001000";
            when x"B" => seg <= b"0000011";
            when x"C" => seg <= b"1000110";
            when x"D" => seg <= b"0100001";
            when x"E" => seg <= b"0000110";
            when x"F" => seg <= b"0001110";
            when others => seg <= b"1111111";
        end case;
    end process;


end Behavioral;
