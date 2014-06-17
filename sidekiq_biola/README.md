Sidekiq Biola
=============

Configure [Sidekiq](http://sidekiq.org) workers to run on the node.

Attributes
----------

    "sidekiq_biola": {
      // Directory containing Sidekiq apps
      "app_root": "/srv/rack",

      "apps": [
        // Minimal Rails app config
        {"name": "classifieds", "user": "classifieds"},

        // Minimal non-rails app config
        {name: 'rack-detour', user: 'rack_detour', require: './config/environment.rb'},

        // App with multiple workers
        {name: 'timecard', user: 'timecard', workers: 2},

        // App with multiple queues
        // Format: {name => weight}
        // Use null for default weight
        {name: "announcement-publisher", user: "announcement_publisher", queues: {"critical": 2, "default": 1}}
      ]
    }

Services
--------

- __sidekiq-all__  
  This service will `start`, `stop` or `restart` all the configured Sidekiq workers.

- __sidekiq-[appname]__  
  In addition a service is created for each application that exists and has been configured on the node.

Logs
----

All logs are stored in `/var/log/sidekiq/[appname]-[index].log`

Notes
-----

- If an application is not found by it's name in the `app_root` directory, no worker will be created.

- All PIDs are stored in `/tmp/sidekiq/[appname]-[index].pid`