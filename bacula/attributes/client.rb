# Used in package installation; see Windows cookbook
default['bacula']['client']['win_displayname'] = "Bacula"

default['bacula']['client']['win_url'] = "http://sourceforge.net/projects/bacula/files/Win32_64/5.2.10/bacula-win64-5.2.10.exe/download"
default['bacula']['client']['win_checksum'] = "c29af565845a323871caf8aaa90ad38d10d8e0b8bab1903f8cdbce801659fe8a"
default['bacula']['client']['win_url_32bit'] = "http://sourceforge.net/projects/bacula/files/Win32_64/5.2.10/bacula-win32-5.2.10.exe/download"
default['bacula']['client']['win_checksum_32bit'] = "09d6dcc6287ac3f5ba3af4f67cbe9611124e1f49de7786c1eaa02ca069a6e182"

case node['platform']
when 'windows'
  default['bacula']['client']['working_directory'] = 'C:\\\\Program Files\\\\Bacula\\\\working'
  default['bacula']['client']['pid_directory'] = 'C:\\\\Program Files\\\\Bacula\\\\working'
  default['bacula']['client']['max_con_jobs'] = '10'
else
  default['bacula']['client']['working_directory'] = '/var/lib/bacula'
  default['bacula']['client']['pid_directory'] = '/var/run/bacula'
  default['bacula']['client']['max_con_jobs'] = '20'
end
