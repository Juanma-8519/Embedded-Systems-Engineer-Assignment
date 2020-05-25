library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.integer_to_ascii.all;
use work.fsm_states.all;
 
entity main_tb is
end main_tb;

architecture Behavioral of main_tb is

    ---------------------------------------
    -- Component declaration for the UUT --
    ---------------------------------------
     
    component main is
        port ( 
            clk                                    : in std_logic;
            --rst                                  : in std_logic;
            vauxp6                                 : in std_logic;
            vauxn6                                 : in std_logic;
            
            
            txd_pin                                : out std_logic;     -- UART transmit.
            rxd_pin                                : in std_logic;      -- UART receive.
               
            --rts                                  : out std_logic;     -- Request to Send
            --cts                                  : in std_logic;      -- Clear to Send
               
            UART_tx_led                            : out std_logic;
            ADC_led                                : out std_logic;
            
            UART_enter_rx_led_1                    : out std_logic;
            UART_enter_rx_led_2                    : out std_logic;
            UART_enter_rx_led_3                    : out std_logic;
            
            UART_rx_led_0                          : out std_logic;
            UART_rx_led_1                          : out std_logic;
            UART_rx_led_2                          : out std_logic;
            UART_rx_led_3                          : out std_logic;
            UART_rx_led_4                          : out std_logic;
            UART_rx_led_5                          : out std_logic;
            UART_rx_led_6                          : out std_logic;
            UART_rx_led_7                          : out std_logic
         );
    end component;
    
    ------------
    -- Inputs --
    ------------
    
    signal clk                      : std_logic := '0';
    signal rst                      : std_logic := '1';
    signal vauxp6                   : std_logic := '1';
    signal vauxn6                   : std_logic := '0';
    
    -------------
    -- Outputs --
    -------------
    
    signal txd_pin                  : std_logic;
    signal rxd_pin                  : std_logic;
    signal UART_tx_led              : std_logic;
    signal ADC_led                  : std_logic;
    
    signal UART_enter_rx_led_1      : std_logic;
    signal UART_enter_rx_led_2      : std_logic;
    signal UART_enter_rx_led_3      : std_logic;
    
    signal UART_rx_led_0            : std_logic;
    signal UART_rx_led_1            : std_logic;
    signal UART_rx_led_2            : std_logic;
    signal UART_rx_led_3            : std_logic;
    signal UART_rx_led_4            : std_logic;
    signal UART_rx_led_5            : std_logic;
    signal UART_rx_led_6            : std_logic;
    signal UART_rx_led_7            : std_logic;
    
    
    signal adq_tick                 : std_logic; 
    signal ADC_data_ready           : std_logic;
            
    signal analog_data              : std_logic_vector(15 downto 0);           
    signal analog_ASCII             : char_array (7 downto 0);
           
    signal ASCII_byte_to_transmit   : STD_LOGIC_VECTOR(7 downto 0);
    signal index_byte_to_transmit   : STD_LOGIC_VECTOR(3 downto 0);
           
    signal UART_ready               : std_logic := '0';
    
    signal UART_tx_state            : UART_tx_state_type;     -- create a signal that uses
    
    -----------------------------
    -- Clock period definition --
    -----------------------------

    constant clk_period             : time := 100 ns;
    
