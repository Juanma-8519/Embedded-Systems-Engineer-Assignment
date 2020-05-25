----------------------------------------------------------------------------
--	acumulator.vhd -- Averaging buffer until 128 12bits ADC samples Component
----------------------------------------------------------------------------
-- Author:  Juanma Manchado
--          Copyright 2020 Innerspec, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This component is a model for a FIR filter. It is taken from vhdl.es
-- It is configured to work as a band pass filter, with the following
-- characteristics:
--
--      - f_samp = 2000 Hz
--      - fL = 200 Hz
--      - Transition bandwidh = 160 Hz
--      - fH = 400 Hz
--      - Transition bandwidh = 160 Hz
--      - Window type: Rectangular
--
-- The initial value of the coefficients has been taken from FIIIR.com.
-- Then they have been transformed to a fixed point - 16bits 
-- with a python script. The same script generates a file with a three
-- frequencies signal sampled, for then to be introduced in the test bench.
--         				
-- Port Descriptions:
--
--    clk_i              - Master clock, could be 100MHz
--    reset_i            - reset
--    x                  - input of the filter (12 bits) because 
--                         comes from the ADC
--    digitizer_fir      - value to adjust the output signal
--                         the value has been adjusted by a test_bench.
--                         Introducing the python generated inputs, the perfect
--                         value to adjust the output signal to the 12 bits widht
--                         is 12000.
--    coeffs_fir         - array of 25 samples for the coeffs to be entered from 
--                         the UART
--    y_32               - output 32bits' width
--    y_16               - output 16bits' width
--    y_12               - output 12bits' width   
--    ADC_ready          - flag signal to capture the analog data
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.integer_to_ascii.all;

entity fir_filter is
port(
  clk_i 	    : in std_logic;
  reset_i 	    : in std_logic;
  x       	    : in std_logic_vector(11 downto 0);
  digitizer_fir : in std_logic_vector(15 downto 0);
  coeffs_fir    : in fir_array (24 downto 0);
  y_32          : out signed(31 downto 0);
  y_16          : out signed(15 downto 0);
  y_12          : out std_logic_vector (11 downto 0)
);
end entity;


architecture behav of fir_filter is

    --type fixed_t is array (0 to 24) of signed(15 downto 0);
  
--  signal coeffs : fixed_t := (to_signed(45,16),
--  to_signed(0,16),
--  to_signed(-136,16),
--  to_signed(-204,16),
--  to_signed(-34,16),
--  to_signed(306,16),
--  to_signed(2082,16),
--  to_signed(0,16),
--  to_signed(-3637,16),
--  to_signed(-4859,16),
--  to_signed(-1409,16),
--  to_signed(4290,16),
--  to_signed(7114,16),
--  to_signed(4290,16),
--  to_signed(-1409,16),
--  to_signed(-4859,16),
--  to_signed(-3637,16),
--  to_signed(0,16),
--  to_signed(2082,16),
--  to_signed(306,16),
--  to_signed(-34,16),
--  to_signed(-204,16),
--  to_signed(-136,16),
--  to_signed(0,16),
--  to_signed(45,16));

    signal delay : fir_array (24 downto 0) := ((others=> (others=>'0')));

begin
--delay registers past inputs
delay_proc : process(clk_i, reset_i)
begin
  if(reset_i='1') then
    for i in 0 to 24 loop
      delay(i) <= (others=>'0');
    end loop;
  elsif(rising_edge(clk_i)) then
    delay(0) <= "0000" & std_logic_vector(x);       --fillig with 0 supossing ADC only give positive signals
    for i in 1 to 24 loop
      delay(i) <= delay(i-1);
    end loop;
  end if;
end process;

-- acumulation process
calc_proc : process(clk_i, reset_i)
  variable acum : signed(31 downto 0) := (others => '0'); --32bits
  variable aux_32 : signed(31 downto 0) := (others => '0'); --32bits
  variable aux_16 : signed(15 downto 0) := (others => '0'); --32bits
  variable output_16 : signed(15 downto 0) := (others => '0'); --32bits
  variable output : signed(11 downto 0) := (others => '0'); --32bits
begin
  if(reset_i='1') then
    y_32 <= (others=>'0');
    y_16 <= (others=>'0');
    y_12 <= (others=>'0');
    acum := (others=>'0');
  elsif (rising_edge(clk_i)) then
    acum:=(others=>'0');
    for i in 0 to 24 loop
       --acum := acum + (signed(coeffs(i))*signed(delay(i)));
       acum := acum + signed(coeffs_fir(i))*signed(delay(i));
    end loop;
    y_32 <= to_signed(to_integer(acum),32);
    --aux_32 := acum/65535;
    --aux_32 := acum/12000;             --Factor to see the python example signal properly in test_bench
    aux_32 := acum/(to_integer(unsigned(digitizer_fir)));           --Factor to see the python example signal properly in test_bench
    output_16 := to_signed(to_integer(aux_32),16);
    --y_16 <= to_signed(to_integer(acum),16);
    y_16 <= output_16;
    --aux_16 := output_16/4096;
    aux_16 := output_16;
    output := to_signed(to_integer(aux_16),12);
    y_12 <= std_logic_vector(to_signed(to_integer(output),12));
  end if;
end process;

end architecture;