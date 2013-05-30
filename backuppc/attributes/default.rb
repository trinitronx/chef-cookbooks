default['backuppc']['users_databag_group'] = "sysadmin"
default['backuppc']['enable_ssl'] = true
default['backuppc']['sslcertfile'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default['backuppc']['sslkeyfile'] = "/etc/ssl/private/ssl-cert-snakeoil.key"
override['apache']['listen_ports'] = [ 80,443 ]
