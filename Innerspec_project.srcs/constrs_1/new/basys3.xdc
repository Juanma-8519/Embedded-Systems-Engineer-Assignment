# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
  set_property IOSTANDARD LVCMOS33 [get_ports clk]
  create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
	
set_property PACKAGE_PIN A18 [get_ports txd_pin]						
  set_property IOSTANDARD LVCMOS33 [get_ports txd_pin]
set_property PACKAGE_PIN B18 [get_ports rxd_pin]						
  set_property IOSTANDARD LVCMOS33 [get_ports rxd_pin]
  
## LEDs    
set_property PACKAGE_PIN U16 [get_ports {UART_tx_led}]					
  set_property IOSTANDARD LVCMOS33 [get_ports {UART_tx_led}]
set_property PACKAGE_PIN E19 [get_ports {ADC_led}]                    
  set_property IOSTANDARD LVCMOS33 [get_ports {ADC_led}]

set_property PACKAGE_PIN v19 [get_ports {UART_enter_rx_led_4}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_enter_rx_led_4}]
set_property PACKAGE_PIN W18 [get_ports {UART_enter_rx_led_3}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_enter_rx_led_3}]
set_property PACKAGE_PIN U15 [get_ports {UART_enter_rx_led_2}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_enter_rx_led_2}]
set_property PACKAGE_PIN U14 [get_ports {UART_enter_rx_led_1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_enter_rx_led_1}] 
set_property PACKAGE_PIN V13 [get_ports {UART_rx_led_7}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_7}] 
set_property PACKAGE_PIN V3 [get_ports {UART_rx_led_6}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_6}]  
set_property PACKAGE_PIN W3 [get_ports {UART_rx_led_5}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_5}]
set_property PACKAGE_PIN U3 [get_ports {UART_rx_led_4}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_4}]
set_property PACKAGE_PIN P3 [get_ports {UART_rx_led_3}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_3}]
set_property PACKAGE_PIN N3 [get_ports {UART_rx_led_2}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_2}]
set_property PACKAGE_PIN P1 [get_ports {UART_rx_led_1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_1}]
set_property PACKAGE_PIN L1 [get_ports {UART_rx_led_0}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {UART_rx_led_0}]
  
  #Sch name = XA1_P
  set_property PACKAGE_PIN J3 [get_ports {vauxp6}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxp6}]
  #Sch name = XA2_P
  set_property PACKAGE_PIN L3 [get_ports {vauxp14}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxp14}]
  #Sch name = XA3_P
  set_property PACKAGE_PIN M2 [get_ports {vauxp7}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxp7}]
  #Sch name = XA4_P
  set_property PACKAGE_PIN N2 [get_ports {vauxp15}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxp15}]
  #Sch name = XA1_N
  set_property PACKAGE_PIN K3 [get_ports {vauxn6}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxn6}]
  #Sch name = XA2_N
  set_property PACKAGE_PIN M3 [get_ports {vauxn14}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxn14}]
  #Sch name = XA3_N
  set_property PACKAGE_PIN M1 [get_ports {vauxn7}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxn7}]
  #Sch name = XA4_N
  set_property PACKAGE_PIN N1 [get_ports {vauxn15}]                
      set_property IOSTANDARD LVCMOS33 [get_ports {vauxn15}]