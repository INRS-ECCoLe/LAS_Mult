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
--  Project: Reconfig MAC 
--  Creation Date: 2023-05-10
--  Module Name: Ordinary_Unsigned_Mult - Behavioral 
--  Description: Ordinary unsigned multiplier with default multiplication circuit 
--               that Xilinx uses
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
--use ieee.std_logic_signed.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ordinary_Unsigned_Mult is
    generic(LENGTH : integer:= 6;
            INOUT_BUF_EN : boolean:= True);
    Port ( a : in unsigned(LENGTH-1 downto 0);  -- Mult input 1
           b : in unsigned(LENGTH-1 downto 0);    -- Mult input 2
           clk, rst : in STD_LOGIC;
           
           result_o : out unsigned (2*LENGTH-1 downto 0)
           );
end Ordinary_Unsigned_Mult;

architecture Behavioral of Ordinary_Unsigned_Mult is
    signal temp :  unsigned (2*LENGTH-1 downto 0);
    signal a_buf : unsigned (LENGTH-1 downto 0);
    signal b_buf : unsigned (LENGTH-1 downto 0);
begin
    temp <= a_buf * b_buf;
    
    INOUT_BUF_ENABLE: if INOUT_BUF_EN=True generate
        process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    result_o <= (others => '0');
                else
                    a_buf <= a;
                    b_buf <= b;
                    result_o <= temp;
                 end if;
            end if;
        end process;
    end generate;
    
    INOUT_BUF_DISABLE: if INOUT_BUF_EN=False generate
        a_buf <= a;
        b_buf <= b;
        result_o <= temp;
    end generate;

end Behavioral;
