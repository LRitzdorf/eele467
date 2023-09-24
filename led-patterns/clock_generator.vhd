-- altera vhdl_input_version vhdl_2008

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
        SYS_CLKs_sec : unsigned;
        -- Scale factors for each clock (array of UQ4.4)
        CLK_SCALES   : byte_2d
    );
    port (
        -- System clock
        clk        : in    std_logic;
        -- NOTE: Active high reset
        reset      : in    std_logic;
        -- Base transition period, in seconds (UQ4.4)
        Base_rate  : in    unsigned(7 downto 0);
        -- Generated clock outputs
        gen_clocks : out   std_logic_vector(CLK_SCALES'range)
    );
end entity;


architecture ClockGenerator_Arch of ClockGenerator is
begin

    -- Clock generator state-machine array
    clock_fsm_array : for N in CLK_SCALES'range generate
        clock_fsm : process (clk, reset) is
            variable limit : unsigned(
                    SYS_CLKs_sec'length
                        + Base_rate'length
                        + CLK_SCALES(N)'length
                        - 1
                    downto 0
                );
            variable ticks : unsigned(
                    SYS_CLKs_sec'length
                        + Base_rate'length - 4
                        + CLK_SCALES(N)'length - 4
                        - 1
                    downto 0
                );
        begin

            if reset then
                gen_clocks(N) <= '0';
                ticks         := to_unsigned(0, ticks'length);
            elsif rising_edge(clk) then
                limit := unsigned(CLK_SCALES(N)) * Base_rate * SYS_CLKs_sec;
                if ticks < limit(limit'high downto limit'low + 8) - 1 then
                    gen_clocks(N) <= '0';
                    ticks         := ticks + 1;
                else
                    gen_clocks(N) <= '1';
                    ticks         := to_unsigned(0, ticks'length);
                end if;
            end if;

        end process;
    end generate;

end architecture;
