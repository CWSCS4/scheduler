#!/usr/bin/env python
#Uncomment above line for executability under UNIX
#This is for Windows, but will work under UNIX
#Alex Grant

spec = []
f = open( 'spec.spc' )
for line in f:
	if line[0] is not '#':
		spec.append( line )

for x in range( len( spec ) ):
	spec[x] = spec[x][:len( spec[x] ) -1]

if __name__ == '__main__':
	import os
	os.system( 'java org.commschool.scheduler.GenerateSpecification ' + spec[0] + ' > ' + spec[1] )
	os.system( 'generateInitialSchedule -s ' + spec[1] + ' > ' + spec[2] )
	os.system( 'printSchedule -s ' + spec[1] + ' -t ' + spec[2] + ' > ' + spec[3] )
	print "Press Control-C to interrupt"
	os.system( 'simulatedAnnealing ' + spec[4] + ' -s ' + spec[1] + ' -t ' + spec[2] + ' -o ' + spec[5] )