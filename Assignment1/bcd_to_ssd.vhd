LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


entity BCD_to_SSD is
	Port ( val : in unsigned (3 downto 0);			-- number to be displayed
	       dp  : in std_logic;						
	       dis : out std_logic_vector (7 downto 0)  -- return the cathode values
	     );
end BCD_to_SSD;

architecture Behavioral of BCD_to_SSD is

begin

-- Value of cathodes after kmap simplification
	dis(0) <= not(val(3) or val(1) or (val(2) and val(0)) or (not(val(2)) and not(val(0))));
	dis(1) <= not(not(val(2)) or (not(val(1)) and not(val(0))) or (val(1) and val(0)));
	dis(2) <= not(val(2) or not(val(1)) or val(0));
    dis(3) <= (not(val(3)) and not(val(2)) and not(val(1)) and val(0)) or (not(val(3)) and val(2) and not(val(1)) and not(val(0))) or (not(val(3)) and val(2) and val(1) and val(0));	dis(4) <= not((not(val(2)) and not(val(0))) or (val(1) and not(val(0))));
	dis(5) <= not(val(3) or (not(val(1)) and not(val(0))) or (val(2) and not(val(1))) or (val(2) and not(val(0))));
	dis(6) <= not(val(3) or (val(2) and not(val(1))) or (not(val(2)) and val(1)) or (val(1) and not(val(0))));
	dis(7) <= dp;

end  Behavioral ;
