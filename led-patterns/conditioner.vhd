-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Conditioner interface
entity Conditioner is
    generic (WIDTH : integer := 1;
             -- Debounce delay: 90 ms (derived from 50MHz fabric clock)
             DEBOUNCE_CYCLES : integer := 4500000);
    port (clk : in std_logic;
          reset : in std_logic;
          input : in std_logic_vector(WIDTH-1 downto 0);
          output : out std_logic_vector(WIDTH-1 downto 0));
end entity;


-- Pass inputs through a chain of conditioning modules
architecture Conditioner_Arch of Conditioner is
    signal synced, debounced : std_logic;
begin
    parallel_conditioning: for I in 0 to WIDTH-1 generate
        synchonizer: entity work.Synchronizer
            port map (clk,
                      input => input(I),
                      output => synced);
        debouncer: entity work.Debouncer
            generic map (DELAY_CYCLES => DEBOUNCE_CYCLES)
            port map (clk,
                      reset,
                      input => synced,
                      output => debounced);
        pulser: entity work.OnePulse
            port map (clk,
                      input => debounced,
                      output => output(I));
    end generate;
end architecture;
