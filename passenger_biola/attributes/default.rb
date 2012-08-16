default['passenger_biola']['passenger']['version'] = '3.0.15'
default['passenger_biola']['passenger']['prefix'] = '/opt/nginx'

default['passenger_biola']['nginx']['user'] = 'www-data'
default['passenger_biola']['nginx']['worker_processes'] = 2
default['passenger_biola']['nginx']['worker_connections'] = 1024
default['passenger_biola']['nginx']['rack_env'] = 'production'
default['passenger_biola']['nginx']['passenger_spawn_method'] = 'smart'
default['passenger_biola']['nginx']['passenger_max_pool_size'] = 6
default['passenger_biola']['nginx']['keepalive_timeout'] = 65
default['passenger_biola']['nginx']['ssl_certificate'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
default['passenger_biola']['nginx']['ssl_certificate_key'] = '/etc/ssl/private/ssl-cert-snakeoil.key'
default['passenger_biola']['nginx']['client_max_body_size'] = '20M'
default['passenger_biola']['nginx']['server_names'] = [] # in addition to node['fqdn']