--This testbench is used to load and test the fibonacci program

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity cpu_top_tb is
end cpu_top_tb;

architecture Behavioral of cpu_top_tb is
signal clk       : std_logic;
signal prog_mode : std_logic;
signal rx        : std_logic;
signal seg       : std_logic_vector (6 downto 0);
signal digit_sel : std_logic;
signal btn_in    : std_logic;
signal rst_btn_in: std_logic;
signal n: integer := 0;

constant clkPeriod : time := 10 ns;

procedure send_uart_byte(
        data_in : in std_logic_vector(7 downto 0);
        signal rx_line : out std_logic
    ) is
    begin
        --Send Start Bit ('0')
        rx_line <= '0';
        wait for 20 ns;

        --Send 8 Data Bits (Standard UART sends LSB first)
        for i in 0 to 7 loop
            rx_line <= data_in(i);
            wait for 20 ns;
        end loop;

        --Send Stop Bit ('1')
        rx_line <= '1';
        wait for 20 ns;
    end procedure;

begin
    dut: entity work.cpu_top
        port map(
            clk => clk,
            btn_in => btn_in,
            rst_btn_in => rst_btn_in,
            prog_mode => prog_mode,
            rx => rx,
            seg => seg,
            digit_sel => digit_sel
            );

    clk_process: process
    begin
        clk <= '0';
        wait for clkPeriod / 2;
        clk <= '1';
        wait for clkPeriod / 2;
    end process;

    stimuli: process
        file program_file : text open read_mode is "fibonacci.txt";
        variable file_line : line;
        variable bit_string : bit_vector(7 downto 0); -- textio reads into standard bits
        variable byte_to_send : std_logic_vector(7 downto 0);
    begin
        --load fibonacci program via UART
        prog_mode <= '1';
        rx <= '1';
        wait for 100 ns;

        while not endfile(program_file) loop
            readline(program_file, file_line);

            -- Extract the 8 characters as a bit_vector
            read(file_line, bit_string);
            --Convert to std_logic_vector
            byte_to_send := To_Std_Logic_Vector(bit_string);
            send_uart_byte(byte_to_send, rx);
            wait for 40 ns;
        end loop; 
        
        prog_mode <= '0';

        --Test program
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
        
        assert false report "SIMULATION COMPLETE" severity failure;
    end process;

end Behavioral;
