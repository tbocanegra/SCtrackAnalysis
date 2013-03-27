# Import required tools
from numpy import *
import matplotlib.pyplot as plt
import time
import sys

print 'List of the current settings, please update them in DefVar function\n'
FFTpt = 3200000
BW    = 16e6
Fsmin = 7.36e6
Fsmax = 7.4e6
Nspec = 225
dts   = 5
Npol  = 6
plot  = 0

def FindMax(Spec, Fscale, Fmin, Fmax):
    np = Spec.size
    mx = Spec.max()
    px = Spec.argmax()

    if px == 0:
        px = 1
    if px == -1:
        px = -2

    a1 = 0.5*(Spec[px+1] - Spec[px-1])
    a2 = 0.5*(Spec[px+1] + Spec[px-1] - 2*Spec[px])
    djx = -a1/(2*a2)

    xmax = px + djx 
    out = (px,xmax,mx)
    return out

def GetRMS(Spec, Fscale, Fdet, Hwin, Fvoid):
    np = Spec.size
    mw = ww = dw = 0
    for i in range(0,np-1):
        if ((abs(Fscale[i]-Fdet) > Fvoid) and (abs(Fscale[i]-Fdet) < Hwin)):
            ww = ww + 1
            mw = mw + Spec[i]

    mm = mw/ww
    for i in range(0,np-1):
        if ((abs(Fscale[i]-Fdet) > Fvoid) and (abs(Fscale[i]-Fdet) < Hwin)):
            dw = dw + power(Spec[i]-mm,2)

    rm  = sqrt(dw/ww)
    out = (mm,rm,ww)
    return out

def han(vspec):
    nd = vspec.size
    hspec = zeros((1,nd))
    hspec[0,0] = 0.5*(vspec[0]+vspec[1])
    hspec[0,-1] = 0.5*(vspec[-2]+vspec[-1])
    for i in range(1,nd-1):
       hspec[0,i] = 0.5*(0.5*vspec[i-1]+vspec[i]+0.5*vspec[i+1])
    return hspec

def PowCenter(Spec, Xm, Nx):
    xo = int(Xm+0.5)
    mp = sum(Spec[xo-Nx:xo+Nx+1])
    wp = sum(Spec[xo-Nx:xo+Nx+1]*(arange(xo-Nx,xo+Nx+1)-Xm))
    dxo = wp/mp;
    return dxo

def PolyfitW1(x, y, w, np):
   nx = x.size
   xx = x.max()
   xn = x/xx

   Vp = zeros((1,np))
   Mp = zeros((np,np))
   Cp = zeros((1,np))
   yf = zeros((nx))

   for jp in range(0,np):
        for jj in range(0,nx):
            Vp[0,jp] = Vp[0,jp] + power(xn[jj],jp)*y[jj]*w[jj]
        for ip in range(0,np):
            for jj in range(0,nx):
                Mp[jp,ip] = Mp[jp,ip] + power(xn[jj],jp+ip)*w[jj]

   Mr = linalg.pinv(Mp)
   Cp = dot(Mr,Vp.T)

   for jj in range(0,nx):
        for jp in range(0,np):
             yf[jj] = yf[jj] + power(xn[jj],jp)*Cp[jp]

   return yf

def PolyfitW1C(x, y, w, np):
   nx = x.size
   xx = x.max()
   xn = x/xx

   Vp = zeros((1,np))
   Mp = zeros((np,np))
   Cp = zeros((1,np))    

   for jp in range(0,np):
        for jj in range(0,nx): 
            Vp[0,jp] = Vp[0,jp] + power(xn[jj],jp)*y[jj]*w[jj]
        for ip in range(0,np):
            for jj in range(0,nx):
                Mp[jp,ip] = Mp[jp,ip] + power(xn[jj],jp+ip)*w[jj]

   Mr = linalg.pinv(Mp)
   Cp = dot(Mr,Vp.T)
   return Cp
    
