-- Lucas Ritzdorf
-- 09/10/2023
-- EELE 467, Lab 4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Convenience library with common utilities
package common is

    type slv_2d is array(integer range <>) of std_logic_vector;
    type byte_2d is array(integer range <>) of std_logic_vector(7 downto 0);

end package;
