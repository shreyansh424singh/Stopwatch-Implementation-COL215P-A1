-- Testbench for OR gate
library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component Stopwatch is
port(
        clk     : IN std_logic;
        start : IN std_logic; 
        pause : IN std_logic;
        reset : IN std_logic;
        anode : OUT std_logic_vector(3 DOWNTO 0);
        cathode : OUT std_logic_vector(7 DOWNTO 0)
    );
end component;

signal clk, s, p, r: std_logic := '0';
signal a : std_logic_vector (3 downto 0) := x"0";
signal c : std_logic_vector (7 downto 0) := x"00";

begin

  -- Connect DUT
  DUT: Stopwatch port map(clk, s, p, r, a, c);

  process
  begin
    s <= '1';
    p <= '0';
    r <= '0';

	for I in 0 to 1000000 loop
    clk <= not(clk);
    wait for 100 ns;
    end loop;

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