try:   
   start = time.clock()

   for arg in sys.argv:
     filename = arg

   SR    = 2*BW
   dtsam = 1/SR
   Hwin  = 1e3
   Avoid = 100
   df    = SR/FFTpt
   Nfft  = FFTpt/2+1;
   jf    = arange(0,Nfft)
   ff    = df*jf
   tsp   = dts*(0.5+arange(0,Nspec))
   Npph  = Npol + 1

   # Read file
   fd = open(filename,'rb')
   if fd < 0:
     print 'Error opening the file'

   bfs = int(Fsmin/df)
   bfm = int(Fsmax/df)
   Sps = zeros((Nspec,bfm-bfs))
   Aspec = zeros((bfm-bfs))
   ffs = ff[bfs:bfm]
   Tspan = max(tsp)

   for i in range(0,Nspec):
      read_data = fromfile(file=fd, dtype=float32, count=Nfft)
      vspec     = read_data[bfs:bfm]
      Sps[i]    = han(vspec)
      Aspec     = Sps[i] + Aspec
 
   fd.close()
   
   Aspec = Aspec/Nspec
   mSp   = Sps.max()
   Sps   = Sps/mSp;

   print('- Spectra file opened and copied to an array')

   xfc  = zeros((Nspec,3))
   RMS  = zeros((Nspec,3))
   Smax = zeros((Nspec))
   SNR  = zeros((Nspec))
   Fdet = zeros((Nspec))
   dxc  = zeros((Nspec))

   print('- Seeking for the Max and estimating the RMS')

   for i in range (0,Nspec):
     xfc[i]  = FindMax(Sps[i],ffs, min(ffs), max(ffs))
     Smax[i] = xfc[i,2]
     Fdet[i] = df*xfc[i,1] + ffs[0]
     RMS[i]  = GetRMS(Sps[i],ffs,Fdet[i],Hwin,Avoid)
     SNR[i]  = (xfc[i,2] - RMS[i,0])/RMS[i,1]

   mSNR = SNR.mean()

   # Calculating the centre of the gravity correction
   for i in range (0,Nspec):
     dxc[i] = PowCenter(Sps[i],xfc[i,1],3)

   dxc = dxc*df

   # Adding the correction to our Frequency detections
   FdetC  = Fdet + dxc
   Weight = power(SNR/mSNR,2)
#   Weight = 1
   print '- Calculating the Polynomial fit'
   Cfs = zeros((Npol))
   Cps = zeros((Npph))
   Cpr = zeros((Npph))

   Cf   = PolyfitW1C(tsp,FdetC,Weight,Npol)
   Ffit = PolyfitW1(tsp,FdetC,Weight,Npol)
   rFit = FdetC - Ffit

   for jpf in range(0,Npol):
       Cfs[jpf] = Cf[jpf]*power(Tspan,-jpf)

   for jpf in range(1,Npph):
       Cps[jpf] = 2*pi*Cfs[jpf-1]/jpf
       Cpr[jpf] = Cps[jpf]*power(dtsam,jpf)

   print '- Preparing the frequencial coefficients'
   cppname = filename[0:39] +'.poly'+str(Npol)+'.txt'
   cfsname = filename[0:39] +'.X'+str(Npol-1)+'cfs.txt'
   print '- The Cpp values are stored to disk'
   savetxt(cppname,Cpr)
   savetxt(cfsname,Cfs)
   
   print '- Reading starting time of the scan'
   fd = open(filename[0:39]+'_starttiming.txt','r')
   if fd < 0:
     print 'Error opening the file'

   fd.readline()
   Day, Tim, Sec = [float(x) for x in fd.readline().split()]
   fd.close()
   Start = Tim

   fbase = 'xxxx.xx'
   nbase = 'spa'
   if filename[0] == 'v':
     fbase = '8415.99'
     nbase  = 'vex'
   if filename[0] == 'r':
     fbase = '8396.59'
     nbase = 'ras'
   if filename[0] == 'm':
     fbase = '8415.99'
     nbase = 'mex'
   if filename[0] == 'g':
     fbase = '2xxx.xx'
     nbase = 'gns'
   if filename[0] == 'h':
     fbase = '8468.50'
     nbase = 'her'

   print '- Create and store the Frequency Detections after the 1st iteration'
   fdetsname = 'Fdets.'+ nbase +'20'+filename[1:3]+'.'+filename[3:5]+'.'+filename[5:7]+'.'+filename[8:10]+'.'+filename[18:22]+'.r0i.txt'
   tsp = tsp + Start

   Fds = array([tsp,SNR,Smax,FdetC,rFit])
   Fdets = Fds.conj().T
   savetxt(fdetsname, Fdets, newline='\n')

   fd = open(fdetsname,'r+')
   fd.seek(0)
   a = fd.read()
   fd.seek(0)
   fd.write('* Observation conducted on '+fdetsname[9:19]+' at '+filename[8:10]+' rev. 0\n')
   fd.write('* S/C base frequency: '+ fbase +' MHz\n')
   fd.write('* Format : Time(UTC) [s]  | Signal-to-Noise ratio  |       Spectral max     |  Freq. detection [Hz]  |  Doppler noise [Hz] \n')
   fd.write('* \n')
   fd.write(a)
   fd.close()

   elapsed = (time.clock() - start)
   print '\033[94m- Total elapsed time : \033[0m' 
   print elapsed
   
   if plot == 1:
      print 'Creating the Figure for plotting the spectra'
      plt.plot(ffs,Aspec)
      plt.ylabel('Spectra')
      plt.xlabel('Freq [Hz]')
      plt.title('Averaged time-integrated spectra')
      plt.show()
      plt.plot(Fdet,'ro')
      plt.xlim(0,Nspec)
      plt.ylim(Fsmin,Fsmax)
      plt.show()
      
except AttributeError:
   print 'Error'
