-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Conditioner interface
entity Conditioner is
    port (clk : in std_logic;
          reset : in std_logic;
          input : in std_logic;
          output : out std_logic);
end entity;


-- Pass inputs through a chain of conditioning modules
architecture Conditioner_Arch of Conditioner is
begin
    -- TODO
end architecture;
