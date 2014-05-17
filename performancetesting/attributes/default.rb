case node['platform_version'].to_i
when 5
  default['performancetesting']['iozone_rpm']       = "http://pkgs.repoforge.org/iozone/iozone-3.408-1.el5.rf.x86_64.rpm"
  default['performancetesting']['iozone_checksum']  = "ab8c28058a022ae009f116e3968cc8211809cff53bb7370a338c3ba8ed6901ac"
when 6
  default['performancetesting']['iozone_rpm']       = "http://pkgs.repoforge.org/iozone/iozone-3.408-1.el6.rf.x86_64.rpm"
  default['performancetesting']['iozone_checksum']  = "80b7bcff432f34fe38e143df180e430c7635ddbdacc4383a81add86ed71f94e9"
end
