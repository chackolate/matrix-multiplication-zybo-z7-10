----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2022 06:25:53 PM
-- Design Name: 
-- Module Name: matrix_wrapper - Behavioral
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

entity matrix_wrapper is
	generic (N : integer);
	port (
		clk   : in std_logic;
		reset : in std_logic;
		start : in std_logic;
		A     : in std_logic_vector(((N * 32) - 1) downto 0); --2x2 matrix = 32 bits * number of matrices invoked
		B     : in std_logic_vector(((N * 32) - 1) downto 0);
		C     : out std_logic_vector(((N * 64) - 1) downto 0);
		done  : out std_logic);
end matrix_wrapper;

architecture Behavioral of matrix_wrapper is

	component matrixMult
		port (
			clk   : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			A, B  : in matrix_type;
			C     : out matrix_type_16;
			done  : out std_logic);
	end component;

	signal A_u : unsigned(((N * 32) - 1) downto 0);
	signal B_u : unsigned(((N * 32) - 1) downto 0);
	signal C_u : unsigned(((N * 64) - 1) downto 0);

begin

	A_u <= unsigned(A);
	B_u <= unsigned(B);
	C   <= std_logic_vector(C_u);

	MM_GEN :
	for I in 1 to N generate
		MMX : matrixMult port map(
			clk     => clk,
			reset   => reset,
			start   => start,

			A(0)(0) => A_u((I * 32) - 1 downto (I * 32) - 8),   --(63:56),(31:24)
			A(0)(1) => A_u((I * 32) - 9 downto (I * 32) - 16),  --(55:48),(23:16)
			A(1)(0) => A_u((I * 32) - 17 downto (I * 32) - 24), --(47:40),(15:8)
			A(1)(1) => A_u((I * 32) - 25 downto (I * 32) - 32), --(39:32),(7:0)

			B(0)(0) => B_u((I * 32) - 1 downto (I * 32) - 8),
			B(0)(1) => B_u((I * 32) - 9 downto (I * 32) - 16),
			B(1)(0) => B_u((I * 32) - 17 downto (I * 32) - 24),
			B(1)(1) => B_u((I * 32) - 25 downto (I * 32) - 32),

			C(0)(0) => C_u((I * 64) - 1 downto (I * 64) - 16),
			C(0)(1) => C_u((I * 64) - 17 downto (I * 64) - 32),
			C(1)(0) => C_u((I * 64) - 33 downto (I * 64) - 48),
			C(1)(1) => C_u((I * 64) - 49 downto (I * 64) - 64),

			done    => done
		);
	end generate MM_GEN;

end Behavioral;