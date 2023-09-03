-- Lucas Ritzdorf
-- 09/02/2023
-- EELE 467, HW 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Synchronizer interface
entity Synchronizer is
    port (clk : in std_logic;
          input : in std_logic;
          output : out std_logic);
end entity;


-- Basic dual-flip-flop synchronizer
architecture Synchronizer_Arch of Synchronizer is
    signal d : std_logic;
begin
sync: process (clk) begin
    if rising_edge(clk) then
        d <= input;
        output <= d;
    end if;
end process;
end architecture;
