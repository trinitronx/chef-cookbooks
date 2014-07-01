#!/opt/chef/embedded/bin/ruby
require 'optparse'
require 'net/http'
require 'json'

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: check_php_fpm.rb [options]"

  options[:ignore] = Array.new
  opts.on("-i", "--ignore POOLS", "A comma separated list of pools to ignore") do |i|
    options[:ignore] = i.split(',')
  end

  options[:port] = ''
  opts.on("-p", "--port VALUE", "The port number for the PHP-FPM status page") do |p|
    options[:port] = ':' + p
  end

  options[:warning] = 50
  opts.on("-w", "--warning VALUE", Integer, "The percent of active processes to result in a warning status") do |w|
    options[:warning] = w
  end

  options[:critical] = 75
  opts.on("-c", "--critical VALUE", Integer, "The percent of active processes to result in a critical status") do |c|
    options[:critical] = c
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

# Initial check values
warning_state = false
critical_state = false
status_details = Array.new

# Parse php-fpm configuration for a list of pools
pools = Array.new
Dir.chdir "/etc/php5/fpm/pool.d"
Dir.glob("*.conf") do |conf|
	pool = Hash.new
	pool['name'] = conf.sub(/\.conf$/, '')

	unless options[:ignore].include? pool['name']
		f = File.open(conf, "r")
		f.each do |line|
			if line =~ /^pm\.status_path/
				pool['status_path'] = line.split('=')[1].strip
			elsif line =~ /^pm\.max_children/
				pool['max_children'] = line.split('=')[1].strip.to_i
			end
		end

		pools << pool if pool['status_path']
	end
end

# Get status for each pool and see if the values are over the warning or critical thresholds
pools.each do |pool|
	uri = URI("http://localhost#{options[:port]}#{pool['status_path']}?json")
	response = Net::HTTP.get(uri)
	pool_status = JSON.parse(response)

	percent_used = (pool_status['active processes'].to_f / pool['max_children']) * 100
	if percent_used.ceil > options[:critical]
		critical_state = true
		status_details << "Pool [#{pool['name']}] CRITICAL: #{percent_used.ceil}% of pool is active"
	elsif percent_used.ceil > options[:warning]
		warning_state = true
		status_details << "Pool [#{pool['name']}] WARNING: #{percent_used.ceil}% of pool is active"
	else
		status_details << "Pool [#{pool['name']}]: #{percent_used.ceil}% of pool is active"		
	end
end

# Return values
status_details.each do |d|
	puts d
end

if critical_state
	exit 2
elsif warning_state
	exit 1
else
	exit 0
end