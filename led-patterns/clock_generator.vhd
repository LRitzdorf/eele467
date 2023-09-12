-- Lucas Ritzdorf
-- 09/10/2023
-- EELE 467, Lab 4

use work.common.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Clock generator interface
entity ClockGenerator is
    generic (
        -- Number of system clock cycles per second
        SYS_CLKs_sec : natural;
        -- Scale factors for each clock (array of UQ4.4)
        CLK_SCALES   : byte_2d);
    port (
        -- System clock
        clk   : in std_logic;
        -- NOTE: Active high reset
        reset : in std_logic;
        -- Base transition period, in seconds (UQ4.4)
        Base_rate  : in  unsigned(7 downto 0);
        -- Generated clock outputs
        gen_clocks : out std_logic_vector(CLK_SCALES'range));
end entity;


architecture ClockGenerator_Arch of ClockGenerator is
begin

-- Clock generator state-machine array
clock_fsm_array: for N in CLK_SCALES'range generate
    process(clk)
        variable ticks : natural;
    begin
        if reset then
            gen_clocks(N) <= '0';
            ticks := 0;
        elsif rising_edge(clk) then
            if ticks = ((unsigned(CLK_SCALES(N)) * Base_rate * SYS_CLKs_sec) / 2**8) - 1 then
                gen_clocks(N) <= '1';
                ticks := 0;
            else
                gen_clocks(N) <= '0';
                ticks := ticks + 1;
            end if;
        end if;
    end process;
end generate;

end architecture;
