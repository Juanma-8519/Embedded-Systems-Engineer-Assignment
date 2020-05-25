----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Juan Manuel Manchado
-- 
-- Create Date: 21/05/2020 11:55:13 AM
-- Design Name: 
-- Module Name: main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


library work;
use work.integer_to_ascii.all;
use work.fsm_states.all;
        

entity main is
    
    generic (
         --ADC_frec                               : integer := 2; 
         clk_freq                               : integer := 100000000
         );
    
    port (
         -- on board clock 
         clk                                    : in std_logic;
           
         -- analog input channel_6
         vauxp6                                 : in std_logic;
         vauxn6                                 : in std_logic;

         -- UART
         txd_pin                                : out std_logic;            -- UART transmit.
         rxd_pin                                : in std_logic;             -- UART receive.
    
         -- LED
         UART_tx_led                            : out std_logic;
         ADC_led                                : out std_logic;
         
         UART_enter_rx_led_1                    : inout std_logic := '0';
         UART_enter_rx_led_2                    : inout std_logic := '0';
         UART_enter_rx_led_3                    : inout std_logic := '0';
         UART_enter_rx_led_4                    : inout std_logic := '0';
         
         UART_rx_led_0                          : out std_logic := '0';
         UART_rx_led_1                          : out std_logic := '0';
         UART_rx_led_2                          : out std_logic := '0';
         UART_rx_led_3                          : out std_logic := '0';
         UART_rx_led_4                          : out std_logic := '0';
         UART_rx_led_5                          : out std_logic := '0';
         UART_rx_led_6                          : out std_logic := '0';
         UART_rx_led_7                          : out std_logic := '0'
         );
         
end main;

