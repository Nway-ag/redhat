import sys, time, mmap, os
from subprocess import Popen, PIPE
import random

global mem_size

def info(msg):
	pid = os.getpid()
	print >> sys.stderr, "%s: %s" % (pid, msg)
	sys.stderr.flush()



def memory_loop(cmd = "a"):
	"""
	cmd may be:
		c: check memory
		else: touch memory
	"""
	c = 0
	for j in xrange(0, mem_size):
		if cmd == "c":
			if f[j<<12] != chr(j % 255):
				info("Data corruption")
				sys.exit(1)
		else:
			f[j<<12] = chr(j % 255)

while True:
	pid = os.fork()
	if (pid != 0):
		mem_size = random.randint(0, 56 * 4096)
		f = mmap.mmap(-1, mem_size << 12, mmap.MAP_ANONYMOUS|mmap.MAP_PRIVATE)
		memory_loop()
		memory_loop("c")
		f.close()
