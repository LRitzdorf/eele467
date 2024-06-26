--! @file
--!
--! @author Ross Snider
--!


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library altera;
use altera.altera_primitives_components.all;


-----------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
-----------------------------------------------------------
entity DE10Nano_System is
    port (
        ----------------------------------------
        --  CLOCK Inputs
        --  See DE10 Nano User Manual page 23
        ----------------------------------------
        FPGA_CLK1_50 : in    std_logic; --! 50 MHz clock input #1
        FPGA_CLK2_50 : in    std_logic; --! 50 MHz clock input #2
        FPGA_CLK3_50 : in    std_logic; --! 50 MHz clock input #3

        ----------------------------------------
        --  Push Button Inputs (KEY)
        --  See DE10 Nano User Manual page 24
        --  The KEY push button inputs produce a '0'
        --  when pressed (asserted)
        --  and produce a '1' in the rest (non-pushed) state
        --  a better label for KEY would be Push_Button_n
        ----------------------------------------
        KEY : in    std_logic_vector(1 downto 0); --! Two Pushbuttons (active low)

        ----------------------------------------
        --  Slide Switch Inputs (SW)
        --  See DE10 Nano User Manual page 25
        --  The slide switches produce a '0' when
        --  in the down position
        --  (towards the edge of the board)
        ----------------------------------------
        SW : in    std_logic_vector(3 downto 0); --! Four Slide Switches

        ----------------------------------------
        --  LED Outputs
        --  See DE10 Nano User Manual page 26
        --  Setting LED to 1 will turn it on
        ----------------------------------------
        LED : out   std_logic_vector(7 downto 0); --! Eight LEDs

        ----------------------------------------
        --  GPIO Expansion Headers (40-pin)
        --  See DE10 Nano User Manual page 27
        --  Pin 11 = 5V supply (1A max)
        --  Pin 29 - 3.3 supply (1.5A max)
        --  Pins 12, 30 GND
        --  Note: the DE10-Nano GPIO_0 & GPIO_1 signals
        --  have been replaced by
        --  Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1
        --  since some of the DE10-Nano GPIO pins
        --  have been dedicated to the Audio Mini
        --  plug-in card.  The new signals
        --  Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1
        --  contain the available GPIO.
        ----------------------------------------
        -- GPIO_0 : inout std_logic_vector(35 downto 0);            --! The 40 pin header on the top of the board
        -- GPIO_1 : inout std_logic_vector(35 downto 0);            --! The 40 pin header on the bottom of the board
        Audio_Mini_GPIO_0 : inout std_logic_vector(33 downto 0); --! 34 available I/O pins on GPIO_0
        Audio_Mini_GPIO_1 : inout std_logic_vector(12 downto 0); --! 13 available I/O pins on GPIO_1

        ----------------------------------------
        --  AD1939 Audio Codec
        --  Physical Connection signals
        ----------------------------------------
        -- AD1939 clock and Reset
        AD1939_MCLK         : in    std_logic; --! 12.288 MHz clock driving AD1939
        AD1939_RST_CODEC_n  : out   std_logic;
        -- AD1939 SPI
        AD1939_spi_CIN      : out   std_logic; --! AD1939 SPI signal = mosi data to AD1939 registers
        AD1939_spi_CLATCH_n : out   std_logic; --! AD1939 SPI signal = ss_n: slave select (active low)
        AD1939_spi_CCLK     : out   std_logic; --! AD1939 SPI signal = sclk: serial clock
        AD1939_spi_COUT     : in    std_logic; --! AD1939 SPI signal = miso data from AD1939 registers
        -- AD1939 ADC Serial Data
        AD1939_ADC_ABCLK    : in    std_logic; --! Serial data from AD1939 pin 28 ABCLK,   Bit Clock for ADCs (Master Mode)
        AD1939_ADC_ALRCLK   : in    std_logic; --! Serial data from AD1939 pin 29 ALRCLK,  LR Clock for ADCs  (Master Mode)
        AD1939_ADC_ASDATA2  : in    std_logic; --! Serial data from AD1939 pin 26 ASDATA2, ADC2 24-bit normal stereo serial mode
        -- AD1939 DAC Serial Data
        AD1939_DAC_DBCLK    : out   std_logic; --! Serial data to   AD1939 pin 21 DBCLK,   Bit Clock for DACs (Slave Mode)
        AD1939_DAC_DLRCLK   : out   std_logic; --! Serial data to   AD1939 pin 22 DLRCLK,  LR Clock for DACs  (Slave Mode)
        AD1939_DAC_DSDATA1  : out   std_logic; --! Serial data to   AD1939 pin 20 DSDATA1, DAC1 24-bit normal stereo serial mode

        ----------------------------------------
        --  Headphone Amplifier TI TPA6130
        --  Physical connection signals
        ----------------------------------------
        TPA6130_i2c_SDA   : inout std_logic;
        TPA6130_i2c_SCL   : inout std_logic;
        TPA6130_power_off : out   std_logic;

        ----------------------------------------
        --  Digital Microphone INMP621
        --  Physical connection signals
        ----------------------------------------
        INMP621_mic_CLK  : out   std_logic;
        INMP621_mic_DATA : in    std_logic;

        ----------------------------------------
        --  Audio Mini LEDs and Switches
        ----------------------------------------
        Audio_Mini_LEDs     : out   std_logic_vector(3 downto 0);
        Audio_Mini_SWITCHES : in    std_logic_vector(3 downto 0);

        ----------------------------------------
        --  Arduino Uno R3 Expansion Header
        --  See DE10 Nano User Manual page 30
        --  500 ksps, 8-channel, 12-bit ADC
        ----------------------------------------
        ARDUINO_IO      : inout std_logic_vector(15 downto 0); --! 16 Arduino I/O
        ARDUINO_RESET_N : inout std_logic;                     --! Reset signal, active low

        ----------------------------------------
        --  ADC
        --  See DE10 Nano User Manual page 33
        --  500 ksps, 8-channel, 12-bit ADC
        ----------------------------------------
        ADC_CONVST : out   std_logic; --! ADC Conversion Start
        ADC_SCK    : out   std_logic; --! ADC Serial Data Clock
        ADC_SDI    : out   std_logic; --! ADC Serial Data Input  (FPGA to ADC)
        ADC_SDO    : in    std_logic; --! ADC Serial Data Output (ADC to FPGA)

        ----------------------------------------
        --  Hard Processor System (HPS)
        --  See DE10 Nano User Manual page 36
        ----------------------------------------
        HPS_CONV_USB_N   : inout std_logic;
        HPS_DDR3_ADDR    : out   std_logic_vector(14 downto 0);
        HPS_DDR3_BA      : out   std_logic_vector(2 downto 0);
        HPS_DDR3_CAS_N   : out   std_logic;
        HPS_DDR3_CKE     : out   std_logic;
        HPS_DDR3_CK_N    : out   std_logic;
        HPS_DDR3_CK_P    : out   std_logic;
        HPS_DDR3_CS_N    : out   std_logic;
        HPS_DDR3_DM      : out   std_logic_vector(3 downto 0);
        HPS_DDR3_DQ      : inout std_logic_vector(31 downto 0);
        HPS_DDR3_DQS_N   : inout std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_P   : inout std_logic_vector(3 downto 0);
        HPS_DDR3_ODT     : out   std_logic;
        HPS_DDR3_RAS_N   : out   std_logic;
        HPS_DDR3_RESET_N : out   std_logic;
        HPS_DDR3_RZQ     : in    std_logic;
        HPS_DDR3_WE_N    : out   std_logic;
        HPS_ENET_GTX_CLK : out   std_logic;
        HPS_ENET_INT_N   : inout std_logic;
        HPS_ENET_MDC     : out   std_logic;
        HPS_ENET_MDIO    : inout std_logic;
        HPS_ENET_RX_CLK  : in    std_logic;
        HPS_ENET_RX_DATA : in    std_logic_vector(3 downto 0);
        HPS_ENET_RX_DV   : in    std_logic;
        HPS_ENET_TX_DATA : out   std_logic_vector(3 downto 0);
        HPS_ENET_TX_EN   : out   std_logic;
        HPS_GSENSOR_INT  : inout std_logic;
        HPS_I2C0_SCLK    : inout std_logic;
        HPS_I2C0_SDAT    : inout std_logic;
        HPS_I2C1_SCLK    : inout std_logic;
        HPS_I2C1_SDAT    : inout std_logic;
        HPS_KEY          : inout std_logic;
        HPS_LED          : inout std_logic;
        HPS_LTC_GPIO     : inout std_logic;
        HPS_SD_CLK       : out   std_logic;
        HPS_SD_CMD       : inout std_logic;
        HPS_SD_DATA      : inout std_logic_vector(3 downto 0);
        HPS_SPIM_CLK     : out   std_logic;
        HPS_SPIM_MISO    : in    std_logic;
        HPS_SPIM_MOSI    : out   std_logic;
        HPS_SPIM_SS      : inout std_logic;
        HPS_UART_RX      : in    std_logic;
        HPS_UART_TX      : out   std_logic;
        HPS_USB_DATA     : inout std_logic_vector(7 downto 0);
        HPS_USB_CLKOUT   : in    std_logic;
        HPS_USB_STP      : out   std_logic;
        HPS_USB_DIR      : in    std_logic;
        HPs_USB_NXT      : in    std_logic
    );