architecture Behavioral of main is

    --component xadc_wiz_1 is
    component xadc_wiz_0 is
        port(
        daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
        den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
        di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
        dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
        do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
        drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
        dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
        reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
        vauxp6          : in  STD_LOGIC;                         -- Auxiliary Channel 6
        vauxn6          : in  STD_LOGIC;
        busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
        channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
        eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
        eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
        alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
        vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
        vn_in           : in  STD_LOGIC
        );
    end component;
    
    component UART_RX is
      generic(
        g_CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
        );
      port(
        i_Clk       : in  std_logic;
        i_RX_Serial : in  std_logic;
        o_RX_DV     : out std_logic;        --Data Valid
        o_RX_Byte   : out std_logic_vector(7 downto 0)
        );
    end component;

    component UART_TX is
      generic(
        g_CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
        );
      port(
        i_Clk       : in  std_logic;
        i_TX_DV     : in  std_logic;        --Data Valid
        i_TX_Byte   : in  std_logic_vector(7 downto 0);
        o_TX_Active : out std_logic;
        o_TX_Serial : out std_logic;
        o_TX_Done   : out std_logic
        );
    end component;
    
    component fir_filter is
    port(
        clk_i 	       : in std_logic;
        reset_i 	   : in std_logic;
        x       	   : in std_logic_vector(11 downto 0);
        digitizer_fir  : in std_logic_vector(15 downto 0);
        coeffs_fir     : in fir_array (24 downto 0);
        y_32           : out signed(31 downto 0);
        y_16           : out signed(15 downto 0);
        y_12           : out std_logic_vector(11 downto 0)
        );
    end component; 
    
    component acumulator is
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
    end component;
    
    ------------------------------
    -- clocking signals & reset --
    ------------------------------ 

    constant clk_rate               : unsigned(31 downto 0) := to_unsigned(clk_freq,32);   -- 100000000, for 100 MHz clock.
    
    signal adq_count                : unsigned(31 downto 0) := (others => '0');            -- Used to frequency divide the core clock to the adquisition clock frequency.
    signal adq_tick                 : std_logic := '0';                                    -- Adquisition clock tick
    signal ADC_freq                 : std_logic_vector (15 downto 0) := "0000000000000010";    
    signal adq_rate                 : unsigned(15 downto 0) := to_unsigned(2,16);   -- 1, for 1 Hz clock. Maximum Adq_Rate = 11.520
    
    signal rst                      : std_logic := '0';
    --signal reset_sr               : std_logic_vector(3 downto 0) := (others => '1');

    -----------------
    -- ADC signals --
    -----------------
   
    signal ADC_start                : std_logic := '0';   
    signal analog_data              : std_logic_vector(15 downto 0) := (others=>'0');

    --signal eoc                    : std_logic;
    --signal eos                    : std_logic;
    --constant daddr                : std_logic_vector(6 downto 0) := (others => '0'); -- temp is 00h addres --  "0010011"; -- hard selecting channel 3, IE JXADC pin 1 & 7 (rightmost, looking into the connector)
    constant daddr                  : std_logic_vector(6 downto 0) := "0010110"; --  "0010110"; canal 6 -- hard selecting channel 3, IE JXADC pin 1 & 7 (rightmost, looking into the connector)
                                                                -- will sequence them later.
    signal ADC_data_ready           : std_logic := '0';
    
    signal enable                   : std_logic := '0';
    signal channel_out              : std_logic_vector(4 downto 0) := (others=>'0'); -- channel selection
    --signal alarm_out              : std_logic;
    
    signal vauxp7                   : std_logic := '0';
    signal vauxn7                   : std_logic := '0';
    signal vauxp14                  : std_logic := '0';
    signal vauxn14                  : std_logic := '0';
    signal vauxp15                  : std_logic := '0';
    signal vauxn15                  : std_logic := '0';
    
    ------------------
    -- FIR signals --
    ------------------ 
    
    signal digitizer_fir            : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(12000,16));
    signal digitizer_aux            : std_logic_vector(15 downto 0) := (others => '0');
    signal coeffs_fir               : fir_array (24 downto 0) := (
                                          std_logic_vector(to_signed(45,16)),
                                          std_logic_vector(to_signed(0,16)),
                                          std_logic_vector(to_signed(-136,16)),
                                          std_logic_vector(to_signed(-204,16)),
                                          std_logic_vector(to_signed(-34,16)),
                                          std_logic_vector(to_signed(306,16)),
                                          std_logic_vector(to_signed(2082,16)),
                                          std_logic_vector(to_signed(0,16)),
                                          std_logic_vector(to_signed(-3637,16)),
                                          std_logic_vector(to_signed(-4859,16)),
                                          std_logic_vector(to_signed(-1409,16)),
                                          std_logic_vector(to_signed(4290,16)),
                                          std_logic_vector(to_signed(7114,16)),
                                          std_logic_vector(to_signed(4290,16)),
                                          std_logic_vector(to_signed(-1409,16)),
                                          std_logic_vector(to_signed(-4859,16)),
                                          std_logic_vector(to_signed(-3637,16)),
                                          std_logic_vector(to_signed(0,16)),
                                          std_logic_vector(to_signed(2082,16)),
                                          std_logic_vector(to_signed(306,16)),
                                          std_logic_vector(to_signed(-34,16)),
                                          std_logic_vector(to_signed(-204,16)),
                                          std_logic_vector(to_signed(-136,16)),
                                          std_logic_vector(to_signed(0,16)),
                                          std_logic_vector(to_signed(45,16))
                                         );
    signal index_coeffs             : std_logic_vector(7 downto 0) := (others => '0');
    signal fir_output               : std_logic_vector(11 downto 0) := (others=>'0');  
    
    ---------------
    -- averaging --
    ---------------
    
    signal av_samples_aux                  : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(1,16));
    signal av_samples_pos                  : std_logic_vector(15 downto 0) := std_logic_vector(to_signed(1,16));
    signal av_buffer                       : fir_array (127 downto 0) := ((others => (others=>'0')));
    signal av_sample_index                 : std_logic_vector(7 downto 0) := (others => '0');
    signal av_size_changed                 : std_logic := '0';
    
    signal av_sample                       : std_logic_vector(15 downto 0) := (others => '0');
    signal av_data_ready                   : std_logic := '0';
    
    ------------------
    -- UART signals --
    ------------------ 

    signal UART_tx_state                : UART_tx_state_type := IDLE;                       -- FSM tx states
    signal UART_rx_acum_state           : UART_rx_acum_type := ACUM;                        -- FSM acumulate data in rx 
    signal UART_rx_state                : UART_rx_state_type := COMPARE;                    -- FSM rx states
    
    
    signal UART_Send_Data               : std_logic := '0';
    signal ASCII_byte_to_transmit       : std_logic_vector(7 downto 0) := (others => '0');
    signal index_byte_to_transmit       : std_logic_vector(7 downto 0) := (others => '0');
    signal UART_ready                   : std_logic := '0';
    signal UART_busy                    : std_logic := '0';
    
    signal UART_receive_data            : std_logic := '0';
    signal UART_received_data           : std_logic_vector (7 downto 0) := (others => '0');
    
    signal analog_ASCII                 : char_array (8 downto 0) := ((others=> (others=>'0')));
    signal UART_received_string         : char_array (31 downto 0):= ((others=> (others=>'0')));
    signal UART_received_string_index   : std_logic_vector (4 downto 0) := (others => '0');
    signal UART_valid_char              : std_logic := '0';
        
    --------------------------
    -- Recognizer constants --
    -------------------------- 
    
    constant NL                     : std_logic_vector(7 downto 0)    := "00001010";-- X"0A" "NL"
    constant CR                     : std_logic_vector(7 downto 0)    := "00001101";-- X"0D" "CR"
    constant char_digitizer         : std_logic_vector(7 downto 0)    := "01000100";-- X"44" "D"
    constant char_sampling_rate     : std_logic_vector(7 downto 0)    := "01010011";-- X"53" "S"
    constant char_coeffs            : std_logic_vector(7 downto 0)    := "01000011";-- X"43" "C"
    constant char_averaging_samples : std_logic_vector(7 downto 0)    := "01000001";-- X"41" "A"
    constant char_start             : std_logic_vector(7 downto 0)    := "01000010";-- X"42" "B"
    constant char_stop              : std_logic_vector(7 downto 0)    := "01010000";-- X"50" "P"
    constant char_exit              : std_logic_vector(7 downto 0)    := "01011000";-- X"58" "X"
    
