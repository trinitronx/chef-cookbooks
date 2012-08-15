Description
===========

Configures a Digital Signage Client (currently Mac OS X 10.6 or 10.7).

Requirements
============

Platform
--------

* Mac OS X

Attributes
==========

Node attributes for this cookbook are logically separated into
different files. Some attributes must be defined via a role or node.


## default.rb

Attributes for the digital signage client software.

* `default['digital_signage']['client']['url']` - Location of the digital signage .air installer. For privacy, this needs to be set with a role or node attribute.

## settings.rb

# OS X Settings
* `default['digital_signage']['system_setup']['ssh']` - turn the SSH service on or off
* `default['digital_signage']['system_setup']['time_zone']` - "America/Los_Angeles" -- run `systemsetup -listtimezones` for valid options
* `default['digital_signage']['system_setup']['computer_sleep']` - number in minutes | "Never" | "Off"
* `default['digital_signage']['system_setup']['display_sleep']` - number in minutes | "Never" | "Off"
* `default['digital_signage']['system_setup']['disk_sleep']` - number in minutes | "Never" | "Off"
* `default['digital_signage']['system_setup']['restart_on_power_failure']` - On | Off
* `default['digital_signage']['system_setup']['restart_after_freeze']` - On | Off
* `default['digital_signage']['system_setup']['button_to_sleep_computer']` - On | Off

# For switching audio sources - https://github.com/downloads/deweller/switchaudio-osx/SwitchAudioSource.zip
* `default['digital_signage']['audio_switcher']['install_path']` - Location to install SwitchAudioSource
* `default['digital_signage']['audio_switcher']['download_path']` - URL without the file name of installer
* `default['digital_signage']['audio_switcher']['download_file']` - File name of the installer
* `default['digital_signage']['audio_switcher']['url']` - Full URL to download 
* `default['digital_signage']['audio_switcher']['output']` - Audio source selection -- run `SwitchAudioSource -a` for list of options


## adobe_air.rb

Attributes related to installing and setting up the Adobe Air environment. 
These may be pulled out into a separate cookbook at some point.

* `default['digital_signage']['adobe_air']['arh_install_path']` - Location to install arh
* `default['digital_signage']['adobe_air']['url']` - Location of the Adobe Air installer .dmg file

Usage
=====

Add `digital_signage` to your run list.
