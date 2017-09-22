#!/usr/bin/ruby
# - blocksize
require 'base64'
$runtime = ENV['runtime'] || (ARGV[0] || 300).to_i
$nr_threads = ENV['nr_threads'] || ENV['nr_cpu']
$blocksize = (ENV['blocksize'] || 128).to_i
$pigz_options = "-p #{$nr_threads}" if $nr_threads
F_LINUX_SPECIFIC_BASE = 1024
F_SETPIPE_SZ = F_LINUX_SPECIFIC_BASE + 7
REPEAT = 5
MB = (1<<20)
$data = Base64.encode64 Random.new(1234).bytes(MB)
$iterations = 0
def run_once(runtime)
	time = Time.now
	io = IO.popen("pigz -c -b #{$blocksize} #{$pigz_options} > /dev/null", 'w')
	io.fcntl(F_SETPIPE_SZ, MB)
	i = 0
	begin
		io.puts $data
		i += 1
		now = Time.now
	end while now - time < runtime
	io.close
	puts "# #{i} iterations in #{now - time} seconds"
	$iterations += i
end
def run_test
	1.upto(REPEAT) do
		run_once $runtime / REPEAT
	end
end
start_time = Time.now
run_test
seconds = Time.now - start_time

puts "throughput: #{MB * $iterations / seconds}"
 



