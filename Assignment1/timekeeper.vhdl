library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timekeeper is
    port(
        -- Input signals
        clk10hz  : IN std_logic;
        paused  : IN std_logic;
        new_reset : IN std_logic;
        -- InOut signals - Read and Write
        m   : INOUT unsigned(3 DOWNTO 0):="0000";
        s1  : INOUT unsigned(3 DOWNTO 0):="0000";
        s2  : INOUT unsigned(3 DOWNTO 0):="0000";
        t   : INOUT unsigned(3 DOWNTO 0):="0000"
    );
end entity;

architecture timing of Timekeeper is
begin
    process(clk10hz, paused, new_reset)
    begin
        if (clk10hz = '1' and clk10hz'event and paused = '0') then -- If clock is not paused then incremenents time every second.
            if(t = "1001") then                          -- when the tenth of second reaches 9   
                t <= "0000";                             -- set it to 0 and check for unit digit of second
                if(s2 = "1001") then                     -- when the unit digit of second reaches 9              
                    s2 <= "0000";                        -- set it to 0 and check for tens of second       
                    if(s1 = "0101") then                 -- when the tens of second reaches 5                 
                        s1 <= "0000";                    -- set it to 0 and check for minute
                        if(m = "1001") then              -- when the minute reaches 9                      
                            m <= "0000";                 -- set it to 0
                        else
                            m <= m+1;
                        end if;
                    else
                        s1 <= s1+1;
                    end if;
                else
                    s2 <= s2+1;
                end if;
            else
                t <= t+1;
            end if;
        end if;

        -- When reset button is pressed set all the values to "0000"
        if(new_reset = '1') then
            m <= "0000";
            s1 <= "0000";
            s2 <= "0000";
            t <= "0000";
        end if; 
    end process;
    
end architecture;
