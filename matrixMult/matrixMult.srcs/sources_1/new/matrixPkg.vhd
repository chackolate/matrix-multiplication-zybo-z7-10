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
	type row_type is array(0 to 1) of unsigned(7 downto 0);
	type matrix_type is array(0 to 1) of row_type;

	type row_type_16 is array(0 to 1) of unsigned(15 downto 0);
	type matrix_type_16 is array(0 to 1) of row_type_16;

	type matrix_row is array(0 to 3) of matrix_type;
	type matrix_row_16 is array(0 to 3) of matrix_type_16;

	type matrix_array is array(0 to 3) of matrix_row;
	type matrix_array_16 is array(0 to 3) of matrix_row_16;

end package;