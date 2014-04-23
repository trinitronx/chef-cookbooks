name             'iptables-biola'
maintainer       'Biola University'
maintainer_email 'jared.king@biola.edu'
license          'Apache 2.0'
description      'Uses LWRP in iptables-ng cookbook to configure firewall rules'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'
depends          'iptables-ng'