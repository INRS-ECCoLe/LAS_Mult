library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.ALL;
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_mult is
    generic(REFINEMENT_PART : INTEGER:= 0;   -- which solution (part of partial products) to be used for accuracy refinement
            INOUT_BUF_EN : BOOLEAN:= False);
    Port ( clk, rst : in STD_LOGIC;
           result_o : out STD_LOGIC_VECTOR (11 downto 0)
           );
end tb_mult;

architecture Behavioral of tb_mult is

    signal a            : STD_LOGIC_VECTOR(5 downto 0);
    signal b            : STD_LOGIC_VECTOR(5 downto 0);
    signal segment_out  : STD_LOGIC_VECTOR(11 downto 0);
    signal ord_mult_out  : STD_LOGIC_VECTOR(11 downto 0);
    signal sa_out  : STD_LOGIC_VECTOR(11 downto 0);
    signal different    : STD_LOGIC;

    component segmented_mult is
        generic(REFINEMENT_PART : INTEGER:= 0;   -- which solution (part of partial products) to be used for accuracy refinement
                INOUT_BUF_EN : BOOLEAN:= False);
        Port ( a_i : in STD_LOGIC_VECTOR(5 downto 0);  -- Mult input 1
               b_i : in STD_LOGIC_VECTOR(5 downto 0);  -- Mult input 2
               clk, rst : in STD_LOGIC;
               result_o : out STD_LOGIC_VECTOR (11 downto 0)
               );
    end component;

    component shift_add_mult is
        generic(REFINEMENT_PART : INTEGER:= 0;   -- which solution (part of partial products) to be used for accuracy refinement
                INOUT_BUF_EN : BOOLEAN:= False);
        Port ( a_i : in STD_LOGIC_VECTOR(5 downto 0);  -- Mult input 1
               b_i : in STD_LOGIC_VECTOR(5 downto 0);  -- Mult input 2
               clk, rst : in STD_LOGIC;
               result_o : out STD_LOGIC_VECTOR (11 downto 0)
               );
    end component;

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if rst = '1' then
                a <= (others => '0');
                b <= (others => '0');
            else
                if b = "111111" then
                    a <= a + 1;
                end if;
                b <= b+1;
                if segment_out /= ord_mult_out then
                    different <= '1';
                else
                    different <= '1';
                end if;

            end if;
        end if;
    end process;


    SM: segmented_mult 
        generic map (
            REFINEMENT_PART => 0,   -- which solution (part of partial products) to be used for accuracy refinement
            INOUT_BUF_EN => false
            )
        Port map( a_i => a,
               b_i => b,
               clk => clk,
               rst => rst,
               result_o => segment_out
            );

    ord_mult_out <= a * b;


    SA: shift_add_mult 
        generic map (
            REFINEMENT_PART => 0,   -- which solution (part of partial products) to be used for accuracy refinement
            INOUT_BUF_EN => false
            )
        Port map( a_i => a,
               b_i => b,
               clk => clk,
               rst => rst,
               result_o => sa_out
            );

    





    end Behavioral;