#   Description: Bug 800328 - CVE-2012-1179 kernel: thp:__split_huge_page() mapcount != page_mapcount BUG_ON() [rhel-6.3]
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
export TEST=/kernel/vm/regression/800328-pmd-race
export TESTVERSION=1.0


FILES=$(METADATA) runtest.sh Makefile PURPOSE do_race_panic.c do_race_2_panic.c make-crash.sh

.PHONY: all install download clean

run: $(FILES) build
	./runtest.sh

build: $(BUILT_FILES)
	chmod a+x make-crash.sh
	chmod a+x runtest.sh

clean:
	rm -fr *~ tests-*.rpm *.o $(BUILT_FILES) kernel-kernel-*.rpm

include /usr/share/rhts/lib/rhts-make.include

$(METADATA): Makefile
	@echo "Owner:           Zhiyou Liu <zhiliu@redhat.com>" > $(METADATA)
	@echo "Name:            $(TEST)" >> $(METADATA)
	@echo "TestVersion:     $(TESTVERSION)" >> $(METADATA)
	@echo "Path:            $(TEST_DIR)" >> $(METADATA)
	@echo "Description:     Bug 800328 - CVE-2012-1179 kernel: thp:__split_huge_page() mapcount != page_mapcount BUG_ON() [rhel-6.3]" >> $(METADATA)
	@echo "TestTime:        120m" >> $(METADATA)
	@echo "RunFor:          $(PACKAGE_NAME)" >> $(METADATA)
	@echo "Requires:        kernel" >> $(METADATA)
	@echo "Architectures:   i386 ppc64 s390x x86_64" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         RedHat Internal" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)
	# @echo "RhtsRequires:    kernel-kernel-ftrace-include" >> $(METADATA)
	@echo "Bug:             800328" >> $(METADATA)

	rhts-lint $(METADATA)
