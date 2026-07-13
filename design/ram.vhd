library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity ram is
    generic (
        DATA_WIDTH: integer := 8;
        ADDRESS_WIDTH: integer := 8
    );
    port(
        clk: in STD_LOGIC;
        address: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        we: in STD_LOGIC; --write enable
        data_in: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        data_out: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end ram;

architecture Behavioral of ram is

    type ram_type is array (0 to (2**ADDRESS_WIDTH) - 1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    
    --THIS FUNCTION IS USED TO LOAD THE PROGRAM "program.hex" TO RAM. TO CHANGE THE PROGRAM LOADED, CHANGE THE NAME IN THE FIRST LINE
    --It doesnt run on the FPGA, but on the PC that's doing the synthesis
    impure function init_ram_from_file return ram_type is
        file text_file : text open read_mode is "add.hex";
        variable text_line : line;
        variable ram_content : ram_type := (others => (others => '0'));
        variable hex_val : std_logic_vector(7 downto 0);
    begin
        for i in 0 to (2**ADDRESS_WIDTH) - 1 loop
            if not endfile(text_file) then
                readline(text_file, text_line);
                hread(text_line, hex_val); -- Read the hex string into logic vector
                ram_content(i) := hex_val;
            else
                exit;
            end if;
        end loop;
        return ram_content;
    end function;

    signal ram: ram_type := init_ram_from_file;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;

    --Asynchronous read
    data_out <= ram(to_integer(unsigned(address)));
    
end Behavioral;
