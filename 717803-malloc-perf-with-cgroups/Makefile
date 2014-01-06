#   Description: Bug 717803 - malloc performance suffers when using mem cgroups
#   Author: Zhiyou Liu <zhiliu@redhat.com>
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2011 - 2012 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export PACKAGE_NAME=kernel
export TEST=/kernel/vm/regression/717803-malloc-perf-with-cgroups
export TESTVERSION=1.0

FILES=$(METADATA) runtest.sh Makefile PURPOSE msrunner.sh malloc_seq.c

.PHONY: all install download clean

run: $(FILES) build
	./runtest.sh

build: $(BUILT_FILES)
	chmod a+x runtest.sh
	chmod a+x msrunner.sh

clean:
	rm -fr *~ tests-*.rpm *.o $(BUILT_FILES) kernel-kernel-*.rpm


include /usr/share/rhts/lib/rhts-make.include

$(METADATA): Makefile
	@echo "Owner:           Zhiyou Liu <zhiliu@redhat.com>" > $(METADATA)
	@echo "Name:            $(TEST)" >> $(METADATA)
	@echo "TestVersion:     $(TESTVERSION)" >> $(METADATA)
	@echo "Path:            $(TEST_DIR)" >> $(METADATA)
	@echo "Description:     Bug 717803 - malloc performance suffers when using mem cgroups" >> $(METADATA)
	@echo "TestTime:        60m" >> $(METADATA)
	@echo "RunFor:          $(PACKAGE_NAME)" >> $(METADATA)
	@echo "Requires:        kernel bc" >> $(METADATA)
	@echo "Architectures:   i386 ppc64 s390x x86_64" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         RedHat Internal" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)
	@echo "Bug:             717803" >> $(METADATA)

	rhts-lint $(METADATA)
