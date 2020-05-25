----------------------------------------------------------------------------
--	string.vhd -- auxiliar file to test the conversions functions 
----------------------------------------------------------------------------
-- Author:  Juanma Manchado
--          Copyright 2020 Innerspec, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This file is aimed to test the different functions to convert
-- from and to ASCII to use the serial port as interface of the Assignment
--
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.integer_to_ascii.all;
use work.fsm_states.all;


entity main_strings_functions is

port ( 

    clk                          : in std_logic;
    
    input_ascii_to_std           : in char_array (31 downto 0);
    output_ascii_to_std          : out std_logic_vector (15 downto 0);
    
    input_integer_to_ascii       : in integer range -9999 to 9999;
    output_integer_to_ascii      : out char_array (4 downto 0);

    input_12bits_signed          : in std_logic_vector (11 downto 0);
    output_signed                : out char_array (31 downto 0);


	UART_received_data           : in std_logic_vector (7 downto 0);
	NL                           : out std_logic_vector(7 downto 0)    := "00001010";-- X"0A" "NL"
	UART_valid_char              : out std_logic := '0';
	UART_received_string	     : out char_array (31 downto 0) := ((others=> (others=>'0')))
	
);
end main_strings_functions;

architecture Behavioral of main_strings_functions is

    signal UART_receive_data            : std_logic := '0';
    signal UART_received_string_index   : unsigned(4 downto 0) := (others => '0');

    
    begin
        
        process (input_ascii_to_std)
        begin
            output_ascii_to_std <= ascii_to_std_logic_vector (input_ascii_to_std);
        end process;
        
        process (input_integer_to_ascii)
        begin
			 output_integer_to_ascii (4 downto 0) <= get_ascii_array_from_int(input_integer_to_ascii); 
 
       end process;
        
        process (UART_received_data)
        begin
            --UART_received_string (0) <= UART_received_data;
            UART_received_string (to_integer(UART_received_string_index)) <= UART_received_data;
            
            if UART_received_string_index >= 31 then
                UART_received_string_index <= (others => '0');
            else
                UART_received_string_index <= UART_received_string_index + 1;
            end if;
            
            if UART_received_data =  "00001010" then
                --if UART_received_data =  NL then
                    UART_received_string_index <= (others => '0');
                    UART_valid_char <= '1';
                    --UART_enter_rx_led <= '1';
                else
                    UART_valid_char <= '0';
                    --UART_enter_rx_led <= '0';
                end if;
        end process;
 
 end Behavioral;
