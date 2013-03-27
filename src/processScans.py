# declare required packages
import os, subprocess, sys
from multiprocessing import Process

# declare variables

def ask_program(prompt):
        while True:
                program = raw_input(prompt)
 		return program

def ask_station(prompt):
	while True:
		station = raw_input(prompt)
		if station in ('Hh','Ht','Hb','Mc','Mh','Wz','On','Ys','Yg'):
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
		if scans < 60:
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
    if (program == '1'):
        print('Using SWspec\n')
        s = open('inifile.'+station).read()
	if ((i-1) < 9):
	   cn = fn.replace('0001','000'+str(start+i-1))
	   s = s.replace('0001','000'+str(start+i-1))
	else:
	   cn = fn.replace('0001','00'+str(start+i-1))
	   s = s.replace('0001','00'+str(start+i-1))
	f = open('inifile.' + station + str(start+i-1),'w')
	f.write(s)
	f.close()
        a = subprocess.Popen(['/bin/cat','inifile.' + station + str(start+i-1)])

        print('Core ' + str(i) + ': Running swspectrometer inifile.' + station + str(start+i-1) + cn)         
        a = subprocess.Popen(['swspectrometer','inifile.'+ station + str(start+i-1),cn])
        a.wait()
        print('SWspec has finished correctly \n')
    if (program == '2'):
        print('Calculating the polynomials\n')
        cn = fn.replace('0001','000'+str(start+1-1))
        a = subprocess.Popen(['python','~/src/CalculateCppy.py',cn])
    else:
         print('Using SCtracker\n')
#         cn = fn.replace('001',str(start+1-1))
         s = open('inifile'+station).read()
         if ((i-1) < 9):
            s = s.replace('0001','000'+str(start+i-1))
         else:
            s = s.replace('0001','00'+str(start+i-1))
         f = open('inifile' + station + str(start+i-1),'w')
         f.write(s)
         f.close()
         a = subprocess.Popen(['/bin/cat','inifile' + station + str(start+i-1)])

         print('Core ' + str(i) + ': Running sctraker inifile' + station + str(start+i-1))
         a = subprocess.Popen(['sctracker','inifile'+station+str(start+i-1)])
         a.wait()
         print('SCtracker has completed the task \n');

print('Configuring the input parameters\n')

for arg in sys.argv:
 fn = arg

program = ask_program('Select: 1- SWspec 2-Calculate polynomials 3- SCtracker')
print(program)
if (program == 2):
   print('Nothing to ask')
else:
   station = ask_station('Which station are you processing? ')
   cores = ask_cores('How many of scans run in parallel? ')
   scans = ask_scans('How many scans do you want to process? ')
   start = ask_first_scan('Which is the first scan? ')
   print('\n')

for i in range (1,scans-start+1):
	p = Process(target=run_scans, args=('test',))
	p.start()
	p.join()
