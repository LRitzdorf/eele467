-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Debouncer interface
entity Debouncer is
    generic (DELAY_CYCLES : integer);
    port (clk : in std_logic;
          reset : in std_logic;
          input : in std_logic;
          output : out std_logic);
end entity;


-- Synchronous debouncer which ignores changes for a specified number of cycles
-- following an initial change
architecture Debouncer_Arch of Debouncer is
begin
    -- TODO
end architecture;
