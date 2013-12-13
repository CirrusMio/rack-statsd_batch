gem 'minitest'
require 'minitest/autorun'

require_relative '../lib/rack/statsd_batch'

class ApplicationInterfaceTest < MiniTest::Test
  def setup
    @recorder = Rack::StatsdBatch::Recorder.new
  end

  def test_count
    @recorder.count('mykey', 1)
    assert_equal 1, @recorder.data.length
    assert_equal 'mykey:1|c', @recorder.data.first
  end

  def test_timing
    @recorder.timing('mykey', 1)
    assert_equal 1, @recorder.data.length
    assert_equal 'mykey:1|ms', @recorder.data.first
  end

  def test_gauge_diff_negative
    @recorder.gauge_diff('mykey', 1)
    assert_equal 1, @recorder.data.length
    assert_equal 'mykey:+1|g', @recorder.data.first
  end

  def test_gauge_diff_negative
    @recorder.gauge_diff('mykey', -1)
    assert_equal 1, @recorder.data.length
    assert_equal 'mykey:-1|g', @recorder.data.first
  end

  def test_gauge_set
    @recorder.gauge('mykey', 10)
    assert_equal 1, @recorder.data.length
    assert_equal 'mykey:10|g', @recorder.data.first
  end

  def test_set_multiple_things
    @recorder.gauge('mykey', 1)
    @recorder.gauge_diff('myotherkey', 10)
    assert_equal 2, @recorder.data.length
  end
end
