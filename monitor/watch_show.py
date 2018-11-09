#!/usr/bin/env python
#-*- coding:UTF-8 -*-
#read data from datafile and plot cpu/mem

import os
import sys
import matplotlib
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
import linecache

timestamp=sys.argv[1]

#lines to skip
nskip=2
#colums to plot
cpuCols=[2,3]
memCols=[2,3]
diskCols=[2,3]
#special date in cpuCols
idleIdx=2
#path of data files
filepath=os.getcwd()

#data files to plot
files=[files for files in os.listdir(filepath) if (files.find(timestamp) != -1)]

def cutfiledata(file,start='00:00',end='00:00'):
	with open(file, 'r') as f:
		n = 1
		lines = f.readlines()
		if end == '00:00' or start == '00:00':
			st = lines[0].split()[0]
			et = lines[-1].split()[0]
			sln = 1
			eln = len(lines) - 2
			return st, et, sln, eln, lines
		else:
			for i in lines:
				if start in i:
					st = i.split()[0]
					sln = lines.index(i) + 1
					break
			for i in lines:
				if end in i:
					et = i.split()[0]
					eln = n
				n += 1
			return st, et, sln, eln, lines

#def readData function
def readData(lines, colsToPlot, sln, eln):
	colsToPlot = [ x-1 for x in colsToPlot ]

	data = []
	for j in range(len(colsToPlot)):
		data.append([])

	for i in range(sln+1, eln+2):
		for j in range(len(colsToPlot)):
			line = lines[i].split()
			data[j].append(int(line[colsToPlot[j]][:-1]))

	# print len(data[0])
	return data

if len(sys.argv) == 4:
	starttime = sys.argv[2]
	endtime = sys.argv[3]
else:
	starttime = '00:00'
	endtime = '00:00'

#read data from files and init lists with readData function
for datafile in files:
	if(datafile.find("cpu_status") != -1):
		cst, cet, csln, celn, lines = cutfiledata(datafile, starttime, endtime)
		cpudata=readData(lines, cpuCols, csln, celn)
	if(datafile.find("mem_status") != -1):
		mst, met, msln, meln, lines = cutfiledata(datafile, starttime, endtime)
		memdata=readData(lines, memCols, msln, meln)
	if(datafile.find("disk_status") != -1):
		dst, det, dsln, deln, lines = cutfiledata(datafile, starttime, endtime)
		diskdata=readData(lines, diskCols, dsln, deln)

plt.figure(1)
cpu_use = map(lambda x,y:int(x)+ int(y),cpudata[0],cpudata[1])
plt.plot(cpu_use)
plt.ylim((0, 100))
plt.xlim((0, celn - csln))
plt.xlabel('Time')
plt.ylabel('cpu use %')
plt.xticks([0, celn - csln], [cst, cet])
# plt.legend(['cpu %'])
#plt.show()
plt.savefig('./cpu.png')

plt.figure(2)
plt.plot(memdata[0])
plt.plot(memdata[1])
plt.xlim((0, meln - msln))
plt.ylim(ymin=0)
plt.xlabel('Time')
plt.ylabel('memory use Mb')
plt.legend(['memory total','memory use'])
plt.xticks([0, meln - msln], [mst, met])
plt.savefig('./mem.png')


plt.figure(3)
plt.plot(diskdata[0])
plt.plot(diskdata[1])
plt.xlim((0, deln - dsln))
plt.ylim(ymin=0)
plt.xlabel('Time')
plt.ylabel('disk use Kb')
plt.legend(['read','write'])
plt.xticks([0, deln - dsln], [dst, det])
plt.savefig('./disk.png')

