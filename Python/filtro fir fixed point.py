import numpy as np
import matplotlib.pyplot as plt

#Taken by fiiir.com
#Band pass filter (windowed-sinc)
#Sampling Rate 2000Hz
#fL = 200Hz
#bL = 160Hz
#fH = 400Hz
#bH = 160Hz
#Rectangular window type

coeffs = np.array ([
    0.001393308741230785,
    0.000000000000000004,
    -0.004179926223692371,
    -0.006231066118073347,
    -0.001044981555923163,
    0.009346599177109963,
    0.063546273476889611,
    -0.000000000000000025,
    -0.110994133554180363,
    -0.148311121291790693,
    -0.043024273765539467,
    0.130934780703932885,
    0.217129080820075593,
    0.130934780703931580,
    -0.043024273765539120,
    -0.148311121291790804,
    -0.110994133554180474,
    -0.000000000000000054,
    0.063546273476889764,
    0.009346599177110055,
    -0.001044981555923101,
    -0.006231066118073373,
    -0.004179926223692395,
    -0.000000000000000025,
    0.001393308741230773,
])

plt.plot(coeffs)
plt.show()

t = np.linspace(0,1.0,2001)

sin_50Hz = np.sin(2*np.pi*50*t)
sin_300Hz = np.sin(2*np.pi*300*t)
sin_600Hz = np.sin(2*np.pi*600*t)

original_signal = sin_50Hz+sin_300Hz+sin_600Hz
#Reescale Amplitude to 0-1
original_signal = original_signal /3

# multiply coeffs and signal (between 1 and -1) by 2^15
Q = 2**15

coeffs_Q = coeffs * Q
original_signal_Q = original_signal * Q

#limitate width to 16 bits, conversion to int16
coeffs_fixed = np.int16(coeffs_Q)
#file for copying coeffs to VHDL code
#for i in range(25):
#    print(coeffs_fixed[i])
#print('\n'.join([hex(i) for i in coeffs_fixed]))

original_signal_fixed = np.int16(original_signal_Q)
#file for inputs in VHDL test_bench
#for i in range(500):
#    print(original_signal_fixed[i])

#original signal in 16bits
plt.plot(t[:500],original_signal_Q[:500],label='input_16bits')
plt.legend()
plt.show()

#initializate
f_fixed = np.zeros(len(original_signal_fixed)+len(coeffs_fixed))

for j in range(len(original_signal_fixed+len(coeffs_fixed))):
    acum = 0;
    for i in range(len(coeffs_fixed)):
        #we need 32bits data
        if((j-i)>0):
            acum = np.int32(acum) + np.int32(coeffs_fixed[i])*np.int32(original_signal_fixed[j-i])
        #saturate signal for not distorsioning
        if(acum>0x3fffffff):
            acum=0x3fffffff
        if(acum<-0x40000000):
            acum=-0x40000000
    f_fixed[j] = acum

#2bits integer part and 30 for decimal
f_float=f_fixed/(2**30)
#file for outputs checking in VHDL test_bench
for i in range(500):
    print(f_fixed[i])

#plt.plot(t[:500],original_signal[:500],label='input_16bits')
#plt.plot(t[:500],sin_300Hz[:500],label='sin_300Hz')
#plt.plot(t[:500],f_float[:500],label='output_16bits')
plt.plot(t[:500],f_fixed[:500],label='output_16bits')
plt.legend()
plt.show()