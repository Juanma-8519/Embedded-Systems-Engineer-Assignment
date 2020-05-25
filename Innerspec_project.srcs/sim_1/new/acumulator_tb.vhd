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
 
entity acumulator_tb is
end acumulator_tb;

architecture Behavioral of acumulator_tb is

    ---------------------------------------
    -- Component declaration for the UUT --
    ---------------------------------------
     
    component acumulator is
        port (
         	-- on board clock 
	        clk                                    : in std_logic;
	
		    ADC_ready				               : in std_logic;
		    size_changed                           : in std_logic;
		    analog_data				               : in std_logic_vector(11 downto 0) ;
	        av_size_buffer_pos 			           : in std_logic_vector(15 downto 0) ;

            av_index         			           : out std_logic_vector(7 downto 0) := (others => '0');
		    av_sample                              : out std_logic_vector(15 downto 0) := (others => '0');
	        av_data_ready                          : out std_logic := '0'	
	   );
                
    end component;
    
    ------------
    -- Inputs --
    ------------
    
    signal clk                              : std_logic := '0';
    signal ADC_ready                        : std_logic := '0';
    signal size_changed                     : std_logic := '0';
    signal analog_data			            : std_logic_vector(11 downto 0) := (others => '0');
    signal av_size_buffer_pos	            : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(1,16));
    
    -------------
    -- Outputs --
    -------------
    
    signal av_index         			: std_logic_vector(7 downto 0) := (others => '0');
    signal av_sample			        : std_logic_vector (15 downto 0) := (others => '0');
    signal av_data_ready	            : std_logic := '0';
    
    -----------------------------
    -- Clock period definition --
    -----------------------------

    constant clk_period             : time := 100 ns;
    constant ADC_period             : time := 10 us;
    
begin

    -------------------------
    -- instantiate the UUT --
    -------------------------

    UUT: acumulator port map (
        clk                                 => clk,
        ADC_ready                           => ADC_ready,
        size_changed                        => size_changed,
	    analog_data			                => analog_data,
	    av_size_buffer_pos			        => av_size_buffer_pos,
	    av_index                            => av_index,
	    av_sample			                => av_sample,
	    av_data_ready			            => av_data_ready
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

    ADC_process: process
    begin
    
        ADC_ready <= '0';
        wait for ADC_period-clk_period;
        ADC_ready <= '1';
        wait for clk_period;
        
    end process;
    
    ----------------------
    -- stimulus process --
    ----------------------
    
    stim_proc: process
    begin
        analog_data <="101100110010";           --700 mV 
        wait for 100 us;
        av_size_buffer_pos <="0000000000010000";	--16
        size_changed <= '1';
        wait for clk_period;
        size_changed <= '0';
        wait for clk_period;
        wait for 200 us;
        av_size_buffer_pos <="0000000000000001";	--16
        size_changed <= '1';
        wait for clk_period;
        size_changed <= '0';
        wait for 100 us;
        av_size_buffer_pos <="0000000000000100";	--16
        size_changed <= '1';
        wait for clk_period;
        size_changed <= '0';
        wait for 100 us;
        
        
        
        wait;
    end process;

end Behavioral;