----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2022 07:27:50 PM
-- Design Name: 
-- Module Name: input_buffer - Behavioral
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

entity input_buffer is
	port (
		A     : in std_logic_vector (127 downto 0); --64 bit inputs
		B     : in std_logic_vector (127 downto 0);
		wr_en : in std_logic; --write enable
		reset : in std_logic; --asynchronous reset
		clk   : in std_logic;
		start : in std_logic;
		C     : out std_logic_vector(255 downto 0);
		done  : out std_logic);
end input_buffer;

architecture Behavioral of input_buffer is

	component matrix_wrapper
		generic (N : integer);
		port (
			clk   : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			A     : in signed(((N * 32) - 1) downto 0); --2x2 matrix = 32 bits * number of matrices invoked
			B     : in signed(((N * 32) - 1) downto 0);
			C     : out signed(((N * 64) - 1) downto 0);
			done  : out std_logic_vector((N - 1) downto 0)); --done signal for each multiplier
	end component;

	signal A0, B0                    : signed(127 downto 0);
	signal C0                        : signed(255 downto 0);
	signal C_buf                     : std_logic_vector(255 downto 0);
	signal done_array                : std_logic_vector(3 downto 0);
	signal read_en, done_buf         : std_logic;
	signal current_state, next_state : std_logic_vector(1 downto 0); --00 reset, 01 hold, 10 write inputs, 11 read output

begin

	C    <= C_buf;
	done <= done_buf;

	MM0 : matrix_wrapper
	generic map(N => 4)
	port map(
		clk   => clk,
		reset => reset,
		start => start,
		A     => A0,
		B     => B0,
		C     => C0,
		done  => done_array
	);

	clocking : process (clk, reset) begin
		if (reset = '1') then
			current_state <= "00";
		elsif (rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process;

	read_en <= done_array(0) and done_array(1) and done_array(2) and done_array(3);

	states : process (current_state, wr_en, start, read_en)
	begin
		case current_state is
			when "00"             =>
				--reset
				A0         <= (others => '0');
				B0         <= (others => '0');
				C_buf      <= (others => '0');
				next_state <= "01";
			when "01" =>
				--hold
				A0    <= A0;
				B0    <= B0;
				C_buf <= C_buf;
				if (wr_en = '1') then
					next_state <= "10"; --write
				elsif (read_en = '1') then
					next_state <= "11"; --read
				else
					next_state <= "01"; --idle
				end if;
				done_buf <= done_buf;
			when "10" =>
				--write inputs
				A0         <= signed(A);
				B0         <= signed(B);
				C_buf      <= C_buf;
				next_state <= "01";
				done_buf   <= '0';
			when "11" =>
				--write output
				A0         <= A0;
				B0         <= B0;
				C_buf      <= std_logic_vector(C0);
				next_state <= "01";
				done_buf   <= '1';
			when others =>
				--base case
				A0         <= A0;
				B0         <= B0;
				C_buf      <= C_buf;
				next_state <= "01";
				done_buf   <= '1';
		end case;
	end process;

end Behavioral;