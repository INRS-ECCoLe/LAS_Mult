---------------------------------------------------------------------------------------------------
--                __________
--    ______     /   ________      _          ______
--   |  ____|   /   /   ______    | |        |  ____|
--   | |       /   /   /      \   | |        | |
--   | |____  /   /   /        \  | |        | |____
--   |  ____| \   \   \        /  | |        |  ____|   
--   | |       \   \   \______/   | |        | |
--   | |____    \   \________     | |_____   | |____
--   |______|    \ _________      |_______|  |______|
--
--  Edge Computing, Communication and Learning Lab (ECCoLe) 
--
--  Author: Shervin Vakili, INRS University
--  Project: LAS Multiplier
--  Creation Date: 2024-02-10
--  Module Name: las_mult - Behavioral 
--  Description: LUT-aware segmentatation (LAS) exact multiplier for AMD-Xilinx FPGAs
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.math_real.all;
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity las_mult_4bit is
    generic(INOUT_BUF_EN : BOOLEAN:= False);
    Port ( a_i : in STD_LOGIC_VECTOR(3 downto 0);  -- Mult input 1
           b_i : in STD_LOGIC_VECTOR(3 downto 0);  -- Mult input 2
           clk, rst : in STD_LOGIC;
           result_o : out STD_LOGIC_VECTOR (7 downto 0)
           );
end las_mult_4bit;

architecture Behavioral of las_mult_4bit is

    constant BITWIDTH : INTEGER:= 4;
    constant NUM_SEGMENTS : INTEGER := integer(floor(real(BITWIDTH)/real(3)));
    constant REMAINED_BITS : INTEGER := BITWIDTH - NUM_SEGMENTS * 3;
    constant ZERO : STD_LOGIC_VECTOR(BITWIDTH downto 0) := (others => '0');

    type PS_TYPE is array (1 to NUM_SEGMENTS ** 2) of STD_LOGIC_VECTOR(2*NUM_SEGMENTS*3-1 downto 0);
    signal ps : PS_TYPE := (others => (others => '0'));

    signal a            : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal b            : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal result_temp  : STD_LOGIC_VECTOR(2*BITWIDTH-1 downto 0);

    --signal result_temp1  : STD_LOGIC_VECTOR(2*NUM_SEGMENTS*3-1 downto 0);
    signal result_temp1  : STD_LOGIC_VECTOR(5 downto 0);
    signal result_temp2  : STD_LOGIC_VECTOR(3 downto 0);
    signal result_temp3  : STD_LOGIC_VECTOR(BITWIDTH downto 0);

    component six_input_mult is
        Port ( a_i      : in STD_LOGIC_VECTOR(2 downto 0);  -- Mult input 1
               b_i      : in STD_LOGIC_VECTOR(2 downto 0);  -- Mult input 2
               result_o : out STD_LOGIC_VECTOR (5 downto 0)
               );
    end component;

begin
    
    WITH_INOUT_BUF_EN: IF INOUT_BUF_EN = true generate
        process(clk)
        begin
            if (rising_edge(clk)) then
                if rst = '1' then
                    a <= (others => '0');
                    b <= (others => '0');
                    result_o <= (others => '0');
                else
                    a <= a_i;
                    b <= b_i;
                    result_o <= result_temp;
                end if;
            end if;
        end process;
    end generate;

    WITHOUT_INOUT_BUF_EN: IF INOUT_BUF_EN = false generate
        a <= a_i;
        b <= b_i;
        result_o <= result_temp;
    end generate;


        S0: six_input_mult 
            port map( 
            a_i      => a(2 downto 0),
            b_i      => b(2 downto 0),
            result_o => result_temp1
        );

        result_temp2(2 downto 0) <= b(2 downto 0) when a(3)='1' else (others=>'0'); 
        result_temp2(3) <= '0';        
        --result_temp3 <= a(3 downto 0) * b(3 downto 3);
        result_temp3(3 downto 0) <= a(3 downto 0) when b(3)='1' else (others=>'0'); 
        result_temp3(4) <= '0';
        result_temp  <= ('0' & result_temp2 & ZERO(BITWIDTH-REMAINED_BITS-1 downto 0)) + 
                        (result_temp3 & ZERO(BITWIDTH-REMAINED_BITS-1 downto 0)) + 
                        (ZERO(1 downto 0) & result_temp1 );


    end Behavioral;