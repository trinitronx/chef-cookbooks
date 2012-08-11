maintainer        "Biola University"
maintainer_email  "jeff.silzer@biola.edu"
license           "Apache 2.0"
description       "Originally from Opscode Cookbooks. Installs memcached and provides a define to set up an instance of memcache via runit"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
depends           "runit"

recipe "memcached", "Installs and configures memcached"

%w{ ubuntu debian redhat fedora centos }.each do |os|
  supports os
end

attribute "memcached/memory",
  :display_name => "Memcached Memory",
  :description => "Memory allocated for memcached instance",
  :default => "64"

attribute "memcached/port",
  :display_name => "Memcached Port",
  :description => "Port to use for memcached instance",
  :default => "11211"

attribute "memcached/user",
  :display_name => "Memcached User",
  :description => "User to run memcached instance as",
  :default => "nobody"

attribute "memcached/listen",
  :display_name => "Memcached IP Address",
  :description => "IP address to use for memcached instance",
  :default => "127.0.0.1"

attribute "memcached/verbose",
  :display_name => "Memcached Verbose On|Off",
  :description => "True or False to set -v in the memcached conf file",
  :default => "false"