----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2022 02:47:21 PM
-- Design Name: 
-- Module Name: matrixMult_tb_2 - Behavioral
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

entity matrixMult_tb_2 is
	--  Port ( );
end matrixMult_tb_2;

architecture Behavioral of matrixMult_tb_2 is

	component matrixMult
		port (
			clk   : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			A, B  : in matrix_type;
			C     : out matrix_type_16;
			done  : out std_logic);
	end component;

	signal A, B                    : unsigned(63 downto 0);
	signal A0, A1, B0, B1          : matrix_type;
	signal C                       : unsigned(127 downto 0);
	signal C0, C1                  : matrix_type_16;
	signal clk, reset, start, done : std_logic;
	constant clk_period            : time := 10 ns;

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
	signal D_a, D_b   : lfsr_in_32;
	signal Q_a, Q_b   : lfsr_in_32;
	signal reload, en : std_logic;

begin

	D_a(0)            <= X"f963558e";
	D_a(1)            <= X"1bbb5363";
	D_b(0)            <= X"1bbb5363";
	D_b(1)            <= X"a6ce5f6c";

	A0(0)(0)          <= A(63 downto 56);
	A0(0)(1)          <= A(55 downto 48);
	A0(1)(0)          <= A(47 downto 40);
	A0(1)(1)          <= A(39 downto 32);

	A1(0)(0)          <= A(31 downto 24);
	A1(0)(1)          <= A(23 downto 16);
	A1(1)(0)          <= A(15 downto 8);
	A1(1)(1)          <= A(7 downto 0);

	B0(0)(0)          <= B(63 downto 56);
	B0(0)(1)          <= B(55 downto 48);
	B0(1)(0)          <= B(47 downto 40);
	B0(1)(1)          <= B(39 downto 32);

	B1(0)(0)          <= B(31 downto 24);
	B1(0)(1)          <= B(23 downto 16);
	B1(1)(0)          <= B(15 downto 8);
	B1(1)(1)          <= B(7 downto 0);

	C(127 downto 112) <= C0(0)(0);
	C(111 downto 96)  <= C0(0)(1);
	C(95 downto 80)   <= C0(1)(0);
	C(79 downto 64)   <= C0(1)(1);
	C(63 downto 48)   <= C1(0)(0);
	C(47 downto 32)   <= C1(0)(1);
	C(31 downto 16)   <= C1(1)(0);
	C(15 downto 0)    <= C1(1)(1);

	MM0 : matrixMult
	port map(
		clk   => clk,
		reset => reset,
		start => start,
		A     => A0,
		B     => B0,
		C     => C0
	);

	MM1 : matrixMult
	port map(
		clk   => clk,
		reset => reset,
		start => start,
		A     => A1,
		B     => B1,
		C     => C1
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
		A(63 downto 32) <= Q_a(0);
		A(31 downto 0)  <= Q_a(1);
		B(63 downto 32) <= Q_b(0);
		B(31 downto 0)  <= Q_b(1);
		en              <= '0';
		reset           <= '0';
		start           <= '1';
		wait for clk_period;
		start <= '0';
		wait;
	end process;

end Behavioral;