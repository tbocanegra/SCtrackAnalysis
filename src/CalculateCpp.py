# Import required tools
from numpy import *
import matplotlib as plt
import time

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
    mp = sum(Spec[xo-Nx:xo+Nx])
    wp = sum(Spec[xo-Nx:xo+Nx]*(arange(xo-Nx+1,xo+Nx+1)-Xm-1))
    dxo = wp/mp;
    return dxo

def PolyfitW1C(x, y, w, np):
   nx = x.size
   xx = x.max()
   xn = x/xx

   Vp = zeros((1,np))
   Mp = zeros((np,np))
   Cp = zeros((1,np))    

   for jp in range(0,np):
        for jj in range(0,nx-1): 
            Vp[0,jp] = Vp[0,jp] + power(xn[jj],jp)*y[jj]*w[jj]
        for ip in range(0,np):
            for jj in range(0,nx-1):
                Mp[jp,ip] = Mp[jp,ip] + power(xn[jj],jp+ip)*w[jj]

   Mr = linalg.pinv(Mp)
   Cp = dot(Mr,Vp.T)
   return Cp
    
#def CalculateCpp(filename,Fsmin,Fsmax):
try:   
   start = time.clock()
   filepath = './'
   filename = 'v120213_Wz_MkIV_No0005_3200000pt_5s_ch1_swspec.bin'
   FFTpt = 3200000
   BW    = 8e6
   SR    = 2*BW
   Fsmin = 3.425e6
   Fsmax = 3.445e6
   Hwin  = 1e3
   Avoid = 100
   Nspec = 228
   dts   = 5
   df    = SR/FFTpt
   Nfft  = FFTpt/2+1;
   jf    = arange(0,Nfft)
   ff    = df*jf
   tsp   = dts*(0.5+arange(0,Nspec-1))

   # Read file
   fd = open(filepath+filename,'rb')
   if fd < 0:
     print 'Error opening the file'

   bfs = int(Fsmin/df)
   bfm = int(Fsmax/df)
   Sps = zeros((Nspec,bfm-bfs))
   Aspec = zeros((1,bfm-bfs))
   ffs = ff[bfs:bfm]
   Npol = 6
   Tspan = max(tsp)

   for i in range(0,Nspec-1):
     read_data = fromfile(file=fd, dtype=float32, count=Nfft)
     vspec = read_data[bfs:bfm]
     Sps[i] = han(vspec)
     ASpec  = Aspec + Sps[i]
 
   fd.close()
   Aspec = Aspec/Nspec
   mSp = Sps.max()
   Sps = Sps/mSp;

   print('Spectra file opened and copied to an array')

   xfc = zeros((Nspec,3))
   RMS = zeros((Nspec,3))
   SNR = zeros((Nspec,1))
   Fdet= zeros((Nspec,1))
   dxc = zeros((Nspec,1))

   print('Seeking for the Max and estimating the RMS')
   for i in range (0,Nspec-1):
     xfc[i]  = FindMax(Sps[i],ffs, Fsmin, Fsmax)
     Fdet[i] = df*xfc[i,1] + ffs[0]
     RMS[i]  = GetRMS(Sps[i],ffs,Fdet[i],Hwin,Avoid)
     SNR[i]  = (xfc[i,2] - RMS[i,0])/RMS[i,1]

   mSNR = SNR.mean()

   # Calculating the centre of the gravity correction
   for i in range (0,Nspec-1):
   	 dxc[i] = PowCenter(Sps[i],xfc[i,1],3)
   #print dxc[0:4]

   dxc = dxc*df

   # Adding the correction to our Frequency detections
   FdetC  = dxc + Fdet
   Weight = power(SNR/mSNR,2)

   Npph       = Npol + 1
   dtsampling = 1/SR

   print 'Calculating the Polynomial fit'
   Cfs = zeros((Npol,1))
   Cps = zeros((Npph,1))
   Cpr = zeros((Npph,1))

   Cf = PolyfitW1C(tsp,FdetC,Weight,Npol)

   for jpf in range(0,Npol):
       Cfs[jpf] = Cf[jpf]*power(Tspan,-jpf)

   for jpf in range(1,Npph):
       Cps[jpf] = 2*pi*Cfs[jpf-1]/jpf
       Cpr[jpf] = Cps[jpf]*power(dtsampling,jpf)

   print 'Preparing the frequencial coefficients'
   cppname = filename[0:39] +'.poly6.txt'
   cfsname = filename[0:39] +'.X5cfs.txt'

   print 'The Cpp values are stored to disk'
   savetxt(cppname,Cpr)
   savetxt(cfsname,Cfs)

   print 'Create and store the Frequency Detections after the 1st iteration'
   fdets = 'Fdets.vex20'+filename[1:3]+'.'+filename[3:5]+'.'+filename[5:7]+'.'+filename[8:10]+'.'+filename[18:22]+'.r0i.txt'
   print fdets
   elapsed = (time.clock() - start)
   print 'Total elapsed time : ' 
   print elapsed

except AttributeError:
   print 'Error'
