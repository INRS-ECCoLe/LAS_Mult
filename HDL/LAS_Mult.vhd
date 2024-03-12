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

entity las_mult is
    generic(BITWIDTH : INTEGER:= 6;   -- which solution (part of partial products) to be used for accuracy refinement
            INOUT_BUF_EN : BOOLEAN:= True);
    Port ( a_i : in STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);  -- Mult input 1
           b_i : in STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);  -- Mult input 2
           clk, rst : in STD_LOGIC;
           result_o : out STD_LOGIC_VECTOR (2*BITWIDTH-1 downto 0)
           );
end las_mult;

architecture Behavioral of las_mult is

    constant NUM_SEGMENTS : INTEGER := integer(floor(real(BITWIDTH)/real(3)));
    constant REMAINED_BITS : INTEGER := BITWIDTH - NUM_SEGMENTS * 3;
    constant ZERO : STD_LOGIC_VECTOR(BITWIDTH downto 0) := (others => '0');

    type PS_TYPE is array (1 to NUM_SEGMENTS ** 2) of STD_LOGIC_VECTOR(2*NUM_SEGMENTS*3-1 downto 0);
    signal ps : PS_TYPE := (others => (others => '0'));

    signal a            : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal b            : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal result_temp  : STD_LOGIC_VECTOR(2*BITWIDTH-1 downto 0);

    signal result_temp1  : STD_LOGIC_VECTOR(2*NUM_SEGMENTS*3-1 downto 0);
    signal result_temp2  : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal result_temp3  : STD_LOGIC_VECTOR(BITWIDTH + REMAINED_BITS-1 downto 0);

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

    F1_GEN: for ii in 0 to NUM_SEGMENTS-1 generate
        F2_GEN: for jj in 0 to NUM_SEGMENTS-1 generate
            S0: six_input_mult 
                port map( 
                a_i      => a(BITWIDTH-ii*3-1 downto BITWIDTH-ii*3-3),
                b_i      => b(BITWIDTH-jj*3-1 downto BITWIDTH-jj*3-3),
                result_o => ps(ii*NUM_SEGMENTS+jj+1)(2*NUM_SEGMENTS*3-1-ii*3-jj*3 downto 2*NUM_SEGMENTS*3-6-ii*3-jj*3)
            );
        end generate;
    end generate;

    process(ps)
    variable result_var  : STD_LOGIC_VECTOR(2*NUM_SEGMENTS*3-1  downto 0):= (others => '0');
    begin
        result_var := (others => '0');
        for ii in 1 to NUM_SEGMENTS ** 2 loop
            result_var := result_var + ps(ii);
        end loop;
    result_temp1 <= result_var;
    end process;

    -- Remaining bits

    REM_GEN_n0: if REMAINED_BITS > 0 generate
        result_temp2 <= a(REMAINED_BITS-1 downto 0) * b(BITWIDTH-1 downto REMAINED_BITS);
        result_temp3 <= a(BITWIDTH-1 downto 0) * b(REMAINED_BITS-1 downto 0);
        result_temp  <= (ZERO(BITWIDTH-REMAINED_BITS-1 downto 0) & result_temp2 & ZERO(REMAINED_BITS-1 downto 0)) + 
                        (ZERO(BITWIDTH-REMAINED_BITS-1 downto 0) & result_temp3) + 
                        (result_temp1 & ZERO(2*REMAINED_BITS-1 downto 0));
    end generate;

    RES_GEN_0: if REMAINED_BITS = 0 generate
        result_temp <= result_temp1 ;
    end generate;



    end Behavioral;