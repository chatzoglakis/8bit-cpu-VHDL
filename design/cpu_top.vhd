library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_top is
    port(
        clk: in STD_LOGIC;
        seg: out STD_LOGIC_VECTOR(6 downto 0);
        digit_sel: out STD_LOGIC;
        btn_in: in STD_LOGIC
    );
end cpu_top;

architecture Behavioral of cpu_top is

    --CONTROL UNIT SIGNALS
    --ALU input signals
    signal ALUop: STD_LOGIC_VECTOR(2 downto 0);
    signal ash: STD_LOGIC; --signal for arithmetic shift right
    signal subtraction: STD_LOGIC;

    --Register read signals
    signal MARin: STD_LOGIC;
    signal MDRin: STD_LOGIC;
    signal PCin: STD_LOGIC;
    signal IRin: STD_LOGIC;
    signal OUTin: STD_LOGIC;
    signal ACCin: STD_LOGIC;
    signal Flagin: STD_LOGIC;

    --Register write to main bus signals
    signal MDRout: STD_LOGIC;
    signal PCout: STD_LOGIC;
    signal ACCout: STD_LOGIC;

    --MUX control signals
    signal IB_EB: STD_LOGIC; --when 0: MDR receives data from ram, otherwise from main bus
    signal ALUout: STD_LOGIC;

    --Jump signals
    signal JMP: STD_LOGIC;
    signal JLT: STD_LOGIC;
    signal JGT: STD_LOGIC;
    signal JEQ: STD_LOGIC;
    signal JNE: STD_LOGIC;

    signal mem_write: STD_LOGIC; --when 1, data from MDR is written in the address stored in MAR

    --REGISTER SIGNALS
    signal IR_data: STD_LOGIC_VECTOR(7 downto 0);
    signal MDR_data: STD_LOGIC_VECTOR(7 downto 0);
    signal MAR_data: STD_LOGIC_VECTOR(7 downto 0);
    signal ACC_data: STD_LOGIC_VECTOR(7 downto 0);
    signal OUT_data: STD_LOGIC_VECTOR(7 downto 0);
    signal PC_data: STD_LOGIC_VECTOR(7 downto 0);

    --FLAG FLIP FLOPS
    signal negative_flag: STD_LOGIC;
    signal zero_flag: STD_LOGIC;

    signal internal_bus: STD_LOGIC_VECTOR(7 downto 0);
    signal external_bus: STD_LOGIC_VECTOR(7 downto 0);
    signal MDR_input: STD_LOGIC_VECTOR(7 downto 0); -- Depending on the value of the IB/EB signal, it either holds the data from the internal or external buses
    signal ACC_input:STD_LOGIC_VECTOR(7 downto 0);-- Depending on the value of the ALUout signal, it either holds the data from the internal bus or the ALU output
    signal ALU_output: STD_LOGIC_VECTOR(7 downto 0);
    signal PC_input:STD_LOGIC_VECTOR(7 downto 0);-- Depending on the value of the jump signals, it either holds the data from the internal bus or the PC data incremented by 1
    signal jmp_active: BOOLEAN;
    signal btn_press: STD_LOGIC;
    signal btn_state: STD_LOGIC;

