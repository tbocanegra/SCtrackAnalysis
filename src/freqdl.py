# Import required tools
from numpy import *
import matplotlib as plt
import time

try:
   filename = 'test.bin'
   fd = open(filename,'r')
   if fd < 0:
      print 'Error while opening the Doppler file'

#  Read line by line and insert the data in vectors
#  Add the data in fields: yy, mm, dd, ho, mn, se, dopp, time
   time = hour*3600 + min*60 + sec

   fd.close()

   # 1st function is to plot the Doppler detections vs. time
   freq = {1,2,3}
   tim  = {0,1,2}
   
   plot(freq,tim)
