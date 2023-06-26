library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ClockDivider is
    port(
        clk: IN std_logic;
        clk_freq: IN natural;
        clk10hz: OUT std_logic;
        clk400hz: OUT std_logic
    );
end entity;

architecture Divider of ClockDivider is 

signal counter10     : natural:= 0; -- Counter for 1Hz clock
signal counter400   : natural:= 0; -- Counter for 400Hz clock
signal bit10 : std_logic := '0';
signal bitref: std_logic := '0';

begin 
    process(clk)
    begin
        if(clk='1' and clk'event) then
            -- increment counter at every clock cycle and wrap at clock_freq/10 to get 10Hz clock.
            if(counter10 = clk_freq/20-1) then 
                counter10 <= 0;
                bit10 <= not(bit10);
            else
                counter10 <= counter10+1;
            end if;
            if(counter400 = clk_freq/400-1) then 
                counter400 <= 0;
                bitref <= not(bitref);
            else
                counter400 <= counter400+1;
            end if;
        end if;
    end process;
    
    clk10hz <= bit10;
    clk400hz <= bitref;

end architecture;