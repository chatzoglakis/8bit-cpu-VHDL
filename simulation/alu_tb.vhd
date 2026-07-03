library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is

    signal a           : std_logic_vector (7 downto 0);
    signal b           : std_logic_vector (7 downto 0);
    signal subtraction : std_logic;
    signal ash         : std_logic;
    signal op          : std_logic_vector (2 downto 0);
    signal f           : std_logic_vector (7 downto 0); 

begin

    DUT: entity work.alu
        port map (
            a => a,
            b => b,
            subtraction => subtraction,
            ash => ash,
            op => op,
            f => f
            );

    stimuli: process
    begin
        -- Initialize defaults
        ash <= '0';
        subtraction <= '0';

        report "testing addition";
        a <= x"01";
        b <= x"01";
        op <= "000";
        subtraction <= '0';
        wait for 10 ns;
        assert f = x"02" report "ERROR: failed addition" severity error;
        wait for 90 ns; 

        report "testing subtraction";
        a <= x"01";
        b <= x"01";
        op <= "000";
        subtraction <= '1';
        wait for 10 ns;
        assert f = x"00" report "ERROR: failed subtraction" severity error;
        wait for 90 ns;

        report "testing AND";
        a <= x"03";
        b <= x"01";
        op <= "010";
        wait for 10 ns;
        assert f = x"01" report "ERROR: failed AND" severity error;
        wait for 90 ns;

        report "testing left shift";
        a <= x"04";
        op <= "101";
        wait for 10 ns;
        assert f = x"08" report "ERROR: failed left shift" severity error;
        wait for 90 ns;

        report "testing right arithmetic shift";
        a <= x"a0";
        op <= "110";
        ash <= '1';
        wait for 10 ns;
        assert f = x"d0" report "ERROR: failed at right arithmetic shift" severity error;
        wait for 90 ns;

        report "testing negation";
        a <= x"ff";
        op <= "111";
        wait for 10 ns;
        assert f = x"00" report "ERROR: failed negation" severity error;
        wait for 90 ns;
        
        report "SIMULATION COMPLETE";
        wait;
    end process;

end Behavioral;
