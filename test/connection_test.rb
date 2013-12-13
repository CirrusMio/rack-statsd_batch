gem 'minitest'
require 'minitest/autorun'

require_relative '../lib/rack/statsd_batch'

$statsd_connection = nil
class TestConnection
  attr_reader :packets

  def initialize socket, host, port
    $statsd_connection = self
  end

  def send packet
    (@packets ||= []) << packet
  end
end

class ConnectionTest < MiniTest::Test
  def setup
    @old_const = Rack::StatsdBatch::Connection
    Rack::StatsdBatch.const_set :Connection, TestConnection
    @recorder = Rack::StatsdBatch::Recorder.new
    @recorder.gauge 'mygauge', 1
    @recorder.gauge_diff 'myothergauge', 3
  end

  def teardown
    Rack::StatsdBatch.const_set :Connection, @old_const
  end

  def test_sends_packet
    @recorder.publish('hostname', port=1234, mtu=1024)
    assert_equal 1, $statsd_connection.packets.length
    assert_equal "mygauge:1|g\nmyothergauge:+3|g",
                 $statsd_connection.packets.first
  end

  def test_splits_packets
    @recorder.publish('hostname', port=1234, mtu=@recorder.data.first.length)
    assert_equal 2, $statsd_connection.packets.length
  end
end
