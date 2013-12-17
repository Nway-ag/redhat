# Copyright (c) 2012 Red Hat, Inc. All rights reserved. This copyrighted material 
# is made available to anyone wishing to use, modify, copy, or
# redistribute it subject to the terms and conditions of the GNU General
# Public License v.2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# Author: Zhouping Liu <zliu@redhat.com> 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Example Makefile for RHTS                                          #
# This example is geared towards a test for a specific package       #
# It does most of the work for you, but may require further coding   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

TOPLEVEL_NAMESPACE=kernel
PACKAGE_NAME=vm/numad
RELATIVE_PATH=test_funcs

export TESTVERSION=1.1
export TEST=/$(TOPLEVEL_NAMESPACE)/$(PACKAGE_NAME)/$(RELATIVE_PATH)


# A phony target is one that is not really the name of a file.
# It is just a name for some commands to be executed when you
# make an explicit request. There are two reasons to use a
# phony target: to avoid a conflict with a file of the same
# name, and to improve performance.
.PHONY: all install download clean

# executables to be built should be added here, they will be generated on the system under test.
BUILT_FILES= 

# data files, .c files, scripts anything needed to either compile the test and/or run it.
FILES=$(METADATA) runtest.sh test_funcs.sh Makefile PURPOSE

run: build
	./runtest.sh

build: $(BUILT_FILES)
	chmod a+x ./runtest.sh
	chmod a+x ./test_funcs.sh

clean:
	rm -f *~ *.rpm $(BUILT_FILES)

# You may need to add other targets e.g. to build executables from source code
# Add them here:


# Include Common Makefile
include /usr/share/rhts/lib/rhts-make.include

# Generate the testinfo.desc here:
$(METADATA): Makefile
	@touch $(METADATA)
# Change to the test owner's name
	@echo "Owner:        Zhouping Liu <zliu@redhat.com>" > $(METADATA)
	@echo "Name:         $(TEST)" >> $(METADATA)
	@echo "Path:         $(TEST_DIR)"	>> $(METADATA)
	@echo "License:      GPLv2" >> $(METADATA)
	@echo "TestVersion:  $(TESTVERSION)"	>> $(METADATA)
	@echo "Description:  test numad user tool ">> $(METADATA)
	@echo "TestTime:     30m" >> $(METADATA)
	@echo "RunFor:       kernel glibc" >> $(METADATA)  
# add any other packages for which your test ought to run here
	@echo "Requires:     $(PACKAGE_NAME)" >> $(METADATA)  
	@echo "Requires:     autoconf" >> $(METADATA)
	@echo "Requires:     automake" >> $(METADATA)
	@echo "Requires:     git"      >> $(METADATA)
	@echo "Requires:     @development" >> $(METADATA)
	@echo "Requires:     numad" >> $(METADATA)
	@echo "Releases:     RHEL6 RHEL7" >> $(METADATA)
	@echo "Destructive:  no" >> $(METADATA)
	@echo "Confidential: no" >> $(METADATA)
	@echo "Priority:     Normal" >>$(METADATA)
