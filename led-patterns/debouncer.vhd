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
    type state_t is (READY, BOUNCE);
    signal state : state_t;
    signal count : integer range 0 to DELAY_CYCLES-1;
begin
debounce: process (clk) is begin
    if rising_edge(clk) then
        if reset then
            state <= READY;
            output <= '0';
        else
            case state is
                when READY =>
                    if input /= output then
                        state <= BOUNCE;
                        count <= 0;
                    end if;
                    output <= input;
                when BOUNCE =>
                    if count = DELAY_CYCLES-1 then
                        state <= READY;
                    else
                        count <= count + 1;
                    end if;
            end case;
        end if;
    end if;
end process;
end architecture;
