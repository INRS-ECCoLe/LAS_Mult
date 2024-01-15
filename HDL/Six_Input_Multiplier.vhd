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
--  Project: LUT-Aware Segmented Multiplier
--  Creation Date: 2023-11-16
--  Module Name: six_input_mult - Behavioral 
--  Description: 3x3 multiplier that can be implemented on 6 parallel LUT6 units.
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.ALL;
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity six_input_mult is
    Port ( a_i      : in STD_LOGIC_VECTOR(2 downto 0);  -- Mult input 1
           b_i      : in STD_LOGIC_VECTOR(2 downto 0);  -- Mult input 2
           result_o : out STD_LOGIC_VECTOR (5 downto 0)
           );
end six_input_mult;

architecture Behavioral of six_input_mult is

    signal term1    : STD_LOGIC_VECTOR(5 downto 0);
    signal term2    : STD_LOGIC_VECTOR(5 downto 0);
    signal term3    : STD_LOGIC_VECTOR(5 downto 0);

begin

    term1       <= ("000" & (a_i(0) and b_i(2)) & (a_i(0) and b_i(1)) & (a_i(0) and b_i(0))         );
    term2       <= ("00"  & (a_i(1) and b_i(2)) & (a_i(1) and b_i(1)) & (a_i(1) and b_i(0)) & '0'   );
    term3       <= ('0'   & (a_i(2) and b_i(2)) & (a_i(2) and b_i(1)) & (a_i(2) and b_i(0)) & "00"  );
    result_o    <= term1 + term2 + term3;

end Behavioral;