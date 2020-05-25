----------------------------------------------------------------------------
--	acumulator.vhd -- Averaging buffer until 128 12bits ADC samples Component
----------------------------------------------------------------------------
-- Author:  Juanma Manchado
--          Copyright 2020 Innerspec, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This component may be used to smooth noisy signals that come from an ADC.
-- The component has the following characteristics:
--         *until 128 samples to store
--         *input widht, 12 bits 
--         				
-- Port Descriptions:
--
--    clk                - Master clock, could be 100MHz
--    ADC_ready          - flag signal to capture the analog data
--    size_changed       - flag signal to capture the new size of the
--                         buffer (async) 
--    analog_data        - digital value coming from the ADC, (12 bits)
--    av_size_buffer_pos - value of the new size of the buffer for new
--                       - averaging
--    av_index           - output to see the current index of the buffer
--                         that is being written
--    av_sample          - output (12 bits) of the average
--    av_data_ready      - output flag to indicate the average capturing
--   
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


library work;
use work.integer_to_ascii.all;
use work.fsm_states.all;
        

entity acumulator is
    
    port (
         -- on board clock 
         clk                                    : in std_logic;
         ADC_ready				                : in std_logic;
         size_changed			                : in std_logic;
         analog_data                            : in std_logic_vector (11 downto 0);
         av_size_buffer_pos  		            : in std_logic_vector(15 downto 0) ;
         av_index         			            : out std_logic_vector(7 downto 0) := (others => '0');
         av_sample                              : out std_logic_vector(15 downto 0) := (others => '0');
         av_data_ready                          : out std_logic := '0'	
         );
         
end acumulator;

architecture Behavioral of acumulator is
    


    
    ---------------
    -- averaging --
    ---------------
    
    signal averaging_state                 : averaging_state_type := A;                        -- FSM averaging
    
    signal av_buffer                       : fir_array (127 downto 0) := ((others => (others=>'0')));
    signal av_sample_index                 : std_logic_vector(7 downto 0) := (others => '0');
    signal av_size_reg                     : std_logic_vector (15 downto 0) := std_logic_vector(to_signed(1,16)); 
    
    
begin

    -------------------------------
    -- averaging samples fos ADC --
    -------------------------------
    
    av_index <= av_sample_index;
    
    average: process (clk, ADC_ready, size_changed)
    variable sample 	: integer := 0; --change the value to mV
    variable acumulator : integer := 0;
    variable average    : integer := 0;
    --variable index      : integer := 0;
    --variable size       : integer := 0;
    begin
        if size_changed = '1' then
            av_size_reg <= av_size_buffer_pos;
            av_buffer <= ((others => (others=>'0')));
            av_sample_index <= (others =>'0'); 
        elsif rising_edge(clk) then
            case averaging_state is
                when A => 
                    if ADC_ready = '1' then
                        sample := to_integer(unsigned(analog_data(11 downto 0)))*1000/4095;
                        --index  := to_integer(unsigned(av_sample_index));
                        --store sample
                        av_buffer(to_integer(unsigned(av_sample_index))) <= std_logic_vector(to_unsigned(sample,16));
                        
                        --size := to_integer(unsigned(av_samples_pos))-1;
                        --if (index < size-1) then
                        if (to_integer(unsigned(av_sample_index)) < to_integer(unsigned(av_size_reg))-1) then
                            av_sample_index <= std_logic_vector(unsigned(av_sample_index)+1);
                        else
                            av_sample_index <= (others =>'0');
                        end if;                            
                        averaging_state <= B;
                        av_data_ready <= '0';
                    end if;
                when B =>
                    -- All the samples must be 0 except the one we are using in the buffer
                    acumulator:=0;
                    for i in 0 to 127 loop
                        acumulator := acumulator + to_integer(unsigned(av_buffer(i)));
                    end loop; 
                    average := acumulator/(to_integer(unsigned(av_size_reg)));
                    av_sample <= std_logic_vector(to_unsigned(average,16));
                    av_data_ready <= '1';
                    averaging_state <= C;
                when C =>
                    av_data_ready <= '0';
                    averaging_state <= A;
                when others =>
                
                end case;
        
        end if;
        
    end process;


end behavioral;