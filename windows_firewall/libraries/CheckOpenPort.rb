# Credit here belongs to http://sherwoodbase.wordpress.com/2013/02/13/how-to-open-firewall-port-on-chef-windwos/
require 'socket'
require 'timeout'

module CheckOpenPort
def CheckOpenPort.is_port_open?(ip, port)
begin
Timeout::timeout(1) do
begin
s = TCPSocket.new(ip, port)
s.close
return true
rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
return false
end
end
rescue Timeout::Error
end

return false
end
end
