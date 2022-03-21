library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity lab5 is
	port (
		clk   : in std_logic;
		reset : in std_logic
	);
end lab5;

architecture Behavioral of lab5 is

	--integer is equivalent to std_logic_vector(32 downto 0) but can use some math operations that we need.
	signal counter   : integer := 0;         --use := to initialize a variable, we want to start ours at 0
	constant maximum : integer := 125000000; --initialize our maximum to 125 million

begin

	counting : process (clk) --run process every time clk value changes
	begin
		if (rising_edge(clk)) then   --if the change in clk was a rising edge, count up
			if (counter >= maximum) then --125 MHz = after 125 million ticks, one second has passed
				counter <= 0;
			else
				counter <= counter + 1; --if value has not reached max, increment count
			end if;
		end if;
	end process;

end Behavioral;