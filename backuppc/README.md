Description
===========
Manages the deployment and configuration of the BackupPC enterprise backup software.

Primary testing is performed on a Ubuntu server, with Linux & Windows clients. Pull requests are welcome for improvements or extending support to other systems


Requirements
============


Attributes
==========

Server configuration:

```
['backuppc']
  ['enable_ssl'] // boolean value for the webserver configuration; defaults to true
  ['users_databag_group'] // string to specify which group members should be granted administrative access to the webui (searchs the 'users' data bag). Defaults to sysadmin
```


Client configuration:

```
['backups']
  ['backuppc']
    ['backupowner'] // user that will own the backups and receive emails (defaults to backuppc)
    ['otherbackupusers'] // additional backuppc users that can use / restore files (defaults to blank)
    ['user']: // service account to perform the backups backuppc (defaults to backuppc)
    ['usesudo'] // boolean for sudo use with rsync, etc ; defaults to true
    ['XferMethod'] // rsync, sftp, smb, etc -- defaults to rsync
    TODO - Additional BackupPC options to be added:
    ['FullPeriod'] // optional; see http://backuppc.sourceforge.net/faq/BackupPC.html#_conf_fullperiod_
    ['FullKeepCnt'] // optional; see http://backuppc.sourceforge.net/faq/BackupPC.html#_conf_fullkeepcnt_
    ['BlackoutPeriods'] // optional; see http://backuppc.sourceforge.net/faq/BackupPC.html#_conf_blackoutperiods_
    ['IncrKeepCnt'] // optional; see http://backuppc.sourceforge.net/faq/BackupPC.html#_conf_incrkeepcnt_
    ['IncrPeriod'] // optional; see http://backuppc.sourceforge.net/faq/BackupPC.html#_conf_incrperiod_
  ['targets'] 
    [

    {
    "/srv/stuff": {

      "backupservice" // "backuppc" or "bacula"  -- defaults to backuppc; no need to change this unless using an additional backup service
      

      }
    },

    ...


    ]
```

Data Bags
=========

For systems that are not managed with chef, a databag titled "backup_targets_nonchef" can be used to manually configure their backups. The json format is the same as the normal attribute configuration (see above):

```
['raw_data']
  ['hostname'] // the hostname of the system to backup
  ['backups']
    ['backuppc']
      ['backupowner'] ...
    ...
    ['targets'] 
      [
      {
      "/srv/stuff": {
        ...
        }
      },
      ...
      ]
```

Usage
=====

Apply the backuppc::server recipe to your BackupPC Server. The BackupPC web admin console will then be available at https://server/backuppc


