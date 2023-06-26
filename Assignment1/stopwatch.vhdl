library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stopwatch is
    port(
        -- Inputs
        clk     : IN std_logic; -- master clock used for synchronous processes
    
        -- Buttons: '1' When button is pressed, '0' when not pressed.
        start : IN std_logic; -- Button to set the mode 
        pause : IN std_logic; -- Button to enter time setting mode and cycle between different digits.
        reset : IN std_logic; -- Button to increase time of the selected digit.
    
        -- Outputs
        anode : OUT std_logic_vector(3 DOWNTO 0); -- Anode output for FPGA Seven Segment Display
        cathode : OUT std_logic_vector(7 DOWNTO 0) -- Cathode output for FPGA Seven Segment Display
    );
    end entity;
    

    architecture StopwatchArch of Stopwatch is
        
        -- Denote whether stopwatch is paused or not.
        signal paused : std_logic := '0';
      
        constant clk_freq : natural := 100000000; -- constant which stores the clock frequency.
        -- Divided clocks: Value is attained from ClockDivider component.
        signal clk10hz   : std_logic; -- For keeping track of time
        signal clk400hz : std_logic; -- For display refresh. A 10ms refresh rate is selected. 4 digits per refresh means 2.5ms clocking is required. This requires a 400Hz clock.
    
    
        -- Signals for tracking time. Value stored in BCD format.
        signal m   : unsigned(3 DOWNTO 0):= "0000"; -- To maintain 2nd digit of minute
        signal s1   : unsigned(3 DOWNTO 0):= "0000"; -- To maintain 1st digit of second
        signal s2   : unsigned(3 DOWNTO 0):= "0000"; -- To maintain 2nd digit of second
        signal t   : unsigned(3 DOWNTO 0):= "0000"; -- To maintain 2nd digit of second
       
        -- Signals which store the last 3 values of the signal. 
        signal start1, start2, start3 : std_logic := '0';
        signal pause1, pause2, pause3 : std_logic := '0';
        signal reset1, reset2, reset3 : std_logic := '0';
        
        -- Updated value after debouncing
        signal new_pause, new_reset, new_start : std_logic := '0';        
        
        signal setAnode : unsigned(3 DOWNTO 0) := "0111"; -- Tracks the position of the selected digit. 0 indicates the display position in the bit string.
        signal digit : unsigned(3 DOWNTO 0) := "1111"; -- Tracks the value of the digit (0-9) to be displayed at the selected position. 
        -- Any value other than 0-9 displays no digit at that position. Used to create blink effect.
        signal dp : std_logic; -- Tracks whether a DP is to be displayed at the position along with the digit.
    
        -- Components
        -- ClockDivider: divides the master clock into various clocks(1Hz, 400Hz)
        component ClockDivider
            port(
                clk: IN std_logic;
                clk_freq: IN natural;
                clk10hz: OUT std_logic;
                clk400hz: OUT std_logic
            );
        end component;
    
        -- Timekeeper: Keeps track of the time
        component Timekeeper 
            port(
                clk10hz: IN std_logic;
                paused : IN std_logic;
                new_reset : IN std_logic;
                m   : INOUT unsigned(3 DOWNTO 0);
                s1  : INOUT unsigned(3 DOWNTO 0);
                s2  : INOUT unsigned(3 DOWNTO 0);
                t   : INOUT unsigned(3 DOWNTO 0)
            );
        end component;
    
        -- BCD2SSD: Converts the bcd digit to the cathode output format.
        component BCD_to_SSD
            port(       
                val : IN unsigned(3 DOWNTO 0);
                dp  : IN std_logic;
                dis : OUT std_logic_vector(7 DOWNTO 0)
            );
        end component;
    
    
    begin
        divideClocks : ClockDivider port map(clk => clk, clk_freq => clk_freq, clk10hz => clk10hz, clk400hz => clk400hz);

        keepTime : Timekeeper port map(clk10hz => clk10hz, paused => paused, new_reset => new_reset, m => m, s1 => s1, s2 => s2, t=>t);
    
        displayTime : BCD_to_SSD port map(val => digit, dp => dp, dis => cathode); 

        -- 400Hz clock used for display refresh. It sets the cathode and anode values.
        -- setAnode is used to track States. In every cycle, state transitions to the next one.
        -- 0111 -> 1011 -> 1101 -> 1110 -> 0111.. and so on
        process(clk400hz)
        begin
         
            -- if the clock is paused and start button is pressed
            if(paused = '1' and new_start = '1') then 
                paused <= '0';      --start the clock
            end if;

            -- if the clock is running and pause button is pressed
            if(paused = '0' and new_pause = '1') then 
                paused <= '1';      -- pause the clock
            end if;

            --  Debouncer Component
            --  Debouncing is done using three flip flop
            if rising_edge(clk) then
                start1 <= start;
                start2 <= start1;
                start3 <= start2;

                pause1 <= pause;
                pause2 <= pause1;
                pause3 <= pause2;

                reset1 <= reset;
                reset2 <= reset1;
                reset3 <= reset2;
            end if;

            --  the signal is set when the signal is stable for last three values.
            new_start <= start1 and start2 and start3;
            new_pause <= pause1 and pause2 and pause3;
            new_reset <= reset1 and reset2 and reset3;

        
            if(clk400hz = '1' and clk400hz'event) then
                -- State Transition
                case setAnode is
                    when "0111" => setAnode <= "1011";
                    when "1011" => setAnode <= "1101";
                    when "1101" => setAnode <= "1110";
                    when "1110" => setAnode <= "0111";
                    when others => setAnode <= "0111";
                end case;
                
                -- Using the setAnode state to determine anode and cathode. (Basically signifies the position of the digit on the display)
                -- Based on the setAnode state, after accounting for blinking, the current digit(BCD) which has to be encoded to cathode signal and sent along with the appropriate anode signal is determined.
                if(setAnode = "0111") then digit <= m;
                elsif(setAnode = "1011") then digit <= s1; 
                elsif(setAnode = "1101") then digit <= s2;
                elsif(setAnode = "1110") then digit <= t;
                end if;
                -- Based on the setAnode state, the current DP state which has to be encoded to cathode signal and sent along with the appropriate anode signal is determined.
                -- Set dp according to the value tracked by each decimal point bit
                if(setAnode = "0111")    then dp <= '0';
                elsif(setAnode = "1011") then dp <= '1';
                elsif(setAnode = "1101") then dp <= '0';
                elsif(setAnode = "1110") then dp <= '1';
                else dp <='1';
                end if;
                -- assign anode 
                anode <= std_logic_vector(setAnode);
                -- cathode assigned in component BCD2SSD
            end if;
            
        end process;
        
    end architecture;