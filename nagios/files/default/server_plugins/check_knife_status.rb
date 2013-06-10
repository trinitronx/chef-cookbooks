# This script must be executed using 'knife exec'
#
outdated_clients = Array.new
time_format = "%F %R"
# Default timeframe of 1 day
timeframe = Time.now.to_i - 86400

# Collect the last checkin time for all of the nodes in Chef
nodes.all do |n|
	last_checkin = Time.at(n['ohai_time']).to_i
	if (last_checkin < timeframe)
		outdated_clients.push("#{n.name}: #{Time.at(last_checkin).strftime(time_format)}")
	end
end

# Return the results to Nagios
if outdated_clients.empty?
	puts "OK: all Chef clients have checked in since #{Time.at(timeframe).strftime(time_format)}"
	# Prevents knife from trying to execute any command line arguments as addtional script files, see CHEF-1973
	exit 0
else
	puts "WARNING: Some Chef clients have not checked in recently: #{outdated_clients.join("; ")}"
	exit 1
end