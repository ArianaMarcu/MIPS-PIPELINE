library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

entity UnitExec is
    Port ( PCinc : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           func : in STD_LOGIC_VECTOR(2 downto 0);
           sa : in STD_LOGIC;
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           Zero : out STD_LOGIC;
           rt: in STD_LOGIC_VECTOR(2 downto 0);
           rd: in STD_LOGIC_VECTOR(2 downto 0);
           RegDst : in STD_LOGIC;
           rWA : out STD_LOGIC_VECTOR(2 downto 0)
           );
end UnitExec;

architecture Behavioral of UnitExec is

signal ALUIn2 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUIn1 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
signal ALUResAux : STD_LOGIC_VECTOR(15 downto 0);

begin

    with RegDst select
        rWA <= rt when '0',
               rd when '1',
               (others => 'X') when others;

    -- MUX for ALU input 2
    with ALUSrc select
        ALUIn2 <= RD2 when '0', -- rt
	              Ext_Imm when '1', -- rd
	              (others => '0') when others; -- unknown
			  
    -- ALU Control
    process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => -- R type 
                case func is
                    when "011" => ALUCtrl <= "011"; -- ADD
                    when "000" => ALUCtrl <= "000"; -- SUB
                    when "101" => ALUCtrl <= "101"; -- SLT
                    when others => ALUCtrl <= (others => '0'); -- unknown
                end case;
            when "001" => ALUCtrl <= "011"; -- + addi
            when "101" => ALUCtrl <= "011"; -- + lw
            when "010" => ALUCtrl <= "011"; -- + sw
            when "110" => ALUCtrl <= "000"; -- - beq
            when "100" => ALUCtrl <= "000"; -- - bne
            when others => ALUCtrl <= (others => '0'); -- unknown
        end case;
    end process;

    -- ALU
    process(ALUCtrl, RD1, AluIn2, sa, ALUResAux)
    begin
        case ALUCtrl  is
            when "011" => -- ADD
                ALUResAux <= RD1 + ALUIn2;
            when "000" =>  -- SUB
                ALUResAux <= RD1 - ALUIn2;                                    	
            when "101" => -- SLT
                if signed(RD1) < signed(ALUIn2) then
                    ALUResAux <= X"0001";
                else 
                    ALUResAux <= X"0000";
                end if;
            when others => -- unknown
                ALUResAux <= (others => '0');              
        end case;

        -- zero detector
        case ALUResAux is
            when X"0000" => Zero <= '1';
            when others => Zero <= '0';
        end case;
    
    end process;

    -- ALU result
    ALURes <= ALUResAux;

    -- generate branch address
    BranchAddress <= PCinc + Ext_Imm;

end Behavioral;