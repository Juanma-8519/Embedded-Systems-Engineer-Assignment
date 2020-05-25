# Innerspec Embedded Systems Engineer Assignment
In this work I will present the tasks performed in relation to the practice for the job position of embedded systems engineer for Innerspec.
Although in this week, I have been trying to make contact with Qt, I have not managed to elaborate a UI similar to the mentioned one, mainly due to the question of the embedded Chart. So my work is mainly focused on the VHDL firmware of the FPGA.
A Basys3 development board was provided by Innerspec on Wednesday 20/05 at morning. So even though I had read the assignment on Friday, I was unable to start downloading designs to the chip until that day.
Regarding my prototyping tasks, I was working at home without the availability of a waveform generator. So I simulated the analog input with a potentiometer acting as a resistive divider.
In the JXADC PMOD connector, I used the 3.3V signal and its ground (pins 6-12 and 5-11 respectively). I connected a fixed resistor R1 at the top of the 1.1Mohm value divider and a 500kohm value potentiometer at the bottom. In this way, using the full linear range of the potentiometer, the one-volt limitation of the analog input channels is not exceeded.

![PMOD Conection] (/media/PMOD%20Connection.png)

