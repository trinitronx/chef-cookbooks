# This script must be executed using 'knife exec'
#
outdated_clients = Array.new
time_format = "%F %R"
# Default timeframe of 1 day
timeframe = Time.now.to_i - 86400

# Get the environments the Nagios server is monitoring
environments = Array.new
search(:node, "roles:nagios_host") do |n|
	if n['nagios']['multi_environment_monitoring']
	  if n["nagios"].attribute?("environments")
	    environments.push(n["nagios"]["environments"])
	  else
	    environments.push("*")
	  end
	else
	  environments.push(n["chef_environment"])
	end
end

# Collect the last checkin time for all of the nodes in Chef in the given environment(s)
search(:node, "chef_environment:#{environments.join(" OR chef_environment:")}") do |n|
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