begin

    rx : UART_RX port map (
        i_Clk               => clk,
        i_RX_Serial         => rxd_pin,
        o_RX_DV             => UART_receive_data,
        o_RX_Byte           => UART_received_data);
        
    tx : UART_TX port map (
        i_Clk               => clk,
        i_TX_DV             => UART_send_data,
        i_TX_Byte           => ASCII_byte_to_transmit,
        o_TX_Active         => UART_busy,
        o_TX_Serial         => txd_pin,
        o_TX_Done           => UART_ready);

    --You may also need to connect "den_in" to something that isn't always asserted (simulation fails with a DRC check):
    
    adc : xadc_wiz_0 port map (
        daddr_in            => daddr,
        --den_in            => bit_tick, -- was '1' this will read the XADC register '9600' times a second
        den_in              => adq_tick, -- this will read the XADC register 'adq_freq' times a second
        di_in               => (others => '0'),
        dwe_in              => '0',
        do_out              => analog_data,
        drdy_out            => ADC_data_ready,
        dclk_in             => clk,
        reset_in            => rst,
        -- JXADC pins
        -- physical numbering and signals
        -- VCC GND 11  2   10  3
        -- 6   5   4   3   2   1 -- Positive
        -- 12  11  10  9   8   7 -- Negative
        vauxp6              => vauxp6, 
        vauxn6              => vauxn6,
        --vauxp7              => vauxp7,
        --vauxn7              => vauxn7,
        --vauxp14             => vauxp14,
        --vauxn14             => vauxn14,
        --vauxp15             => vauxp15,
        --vauxn15             => vauxn15,
        busy_out            => adc_led,
        channel_out         => channel_out,
        eoc_out             => enable,
        eos_out             => open,
        alarm_out           => open,
        vp_in               => '0',
        vn_in               => '0'
        );
        
    fir: fir_filter port map (
        clk_i 	            => ADC_data_ready,        
        reset_i             => rst, 	   
        x                   => analog_data (15 downto 4),     	   
        digitizer_fir       => digitizer_fir, 
        coeffs_fir          => coeffs_fir,
        y_32                => open,
        y_16                => open,
        y_12                => fir_output
        );
     
     averaging: acumulator port map (
         
         clk                => clk,                           
         ADC_ready			=> ADC_data_ready,	                
         size_changed		=> av_size_changed,	                
         analog_data        => analog_data(15 downto 4),                   
         av_size_buffer_pos => av_samples_pos,		            
         av_index         	=> av_sample_index,		           
         av_sample          => av_sample,                   
         av_data_ready      => av_data_ready                   
         );
    
    --enable <= '1';
    --rst <= reset_sr(0);
    
    uart_tx_led <= UART_ready;
    
    --------------------------------
    -- rising edge finder for ADC --
    --------------------------------

    adq_tick_proc:  process(clk, ADC_start)
    variable UART_enter_rx_led_2_aux : std_logic :='0';
    begin
        -- Until the signal from the serial port is received, we do not start the acquisition
        if ADC_start = '1' then
            -- generates the pulses to read the ADC
            if rising_edge(clk) then
                if adq_count = clk_rate/adq_rate-1 then
                    UART_enter_rx_led_2_aux := UART_enter_rx_led_2;
                    UART_enter_rx_led_2 <= not UART_enter_rx_led_2_aux;
                    adq_count <= (others => '0');
                    adq_tick  <= '1';
                    
                else
                    --UART_enter_rx_led_2 <= '1';
                    adq_count <= adq_count + 1;
                    adq_tick <= '0';
                end if;
            end if;
         end if;
    end process;
    
    -----------------------------------------------
    -- state machine for transmitting ADC Values --
    -----------------------------------------------
    
    --to check the acumulator
    USART_send_data_proc:  process (clk, av_data_ready, UART_busy)  
    --USART_send_data_proc:  process (clk, ADC_data_ready, UART_busy) 

	  variable mVolts : integer;
	  variable temp   : integer;

  	begin 
  		-- generates the signal sequence to write the serial port
   	if (ADC_data_ready = '1') then            -- Upon reset, set the state to A
			     UART_tx_state <= A;
 
    	elsif rising_edge(clk) then       -- if there is a rising edge of the
		                                  -- clock, then do the stuff below
       		case UART_tx_State is
	              when IDLE =>
	              
	 			               UART_tx_State <= IDLE;
	 			     		
		          when A =>
		                     -- Temp = (value * 503.975)/4096 - 273.15
                             --      =  (2499* 503.975)/4096 - 273.15
                             --      = 34.3 degrees C
                             --Temp :=to_integer(unsigned(analog_data(15 downto 4)))*12/100;
    		                 --mVolts :=to_integer(unsigned(analog_data(15 downto 4)))*1000/4095;
    		                 --mVolts :=to_integer(unsigned(fir_output));
    		                 
			                 --analog_ASCII (4 downto 0) <= get_ascii_array_from_int(mVolts);
                             analog_ASCII (4 downto 0) <= get_ascii_array_from_int(to_integer(unsigned(av_sample)));
			                 analog_ASCII (5) <= "01101101"; --0x6D 'm'
			                 --analog_ASCII (4) <="00100010"; --0x20 ''
			                 analog_ASCII (6) <= "01010110"; --0x56 'V'
			                 --analog_ASCII (5) <="01001011"; --0x4B 'K'
			                 analog_ASCII (7) <= CR; --0x0D 'CR'
			                 analog_ASCII (8) <= NL; --0x0A 'NL' 
			                 index_byte_to_transmit <= (others => '0');
			                 UART_tx_state <= B; 
			         
		          when B => 
			         
			                 --ASCII_byte_to_transmit <= analog_ASCII(1))); 
			                 ASCII_byte_to_transmit <= analog_ASCII(to_integer(unsigned(index_byte_to_transmit)));
			                 UART_tx_state <= C;
			                   
		          when C =>
		           
			                 if UART_busy = '0' then 
				                    UART_send_data <= '1'; 
				                    UART_tx_state <= D; 
			                   else
				                    UART_tx_state <= C;
			                   end if;
			                     	
		          when D => 
			         
			                   UART_send_data <= '0';
			                   UART_tx_state <= E;
			                   
			      when E =>
			      
			                   if UART_busy = '0' then 
			                        -- 9 bytes will be transmitted in each tx stream
			                        if unsigned(index_byte_to_transmit) < 8 then
			                             index_byte_to_transmit <= std_logic_vector(unsigned(index_byte_to_transmit)+1);
			                             UART_tx_state <= B;
			                         else 
			                             UART_tx_state <= IDLE;
			                         end if;
			                   end if;
			                   
		          when others =>
		          
			                   UART_tx_state <= IDLE;
			         
	              end case; 
        end if; 
    end process;
  
   --------------------------------------------------
   -- state machine for acumulating UART rx values --
   --------------------------------------------------

   -- Accumulate values until CR+NL
   -- Configure teraterm: Setup -> Terminal -> New Line -> Transmit-> CR+LF
   --                                                   -> Receive -> LF
   --                                       -> Local Echo
 
   USART_acum_data_proc:  process (clk, UART_received_data, UART_receive_data) 
 
   begin
     if rising_edge(clk) then  
        case UART_rx_acum_state is
	       when ACUM => 
	          
                if (UART_receive_data = '1') then
                    -- acummulate when data alid in UART
                    UART_received_string (to_integer(unsigned(UART_received_string_index))) <= UART_received_data; 
                    
                    -- if last two characters received are 'CR' & 'NL'
                    -- last reception
                    -- if UART_received_string (to_integer(unsigned(UART_received_string_index))) = CR then
                    -- current reception
                    if UART_received_data = NL then
                        --UART_received_string_index <= (others => '0');
                        UART_valid_char <= '1';
                        UART_rx_acum_state <= END_STATE;
                    -- increment index 
                    elsif unsigned(UART_received_string_index) < 31 then
                        UART_received_string_index <= std_logic_vector(unsigned(UART_received_string_index)+1);
                        UART_valid_char <= '0';
                    -- saturated buffer 32 positions
                    else
                        UART_received_string_index <= (others => '0');
                        UART_valid_char <= '0';
                        -- error led
                        UART_enter_rx_led_3 <= '1'; 
                    end if;
                end if;
                
            when END_STATE =>
            
                UART_valid_char <= '0'; 
                UART_rx_acum_state <= ACUM;
                UART_received_string_index <= (others => '0');
                               
            when others =>   
            
                UART_rx_acum_state <= ACUM;
                
        end case;       
     end if;
   end process;
 
   ----------------------------------
   -- state machine for receiving  --
   ----------------------------------
  
   USART_interpretate_char_proc: process (clk, UART_valid_char)
   begin
      if rising_edge(clk) then
        case UART_rx_state is
            when COMPARE =>
            
                if UART_valid_char = '1' then                              			   
			        --if string received is X, 'NL' check X
			        if (UART_received_string (1) = CR) and (UART_received_string (2) = NL) then
			        --if ((UART_received_string(to_integer(unsigned(UART_received_string_index)-1)) = CR) and (UART_received_string (to_integer(unsigned(UART_received_string_index)))) = NL) then
			         			                       
    			         case UART_received_string (0) is
                            when char_digitizer =>
                                UART_rx_state <= DIGITIZER;
                            when char_sampling_rate =>
                                UART_rx_state <= SAMPLING_RATE;
                            when char_coeffs =>
                                UART_rx_state <= COEFFS;
                                index_coeffs <= (others => '0');
                            when char_averaging_samples =>
                                UART_rx_state <= AVERAGING_SAMPLES;
                            when char_start =>
                                UART_rx_state <= START;
                            when char_stop =>
                                UART_rx_state <= STOP;
                            when others =>
    		                    UART_rx_state <= COMPARE;
    		                    -- error led
    		                    UART_enter_rx_led_4 <= '1';
    			         end case;
    			    else 
    			         -- error led
    			         UART_enter_rx_led_4 <= '1';      
			        end if;
			    end if;
			                                    
       		when START =>
   
       		   -- Begin conversions
       		   --UART_enter_rx_led_1 <= '1';
       		   ADC_start <= '1';
       		   UART_rx_state <= COMPARE;
       		   
       		when STOP =>
       		       
       		   -- Stop conversions
       		   --UART_enter_rx_led_1 <= '0';
       		   ADC_start <= '0';
       		   UART_rx_state <= COMPARE;
       		                
       		when DIGITIZER =>

       		   --convert ASCII to integer 
       		   --output <= ascii_to_std_logic_vector (input);        
       		   if (UART_valid_char = '1') then                      			        		                                
       		       --if string received is X, 'NL' check XUART_rx_state <= COMPARE;
       		       if ((UART_received_string(to_integer(unsigned(UART_received_string_index)-1)) = CR) and (UART_received_string (to_integer(unsigned(UART_received_string_index)))) = NL) then
       		           --convert ASCII to integer
       		           --CHECK IF IT IS NEGATIVE!!!!
       		           
       		           digitizer_aux <= ascii_to_std_logic_vector (UART_received_string);
       		           UART_rx_state <= DIGITIZER_2;		         
       		       end if;    			   
		       end if;
       		   
       		when DIGITIZER_2 =>
       		
               if (signed(digitizer_aux) > 0) then
                    digitizer_fir <= digitizer_aux;
               end if; 
               UART_rx_state <= COMPARE;  
                    
			when SAMPLING_RATE =>
			       		   
       		   if UART_valid_char = '1' then                           
       		       --if string received is X, 'NL' check XUART_rx_state <= COMPARE                          			      		                                
       		       if ((UART_received_string(to_integer(unsigned(UART_received_string_index)-1)) = CR) and (UART_received_string (to_integer(unsigned(UART_received_string_index)))) = NL) then
       		           --convert ASCII to integer
       		           ADC_Freq <= ascii_to_std_logic_vector (UART_received_string);
       		           ADC_start <= '0';
       		           UART_rx_state <= SAMPLING_RATE_2;		         
       		       end if;    			   
		       end if;
		       
			when SAMPLING_RATE_2 =>
			   --UART_rx_led_0 <= ADC_Freq(0);                      
               --UART_rx_led_1 <= ADC_Freq(1);                        
               --UART_rx_led_2 <= ADC_Freq(2);                     
               --UART_rx_led_3 <= ADC_Freq(3);                        
               --UART_rx_led_4 <= ADC_Freq(4);
               --UART_rx_led_5 <= ADC_Freq(5);
               --UART_rx_led_6 <= ADC_Freq(6);
               --UART_rx_led_7 <= ADC_Freq(7);
               if signed(ADC_Freq) > 0 then
			         adq_rate <= unsigned(ADC_Freq);
			         UART_rx_state <= SAMPLING_RATE_3;
			   else
			         -- error led
    			     UART_enter_rx_led_4 <= '1';
			         ADC_start <= '1';
			         UART_rx_state <= COMPARE;  
			   end if;
			   --UART_rx_state <= SAMPLING_RATE_3;  
			   
			when SAMPLING_RATE_3 =>
			   --UART_enter_rx_led_1 <= '1';
			   ADC_start <= '1';
			   UART_rx_state <= COMPARE;
			   
