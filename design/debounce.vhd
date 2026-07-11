library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    port(
        clk: in STD_LOGIC;
        rst: in std_logic;
        btn_in: in STD_LOGIC;
        btn_state: out STD_LOGIC;
        btn_press: out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is

constant C_MAX: positive := 2;
constant C_SHIFT_LEN: positive := 4;

signal ce: STD_LOGIC;
signal sync0: STD_LOGIC;
signal sync1: STD_LOGIC;
signal shift_reg: std_logic_vector(C_SHIFT_LEN-1 downto 0);
signal debounced: std_logic;
signal delayed: std_logic;

begin
    clk_en: entity work.clk_en
     generic map(
        G_MAX => C_MAX
    )
     port map(
        clk => clk,
        rst => rst,
        ce => ce
    );
    
    p_debounce: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync0     <= '0';
                sync1     <= '0';
                shift_reg <= (others => '0');
                debounced <= '0';
                delayed   <= '0';
            else
                sync1 <= sync0;
                sync0 <= btn_in;

                if ce = '1' then
                     -- Shift values to the left and load a new sample as LSB
                    shift_reg <= shift_reg(C_SHIFT_LEN-2 downto 0) & sync1;

                    -- Check if all bits are '1'
                    if shift_reg = (shift_reg'range => '1') then
                        debounced <= '1';
                    -- Check if all bits are '0'
                    elsif shift_reg = (shift_reg'range => '0') then
                        debounced <= '0';
                    end if;
                end if;

                delayed <= debounced;
            end if;
        end if;
    end process;

    btn_state <= debounced;

    btn_press <= debounced and not(delayed);
end Behavioral;