begin

    MDR_input <= internal_bus when IB_EB = '1' else external_bus;
    ACC_input <= ALU_output when ALUout = '1' else internal_bus;
    
    pc_input_select: process(jmp_active, JMP, JEQ, JNE, JGT, JLT, zero_flag, negative_flag, internal_bus, PC_data)
    begin
        --There are 3 cases:
        --1) There is a jump instruction (jmp_active = 1) and conditions are met: PC takes the data from the internal bus
        --2) There is no jump intruction (jmp_active = 0): the data of the PC is incremented by 1
        --3) There is a jump instruction (jmp_active = 1) but the conditions are not met: PC remains unchanged
        --The 3rd case is important, because the PCin signal from the control unit is activated regardless if the jump conditions are met, so we need
        --to ensure that the PC's value doesnt change at all in this case
        jmp_active <= JMP = '1' or JEQ = '1' or JNE = '1' or JGT = '1' or JLT = '1';
        if jmp_active then
            if JMP ='1' then
                PC_input <= internal_bus;
            elsif JEQ = '1' and zero_flag ='1' then
                PC_input <= internal_bus;
            elsif JNE ='1' and zero_flag = '0' then
                PC_input <= internal_bus;
            elsif JGT ='1' and negative_flag ='0' then
                PC_input <= internal_bus;
            elsif JLT = '1' and negative_flag ='1' then
                PC_input <= internal_bus;
            end if;
        else
            PC_input <= STD_LOGIC_VECTOR(unsigned(PC_data) + 1);
        end if;
    end process;



    --REGISTERS
    IR: entity work.reg
        port map(clk => clk, en => IRin, clear => '0', data_in => internal_bus, data_out => IR_data);
    MDR: entity work.reg
        port map(clk => clk, en => MDRin, clear => '0', data_in => MDR_input, data_out => MDR_data);
    MAR: entity work.reg
        port map(clk => clk, en => MARin, clear => '0', data_in => internal_bus, data_out => MAR_data);
    ACC: entity work.reg
        port map(clk => clk, en => ACCin, clear => '0', data_in => ACC_input, data_out => ACC_data);
    OUT_REG: entity work.reg
        port map(clk => clk, en => OUTin, clear => '0', data_in => internal_bus, data_out => OUT_data);
    PC: entity work.reg
        port map(clk => clk, en => PCin, clear => '0', data_in => PC_input, data_out => PC_data);

    --RAM
    RAM: entity work.ram
        generic map(DATA_WIDTH => 8, ADDRESS_WIDTH => 8)
        port map(clk => clk, address => MAR_data, we => mem_write, data_in => MDR_data, data_out => external_bus);

    --ALU
    ALU: entity work.alu
        port map(a => ACC_data, b => internal_bus, subtraction => subtraction, ash => ash, op => ALUop, f => ALU_output);

    --CONTROL UNIT
    control_unit: entity work.control_unit
        port map (clk     => clk,
              opcode      => IR_data,
              btn_press   => btn_press,
              ALUop       => ALUop,
              ash         => ash,
              subtraction => subtraction,
              MARin       => MARin,
              MDRin       => MDRin,
              PCin        => PCin,
              IRin        => IRin,
              OUTin       => OUTin,
              ACCin       => ACCin,
              Flagin      => Flagin,
              MDRout      => MDRout,
              PCout       => PCout,
              ACCout      => ACCout,
              IB_EB       => IB_EB,
              ALUout      => ALUout,
              JMP         => JMP,
              JLT         => JLT,
              JGT         => JGT,
              JEQ         => JEQ,
              JNE         => JNE,
              mem_write   => mem_write
            );
    
    --HEX DISPLAY
    display_driver: entity work.display_driver
     port map(
        clk => clk,
        data => OUT_data,
        seg => seg,
        digit_sel => digit_sel
    );

    --BUTTON PRESS DEBOUNCER
    debouncer: entity work.debounce
     port map(
        clk => clk,
        rst => '0',
        btn_in => btn_in,
        btn_state => btn_state,
        btn_press => btn_press
    );

    internal_bus_write: process(PCout, MDRout, ACCout, PC_data, MDR_data, ACC_data)
    begin
        -- Default state to prevent latches
        internal_bus <= (others => '0'); 
        
        if PCout = '1' then
            internal_bus <= PC_data;
        elsif MDRout = '1' then
            internal_bus <= MDR_data;
        elsif ACCout = '1' then
            internal_bus <= ACC_data;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if Flagin = '1' then
                negative_flag <= ALU_output(7);
                zero_flag <= '1' when unsigned(ALU_output) = 0 else '0'; 
            end if;
        end if;

    end process;

end Behavioral;
