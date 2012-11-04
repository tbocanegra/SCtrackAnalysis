# declare required packages
import os, subprocess
#import CalculateCpp
from multiprocessing import Process

# declare variables

def ask_station(prompt):
	while True:
		station = raw_input(prompt)
		if station in ('Mh','Wz','On','Hh','Ys'):
			return station
		else:
			retries = retries -1
		if retries < 0:
			raise IOError('Error in specifying the station')
		print(complaint)

def ask_format(prompt, retries=2, complaint='Format not supported'):
	while True:
		format = raw_input(prompt)
		if format in  ('MkIV','VLBA','Mk5B','VSIB'):
			return format
		else:
			retries = retries -1
		if retries < 0:
			raise IOError('Error to specify data format')
		print(complaint)

def ask_scans(prompt, retries=2, complaint='Only numbers!'):
	while True:
		scans = input(prompt)
		if scans < 25:
			return scans
		else:
			retries = retries - 1
		if retries < 0:
			raise IOError('Error to add scan numbers');
		print(complaint)

def ask_cores(prompt, retries=2, complaint='Valid number 0 to 6'):
	while True:
		cores = input(prompt)
		if cores < 7:
			return cores
		else:
			retries = retries - 1
		if retries < 0:
			raise IOError('Error to add scan numbers');
		print(complaint)

def filename(prompt, retries=2, complaint='File not found'):
	fn = raw_input(prompt)
	if (os.path.isfile(fn)):
		return fn
	else:
		retries = retries - 1
	if retries < 0:
		raise IOError('The file you entered is not found')
	print(complaint)

def ask_first_scan(prompt, retries=2, complaint='Insert a correct number'):
    while True:
        start = input(prompt)
        if start > 0:
            return start
        else:
            retries = retries -1
        if retries < 0:
            raise IOError('Error with the first scan to process')
        print(complaint)

def run_scans(flag):
	cn = fn.replace('001','00'+str(start+i-1))
	print('Core ' + str(i) + ': Running swspectrometer inifile'+str(start+i-1)+'.ini ' + cn)
	s = open('inifile.ini').read()
	s = s.replace('001','00'+str(start+i-1))
	s = s.replace('_ST_','_'+station+'_');
	f = open('inifile'+ str(start+i-1) +'.ini','w')
	f.write(s)
	f.close()
	a = subprocess.Popen(['/bin/cat','inifile'+str(start+i-1)+'.ini'])#,filename)
	a.wait()
#	a = subprocess.Popen(['swspectrometer','inifile'+str(start+i)+'.ini',cn])
#	print('SWspec has finished correctly. Calculating the Cpp coefficients...\n')
#	a = CalculateCpp(fn[1:7]+'_'+ station + '_' + format + '_3200000pt_5s_ch1.swspec.bin',3.4e6,3.45e6)
#	a.wait()
#   s = open('inifile').read()
#   s = s.replace('001','00'+str(i))
#   s = s.replace('_ST_','_'+station+'_');
#   f = open('inifile'+str(i),'w')
#   f.write(s)
#   f.close()
#   a = subprocess.Popen(['./sctracker','inifile'+str(i)])

print('Configuring the input parameters\n')
fn = filename('Which is the basename of the file to process? ')
station = ask_station('Which station are you processing? ')
cores = ask_cores('How many of scans run in parallel? ')
scans = ask_scans('How many scans do you want to process? ')
start = ask_first_scan('Which is the first scan? ')
#format = ask_format('Which data format was used? ')
print('\n')

for i in range (1,cores+1):
	p = Process(target=run_scans, args=('test',))
	p.start()
	p.join()
