Description
===========

This cookbooks automates the provisioning of ruby/rack applications.

Recipes
=======

Loops through all apps found in `/srv/rack` , looks them up in the `ruby_apps` data bag and and performs the following actions.

Let's say there was an app called `boring-blog`.

Node Setup
----------

1. Create data bag encryption key and put it in `/etc/chef/encryption_keys/ruby_app.key`

Per-Application User Steps
--------------------------

1. Put the application files in `/srv/rack/boring-blog`
2. Add a data bag item using the following command:

        knife data bag create ruby_apps boring-blog
    
    The data bag item should be in the following format for a url of `http://boring.example.com/blog`:
    
        {
          "id": "boring-blog",
          "url": {
            "subdomain": "boring",
            "domain": "example.com",
            "path": "/blog"
          }
        }

3. Add an encrypted data bag item using the following command:

        knife data bag create ruby_apps_conf boring-blog --secret-file=/path/to/encryption.key

    The data bag item should be in the following format:
    
        {
          "id": "course-pallet",
          "environments": {
            "all": {
              "files": {
                "config/database.yml": {
                  "staging": {
                    "adapter": "mysql2",
                    "host": "db.example.com",
                    "database": "boring_blog",
                    "username": "boring_blog_dbo",
                    "password": "**************"
                  }
                }
              }
            },
            "prod": {
              "files": {
                "config/newrelic.yml": {
                  "production": {
                    "license_key": "*********************"
                  }
                }
              }
            }
          }
        }

    __Notes:__
    
      - The `--secret-file` should be a local copy of the key you put in `/etc/chef/encryption_keys/` on the server.
      - The environment is the Chef environment not the Ruby application environment. So use `prod` not `production`.
      - The file contents will be converted from JSON to YAML before they're writted to the applyication directory.
      - The files must be within the `/srv/rack/boring-blog` directory.


Per-Application Chef Steps
--------------------------

This is what the `chef-client` run will automatically do when it finds the `boring-blog` app in `/srv/rack/`.

1. Create a `boring_blog` group.
2. Create a `boring_blog` user.
3. Create a `/var/log/rack/boring-blog/` directory.
4. Delete `/srv/rack/boring-blog/log/` if it exists.
5. Symlink `/srv/rack/boring-blog/log/` to `/var/log/rack/boring-blog/`.
6. Create `/srv/rack/boring-blog/tmp`.
7. Run the following permission change commands:
    - `chgrp --recursive ruby-dev . ./log/`
    - `chown --recursive ruby-dev ./tmp/ ./log/`
    - `chmod --recursive g+w . ./log/`
8. Set the git repository to `sharedRepository = group`.
9. Create or update `config/database.yml`, `config/newrelic.yml` and any other files defined in `ruby_apps_conf`.
10. Create an Nginx config file in `/etc/nginx/sites/boring.[staging.]exmaple.com.server.conf`.
11. Symlink `/srv/static/boring.[staging.]example.com/blog` to `/srv/rack/boring-blog/public/` *(if the app's URL was just `boring.example.com` this would be skipped)*.