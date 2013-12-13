# Rack::StatsdBatch

Throw your metrics data into your request env, and on egress it will get pushed
to statsd in as few requests as possible.

# Setup

Add to your gemfile

    gem 'rack-statsd-batch', git: 'git@github.com:CirrusMio/rack-statsd-batch', require: 'rack/statsd_batch'

Add to your middleware in config/application.rb

    config.middleware.use Rack::StatsdBatch, 'statsd-server.myhost.com', 1234

# Use

The stats collector is included in your request environment. Access it from your
controller:

    metrics = request.env['metrics']

There are five message types that map to the statsd backend

    metrics.gauge_diff 'registered-users', +1
    metrics.gauge 'total_things', 2037
    metrics.timing 'render_time_ms', 237
    metrics.count 'things_done', 1
    metrics.sets 'user_ids', 27
