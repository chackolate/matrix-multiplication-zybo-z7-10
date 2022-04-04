----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2022 03:54:06 PM
-- Design Name: 
-- Module Name: matrixMult - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

library work;
use work.matrixPkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity matrixMult is
	port (
		clk   : in std_logic;
		reset : in std_logic;
		start : in std_logic;
		A, B  : in matrix_type;
		C     : out matrix_type_16;
		done  : out std_logic);
end matrixMult;

architecture Behavioral of matrixMult is

	-- type matrix_type is array(0 to 2, 0 to 2) of unsigned(7 downto 0);
	signal m_A, m_B : matrix_type    := (others => (others => X"00"));
	signal m_C      : matrix_type_16 := (others => (others => X"0000"));
	type state_type is (init, mult, apply_c);
	signal state : state_type := init;

begin

	states : process (clk, reset)
		variable tmp : unsigned(15 downto 0) := (others => '0');
	begin
		if (reset = '1') then --asynchronous reset
			state <= init;
			done  <= '0';
			m_A   <= (others => (others => X"00"));
			m_B   <= (others => (others => X"00"));
			m_C   <= (others => (others => X"0000"));
		elsif rising_edge(clk) then
			case state is
				when init => --store input to 2D arrays
					if (start = '1') then
						done <= '0';
						for i in 0 to 1 loop
							for j in 0 to 1 loop --iterate through rows and columns (3x3)
								m_A(i)(j) <= A(i)(j);
								m_B(i)(j) <= B(i)(j);
							end loop;
						end loop;
						state <= mult;
					end if;
				when mult => --multiply-accumulate
					m_C(0)(0) <= (A(0)(0) * B(0)(0)) + (A(0)(1) * B(1)(0));
					m_C(0)(1) <= (A(0)(0) * B(0)(1)) + (A(0)(1) * B(1)(1));
					m_C(1)(0) <= (A(1)(0) * B(0)(0)) + (A(1)(1) * B(1)(0));
					m_C(1)(1) <= (A(1)(0) * B(0)(1)) + (A(1)(1) * B(1)(1));
					state     <= apply_c;
					-- for i in 0 to 1 loop
					-- 	for j in 0 to 1 loop
					-- 		m_C(i)(j) <= (A(i)(j)*B(j)(i)) + (A())
					-- if (k = 2) then
					-- 	k <= 0;
					-- 	if (j = 2) then
					-- 		j <= 0;
					-- 		if (i = 2) then
					-- 			i     <= 0;
					-- 			state <= apply_c;
					-- 		else
					-- 			i <= i + 1;
					-- 		end if;
					-- 	else
					-- 		j <= j + 1;
					-- 	end if;
					-- else
					-- 	k <= k + 1;
					-- end if;
				when apply_c =>
					C(0)(0) <= m_C(0)(0);
					C(0)(1) <= m_C(0)(1);
					C(1)(0) <= m_C(1)(0);
					C(1)(1) <= m_C(1)(1);
					done    <= '1';
					state   <= init;
			end case;
		end if;
	end process;

end Behavioral;