import numpy as np
import matplotlib.pyplot as plt

#Input:
#f1, the lowest frequency to be included, in Hz
#f2, the highest frequency to be included, in Hz
#f_samp, sampling frequency of the audio signal to be filtered, in Hz
#N, the order of the filter; assume N is odd
#Output:
#a bandpass FIR filter in the form of an N-element array

#Normalize f_c and w_c so that pi is equal to the Nyquist angular frequency
f1=200
f2=400
f_samp=2000
#N by4 multiplier
N=512

f1_c = f1/f_samp
f2_c = f2/f_samp
w1_c = 2*np.pi*f1_c
w2_c = 2*np.pi*f2_c
#Integer division, dropping remainder
middle = int(N/2)
fltr = np.zeros(N)
#for i in range (int(−N/2), int(N/2),1):
for i in range (-128,128):
    if i == 0 :
        fltr[middle] = 2*f2_c - 2*f1_c
    else:
        fltr[int(i + middle)] = np.sin(w2_c*i)/(np.pi*i) - np.sin(w1_c*i)/(np.pi*i)
#Now apply a windowing function to taper the edges of the filter, e.g.
#Hamming, Hanning, or Blackman

plt.plot(fltr)
plt.show()
#for i in range(28):
#    print(fltr[i])