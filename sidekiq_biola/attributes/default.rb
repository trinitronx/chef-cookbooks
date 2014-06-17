default['sidekiq_biola']['app_root'] = '/srv/rack'
default['sidekiq_biola']['apps'] = {}

# Example rails app
# default['sidekiq_biola']['apps'] << {name: 'timecard', user: 'timecard'}

# Example non-rails app
# default['sidekiq_biola']['apps'] << {name: 'timecard', user: 'timecard', require: './config/environment.rb'}

# Example app with multiple workers
# default['sidekiq_biola']['apps'] << {name: 'timecard', user: 'timecard', workers: 2}

# Example app with multiple queues
# Format: {name => weight}
# Use nil for default weight
# default['sidekiq_biola']['apps'] << {name: 'timecard', user: 'timecard', queues: {critical: 2, default: 1}}