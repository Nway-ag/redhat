### Makefile --- module

## Author: bbboson@gmail.com
## Version: $Id: Makefile,v 0.0 2013/10/14 07:02:26 Madper Exp $
## Keywords: 
## X-URL: 

obj-m := nvram-gc.o
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
default:
	make -C $(KDIR) SUBDIRS=$(PWD) modules
clean:
	rm -f *.mod.c *.ko *.o