--			when SAMPLING_RATE_4 =>

			   
			when COEFFS =>

			   if UART_valid_char = '1' then
       		       --if string received is X, 'NL' check XUART_rx_state <= COMPARE;
       		       --if (UART_received_string (1) = CR) and (UART_received_string (2) = NL) then
       		       if ((UART_received_string(to_integer(unsigned(UART_received_string_index)-1)) = CR) and (UART_received_string (to_integer(unsigned(UART_received_string_index)))) = NL) then
       		           coeffs_fir(to_integer(unsigned(index_coeffs))) <= ascii_to_std_logic_vector (UART_received_string);
       		           if (unsigned(index_coeffs)<24) then
       		                index_coeffs <= std_logic_vector(unsigned(index_coeffs)+1);
                            UART_rx_state <= COEFFS;
                       else 
                            index_coeffs <= (others => '0'); 
                            UART_rx_state <= COMPARE; 
                       end if;     
                   end if;    			   
		       end if;
		       
		    when AVERAGING_SAMPLES =>
		       --convert ASCII to integer 
       		   --output <= ascii_to_std_logic_vector (input);        
       		   if UART_valid_char = '1' then                      			        		                                
       		       --if string received is X, 'NL' check XUART_rx_state <= COMPARE;
       		       if ((UART_received_string(to_integer(unsigned(UART_received_string_index)-1)) = CR) and (UART_received_string (to_integer(unsigned(UART_received_string_index)))) = NL) then
       		           --convert ASCII to integer
       		           --CHECK IF IT IS NEGATIVE!!!!
       		           av_samples_aux <= ascii_to_std_logic_vector (UART_received_string);
       		           UART_rx_state <= AVERAGING_SAMPLES_2;		         
       		       end if;    			   
		       end if;
       		   
       		when AVERAGING_SAMPLES_2 =>
       		   UART_rx_led_0 <= av_samples_aux(0);                      
               UART_rx_led_1 <= av_samples_aux(1);                        
               UART_rx_led_2 <= av_samples_aux(2);                     
               UART_rx_led_3 <= av_samples_aux(3);                        
               UART_rx_led_4 <= av_samples_aux(4);
               UART_rx_led_5 <= av_samples_aux(5);
               UART_rx_led_6 <= av_samples_aux(6);
               UART_rx_led_7 <= av_samples_aux(7);
       		   --Maximum size buffer to averaging = 128
               if ((signed(av_samples_aux) > 0) and (signed(av_samples_aux) < 128)) then
                    av_samples_pos <= av_samples_aux;             
                    UART_rx_state <= AVERAGING_SAMPLES_3;
               else
                    -- error led
    			     UART_enter_rx_led_4 <= '1';
			         UART_rx_state <= COMPARE;
               end if; 
          
		    when AVERAGING_SAMPLES_3 =>
		          av_size_changed <= '1';
		          UART_rx_state <= AVERAGING_SAMPLES_4;
		          
		    when AVERAGING_SAMPLES_4 => 
		          av_size_changed <= '0';
		          UART_rx_state <= COMPARE;  
			
			when others =>
			
       		   UART_rx_state <= COMPARE;
       		            
	    end case;                        
     end if;
   end process;
 
end behavioral;