# Innerspec Embedded Systems Engineer Assignment
In this work I will present the tasks performed in relation to the practice for the job position of embedded systems engineer for Innerspec.
Although in this week, I have been trying to make contact with Qt, I have not managed to elaborate a UI similar to the mentioned one, mainly due to the question of the embedded Chart. So my work is mainly focused on the VHDL firmware of the FPGA.
A Basys3 development board was provided by Innerspec on Wednesday 20/05 at morning. So even though I had read the assignment on Friday, I was unable to start downloading designs to the chip until that day.
Regarding my prototyping tasks, I was working at home without the availability of a waveform generator. So I simulated the analog input with a potentiometer acting as a resistive divider.
In the JXADC PMOD connector, I used the 3.3V signal and its ground (pins 6-12 and 5-11 respectively). I connected a fixed resistor R1 at the top of the 1.1Mohm value divider and a 500kohm value potentiometer at the bottom. In this way, using the full linear range of the potentiometer, the one-volt limitation of the analog input channels is not exceeded.

<img src="media/PMOD%20Connection.png">

Below is a photograph of the working situation. I use the multimeter to check if the values we are measuring though the serial match with the real input.

<img src="media/basys3.png">

Next, I will describe how the different stages of the FPGA hardware design are structured. The layout consists of 6 .vhd files and this is how they are interconnected.

* [main.vhd](Innerspec_project.srcs/sources_1/new/main.vhd)
* [uart_tx.vhd](Innerspec_project.srcs/sources_1/new/UART_TX.vhd)
* [uart_rx.vhd](Innerspec_project.srcs/sources_1/new/UART_RX.vhd)
* [xadc_wiz_o.vhd](Innerspec_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.vhd)
* [acumulator.vhd](Innerspec_project.srcs/sources_1/new/acumulator.vhd)
* [fir_filter.vhd](Innerspec_project.srcs/sources_1/new/FIR.vhd)

<img src="media/block%20diagram.png">

For the interpretation of the commands from the UI, I have created a state machine in the serial reception. The PC will deliver the following commands:

* B↵: Starts
* Q↵: Stops
* A↵: Averaging Samples
* S↵: Sampling Rate
* D↵: Digitalize
* C↵: Coefficients

In the “Averaging samples”, “sampling rate”, “digitizer” and “coeffs” states, the machine states waits for the user to enter the corresponding data following by an enter.
Since all communication is via serial, I have had to develop a function package to work with ASCII characters. Functions to convert to ASCII and to convert from ASCII.

<img src="media/serial.png">

## [acumulator.vhd](Innerspec_project.srcs/sources_1/new/acumulator.vhd)

### ACUMULATOR_FSM
<img src="Average%20FSM.png">


