maintainer       "Troy Ready"
maintainer_email "troy.ready@biola.edu"
license          "Apache 2.0"
description      "Installs/Configures splunk forwarders on Windows"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
depends          "windows"
%w{windows}.each do |os|
  supports os
end
