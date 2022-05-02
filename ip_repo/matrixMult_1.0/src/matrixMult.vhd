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
	signal m_C : matrix_type_16 := (others => (others => X"0000"));
	type state_type is (init, mult, apply_c, idle);
	signal current_state, next_state : state_type := init;

begin

	clocking : process (clk, reset)
	begin
		if (reset = '1') then
			current_state <= init;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;

	nextstates : process (current_state, start)
	begin
		case current_state is
			when init => --clear and wait
				m_C(0)(0) <= (X"0000");
				m_C(0)(1) <= (X"0000");
				m_C(1)(0) <= (X"0000");
				m_C(1)(1) <= (X"0000");
				C(0)(0)   <= (X"0000");
				C(0)(1)   <= (X"0000");
				C(1)(0)   <= (X"0000");
				C(1)(1)   <= (X"0000");
				done      <= '0';
				if (start = '1') then
					next_state <= mult;
				else
					next_state <= init;
				end if;
			when mult => --multiply
				m_C(0)(0)  <= (A(0)(0) * B(0)(0)) + (A(0)(1) * B(1)(0));
				m_C(0)(1)  <= (A(0)(0) * B(0)(1)) + (A(0)(1) * B(1)(1));
				m_C(1)(0)  <= (A(1)(0) * B(0)(0)) + (A(1)(1) * B(1)(0));
				m_C(1)(1)  <= (A(1)(0) * B(0)(1)) + (A(1)(1) * B(1)(1));
				C(0)(0)    <= (X"0000");
				C(0)(1)    <= (X"0000");
				C(1)(0)    <= (X"0000");
				C(1)(1)    <= (X"0000");
				done       <= '0';
				next_state <= apply_c;
			when apply_c => --load result to output
				C(0)(0)    <= m_C(0)(0);
				C(0)(1)    <= m_C(0)(1);
				C(1)(0)    <= m_C(1)(0);
				C(1)(1)    <= m_C(1)(1);
				done       <= '1';
				next_state <= idle;
			when idle => --hold and wait
				if (start = '1') then
					next_state <= init;
				else
					next_state <= idle;
				end if;
				done <= '0';
		end case;
	end process;

end Behavioral;