gem 'minitest'
require 'minitest/autorun'

require_relative '../lib/rack/statsd_batch'

class MiddlewareTestApp
  attr_accessor :callback

  def call env
    if @callback
      @callback.call(env)
    end
    return [{}, 200, '']
  end
end

class MiddlewareTest < MiniTest::Test
  def setup
    @tester = MiddlewareTestApp.new
    @app = Rack::StatsdBatch.new(@tester, 'localhost', 1234)
  end

  def test_env_contains_recorder
    passed = nil
    @tester.callback = ->(env){ passed = env.include?('metrics') }
    @app.call({})
    assert passed
  end
end
