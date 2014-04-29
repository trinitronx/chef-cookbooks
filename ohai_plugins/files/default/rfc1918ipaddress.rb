Ohai.plugin(:Rfc1918ipaddress) do
  provides "ipaddress"
  depends "ipaddress", "network/interfaces"
  collect_data(:default) do
    addresses = network['interfaces'].map { |name, i| i['addresses'].keys }.flatten
    ipaddress addresses.grep(/^10\.|^172\.1[6-9]\.|^172\.2\d\.|^172\.3[0-1]\.|^192\.168/).first
  end
end
