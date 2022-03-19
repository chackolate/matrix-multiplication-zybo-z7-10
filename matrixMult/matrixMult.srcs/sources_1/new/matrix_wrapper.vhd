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
use work.matrixPkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity matrix_wrapper is
	port (
		clk    : in std_logic;
		reset  : in std_logic;
		start  : in std_logic;
		A0, B0 : in std_logic_vector(23 downto 0);
		A1, B1 : in std_logic_vector(23 downto 0);
		A2, B2 : in std_logic_vector(23 downto 0);
		C0     : out std_logic_vector(23 downto 0);
		C1     : out std_logic_vector(23 downto 0);
		C2     : out std_logic_vector(23 downto 0);
		done   : out std_logic);
end matrix_wrapper;

architecture Behavioral of matrix_wrapper is

	component matrixMult
		port (
			clk   : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			A, B  : in matrix_type;
			C     : out matrix_type;
			done  : out std_logic);
	end component;

	signal A0_u, A1_u, A2_u : unsigned(23 downto 0);
	signal B0_u, B1_u, B2_u : unsigned(23 downto 0);
	signal C0_u, C1_u, C2_u : unsigned(23 downto 0);

begin

	A0_u <= unsigned(A0);
	A1_u <= unsigned(A1);
	A2_u <= unsigned(A2);

	B0_u <= unsigned(B0);
	B1_u <= unsigned(B1);
	B2_u <= unsigned(B2);

	C0   <= std_logic_vector(C0_u);
	C1   <= std_logic_vector(C1_u);
	C2   <= std_logic_vector(C2_u);

	MM0 : matrixMult
	port map(
		clk     => clk,
		reset   => reset,
		start   => start,
		A(0)(0) => A0_u(23 downto 16),
		A(0)(1) => A0_u(15 downto 8),
		A(0)(2) => A0_u(7 downto 0),
		A(1)(0) => A1_u(23 downto 16),
		A(1)(1) => A1_u(15 downto 8),
		A(1)(2) => A1_u(7 downto 0),
		A(2)(0) => A2_u(23 downto 16),
		A(2)(1) => A2_u(15 downto 8),
		A(2)(2) => A2_u(7 downto 0),
		B(0)(0) => B0_u(23 downto 16),
		B(0)(1) => B0_u(15 downto 8),
		B(0)(2) => B0_u(7 downto 0),
		B(1)(0) => B1_u(23 downto 16),
		B(1)(1) => B1_u(15 downto 8),
		B(1)(2) => B1_u(7 downto 0),
		B(2)(0) => B2_u(23 downto 16),
		B(2)(1) => B2_u(15 downto 8),
		B(2)(2) => B2_u(7 downto 0),
		C(0)(0) => C0_u(23 downto 16),
		C(0)(1) => C0_u(15 downto 8),
		C(0)(2) => C0_u(7 downto 0),
		C(1)(0) => C1_u(23 downto 16),
		C(1)(1) => C1_u(15 downto 8),
		C(1)(2) => C1_u(7 downto 0),
		C(2)(0) => C2_u(23 downto 16),
		C(2)(1) => C2_u(15 downto 8),
		C(2)(2) => C2_u(7 downto 0),
		done    => done
	);

end Behavioral;