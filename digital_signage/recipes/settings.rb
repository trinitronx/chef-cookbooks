#
# Cookbook Name:: digital_signage
# Recipe:: settings
#
# Copyright 2012, Biola University
#
# All rights reserved - Do Not Redistribute
#

# TURN SSH SERVICE ON|OFF
execute "turn-on-ssh" do
  #This command still works, but it is deprecated. Please use launchctl(8) instead.
  command "systemsetup -f -setremotelogin #{node['digital_signage']['system_setup']['ssh']}"
  not_if do
    result = `systemsetup -getremotelogin | sed 's/Remote Login: //'`.downcase.strip
    result == node['digital_signage']['system_setup']['ssh'].downcase
  end
end

# SET TIME ZONE
execute "set-time-zone" do
  command "systemsetup -settimezone '#{node['digital_signage']['system_setup']['time_zone']}'"
  not_if do
    result = `systemsetup -gettimezone | sed 's/Time Zone: //'`.strip 
    result == node['digital_signage']['system_setup']['time_zone']
  end
end

# GET ENERGY SAVER SETTINGS. 
sleep_settings = `systemsetup -getsleep`.split("\n") #Array order is Computer, Display, Disk
computer_sleep = sleep_settings[0].gsub(/Sleep: Computer |sleeps |after | minutes/, "")
display_sleep = sleep_settings[1].gsub(/Sleep: Display |sleeps |after | minutes/, "")
disk_sleep = sleep_settings[2].gsub(/Sleep: Disk |sleeps |after | minutes/, "")

# CONFIGURE ENERGY SAVER SETTINGS
## computer sleep settings
execute "set-sleep-settings" do
  command "systemsetup -setcomputersleep #{node['digital_signage']['system_setup']['computer_sleep']}"
  not_if do
    computer_sleep.downcase == node['digital_signage']['system_setup']['computer_sleep'].to_s.downcase
  end
end

## display sleep settings
execute "set-sleep-settings" do
  command "systemsetup -setdisplaysleep #{node['digital_signage']['system_setup']['computer_sleep']}"
  not_if do
    display_sleep.downcase == node['digital_signage']['system_setup']['display_sleep'].to_s.downcase
  end
end

## disk sleep settings
execute "set-disk-settings" do
  command "systemsetup -setharddisksleep #{node['digital_signage']['system_setup']['disk_sleep']}"
  not_if do
    disk_sleep.downcase == node['digital_signage']['system_setup']['disk_sleep'].to_s.downcase
  end
end

## Check Start up automatically after a power failure -- this isn't supported on some Macs
#unless `systemsetup -getrestartpowerfailure`.strip =~ /not supported/i
execute "set-restart-on-power-failure" do
  command "systemsetup -setrestartpowerfailure #{node['digital_signage']['system_setup']['restart_on_power_failure']}"
  #returns ["setrestartpowerfailure: On\n"]
  not_if do
    result =`systemsetup -getrestartpowerfailure | sed 's/Restart After Power Failure: //g'`.strip.downcase 
    result == node['digital_signage']['system_setup']['restart_on_power_failure'].to_s.downcase
  end
end
#end

## Configure restart on freeze setting
execute "set-restart-after-freeze-setting" do
  command "systemsetup -setrestartpowerfailure #{node['digital_signage']['system_setup']['restart_after_freeze']}"
  not_if do
    result =`systemsetup -getrestartfreeze | sed 's/Restart After Freeze: //g'`.strip.downcase 
    result == node['digital_signage']['system_setup']['restart_after_freeze'].to_s.downcase
  end
end

## Uncheck Allow power button to put the computer to sleep
execute "set-whether-power-button-can-sleep-computer" do
  command "systemsetup -setallowpowerbuttontosleepcomputer #{node['digital_signage']['system_setup']['button_to_sleep_computer']}"
  not_if do
    result = `systemsetup -getallowpowerbuttontosleepcomputer | sed 's/getAllowPowerButtonToSleepComputer: //g'`.strip.downcase 
    result == node['digital_signage']['system_setup']['button_to_sleep_computer'].to_s.downcase
  end
