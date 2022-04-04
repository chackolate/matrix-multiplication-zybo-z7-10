----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2022 04:11:24 PM
-- Design Name: 
-- Module Name: matrixMult_tb - Behavioral
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

entity matrixMult_tb is
	--  Port ( );
end matrixMult_tb;

architecture Behavioral of matrixMult_tb is

	-- component matrixMult
	-- 	port (
	-- 		clk   : in std_logic;
	-- 		reset : in std_logic;
	-- 		start : in std_logic;
	-- 		A, B  : in matrix_type;
	-- 		C     : out matrix_type_16;
	-- 		done  : out std_logic);
	-- end component;

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
	signal A0                      : std_logic_vector(511 downto 0);
	signal A                       : matrix_array;
	signal B0                      : std_logic_vector(511 downto 0);
	signal B                       : matrix_array;
	signal C0                      : std_logic_vector(1023 downto 0);
	signal C                       : matrix_array_16;

	component LFSR4             --used to generate random 8-bit numbers
		generic (width : positive); --LFSR port size
		port (
			clock  : in std_logic;                     --driven clock
			reload : in std_logic;                     --load seed from input D
			D      : in unsigned (width - 1 downto 0); --input for loading seed
			en     : in std_logic;                     --enable random generation
			Q      : out unsigned (width - 1 downto 0) --ouptput for random number
		);
	end component;

	type lfsr_in_32 is array(0 to 15) of unsigned(31 downto 0);
	signal D_a, D_b     : lfsr_in_32;

	signal Q_a, Q_b     : lfsr_in_32;
	signal reload, en   : std_logic;
	constant clk_period : time := 10 ns;

begin

	D_a(0) <= X"f963558e";
	D_a(1) <= X"1bbb5363";
	D_a(2) <= X"f6233b91";
	D_a(3) <= X"4804b2e7";

	D_b(0) <= X"5bb5bb52";
	D_b(1) <= X"a6ce5f6c";
	D_b(2) <= X"910e4136";
	D_b(3) <= X"f440912d";

	MM0 : matrix_wrapper
	generic map(N => 16)
	port map(
		clk   => clk,
		reset => reset,
		start => start,
		A     => A0,
		B     => B0,
		C     => C0,
		done  => done
	);

	LFSR_A : for I in 0 to 15 generate
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

	LFSR_B : for I in 0 to 15 generate
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

		for I in 1 to 16 loop
			A0((I * 32) - 1 downto (I * 32) - 8) <= std_logic_vector(Q_a(I - 1));
			B0((I * 32) - 1 downto (I * 32) - 8) <= std_logic_vector(Q_b(I - 1));
		end loop;

		en    <= '0';
		reset <= '0';
		start <= '1';
		wait for clk_period;
		start <= '0';
		wait;
	end process;
	
	for I in 0 to 15 loop
	   
    end loop;

	C(0)(0)(0)(0) <= unsigned(C0(1023 downto 1008));
end Behavioral;