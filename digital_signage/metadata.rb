maintainer       "Biola University"
maintainer_email "jeff.silzer@biola.edu"
license          "All rights reserved"
description      "Setups up a Biola Digital Signage Client"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.7"

recipe "digital_signage", "Installs the Biola digital signage .air application. Includes digital_signage::settings and digital_signage::adobe_air."
recipe "digital_signage::settings", "Configures the OS X environment for a digital signage computer."
recipe "digital_signage::adobe_air", "Installs Adobe Air."

%w{ mac_os_x }.each do |os|
  supports os
end