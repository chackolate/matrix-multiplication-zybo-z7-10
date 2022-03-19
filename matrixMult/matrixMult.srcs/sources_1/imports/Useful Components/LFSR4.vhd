----------------------------------------------------------------------------------
-- Create Date: 02/20/2020 10:57:14 AM
-- Design Name: Random number generator.
-- Module Name: LFSR - LFSR
-- Project Name: Project 1
-- Target Devices: Zybo
-- Tool Versions: 2017.4
-- Description: Generate n-bit pseudo random number. 

---------------- input reload=1,en=0; load seed from input D.
---------------- input reload=0,en=1; generate a new random number every clock cycle..
---------------- Q; ouptput for random number
----------------------------------------------------------------------------------

------------------------------------library---------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
------------------------------------end-------------------------------------------

------------------------------------entity----------------------------------------
entity LFSR4 is
	--  Port ( );
	generic (width : positive); --LFSR port size
	port (
		clock  : in std_logic;                     --driven clock
		reload : in std_logic;                     --load seed from input D
		D      : in unsigned (width - 1 downto 0); --input for loading seed
		en     : in std_logic;                     --enable random generation
		Q      : out unsigned (width - 1 downto 0) --ouptput for random number
	);
end LFSR4;
------------------------------------end-------------------------------------------

---------------------------------architecture-------------------------------------
architecture LFSR4 of LFSR4 is

	signal Qt : unsigned(width - 1 downto 0); -- random number register

begin

	process (clock)                  -- clock signal sensitive 
		variable tmp : std_logic := '0'; -- random generated new bit
	begin
		if rising_edge(clock) then
			if (reload = '1') then -- input reload=1,en=0; load seed from input D.
				Qt <= D;

			elsif (en = '1') then -- input reload=0,en=1; generate a new random number every clock cycle.
				tmp := not((Qt(width - 1) xor Qt(0)));
				Qt <= tmp & Qt(width - 1 downto 1);
			end if;
		end if;
	end process;

	Q <= Qt; -- give random number to output

end LFSR4;
------------------------------------end-------------------------------------------