end entity;


architecture DE10Nano_arch of DE10Nano_System is

    --------------------------------------------------------------
    -- SoC Component from Intel Platform Designer
    --------------------------------------------------------------
    component soc_system is
        port (
            clk_clk                             : in    std_logic;
            hps_f2h_cold_reset_req_reset_n      : in    std_logic;
            hps_f2h_debug_reset_req_reset_n     : in    std_logic;
            hps_f2h_warm_reset_req_reset_n      : in    std_logic;
            hps_h2f_reset_reset_n               : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_RXD0   : in    std_logic;
            hps_hps_io_hps_io_emac1_inst_MDIO   : inout std_logic;
            hps_hps_io_hps_io_emac1_inst_MDC    : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic;
            hps_hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;
            hps_hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic;
            hps_hps_io_hps_io_emac1_inst_RXD1   : in    std_logic;
            hps_hps_io_hps_io_emac1_inst_RXD2   : in    std_logic;
            hps_hps_io_hps_io_emac1_inst_RXD3   : in    std_logic;
            hps_hps_io_hps_io_sdio_inst_CMD     : inout std_logic;
            hps_hps_io_hps_io_sdio_inst_D0      : inout std_logic;
            hps_hps_io_hps_io_sdio_inst_D1      : inout std_logic;
            hps_hps_io_hps_io_sdio_inst_CLK     : out   std_logic;
            hps_hps_io_hps_io_sdio_inst_D2      : inout std_logic;
            hps_hps_io_hps_io_sdio_inst_D3      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D0      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D1      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D2      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D3      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D4      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D5      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D6      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_D7      : inout std_logic;
            hps_hps_io_hps_io_usb1_inst_CLK     : in    std_logic;
            hps_hps_io_hps_io_usb1_inst_STP     : out   std_logic;
            hps_hps_io_hps_io_usb1_inst_DIR     : in    std_logic;
            hps_hps_io_hps_io_usb1_inst_NXT     : in    std_logic;
            hps_hps_io_hps_io_spim1_inst_CLK    : out   std_logic;
            hps_hps_io_hps_io_spim1_inst_MOSI   : out   std_logic;
            hps_hps_io_hps_io_spim1_inst_MISO   : in    std_logic;
            hps_hps_io_hps_io_spim1_inst_SS0    : out   std_logic;
            hps_hps_io_hps_io_uart0_inst_RX     : in    std_logic;
            hps_hps_io_hps_io_uart0_inst_TX     : out   std_logic;
            hps_hps_io_hps_io_i2c1_inst_SDA     : inout std_logic;
            hps_hps_io_hps_io_i2c1_inst_SCL     : inout std_logic;
            hps_hps_io_hps_io_gpio_inst_GPIO09  : inout std_logic;
            hps_hps_io_hps_io_gpio_inst_GPIO35  : inout std_logic;
            hps_hps_io_hps_io_gpio_inst_GPIO40  : inout std_logic;
            hps_hps_io_hps_io_gpio_inst_GPIO53  : inout std_logic;
            hps_hps_io_hps_io_gpio_inst_GPIO54  : inout std_logic;
            hps_hps_io_hps_io_gpio_inst_GPIO61  : inout std_logic;
            hps_i2c0_out_data                   : out   std_logic;
            hps_i2c0_sda                        : in    std_logic;
            hps_i2c0_clk_clk                    : out   std_logic;
            hps_i2c0_scl_in_clk                 : in    std_logic;
            hps_spim0_txd                       : out   std_logic;
            hps_spim0_rxd                       : in    std_logic;
            hps_spim0_ss_in_n                   : in    std_logic;
            hps_spim0_ssi_oe_n                  : out   std_logic;
            hps_spim0_ss_0_n                    : out   std_logic;
            hps_spim0_ss_1_n                    : out   std_logic;
            hps_spim0_ss_2_n                    : out   std_logic;
            hps_spim0_ss_3_n                    : out   std_logic;
            hps_spim0_sclk_out_clk              : out   std_logic;
            memory_mem_a                        : out   std_logic_vector(14 downto 0);
            memory_mem_ba                       : out   std_logic_vector(2 downto 0);
            memory_mem_ck                       : out   std_logic;
            memory_mem_ck_n                     : out   std_logic;
            memory_mem_cke                      : out   std_logic;
            memory_mem_cs_n                     : out   std_logic;
            memory_mem_ras_n                    : out   std_logic;
            memory_mem_cas_n                    : out   std_logic;
            memory_mem_we_n                     : out   std_logic;
            memory_mem_reset_n                  : out   std_logic;
            memory_mem_dq                       : inout std_logic_vector(31 downto 0);
            memory_mem_dqs                      : inout std_logic_vector(3 downto 0);
            memory_mem_dqs_n                    : inout std_logic_vector(3 downto 0);
            memory_mem_odt                      : out   std_logic;
            memory_mem_dm                       : out   std_logic_vector(3 downto 0);
            memory_oct_rzqin                    : in    std_logic;
            reset_reset_n                       : in    std_logic;
            led_patterns_pushbutton             : in    std_logic;
            led_patterns_switches               : in    std_logic_vector(3 downto 0);
            led_patterns_leds                   : out   std_logic_vector(7 downto 0)
        );
    end component soc_system;

    ------------------------------------------------------------
    -- Tristate buffer with pullup for i2c lines
    ------------------------------------------------------------
    component alt_iobuf is
        generic (
            io_standard           : string  := "3.3-V LVTTL";
            current_strength      : string  := "maximum current";
            slew_rate             : integer := -1;
            slow_slew_rate        : string  := "NONE";
            location              : string  := "NONE";
            enable_bus_hold       : string  := "NONE";
            weak_pull_up_resistor : string  := "ON";
            termination           : string  := "NONE";
            input_termination     : string  := "NONE";
            output_termination    : string  := "NONE"
        );
        port (
            i  : in    std_logic;
            oe : in    std_logic;
            io : inout std_logic;
            o  : out   std_logic
        );
    end component;

    ---------------------------------------------------------
    -- Signal declarations
    ---------------------------------------------------------
    signal hps_fpga_reset_n : std_logic;
    signal hps_reset_req    : std_logic_vector(2 downto 0);

    signal hps_cold_reset  : std_logic;
    signal hps_warm_reset  : std_logic;
    signal hps_debug_reset : std_logic;
    signal hps_h2f_reset   : std_logic;

    signal i2c_0_i2c_serial_sda_in : std_logic;
    signal i2c_serial_scl_in       : std_logic;
    signal i2c_serial_sda_oe       : std_logic;
    signal serial_scl_oe           : std_logic;

    signal system_rst  : std_logic;                    --! Global reset pin
    signal Push_Button : std_logic_vector(1 downto 0); --! a better description of KEY input, which should really be labelled as KEY_n

    signal reset : std_logic;

    signal next_led_pattern : std_logic;

