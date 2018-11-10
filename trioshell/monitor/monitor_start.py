#!/usr/bin/env python

import psutil
import sys
import time
import os

global Date
global Time

Date = time.strftime("%Y%m%d", time.localtime())
Time = time.strftime("%H:%M:%S", time.localtime())

def cpu_monitor():
    cpu = psutil.cpu_times_percent(0.5)
    return '%s \t %d%% \t %d%% \t %d%% \t %d%%' % (Time, cpu.user, cpu.system, cpu.iowait, cpu.idle)

def mem_monitor():
    mem = psutil.virtual_memory()
    return "%s \t %dM \t %dM \t %dM" % (Time, mem.total/1024/1024, mem.used/1024/1024, mem.available/1024/1024)

def disk_monitor():
    disk = psutil.disk_io_counters()
    read_bytes = disk.read_bytes
    write_bytes = disk.write_bytes
    time.sleep(1)
    disk = psutil.disk_io_counters()
    read_bytes = disk.read_bytes - read_bytes
    write_bytes = disk.write_bytes - write_bytes
    return "%s \t %dK \t %dK" % (Time, read_bytes/1024, write_bytes/1024)

def chinamobile_process_monitor():
    home = os.environ['HOME']
    if not os.path.exists(home + '/ChinaMobile/Shell/server.pid'):
        print "server.pid do not exist."
        return "server.pid do not exist."
    with open(home + '/ChinaMobile/Shell/server.pid', 'r') as f:
        for i in f:
            if len(i.strip()) == 0:
                pass
            pid, pname = i.strip().split()
            pmem = psutil.Process(int(pid)).memory_info().rss / 1024 /1024
            with open("./%s.%s.txt" % (pname, Date), 'a') as pinfofile:
                pinfofile.write("%s \t %dM" % (Time, pmem) + '\n')

if __name__ == '__main__':
    with open("./cpu_status.%s.txt" % Date, 'a') as cpufile:
        cpustat = cpu_monitor()
        cpufile.write(cpustat + '\n')

    with open("./mem_status.%s.txt" % Date, 'a') as memfile:
        memstat = mem_monitor()
        memfile.write(memstat + '\n')

    with open("./disk_status.%s.txt" % Date, 'a') as diskfile:
        diskstat = disk_monitor()
        diskfile.write(diskstat + '\n')

    chinamobile_process_monitor()