begin

    -------------------------
    -- instantiate the UUT --
    -------------------------

    UUT: main port map (
        clk                                 => clk,
        --rst                               => rst,
        vauxp6                              => vauxp6,
        vauxn6                              => vauxn6,
        --vauxp7                            => vauxp7,
        --vauxn7                            => vauxn7,
        --vauxp14                           => vauxp14,
        --vauxn14                           => vauxn14,
        --vauxp15                           => vauxp15,
        --vauxn15                           => vauxn15,
        txd_pin                             => txd_pin,
        rxd_pin                             => rxd_pin,
        UART_tx_led                         => UART_tx_led,
        adc_led                             => adc_led,
        
        UART_enter_rx_led_1                 => UART_enter_rx_led_1, 
        UART_enter_rx_led_2                 => UART_enter_rx_led_2, 
        UART_enter_rx_led_3                 => UART_enter_rx_led_3, 
        
        UART_rx_led_0                       => UART_rx_led_0,
        UART_rx_led_1                       => UART_rx_led_1,          
        UART_rx_led_2                       => UART_rx_led_2,
        UART_rx_led_3                       => UART_rx_led_3,
        UART_rx_led_4                       => UART_rx_led_4,
        UART_rx_led_5                       => UART_rx_led_5,
        UART_rx_led_6                       => UART_rx_led_6,
        UART_rx_led_7                       => UART_rx_led_7        
    );
    
    ------------------------------
    -- clock process definition --
    ------------------------------
    
   
    clk_process: process
    begin
    
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        
    end process;
    
    ----------------------
    -- stimulus process --
    ----------------------
    
    stim_proc: process
    begin
        rst <= '1';
        wait for 10*clk_period;
        rst <= '0';
        wait for clk_period*8;
        vauxp6  <= '0';
        vauxn6  <= '0';
        --vauxp7 <= '0';
        --vauxn7 <= '0';
        --vauxp14  <= '0';
        --vauxn14  <= '0';
        --vauxp15 <= '0';
        --vauxn15 <= '0';
        --wait for clk_period*8;
        wait for 20 ms;
        vauxp6  <= '0';
        vauxn6  <= '1';
        --vauxp7 <= '0';
        --vauxn7 <= '1';
        --vauxp14  <= '0';
        --vauxn14  <= '1';
        --vauxp15 <= '0';
        --vauxn15 <= '1';
        wait for 20 ms;
        vauxp6  <= '1';
        vauxn6  <= '0';
        --vauxp7 <= '1';
        --vauxn7 <= '0';
        --vauxp14  <= '1';
        --vauxn14  <= '0';
        --vauxp15 <= '1';
        --vauxn15 <= '0';
        wait for 20 ms;
        vauxp6  <= '0';
        vauxn6  <= '1';
        --vauxp7 <= '0';
        --vauxn7 <= '1';
        --vauxp14  <= '0';
        --vauxn14  <= '1';
        --vauxp15 <= '0';
        --vauxn15 <= '1';
        wait for 20 ms;
        vauxp6  <= '1';
        vauxn6  <= '0';
        --vauxp7 <= '1';
        --vauxn7 <= '0';
        --vauxp14  <= '1';
        --vauxn14  <= '0';
        --vauxp15 <= '1';
        --vauxn15 <= '0';
        wait for 20 ms;
        vauxp6  <= '0';
        vauxn6  <= '1';
        --vauxp7 <= '0';
        --vauxn7 <= '1';
        --vauxp14  <= '0';
        --vauxn14  <= '1';
        --vauxp15 <= '0';
        --vauxn15 <= '1';
        wait for 20 ms;
        vauxp6  <= '1';
        vauxn6  <= '0';
        --vauxp7 <= '1';
        --vauxn7 <= '0';
        --vauxp14  <= '1';
        --vauxn14  <= '0';
        --vauxp15 <= '1';
        --vauxn15 <= '0';
        wait for 20 ms;
        vauxp6  <= '0';
        vauxn6  <= '1';
        --vauxp7 <= '0';
        --vauxn7 <= '1';
        --vauxp14  <= '0';
        --vauxn14  <= '1';
        --vauxp15 <= '0';
        --vauxn15 <= '1';
        wait for 20 ms;
        vauxp6  <= '1';
        vauxn6  <= '0';
        --vauxp7 <= '1';
        --vauxn7 <= '0';
        --vauxp14  <= '1';
        --vauxn14  <= '0';
        --vauxp15 <= '1';
        --vauxn15 <= '0';
        wait for 20 ms;
        vauxp6  <= '0';
        vauxn6  <= '1';
        --vauxp7 <= '0';
        --vauxn7 <= '1';
        --vauxp14  <= '0';
        --vauxn14  <= '1';
        --vauxp15 <= '0';
        --vauxn15 <= '1';
        wait for 20 ms;
        vauxp6  <= '1';
        vauxn6  <= '0';
        --vauxp7 <= '1';
        --vauxn7 <= '0';
        --vauxp14  <= '1';
        --vauxn14  <= '0';
        --vauxp15 <= '1';
        --vauxn15 <= '0';
        wait for 20 ms;
        vauxp6  <= '0';
        vauxn6  <= '1';
        --vauxp7 <= '0';
        --vauxn7 <= '1';
        --vauxp14  <= '0';
        --vauxn14  <= '1';
        --vauxp15 <= '0';
        --vauxn15 <= '1';
        wait for 20 ms;
        vauxp6  <= '1';
        vauxn6  <= '0';
        --vauxp7 <= '1';
        --vauxn7 <= '0';
        --vauxp14  <= '1';
        --vauxn14  <= '0';
        --vauxp15 <= '1';
        --vauxn15 <= '0';

        wait;
    end process;

end Behavioral;




