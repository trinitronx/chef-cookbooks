#
# Cookbook Name:: digital_signage
# Attributes:: digital_signage settings
#
#
# Copyright 2012, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['digital_signage']['system_setup']['ssh'] = "on" # on|off
default['digital_signage']['system_setup']['time_zone'] = "America/Los_Angeles" # run `systemsetup -listtimezones` for valid options
default['digital_signage']['system_setup']['computer_sleep'] = "Never" # number in minutes | "Never" | "Off"
default['digital_signage']['system_setup']['display_sleep'] = "Never" # number in minutes | "Never" | "Off"
default['digital_signage']['system_setup']['disk_sleep'] = "Never" # number in minutes | "Never" | "Off"
default['digital_signage']['system_setup']['restart_on_power_failure'] = "On" # On | Off
default['digital_signage']['system_setup']['restart_after_freeze'] = "Off" # On | Off
default['digital_signage']['system_setup']['button_to_sleep_computer'] = "Off" # On | Off

# For switching audio sources - https://github.com/downloads/deweller/switchaudio-osx/SwitchAudioSource.zip
default['digital_signage']['audio_switcher']['install_path'] = "/usr/local/bin"
default['digital_signage']['audio_switcher']['download_path'] = "https://github.com/downloads/deweller/switchaudio-osx"
default['digital_signage']['audio_switcher']['download_file'] = "SwitchAudioSource.zip"
default['digital_signage']['audio_switcher']['url'] = "#{default['digital_signage']['audio_switcher']['download_path']}/#{default['digital_signage']['audio_switcher']['download_file']}"
default['digital_signage']['audio_switcher']['output'] = "HDMI" #run `SwitchAudioSource -a` for list of options