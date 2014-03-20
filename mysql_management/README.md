Description
===========

This cookbook automates the creation of MySQL databases, users, and backups. Configuration is stored in data bags and the resources in Opscode's database cookbook are leveraged to create the databases and users.

Requirements
============

Currently only tested on Ubuntu 12.04, but should work on any modern Ubuntu distribution.

Recipes
=======

default.rb
----------

Loops through all of the items in the `mysql_databases` and `mysql_users` databags. For each of the database items, it creates a database in MySQL along with an optional set of dedicated users. For each of the user items, it creates a user in MySQL if permissions have been defined for one or more databases.

Usage
=====

Server setup
------------

Create `mysql_databases` and `mysql_users` data bags in Chef to hold configuration. Items in the `mysql_databases` data bag should be in the following format:

    {
      "id": "database_name",
      "encoding": "utf8",
      "backup_schedule": "daily",
      "backup_rotation_period": "7"
    }

In the above example, "encoding", "backup_schedule", and "backup_rotation_period" are optional. A database can be created simply with an "id" and other options can be added later if needed.

Items in the `mysql_users` data bag should be in the following format:

    {
      "id": "user_name",
      "hosts": [ "localhost" ],
      "password": "passwordgoeshere",
      "privileges": {
        "db1": [ "select", "insert" ],
        "db2": [ "all" ]
      }
    }

Any users that do not have privileges configured will not be managed by this cookbook.