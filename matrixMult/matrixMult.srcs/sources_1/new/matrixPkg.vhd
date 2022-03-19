library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package matrixPkg is
	type row_type is array(0 to 2) of unsigned(7 downto 0);
	type matrix_type is array(0 to 2) of row_type;
	type row_std_logic is array(0 to 2) of std_logic_vector(7 downto 0);
	type matrix_std_logic is array(0 to 2) of row_std_logic;
end package;