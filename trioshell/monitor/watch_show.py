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
import random



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
            j = 1
            for i in lines:
                if i.startswith(start):
                    st = i.split()[0]
                    sln = j - 1
                    break
                j += 1
            j = sln
            for i in lines[sln:]:
                
                if i.startswith(end):
                    et = i.split()[0]
                    eln = j
                j += 1
            return st, et, sln, eln, lines[sln:eln]

#def readData function
def readData(lines, colsToPlot, sln, eln):
    colsToPlot = [ x-1 for x in colsToPlot ]

    data = []
    for j in range(len(colsToPlot)):
        data.append([])

    for i in lines:
        for j in range(len(colsToPlot)):
            l = i.split()
            data[j].append(int(l[colsToPlot[j]][:-1]))

    return data

def ppp(proc_memdata, procname, kedu_num, kedu_time):
    j = random.randint(100,9999)
    plt.figure(j)
    plt.plot(proc_memdata[0])
    plt.xlim((0, meln - msln))
    plt.ylim(ymin=0)
    plt.xlabel('Time')
    plt.ylabel('memory use Mb')
    plt.legend(['memory use'])
    plt.xticks(kedu_num, kedu_time, fontsize=6)
    plt.savefig('./' + procname + '.png', dpi=200)

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print "usage: python %s 20181108 10:00 12:00" % sys.argv[0] 
        sys.exit()

    timestamp=sys.argv[1]

    #lines to skip
    nskip=2
    #colums to plot
    cpuCols=[2,3]
    memCols=[2,3]
    diskCols=[2,3]
    process_memCols=[2]
    #special date in cpuCols
    idleIdx=2
    #path of data files
    filepath=os.getcwd()

    #data files to plot
    files=[files for files in os.listdir(filepath) if (files.find(timestamp) != -1)]

    if not files:
        sys.exit()

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
        Time = [ i.split()[0] for i in lines ]
        kedu_num = [0, len(Time)/5, len(Time)/5*2, len(Time)/5*3, len(Time)/5*4, len(Time)-1]
        kedu_time = [Time[0], Time[len(Time)/5], Time[len(Time)/5*2], Time[len(Time)/5*3], Time[len(Time)/5*4], Time[len(Time)-1] ]
        if(datafile.find("mem_status") != -1):
            mst, met, msln, meln, lines = cutfiledata(datafile, starttime, endtime)
            memdata=readData(lines, memCols, msln, meln)
        if(datafile.find("disk_status") != -1):
            dst, det, dsln, deln, lines = cutfiledata(datafile, starttime, endtime)
            diskdata=readData(lines, diskCols, dsln, deln)
        if(datafile.find("CRS_brain_server") != -1):
            mst, met, msln, meln, lines = cutfiledata(datafile, starttime, endtime)
            CRS_brain_server_memdata=readData(lines, process_memCols, msln, meln)
            ppp(CRS_brain_server_memdata, "CRS_brain_server", kedu_num, kedu_time)
        if(datafile.find("NLU_server") != -1):
            mst, met, msln, meln, lines = cutfiledata(datafile, starttime, endtime)
            NLU_server_memdata=readData(lines, process_memCols, msln, meln)
            ppp(NLU_server_memdata, "NLU_server", kedu_num, kedu_time)
        if(datafile.find("task_flow_server") != -1):
            mst, met, msln, meln, lines = cutfiledata(datafile, starttime, endtime)
            task_flow_server_memdata=readData(lines, process_memCols, msln, meln)
            ppp(task_flow_server_memdata, "task_flow_server", kedu_num, kedu_time)
        if(datafile.find("query_parser_server") != -1):
            mst, met, msln, meln, lines = cutfiledata(datafile, starttime, endtime)
            query_parser_server_memdata=readData(lines, process_memCols, msln, meln)
            ppp(query_parser_server_memdata, "query_parser_server", kedu_num, kedu_time)

    plt.figure(1)
    cpu_use = map(lambda x,y:int(x)+ int(y),cpudata[0],cpudata[1])
    plt.plot(cpu_use)
    plt.ylim((0, 100))
    plt.xlim((0, celn - csln))
    plt.xlabel('Time')
    plt.ylabel('cpu use %')
    plt.xticks(kedu_num, kedu_time, fontsize=6)
    plt.legend(['cpu %'])
    plt.show()
    plt.savefig('./cpu.png', dpi=200)

    plt.figure(2)
    plt.plot(memdata[0])
    plt.plot(memdata[1])
    plt.xlim((0, meln - msln))
    plt.ylim(ymin=0)
    plt.xlabel('Time')
    plt.ylabel('memory use Mb')
    plt.legend(['memory total','memory use'])
    plt.xticks(kedu_num, kedu_time, fontsize=6)
    plt.savefig('./mem.png', dpi=200)

    plt.figure(3)
    plt.plot(diskdata[0])
    plt.plot(diskdata[1])
    plt.xlim((0, deln - dsln))
    plt.ylim(ymin=0)
    plt.xlabel('Time')
    plt.ylabel('disk use Kb')
    plt.legend(['read','write'])
    plt.xticks(kedu_num, kedu_time, fontsize=6)
    plt.savefig('./disk.png', dpi=200)
