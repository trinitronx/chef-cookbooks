data_bag_name = node['ssl_certs_biola']['data_bag_name']
key_dir = node['ssl_certs_biola']['key_dir']
cert_dir = node['ssl_certs_biola']['cert_dir']

cert_names = node['ssl_certs_biola']['cert_names'] || []

cert_names.each do |cert_name|
  cert = Chef::EncryptedDataBagItem.load(data_bag_name, cert_name)  

  # Create key file
  file File.join(key_dir, "#{cert_name}.key") do
    owner 'root'
    group 'root'
    mode 0600
    action :create
    content cert['key']
  end

  # Create cert file
  file File.join(cert_dir, "#{cert_name}.crt") do
    owner 'root'
    group 'root'
    mode 0644
    action :create
    content cert['cert']
  end
end