default['sidekiq_biola']['app_root'] = '/srv/rack'
default['sidekiq_biola']['apps'] = {}

# Example rails app
# default['sidekiq_biola']['apps'] << {name: 'timecard', user: 'timecard', workers: 1}

# Example non-rails app
# default['sidekiq_biola']['apps'] << {name: 'timecard', user: 'timecard', workers: 1, require: './config/environment.rb'}