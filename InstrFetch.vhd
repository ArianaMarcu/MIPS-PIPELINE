library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrFetch is
    Port (clk: in STD_LOGIC;
          rst : in STD_LOGIC;
          en : in STD_LOGIC;
          BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
          JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
          Jump : in STD_LOGIC;
          PCSrc : in STD_LOGIC;
          Instruction : out STD_LOGIC_VECTOR(15 downto 0);
          PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end InstrFetch;

architecture Behavioral of InstrFetch is

-- Memorie ROM
type tROM is array (0 to 255) of STD_LOGIC_VECTOR (15 downto 0);
signal ROM : tROM := (

    B"000_000_000_001_0_011",   --0     add $1, $0, $0           X"0013"
    B"101_000_010_0000000",     --1     lw $2, 0($0)             X"A100"
    B"101_000_011_0000001",     --2     lw $3, 1($0)             X"A181"
    B"101_000_100_0000010",     --3     lw $4, 2($0)             X"A202"
    B"000_000_000_101_0_011",   --4     add $5, $0, $0           X"0053"
    B"110_010_011_0000111",     --5     beq $2, $3, 7            X"C987"
    B"000_000_000_000_0_000",   --6     NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --7     NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --8     NoOp (add $0, $0, $0)    X"0000"
    B"000_001_010_001_0_011",   --9     add $1, $1, $2           X"0513"
    B"001_010_010_0000001",     --10    addi $2, $2, 1           X"2901"
    B"111_0000000000101",       --11    j 5                      X"E005"
    B"000_000_000_000_0_000",   --12    NoOp (add $0, $0, $0)    X"0000"
    B"110_100_001_0010000",     --13    beq $4, $1, 16           X"D090"
    B"000_000_000_000_0_000",   --14    NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --15    NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --16    NoOp (add $0, $0, $0)    X"0000"
    B"000_100_001_101_0_101",   --17    slt $5, $4, $1           X"10D5"
    B"000_000_000_000_0_000",   --18    NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --19    NoOp (add $0, $0, $0)    X"0000"
    B"100_101_000_0000011",     --20    bne $5, $0, 3            X"9403"
    B"000_000_000_000_0_000",   --21    NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --22    NoOp (add $0, $0, $0)    X"0000"
    B"000_000_000_000_0_000",   --23    NoOp (add $0, $0, $0)    X"0000"
    B"000_001_100_001_0_000",   --24    sub $1, $1, $4           X"0610"
    B"111_0000000001101",       --25    j 13                     X"E00D"
    B"000_000_000_000_0_000",   --26    NoOp (add $0, $0, $0)    X"0000"
    B"000_100_001_100_0_000",   --27    sub $4, $4, $1           X"10C0"
    B"111_0000000001101",       --28    j 13                     X"E00D"
    B"000_000_000_000_0_000",   --29    NoOp (add $0, $0, $0)    X"0000"
    B"010_000_100_0000011",     --30    sw $4, 3($0)             X"4203"
    others => X"0000" );

signal PC : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal PCAux, NextAddr, AuxSgn, AuxSgn1: STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Program Counter
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                PC <= (others => '0');
            elsif en = '1' then
                PC <= NextAddr;
            end if;
        end if;
    end process;

    -- Instruction OUT
    Instruction <= ROM(conv_integer(PC(7 downto 0)));

    -- PC incremented
    PCAux <= PC + 1;
    PCinc <= PCAux;

    -- MUX Branch
    process(PCSrc, PCAux, BranchAddress)
    begin
        case PCSrc is 
            when '1' => AuxSgn <= BranchAddress;
            when others => AuxSgn <= PCAux;
        end case;
    end process;	

     -- MUX Jump
    process(Jump, AuxSgn, JumpAddress)
    begin
        case Jump is
            when '1' => NextAddr <= JumpAddress;
            when others => NextAddr <= AuxSgn;
        end case;
    end process;

end Behavioral;