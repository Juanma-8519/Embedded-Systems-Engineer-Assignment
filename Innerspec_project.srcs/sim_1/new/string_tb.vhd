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
 
entity string_tb is
end string_tb;

architecture Behavioral of string_tb is

    ---------------------------------------
    -- Component declaration for the UUT --
    ---------------------------------------
     
    component main_strings_functions is
        port ( 
               clk                          : in std_logic;
               input_ascii_to_std           : in char_array (31 downto 0);
               output_ascii_to_std          : out std_logic_vector (15 downto 0);
    
               input_integer_to_ascii       : in integer range -9999 to 9999;
               output_integer_to_ascii      : out char_array (4 downto 0);

               input_12bits_signed          : in std_logic_vector (11 downto 0);
               output_signed                : out char_array (31 downto 0);
               
               UART_received_data           : in std_logic_vector (7 downto 0);
	           UART_valid_char              : out std_logic;
	           NL                           : out std_logic_vector (7 downto 0);
	           UART_received_string	        : out char_array (31 downto 0)
             );
                
    end component;
    
    ------------
    -- Inputs --
    ------------
    
    signal input_ascii_to_std               : char_array (31 downto 0) := ((others=> (others=>'0')));
    signal clk                              : std_logic := '0';
    signal UART_received_data               : std_logic_vector (7 downto 0) := (others => '0');
    signal input_integer_to_ascii           : integer range -9999 to 9999 := 0;
    signal input_12bits_signed              : std_logic_vector (11 downto 0) := (others => '0');

    
    -------------
    -- Outputs --
    -------------
    
    signal output_ascii_to_std       : std_logic_vector (15 downto 0) := (others => '0');
    signal NL                        : std_logic_vector (7 downto 0) := (others => '0');
    signal UART_valid_char           : std_logic := '0';
    signal UART_received_string      : char_array (31 downto 0) := ((others=> (others=>'0')));
    signal output_integer_to_ascii   : char_array (4 downto 0) := ((others=> (others=>'0')));
    signal output_signed             : char_array (31 downto 0) := ((others=> (others=>'0')));
    
    -----------------------------
    -- Clock period definition --
    -----------------------------

    constant clk_period             : time := 100 ns;
    
begin

    -------------------------
    -- instantiate the UUT --
    -------------------------

    UUT: main_strings_functions port map (
        clk                                 => clk,
        input_ascii_to_std                  => input_ascii_to_std,
        output_ascii_to_std                 => output_ascii_to_std,
        input_integer_to_ascii              => input_integer_to_ascii,
        output_integer_to_ascii             => output_integer_to_ascii,
        input_12bits_signed                 => input_12bits_signed,
        output_signed                       => output_signed,
        UART_received_data                  => UART_received_data,
        UART_valid_char                     => UART_valid_char,
        NL                                  => NL,
        UART_received_string                => UART_received_string       
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
         -- -5
        input_ascii_to_std(0)<= "00101101"; 
        input_ascii_to_std(1)<= "00110101";
        input_ascii_to_std(2)<= "00001101";
        input_ascii_to_std(3)<= "00001010";  
        
        
        input_integer_to_ascii <= 1234;   
        wait for 10 ns;
        -- -55
        input_ascii_to_std (0)<= "00101101"; 
        input_ascii_to_std (1)<= "00110101";
        input_ascii_to_std (2)<= "00110101";
        input_ascii_to_std (3)<= "00001101";
        input_ascii_to_std (4)<= "00001010";   
        
        input_integer_to_ascii <= 234;  
        wait for 10 ns;
        --5
        input_ascii_to_std (0)<= "00110101";
        input_ascii_to_std (1)<= "00001101";
        input_ascii_to_std (2)<= "00001010";
        
        input_integer_to_ascii <= 34;     
        wait for 10 ns;
        --54
        input_ascii_to_std(0)<= "00110101";
        input_ascii_to_std(1)<= "00110100";
        input_ascii_to_std(2)<= "00001101";
        input_ascii_to_std(3)<= "00001010";
        
        input_integer_to_ascii <= 4;     
        wait for 10 ns;
        --575
        input_ascii_to_std(0)<= "00110101";
        input_ascii_to_std(1)<= "00110111";
        input_ascii_to_std(2)<= "00110101";
        input_ascii_to_std(3)<= "00001101";
        input_ascii_to_std(4)<= "00001010"; 
        input_integer_to_ascii <= -4;     
        wait for 10 ns;
        --10000
        input_ascii_to_std(0)<= "00110001";
        input_ascii_to_std(1)<= "00110000";
        input_ascii_to_std(2)<= "00110000";
        input_ascii_to_std(3)<= "00110000";
        input_ascii_to_std(4)<= "00110000";
        input_ascii_to_std(5)<= "00001101";
        input_ascii_to_std(6)<= "00001010"; 
        input_integer_to_ascii <= -34;    
        wait for 10 ns;
        --20000
        input_ascii_to_std(0)<= "00110010";
        input_ascii_to_std(1)<= "00110000";
        input_ascii_to_std(2)<= "00110000";
        input_ascii_to_std(3)<= "00110000";
        input_ascii_to_std(4)<= "00110000";
        input_ascii_to_std(5)<= "00001101";
        input_ascii_to_std(6)<= "00001010";
        input_integer_to_ascii <= -234;     
        wait for 10 ns;
        --4
        input_ascii_to_std(0)<= "00110100";
        input_ascii_to_std(1)<= "00001101";
        input_ascii_to_std(2)<= "00001010"; 
        input_integer_to_ascii <= -1234;    
        wait for 10 ns;
        --error
        input_ascii_to_std(0)<= "01000001";
        input_ascii_to_std(1)<= "00001101";
        input_ascii_to_std(2)<= "00001010";     
        wait for 10 ns;
        
        
        
        
        wait;
    end process;

end Behavioral;