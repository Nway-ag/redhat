#!/bin/bash -x

FAIL_COUNT=0
SYS_VERSION=7

function start_numad()
{
	echo "Start numad service"
	if [ $SYS_VERSION -eq 7 ]; then
		systemctl status numad.service | grep 'active (running)' > /dev/null
	else
		service numad status | grep 'running' > /dev/null
	fi

	if [ $? -ne 0 ]; then
		if [ $SYS_VERSION -eq 7 ]; then
			systemctl start numad.service
		else
			service numad start
		fi
		if [ $? -ne 0 ]; then
			echo "Failed: start numad service"
			FAIL_COUNT=$((FAIL_COUNT+1))
			return 1
		fi
	fi

	return 0
}

function stop_numad()
{
	echo "Stop numad service"
	if [ $SYS_VERSION -eq 7 ]; then
		systemctl stop numad.service
	else
		service numad stop
	fi
	if [ $? -ne 0 ]; then
		echo "Failed: stop numad service"
		FAIL_COUNT=$((FAIL_COUNT+1))
		return 1
	fi

	return 0
}

function test_args_i()
{
	for i in `seq 10`; do
		echo y | cp /var/log/numad.log /var/log/numad.log_pri
		numad -i $i:$((i+2))
		sleep 1
		diff /var/log/numad.log_pri /var/log/numad.log > log_diff
		echo "check numad.log, expect log: Changing interval to $i:$((i+2))"
		cat log_diff | grep "Changing interval to $i:$((i+2))" > /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed: comand numad -i $i:$((i+2))"
			FAIL_COUNT=$((FAIL_COUNT+1))
			return 1
		fi
	done

	return 0
}

function test_args_l()
{
	for i in 5 6 7; do
		echo y | cp /var/log/numad.log /var/log/numad.log_pri
		numad -l $i
		sleep 1
		diff /var/log/numad.log_pri /var/log/numad.log > log_diff
		echo "check numad.log, expect log: Changing log level to $i"
		cat log_diff | grep "Changing log level to $i" > /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed: command numad -l $i"
			FAIL_COUNT=$((FAIL_COUNT+1))
			return 1
		fi

		# check LOG_INFO numad -l 6
		if [ $i -eq 6 ]; then
			echo y | cp /var/log/numad.log /var/log/numad.log_pri
			sleep 20
			diff /var/log/numad.log_pri /var/log/numad.log > log_diff
			echo "check numad.log, expect log: MBs_total XXX, MBs_free XXX ..."
			cat log_diff | grep "MBs_total" | grep "MBs_free" > /dev/null
			if [ $? -ne 0 ]; then
				echo "Failed: LOG_INFO can't work fine"
				FAIL_COUNT=$((FAIL_COUNT+1))
				return 1
			fi
		fi
	done 
	return 0
}

function test_args_w()
{
	for i in `seq 4`; do
		echo y | cp /var/log/numad.log /var/log/numad.log_pri
		numad -w $i:128
		sleep 1
		diff /var/log/numad.log_pri /var/log/numad.log > log_diff
		echo "check numad.log, expect log: Getting NUMA pre-placement advice ..."
		cat log_diff | grep "Getting NUMA pre-placement advice for $i CPUs and 128 MBs" > /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed: command numad -w $i:128"
			FAIL_COUNT=$((FAIL_COUNT+1))
			return 1
		fi
	done
	return 0
}

function test_args_u()
{
	for i in `seq 5 10`; do
		echo y | cp /var/log/numad.log /var/log/numad.log_pri
		numad -u $((i*10))
		sleep 1
		diff /var/log/numad.log_pri /var/log/numad.log > log_diff
		echo "check numad.log, expect log: Changing target utilization to $((i*10))"
		cat log_diff | grep "Changing target utilization to $((i*10))" > /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed: command numad -u $((i*10))"
			FAIL_COUNT=$((FAIL_COUNT+1))
			return 1
		fi
	done
	return 0
}

function set_default()
{
	numad -i 5:10
	numad -l 5
	numad -u 85
}

function check_sys_version()
{
	SYS_VERSION=`cat /etc/redhat-release | cut -d ' ' -f 7 | cut -d '.' -f 1`
	if [ "test$SYS_VERSION" = "test" ]; then
		SYS_VERSION=7
	fi
}

function main()
{
	# create an empty tmp log file to avoid unexpected fail
	touch /var/log/numad.log_pri

	check_sys_version

	start_numad

	set_default
	test_args_i

	set_default
	test_args_l

	set_default
	test_args_w

	set_default
	test_args_u

	stop_numad

	if [ $FAIL_COUNT -ne 0 ]; then
		echo "Failed: there are $FAIL_COUNT cases failed"
		return 1
	fi
	return 0
}

main
