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

	component matrixMult
		port (
			clk   : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			A, B  : in matrix_type;
			C     : out matrix_type;
			done  : out std_logic);
	end component;

	signal clk, reset, start, done : std_logic;
	signal A, B, C                 : matrix_type;

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

	signal D0, D1       : matrix_type := (others => (others => X"32"));
	signal Q0, Q1       : matrix_type := (others => (others => X"00"));
	signal reload, en   : std_logic;
	constant clk_period : time := 8 ns;

begin

	MM0 : matrixMult port map(
		clk   => clk,
		reset => reset,
		start => start,
		A     => A,
		B     => B,
		C     => C,
		done  => done
	);

	GEN_LFSR_A : for I in 0 to 2 generate
		GEN_LFSR_INST_A : for J in 0 to 2 generate
			LFSR_X : LFSR4
			generic map(width => 8)
			port map(
				clock  => clk,
				reload => reload,
				D      => D0(I)(J),
				en     => en,
				Q      => Q0(I)(J)
			);
		end generate;
	end generate;

	GEN_LFSR_B : for I in 0 to 2 generate
		GEN_LFSR_INST_B : for J in 0 to 2 generate
			LFSR_X : LFSR4
			generic map(width => 8)
			port map(
				clock  => clk,
				reload => reload,
				D      => D1(I)(J),
				en     => en,
				Q      => Q1(I)(J)
			);
		end generate;
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
		wait for clk_period * 8;
		en    <= '0';
		start <= '1';
		reset <= '0';
		A     <= Q0;
		B     <= Q1;
		wait;
	end process;

end Behavioral;