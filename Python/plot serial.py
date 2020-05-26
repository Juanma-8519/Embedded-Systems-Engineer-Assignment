import serial
import matplotlib.pyplot as plt
from drawnow import *
import atexit

values = []

plt.ion()
cnt = 0

serialFPGA = serial.Serial('COM8', 115200)
serialFPGA.write(b'B\r\n')     # write a string


def plotValues():
    plt.title('Serial value from FPGA')
    plt.grid(True)
    plt.ylabel('Values')
    plt.plot(values, 'rx-', label='values')
    plt.legend(loc='upper right')


def doAtExit():
    serialFPGA.write(b'P\r\n')  # write a string
    serialFPGA.close()
    print("Close serial")
    print("serialFPGA.isOpen() = " + str(serialFPGA.isOpen()))


atexit.register(doAtExit)

print("serialFPGA.isOpen() = " + str(serialFPGA.isOpen()))

# pre-load dummy data
for i in range(0, 26):
    values.append(0)

while True:
    while (serialFPGA.inWaiting() == 0):
        pass
    print("readline()")
    valueRead = serialFPGA.readline()

    # check if valid value can be casted
    try:
        resultant = 0
        for i in range(1, 5):
            # print(ser_bytes[i])
            resultant = (resultant * 10) + (valueRead[i]) - ord('0')
        print(resultant)
        values.append(resultant)
        values.pop(0)
        drawnow(plotValues)


    except ValueError:
        print("Invalid! cannot cast")