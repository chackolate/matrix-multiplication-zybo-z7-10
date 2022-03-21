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

	signal D_a          : unsigned (3 downto 0) := X"3"; --LFSR seeds
	signal D_b          : unsigned (3 downto 0) := X"1";
	signal Q_a, Q_b     : unsigned (3 downto 0) := X"0"; --LFSR output
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

	LFSR0 : LFSR4
	generic map(width => 4)
	port map(
		clock  => clk,
		reload => reload,
		D      => D_a,
		en     => en,
		Q      => Q_a
	);

	LFSR1 : LFSR4
	generic map(width => 4)
	port map(
		clock  => clk,
		reload => reload,
		D      => D_b,
		en     => en,
		Q      => Q_b
	);

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
		for i in 0 to 2 loop
			for j in 0 to 2 loop
				A(i)(j)(3 downto 0) <= Q_a;
				A(i)(j)(7 downto 4) <= "0000";
				B(i)(j)(3 downto 0) <= Q_b;
				B(i)(j)(7 downto 4) <= "0000";
				wait for clk_period;
			end loop;
		end loop;
		en    <= '0';
		reset <= '0';
		start <= '1';
		wait;
	end process;

end Behavioral;