begin

    ---------------------------------------------------------------------------------------------
    -- Signal renaming to make code more readable
    ---------------------------------------------------------------------------------------------
    Push_Button    <= not KEY; -- Rename signal to push button, which is a better description of KEY input (which really should be labelled as KEY_n since it is active low).
    reset          <= Push_Button(1);
    hps_cold_reset <= reset;

    -------------------------------------------------------
    -- Control Audio Mini LEDs using switches
    -------------------------------------------------------
    Audio_Mini_LEDs <= Audio_Mini_switches;

    -------------------------------------------------------
    -- AD1939
    -------------------------------------------------------
    AD1939_RST_CODEC_n <= '1'; -- hold AD1939 out of reset

    -------------------------------------------------------
    -- TPA6130
    -------------------------------------------------------
    TPA6130_power_off <= '1'; --! Enable the headphone amplifier output

    -------------------------------------------------------
    -- HPS
    -------------------------------------------------------
    hps_debug_reset <= '0';
    hps_warm_reset  <= '0';

    ---------------------------------------------------------------------------------------------
    -- SoC System
    ---------------------------------------------------------------------------------------------
    u0 : component soc_system
        port map (
            -- HPS SPI connection to AD1939
            hps_spim0_txd          => AD1939_spi_CIN,
            hps_spim0_rxd          => AD1939_spi_COUT,
            hps_spim0_ss_in_n      => '1',
            hps_spim0_ssi_oe_n     => open,
            hps_spim0_ss_0_n       => AD1939_spi_CLATCH_n,
            hps_spim0_ss_1_n       => open,
            hps_spim0_ss_2_n       => open,
            hps_spim0_ss_3_n       => open,
            hps_spim0_sclk_out_clk => AD1939_spi_CCLK,

            -- HPS I2C #1 connection to TPA6130
            hps_i2c0_out_data   => i2c_serial_sda_oe,
            hps_i2c0_sda        => i2c_0_i2c_serial_sda_in,
            hps_i2c0_clk_clk    => serial_scl_oe,
            hps_i2c0_scl_in_clk => i2c_serial_scl_in,

            -- HPS Clock and Reset
            clk_clk                         => FPGA_CLK1_50,
            reset_reset_n                   => not hps_cold_reset,
            hps_f2h_cold_reset_req_reset_n  => not hps_cold_reset,
            hps_f2h_debug_reset_req_reset_n => not hps_debug_reset,
            hps_f2h_warm_reset_req_reset_n  => not hps_warm_reset,
            hps_h2f_reset_reset_n           => hps_h2f_reset,

            -- HPS Ethernet
            hps_hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK,
            hps_hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),
            hps_hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),
            hps_hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2),
            hps_hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),
            hps_hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),
            hps_hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,
            hps_hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,
            hps_hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,
            hps_hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,
            hps_hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK,
            hps_hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),
            hps_hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),
            hps_hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),

            -- HPS USB OTG
            hps_hps_io_hps_io_usb1_inst_D0  => HPS_USB_DATA(0),
            hps_hps_io_hps_io_usb1_inst_D1  => HPS_USB_DATA(1),
            hps_hps_io_hps_io_usb1_inst_D2  => HPS_USB_DATA(2),
            hps_hps_io_hps_io_usb1_inst_D3  => HPS_USB_DATA(3),
            hps_hps_io_hps_io_usb1_inst_D4  => HPS_USB_DATA(4),
            hps_hps_io_hps_io_usb1_inst_D5  => HPS_USB_DATA(5),
            hps_hps_io_hps_io_usb1_inst_D6  => HPS_USB_DATA(6),
            hps_hps_io_hps_io_usb1_inst_D7  => HPS_USB_DATA(7),
            hps_hps_io_hps_io_usb1_inst_CLK => HPS_USB_CLKOUT,
            hps_hps_io_hps_io_usb1_inst_STP => HPS_USB_STP,
            hps_hps_io_hps_io_usb1_inst_DIR => HPS_USB_DIR,
            hps_hps_io_hps_io_usb1_inst_NXT => HPs_USB_NXT,

            -- HPS SD Card
            hps_hps_io_hps_io_sdio_inst_CMD => HPS_SD_CMD,
            hps_hps_io_hps_io_sdio_inst_D0  => HPS_SD_DATA(0),
            hps_hps_io_hps_io_sdio_inst_D1  => HPS_SD_DATA(1),
            hps_hps_io_hps_io_sdio_inst_CLK => HPS_SD_CLK,
            hps_hps_io_hps_io_sdio_inst_D2  => HPS_SD_DATA(2),
            hps_hps_io_hps_io_sdio_inst_D3  => HPS_SD_DATA(3),

            -- HPS SPI
            hps_hps_io_hps_io_spim1_inst_CLK  => HPS_SPIM_CLK,
            hps_hps_io_hps_io_spim1_inst_MOSI => HPS_SPIM_MOSI,
            hps_hps_io_hps_io_spim1_inst_MISO => HPS_SPIM_MISO,
            hps_hps_io_hps_io_spim1_inst_SS0  => HPS_SPIM_SS,

            -- HPS UART
            hps_hps_io_hps_io_uart0_inst_RX => HPS_UART_RX,
            hps_hps_io_hps_io_uart0_inst_TX => HPS_UART_TX,

            -- HPS I2C #2
            hps_hps_io_hps_io_i2c1_inst_SDA => HPS_I2C1_SDAT,
            hps_hps_io_hps_io_i2c1_inst_SCL => HPS_I2C1_SCLK,

            -- HPS GPIO
            hps_hps_io_hps_io_gpio_inst_GPIO09 => HPS_CONV_USB_N,
            hps_hps_io_hps_io_gpio_inst_GPIO35 => HPS_ENET_INT_N,
            hps_hps_io_hps_io_gpio_inst_GPIO40 => HPS_LTC_GPIO,
            hps_hps_io_hps_io_gpio_inst_GPIO53 => HPS_LED,
            hps_hps_io_hps_io_gpio_inst_GPIO54 => HPS_KEY,
            hps_hps_io_hps_io_gpio_inst_GPIO61 => HPS_GSENSOR_INT,

            -- HPS DDR3 DRAM
            memory_mem_a       => HPS_DDR3_ADDR,
            memory_mem_ba      => HPS_DDR3_BA,
            memory_mem_ck      => HPS_DDR3_CK_P,
            memory_mem_ck_n    => HPS_DDR3_CK_N,
            memory_mem_cke     => HPS_DDR3_CKE,
            memory_mem_cs_n    => HPS_DDR3_CS_N,
            memory_mem_ras_n   => HPS_DDR3_RAS_N,
            memory_mem_cas_n   => HPS_DDR3_CAS_N,
            memory_mem_we_n    => HPS_DDR3_WE_N,
            memory_mem_reset_n => HPS_DDR3_RESET_N,
            memory_mem_dq      => HPS_DDR3_DQ,
            memory_mem_dqs     => HPS_DDR3_DQS_P,
            memory_mem_dqs_n   => HPS_DDR3_DQS_N,
            memory_mem_odt     => HPS_DDR3_ODT,
            memory_mem_dm      => HPS_DDR3_DM,
            memory_oct_rzqin   => HPS_DDR3_RZQ,

            -- LED Patterns module
            led_patterns_pushbutton => next_led_pattern,
            led_patterns_switches   => SW,
            led_patterns_leds       => LED
        );

    -- Instantiate push-button signal conditioner
    conditioner : entity work.Conditioner
        generic map (
            WIDTH => 1
        )
        port map (
            clk       => FPGA_CLK1_50,
            reset     => not hps_cold_reset,
            input(0)  => Push_Button(0),
            output(0) => next_led_pattern
        );


    ---------------------------------------------------------------------------------------------
    -- Tri-state buffer the I2C signals
    ---------------------------------------------------------------------------------------------
    ubuf1 : component alt_iobuf
        port map (
            i  => '0',
            oe => i2c_serial_sda_oe,
            io => TPA6130_i2c_SDA,
            o  => i2c_0_i2c_serial_sda_in
        );

    ubuf2 : component alt_iobuf
        port map (
            i  => '0',
            oe => serial_scl_oe,
            io => TPA6130_i2c_SCL,
            o  => i2c_serial_scl_in
        );


    -------------------------------------------------------
    -- DE10-Nano Board (unused output signals)
    -------------------------------------------------------
    Audio_Mini_GPIO_0 <= (others => 'Z');
    Audio_Mini_GPIO_1 <= (others => 'Z');
    ARDUINO_IO        <= (others => 'Z');
    ARDUINO_RESET_N   <= 'Z';
    ADC_CONVST        <= '0';
    ADC_SCK           <= '0';
    ADC_SDI           <= '0';

end architecture;
