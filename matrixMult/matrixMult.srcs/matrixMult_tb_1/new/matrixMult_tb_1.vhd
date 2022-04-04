----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2022 02:25:31 PM
-- Design Name: 
-- Module Name: matrixMult_tb_1 - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library work;
use work.matrixPkg.all;

entity matrixMult_tb_1 is
	--  Port ( );
end matrixMult_tb_1;

architecture Behavioral of matrixMult_tb_1 is

	component matrix_wrapper
		generic (N : integer);
		port (
			clk   : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			A     : in std_logic_vector(((N * 32) - 1) downto 0); --2x2 matrix = 32 bits * number of matrices invoked
			B     : in std_logic_vector(((N * 32) - 1) downto 0);
			C     : out std_logic_vector(((N * 64) - 1) downto 0);
			done  : out std_logic);
	end component;
	signal clk, reset, start, done : std_logic;
	signal A0, B0                  : std_logic_vector(63 downto 0);
	signal C0                      : std_logic_vector(127 downto 0);
	signal A, B                    : matrix_type;
	signal C                       : matrix_type_16;

	component LFSR4
		generic (width : positive); --LFSR port size
		port (
			clock  : in std_logic;                     --driven clock
			reload : in std_logic;                     --load seed from input D
			D      : in unsigned (width - 1 downto 0); --input for loading seed
			en     : in std_logic;                     --enable random generation
			Q      : out unsigned (width - 1 downto 0) --ouptput for random number
		);
	end component;
	type lfsr_in_32 is array(0 to 1) of unsigned(31 downto 0);
	signal D_a, D_b     : lfsr_in_32;
	signal Q_a, Q_b     : lfsr_in_32;
	signal reload, en   : std_logic;
	constant clk_period : time := 10 ns;

begin

	D_a(0) <= X"f963558e";
	D_a(1) <= X"1bbb5363";
	D_b(0) <= X"841e67c0";
	D_b(1) <= X"a6ce5f6c";

	MM0 : matrix_wrapper
	generic map(N => 2)
	port map(
		clk   => clk,
		reset => reset,
		start => start,
		A     => A0,
		B     => B0,
		C     => C0,
		done  => done
	);

	LFSR_A : for I in 0 to 1 generate
		LFSR_AX : LFSR4
		generic map(width => 32)
		port map(
			clock  => clk,
			reload => reload,
			D      => D_a(I),
			en     => en,
			Q      => Q_a(I)
		);
	end generate;

	LFSR_B : for I in 0 to 1 generate
		LFSR_BX : LFSR4
		generic map(width => 32)
		port map(
			clock  => clk,
			reload => reload,
			D      => D_b(I),
			en     => en,
			Q      => Q_b(I)
		);
	end generate;

	clocking : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	stim : process
	begin
		reload <= '1';
		start  <= '0';
		reset  <= '1';
		wait for clk_period;
		reload <= '0';
		reset  <= '0';
		en     <= '1';
		wait for clk_period * 32;
		A0(63 downto 32) <= std_logic_vector(Q_a(0));
		A0(31 downto 0)  <= std_logic_vector(Q_a(1));
		B0(63 downto 32) <= std_logic_vector(Q_b(0));
		B0(31 downto 0)  <= std_logic_vector(Q_b(1));

		en               <= '0';
		reset            <= '0';
		start            <= '1';
		wait for clk_period;
		start <= '0';
		wait;
	end process;
end Behavioral;