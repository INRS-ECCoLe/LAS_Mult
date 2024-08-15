library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.ALL;
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_add_mult is
    generic(BITWIDTH : INTEGER:= 5;   -- which solution (part of partial products) to be used for accuracy refinement
            INOUT_BUF_EN : BOOLEAN:= False);
    Port ( a_i : in STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);  -- Mult input 1
           b_i : in STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);  -- Mult input 2
           clk, rst : in STD_LOGIC;
           result_o : out STD_LOGIC_VECTOR (2*BITWIDTH-1 downto 0)
           );
end shift_add_mult;

architecture Behavioral of shift_add_mult is

    signal a            : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal b            : STD_LOGIC_VECTOR(BITWIDTH-1 downto 0);
    signal result_temp  : STD_LOGIC_VECTOR(2*BITWIDTH-1 downto 0);

    type PS_TYPE is array (1 to BITWIDTH) of STD_LOGIC_VECTOR(2*BITWIDTH-1 downto 0);
    signal ps : PS_TYPE := (others => (others => '0'));


    component six_input_mult is
        Port ( a_i      : in STD_LOGIC_VECTOR(2 downto 0);  -- Mult input 1
               b_i      : in STD_LOGIC_VECTOR(2 downto 0);  -- Mult input 2
               result_o : out STD_LOGIC_VECTOR (5 downto 0)
               );
    end component;

begin
    
    WITH_INOUT_BUF_EN: IF INOUT_BUF_EN = true generate
        --result_o <= a + b + c;
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

    PS_GEN: for ii in 0 to BITWIDTH-1 generate
        ps(ii+1)(BITWIDTH+ii-1 downto ii) <= a when b(ii)='1' else (others => '0');
    end generate;


    process(ps)
        variable result_var  : STD_LOGIC_VECTOR(2*BITWIDTH-1 downto 0):= (others => '0');
        begin
            result_var := (others => '0');
            for ii in 1 to BITWIDTH loop
                result_var := result_var + ps(ii);
            end loop;
            result_temp <= result_var;
    end process;

    --ps0 <= a when b(0)='1' else (others => '0');
    --ps1 <= a when b(1)='1' else (others => '0');
    --ps2 <= a when b(2)='1' else (others => '0');
    --ps3 <= a when b(3)='1' else (others => '0');
    --ps4 <= a when b(4)='1' else (others => '0');
    --ps5 <= a when b(5)='1' else (others => '0');


    --result_temp <= ("0" & ps5 & "00000") + ("00" & ps4 & "0000") + ("000" & ps3 & "000") + ("0000" & ps2 & "00") + ("00000" & ps1 & "0") + ("000000" & ps0);



    end Behavioral;