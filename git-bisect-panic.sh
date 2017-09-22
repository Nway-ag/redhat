#!/bin/bash

kernel_src=/root/kernel
test_src=/root/testcase
bisect_root=/root/bisect
bisect_flag=$bisect_root/bisecting_flag
runtest_flag=$bisect_root/runtest_flag
log_file=$bisect_root/bisect.log

initial_bad="$1"
initial_good="$2"

compile_kernel()
{
	yes "" | make oldconfig && make -j $(($(lscpu -p=cpu -b | grep -v "#" | wc -l)*2)) && \
		make modules_install install || \
		{ echo "Build kernel failed | tee -a $log_file"; rm -f $bisect_flag; exit 2; }
	new_kernel=`find /boot -name "vmlinu*" ! -name "vmlinu*old" -type f -cnewer $kernel_src/.config`
	if [ "$new_kernel" == "" ]; then
		echo "No new kernel found" | tee -a $log_file
		rm -f $bisect_flag
		exit 3
	fi
	echo "Set $new_kernel as default" | tee -a $log_file
	grubby --set-default=$new_kernel
}

run_test()
{
	local i=0
	pushd $test_src
	while [ $i -lt 50 ]; do
		make run # should be replaced here
		((i++))
	done
	popd
}

# reboot in 3 seconds after panic/oops
echo 3 > /proc/sys/kernel/panic

if [ ! -f $kernel_src/.git/config ]; then
	git clone https://github.com/torvalds/linux $kernel_src
fi

cd $kernel_src

if [ ! -f $bisect_flag ]; then
	# no bisect running, start one
	if [ "$initial_good" == "" ]; then
		echo "No initial good commit specified"
		exit 1
	fi
	if [ "$initial_bad" == "" ]; then
		initial_bad=HEAD
	fi
	mkdir -p $bisect_root
	rm -f $log_file
	touch $log_file
	touch $bisect_flag
	echo "git bisect start $initial_bad $initial_good" | tee -a $log_file
	git bisect start $initial_bad $initial_good | tee -a $log_file
	compile_kernel
	touch $runtest_flag
	sync

	echo /root/git-bisect-panic.sh >> /etc/rc.d/rc.local
	chmod +x /etc/rc.d/rc.local
	systemctl enable rc-local.service

	reboot
else
	if [ -f $runtest_flag ]; then
		rm -f $runtest_flag
		sync
		run_test
		
		# no panic, test passed
		git bisect good | tee -a $log_file
	else
		# paniced in run_test, just booted into bad kernel
		git bisect bad | tee -a $log_file
	fi

	if grep "the first bad commit" $log_file; then
		echo -e "\n=== First bad commit found! ===\n"
		git bisect log | tee -a $log_file
		rm -f $bisect_flag
		exit 0
	fi

	# Need continue bisect
	compile_kernel
	touch $runtest_flag
	sync
	reboot
fi
