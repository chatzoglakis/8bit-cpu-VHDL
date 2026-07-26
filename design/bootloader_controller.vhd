library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bootloader_controller is
    port(
        clk: in STD_LOGIC;
        rx: in STD_LOGIC;
        prog_mode: in STD_LOGIC;
        boot_address: out STD_LOGIC_VECTOR(7 downto 0);
        boot_data: out STD_LOGIC_VECTOR(7 downto 0);
        boot_we: out STD_LOGIC
    );
end bootloader_controller;

architecture Behavioral of bootloader_controller is

    signal rx_done: STD_LOGIC;
    signal address_num: integer range 0 to 255 := 0;

begin

    uart_receiver: entity work.uart_receiver
        port map(
            clk => clk,
            rx => rx,
            rx_data => boot_data,
            rx_done => rx_done
        );

    boot_we <= rx_done;
    boot_address <= STD_LOGIC_VECTOR(to_unsigned(address_num, 8));

    process(clk, rx_done, address_num)
    begin
        if rising_edge(clk) then
            if prog_mode = '0' then
                address_num <= 0;

            elsif rx_done = '1' then
                
                if address_num < 255 then
                    address_num <= address_num + 1;
                else
                    address_num <= 0;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
