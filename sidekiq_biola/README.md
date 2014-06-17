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
        {"name": "app-a", "user": "app_a"},

        // Minimal non-rails app config
        {name: "app-b", user: "app_b", require: "./config/environment.rb"},

        // App with multiple workers
        {name: "app-c", user: "app_c", workers: 2},

        // App with customized concurrency (or number of threads)
        {name: "app-d", user: "app_d", concurrency: 50},

        // App with multiple queues
        // Format: {name => weight}
        // Use null for default weight
        {name: "app-e", user: "app_e", queues: {"critical": 2, "default": 1}}
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

- Default `app_root` is `/srv/rack`

- Default `concurrency` is 25

- All PIDs are stored in `/tmp/sidekiq/[appname]-[index].pid`
