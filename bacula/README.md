Bacula Cookbook
===============

Recipe for managing Bacula as a backup service.

Originally adapted from https://github.com/computerlyrik/chef-bacula

Requirements
------------

See dependencies in metadata.

Usage
-----

### Overview

This cookbook aims to automatically populate as many of the Bacula resource configurations as possible and minimize manual configuration. For example, client resources are automatically definied via a search for nodes with the `bacula_client` role (or whatever role you specify in your director node's `['bacula']['clientrole']` attribute) in their expanded run\_list.


### Client Setup

* Create a role titled `bacula_client` and include the `bacula::client` recipe in it (or assign a different role name via your director node's `['bacula']['clientrole']` attribute). Apply any appropriate attribute(s)/recipe(s) to the role to open TCP port 9102 in your firewall for your director node.
* Apply the bacula client role to each of your backup client nodes.
* On each backup client node, configure the `filesets`,`jobs`, and `schedules` attributes. E.g.:
```json
{
  "name":"bacula_client",
  "default_attributes": {
    "bacula": {
      "client": {
        "filesets": [
          {
            "ddrive": {
              "file": [
                "D:/"
              ]
            }
          }
        ],
        "jobs": [
          {
            "monthlydbbackup": {
              "pool": "BaculaFileSystem",
              "schedule": "dbmonthly",
              "fileset": "ddrive"
            }
          }
        ],
        "schedules": [
          {
            "dbdaily": [
              "Level=Full 2nd-5th sun at 01:05",
              "Level=Incremental mon-sat at 01:05"
            ]
          },
          {
            "dbmonthly": [
              "Level=Full 1st sun at 01:05"
            ]
          }
        ]
      }
    }
  }
}
```
Some general notes on this configuration syntax:
* While Bacula configuration is generally director-centric (i.e. elements like schedules & filesets are centrally defined on the director and re-used by different clients), the node attribute system used in this cookbook makes the fileset and schedule definitions specific to each node.
  - The director configuration will automatically prepend the applicable node name to each fileset/schedule definition.
* The `schedules` array contains hashes for each of the node's schedules. Each of the node's schedules is an array of `Run` statements -- see [the Bacula manual](http://www.bacula.org/5.2.x-manuals/en/main/main/Configuring_Director.html#SECTION001450000000000000000) for further details.
* The `filesets` array elements are arranged in mostly the same manner as the FileSet resources detailed in [the Bacula manual](http://www.bacula.org/5.2.x-manuals/en/main/main/Configuring_Director.html#SECTION001470000000000000000). Sensible defaults are automatically added as appropriate (e.g. VSS is automatically enabled on Windows nodes).
* `jobs` array members specifically look for the following 3 attributes:
  - fileset
    - Optional; defaults to the name of the job (e.g. in our example above we could omit the `fileset` under `monthlydbbackup` and rename the `ddrive` fileset to `monthlydbbackup`)
  - pool
    - Optional; defaults to `Default`.
  - schedule
    - Optional; only required if you wish for your job to run automatically
* Jobs are automatically defined as Incremental; override as desired in your `schedules`
* `jobs` array members can also have an `options` array specified, to allow arbitrary 'key = value' lines to be added to the job; e.g.:
```json
"jobs": [
  {
    "monthlydbbackup": {
      "pool": "BaculaFileSystem",
      "schedule": "dbmonthly",
      "fileset": "ddrive",
      "options": [
        {
          "Run Before Job": "\"echo test\""
        },
        {
          "Run After Job": "\"echo done\""
        }
      ]
    }
  }
]
```


### Storage Setup

* Determine your tape/autochanger/filesystem backup devices.
  - The command 'sudo lsscsi -g' can be useful for identifying tape/autochanger devices.
* Create a role titled 'bacula\_storage' and include the `bacula::storage` recipe in it (or assign a different role name via your director node's `['bacula']['storagerole']` attribute). Apply any appropriate attribute(s)/recipe(s) to the role to open TCP port 9103 in your firewall for your director node.
* Add attributes to your storage role to define your storage devices and apply the role to your storage node(s). E.g.:

```json
{
  "name":"bacula_storage",
  "default_attributes": {
    "bacula": {
      "sd": {
        "devices": [
          {
            "FileStorageDev": {
              "Media Type": "File",
              "Archive Device": "/backupstorage",
              "LabelMedia": "yes",
              "Random Access": "yes",
              "AutomaticMount": "yes",
              "Removable media": "no",
              "Device Type": "File"
            }
          },
          {
            "TapeDev": {
              "Media Type": "LTO5",
              "RemovableMedia": "yes",
              "RandomAccess": "no",
              "Archive Device": "/dev/nst1",
              "Maximum File Size": "5GB",
              "Autochanger": "yes",
              "AutomaticMount": "yes",
              "Alert Command": "\"sh -c 'tapeinfo -f %c |grep TapeAlert|cat'\""
            }
          }
        ],
        "autochangers": [
          {
            "MyChangerDev": {
              "Devices": [
                "TapeDev"
              ],
              "Changer Command": "/etc/bacula/scripts/mtx-changer %c %o %S %a %d",
              "Changer Device": "/dev/sg7"
            }
          }
        ]
      }
    }
  }
}

```
**NOTE:** Storage device hashes are mostly enumerated line by line into your bacula storage daemon configuration in the form of "key = value"; e.g. the above `FileStorageDev` device becomes:

```
Device {
  Name = FileStorageDev
  Media Type = File
  Archive Device = /backupstorage
  LabelMedia = yes
...etc
```
Autochangers however are listed under their own attribute, allowing them to be cross-referenced against any number of tape devices in them (listed in their `Devices` array).

### Director Setup

* Create a role titled 'bacula\_director' and include the `bacula::director` recipe in it (or assign a different role name in the `['bacula']['directorrole']` attribute on ALL of your nodes).
* Optionally, assign a `['bacula']['dir']['pools']` array to your director to specify your storage pools (if none are specified, only `Default` and `Scratch` pools will be defined).
  - Pools are enumerated "key = value"; e.g.:

```json
"bacula": {
  "dir": {
    "pools": [
      {
        "BaculaFileSystem": {
          "Volume Retention": "365 days",
          "Storage": "\"mystoragehost.mydomain.org-FileStorageDev-File\"",
          "Pool Type": "Backup",
          "Recycle Oldest Volume": "yes"
        }
      }
    ]
  }
}
```
**NOTE:** Because you are manually specifying your pool's `Storage` device (that was automatically defined in your director based on a Chef search of your storage devices), it needs to be done in the syntax of "`storagedaemonfqdn`-`storagedaemondevicename`-`storagedaemondevicemediatype`". Check your generated bacula-dir.conf's Storage devices if the exact value is unclear.



Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
 Copyright 2012, computerlyrik
 Copyright 2014, Biola University 

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