end

# Configure Screen Saver
execute "disable-screen-saver-password" do
  user "digsig"
  command "sudo osascript -e 'tell application \"System Events\" to set require password to wake of security preferences to false'"
  not_if do
    `defaults read com.apple.screensaver askForPassword`.strip == "0"
  end
end

execute "disable-screen-saver" do
  user "digsig"
  command "defaults -currentHost write com.apple.screensaver idleTime 0"
  not_if do
    `defaults -currentHost read com.apple.screensaver idleTime`.strip == "0"
  end
end

# Disable Bluetooth Setup Assistant on Startup-- Prevents OS X from automatically starting the Bluetooth Keyboard/Mouse window when no keyboard or mouse is detected
case node['platform_version'].to_f
when 10.6
  execute "disable-bluetooth-setup-assistant-for-10_6" do
    command "defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekHIDDevices 0" # TODO: For OS X 10.6
    not_if do
      `defaults read /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekHIDDevices`.strip == "0"
    end
  end
when 10.7
  execute "disable-BluetoothAutoSeekPointingDevice-for-10_7" do
    command "defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekPointingDevice -bool false" #For OS X 10.6
    not_if do
      `defaults read /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekPointingDevice`.strip == "0"
    end
  end

  execute "disable-BluetoothAutoSeekKeyboard-for-10_7" do
    command "defaults write /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekKeyboard -bool false" #For OS X 10.6
    not_if do
      `defaults read /Library/Preferences/com.apple.Bluetooth BluetoothAutoSeekKeyboard`.strip == "0"
    end
  end
end

# Disable Bluetooth
execute "disable-bluetooth" do
  command "defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState 0; sudo killall -SIGHUP blued"
  not_if {`defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState`.strip == "0"} #TODO: This fails if blued isn't running (ie. if someone unloaded /System/Library/LaunchDaemons/com.apple.blued.plist)
end

# Configure Audio Settings
## 1. install audio switcher -- TODO: move to separate cookbook
directory "#{node['digital_signage']['audio_switcher']['install_path']}" do
  owner "root"
  group "staff"
  mode "755"
  recursive true
end

# download the compressed version
audio_switcher_archive = "#{Chef::Config['file_cache_path']}/#{node['digital_signage']['audio_switcher']['download_file']}"
remote_file "#{audio_switcher_archive}" do
  source node['digital_signage']['audio_switcher']['url']
  notifies :run, "execute[install-audio-switcher]", :immediately
  action :nothing
end

# See if file has changed
http_request "HEAD #{node['digital_signage']['audio_switcher']['url']}" do
  message ""
  url node['digital_signage']['audio_switcher']['url']
  action :head
  if File.exists?(audio_switcher_archive)
    headers "If-Modified-Since" => File.mtime(audio_switcher_archive).httpdate
  end
  notifies :create, "remote_file[#{audio_switcher_archive}]", :immediately
end

# unpack the compressed version
execute "install-audio-switcher" do
  command "unzip #{audio_switcher_archive} -d #{node['digital_signage']['audio_switcher']['install_path']}"
  # not if executable exists already -- TODO: make this check that the version is right
  not_if do
    File.exists?("#{node['digital_signage']['audio_switcher']['install_path']}/SwitchAudioSource")
  end
end
 
## 2. Select HDMI
execute "select-audio-output" do
  path [node['digital_signage']['audio_switcher']['install_path']]
  command "SwitchAudioSource -s #{node['digital_signage']['audio_switcher']['output']}"
  not_if do
    `SwitchAudioSource -c`.strip == node['digital_signage']['audio_switcher']['output']
  end
end

# Configure Software Updates
execute "disable-software-update" do
  #user "digsig" # TODO: look into differences of 10.6 vs. 10.7. 10.7 says to run this as root.
  command "softwareupdate --schedule off"
  not_if do
    `softwareupdate --schedule`.strip == "Automatic check is off"
  end
end

# TODO: Turn off wireless

# TODO: Set VNC Access

# TODO: Set Dig Sig user to automatically login