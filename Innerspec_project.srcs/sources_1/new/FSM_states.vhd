----------------------------------------------------------------------------
--	FSM_states.vhd -- type description of the FSM used in the project
----------------------------------------------------------------------------
-- Author:  Juanma Manchado
--          Copyright 2020 Innerspec, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	There are 4 FSM, 
--
--      - two for the reception of the UART
--      - one for the UART transmission
--      - one for the average calculator
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

---------------------------------
-- package declaration section --
--------------------------------- 

package FSM_states is

    type UART_tx_state_type   IS (IDLE, A, B, C, D, E);                -- Define the states
    type UART_rx_acum_type    IS (ACUM, END_STATE);                 -- Define the states
    type UART_rx_state_type   IS (COMPARE, START, STOP, DIGITIZER, DIGITIZER_2, SAMPLING_RATE, SAMPLING_RATE_2, SAMPLING_RATE_3, AVERAGING_SAMPLES, AVERAGING_SAMPLES_2, AVERAGING_SAMPLES_3, AVERAGING_SAMPLES_4, COEFFS);           -- Define the states
    type averaging_state_type IS (A, B, C);                             -- Define the states
    
end package FSM_states;

--------------------------
-- package body section --
-------------------------- 

