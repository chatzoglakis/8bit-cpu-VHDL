library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity control_unit is
    port (
        clk: in STD_LOGIC;
        opcode: in STD_LOGIC_VECTOR(7 downto 0);
        btn_press: in STD_LOGIC;

        --ALU input signals
        ALUop: out STD_LOGIC_VECTOR(2 downto 0);
        ash: out STD_LOGIC; --signal for arithmetic shift right
        subtraction: out STD_LOGIC;

        --Register read signals
        MARin: out STD_LOGIC;
        MDRin: out STD_LOGIC;
        PCin: out STD_LOGIC;
        IRin: out STD_LOGIC;
        OUTin: out STD_LOGIC;
        ACCin: out STD_LOGIC;
        Flagin: out STD_LOGIC;

        --Register write to main bus signals
        MDRout: out STD_LOGIC;
        PCout: out STD_LOGIC;
        ACCout: out STD_LOGIC;

        --MUX control signals
        IB_EB: out STD_LOGIC; --when 0: MDR receives data from ram, otherwise from main bus
        ALUout: out STD_LOGIC;

        --Jump signals
        JMP: out STD_LOGIC;
        JLT: out STD_LOGIC;
        JGT: out STD_LOGIC;
        JEQ: out STD_LOGIC;
        JNE: out STD_LOGIC;
        mem_write: out STD_LOGIC --when 1, data from MDR is written in the address stored in MAR
    );
end control_unit;

architecture Behavioral of control_unit is

    signal step: STD_LOGIC_VECTOR(2 downto 0);
    signal rst: STD_LOGIC;
    signal count_en: STD_LOGIC;
        
begin    
    counter: entity work.counter
        generic map(G_BITS => 3)
        port map(
            clk => clk,
            rst => rst,
            en => count_en,
            cnt => step
            );

    
    
    control_logic: process(step, opcode, btn_press)
    begin

        ALUop <= "000";
        ash <= '0';
        subtraction <= '0';
        MARin <= '0';
        MDRin <= '0';
        PCin <= '0';
        IRin <= '0';
        OUTin <= '0';
        ACCin <= '0';
        Flagin <= '0';
        MDRout <= '0';
        PCout <= '0';
        ACCout <= '0';
        IB_EB <= '0';
        ALUout <= '0';
        JMP <= '0';
        JLT <= '0';
        JGT <= '0';
        JEQ <= '0';
        JNE <= '0';
        mem_write <= '0';
        rst <= '0';
        count_en <= '1';

        case step is 
        when "000" =>
                MARin <= '1';
                PCout <='1';
        when "001" =>
                MDRin <= '1';
        when "010" =>
                IRin <= '1';
                MDRout <= '1';
        when "011" =>
                if unsigned(opcode) < 20 then
                    MARin <= '1';
                    PCout <= '1';
                else
                    case opcode is 
                        when x"14" =>
                                ACCin <= '1';
                                ALUout <= '1';
                                ALUop <= "101";
                        when x"15" =>
                                ACCin <= '1';
                                ALUout <= '1';
                                ALUop <= "110";
                        when x"16" =>
                                ACCin <= '1';
                                ALUout <= '1';
                                ALUop <= "110";
                                ash <= '1';
                        when x"17" =>
                                Accin <= '1';
                                ALUout <='1';
                                ALUop <= "111";
                        when x"18" =>
                                OUTin <= '1';
                        when x"19" =>
                                count_en <= '0';
                        when x"1a" =>
                                if btn_press ='0' then
                                    count_en <= '0';
                                end if;
                    end case;
                end if;
        when "100" => 
                if unsigned(opcode) > 19 then
                        rst <= '1';
                else
                        MDRin <= '1';
                end if;
        when "101" =>
                if unsigned(opcode) < 9 then
                        MARin <= '1';
                        MDRout <= '1';
                elsif unsigned(opcode) < 14 then
                        ACCin <= '1';
                        ALUout <= '1';
                        MDRout <= '1';
                        case opcode is
                            when x"09" => ALUop <= "000";
                            when x"0a" => ALUop <= "010";
                            when x"0b" => ALUop <= "011";
                            when x"0c" => ALUop <= "100";
                            when x"0d" => ALUop <= "001";
                        end case;
                elsif unsigned(opcode) < 19 then
                        PCin <= '1';
                        MDRout <= '1';
                        case opcode is
                            when x"0e" => JMP <= '1';
                            when x"0f" => JEQ <= '1';
                            when x"10" => JNE <= '1';
                            when x"11" => JGT <= '1';
                            when x"12" => JLT <= '1';
                        end case;
                else --CMPI instruction
                        ALUop <= "000";
                        subtraction <= '1';
                        MDRout <= '1';
                        Flagin <= '1';
                end if;
        when "110" =>
                if unsigned(opcode) > 8 then
                        rst <= '1';
                elsif unsigned(opcode) = 7 then --STA instruction
                        MDRin <= '1';
                        ACCout <= '1';
                        IB_EB <= '1';
                else
                        MDRin <= '1';
                end if;
        when "111" =>
                if unsigned(opcode) = 7 then --STA instruction
                        mem_write <= '1';
                elsif unsigned(opcode) = 8 then --CMP instruction
                        ALUop <= "000";
                        subtraction <= '1';
                        MDRout <= '1';
                        Flagin <= '1';
                elsif unsigned(opcode) = 6 then --LDA instruction
                        ACCin <= '1';
                        MDRout <= '0';
                else
                        ACCin <= '1';
                        MDRout <= '1';
                        ALUout <= '1';
                        case opcode is
                            when x"00" => ALUop <= "000";
                            when x"01" =>
                                        ALUop <= "000";
                                        subtraction <= '1';
                            when x"02" => ALUop <= "010";
                            when x"03" => ALUop <= "011";
                            when x"04" => ALUop <= "100";
                            when x"05" => ALUop <= "001";
                        end case;
                end if;
        end case;
        
    end process;

end Behavioral;
