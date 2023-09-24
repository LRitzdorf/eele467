-- Lucas Ritzdorf
-- 09/23/2023
-- EELE 467, Lab 6

use work.common.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- HPS interface for LED Patterns module
entity HPS_LED_Patterns is
    port (
        clk   : in std_logic;
        -- NOTE: Active high reset
        reset : in std_logic;
        -- Memory-mapped Avalon agent interface
        avs_s1_read      : in  std_logic;
        avs_s1_write     : in  std_logic;
        avs_s1_address   : in  std_logic_vector(1 downto 0);
        avs_s1_readdata  : out std_logic_vector(31 downto 0);
        avs_s1_writedata : in  std_logic_vector(31 downto 0);
        -- Active high state-change signal
        PB               : in  std_logic;
        -- Next-state selection switches
        SW               : in  std_logic_vector(3 downto 0);
        -- LED outputs
        LED              : out std_logic_vector(7 downto 0));
end entity;


architecture HPS_LED_Patterns_Arch of HPS_LED_Patterns is

    -- Number of system clock cycles per second
    constant SYS_CLKs_sec  : unsigned := to_unsigned(50000000, 26);

    -- Avalon-mapped LED control registers
    signal HPS_LED_control : std_logic                    := '0';
    signal LED_reg         : std_logic_vector(7 downto 0) := "01010101";
    signal Base_rate       : unsigned(7 downto 0)         := x"10";

begin

    -- Manage reading from mapped registers
    avalon_register_read : process(clk)
    begin
        if rising_edge(clk) and avs_s1_read = '1' then
            case avs_s1_address is
                when "00"   => avs_s1_readdata <= 31x"0" & HPS_LED_control;
                when "01"   => avs_s1_readdata <= 24x"0" & LED_reg;
                when "10"   => avs_s1_readdata <= 24x"0" & std_logic_vector(Base_rate);
                -- Return zeros for unused registers
                when others => avs_s1_readdata <= (others => '0');
            end case;
        end if;
    end process;

    -- Manage writing to mapped registers
    avalon_register_write : process(clk, reset)
    begin
        if reset then
            -- Reset all registers to their default values
            HPS_LED_control <= '0';
            LED_reg         <= "01010101";
            Base_rate       <= x"10";
        elsif rising_edge(clk) and avs_s1_write = '1' then
            case avs_s1_address is
                when "00"   => HPS_LED_control <= avs_s1_writedata(0);
                when "01"   => LED_reg <= avs_s1_writedata(7 downto 0);
                when "10"   => Base_rate <= unsigned(avs_s1_writedata(7 downto 0));
                -- Do nothing for unused registers
                when others => null;
            end case;
        end if;
    end process;

    -- Instantiate the LED_Patterns component
    patterns: entity work.LED_Patterns
        generic map (SYS_CLKs_sec => to_unsigned(50000000, 26))
        port map (clk,
                  reset,
                  PB,
                  SW,
                  HPS_LED_control,
                  Base_rate,  -- UQ4.4
                  LED_reg,
                  LED);

end architecture;
