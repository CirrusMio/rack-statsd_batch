require 'socket'

module Rack
  class StatsdBatch
    def initialize rack_app, hostname, port, mtu=1432
      @app = rack_app
      @hostname = hostname
      @port = port
      @mtu = mtu
    end

    def call env
      env['metrics'] = Rack::StatsdBatch::Recorder.new
      status, headers, response = @app.call(env)
      env['metrics'].publish(@hostname, @port, @mtu)
      [status, headers, response]
    end

    class Recorder
      attr_reader :data

      def initialize
        @data = []
      end

      def count key, diff
        @data << "#{key}:#{diff}|c"
      end

      def timing key, ms
        @data << "#{key}:#{ms}|ms"
      end

      def gauge key, value
        @data << "#{key}:#{value}|g"
      end

      def gauge_diff key, diff
        value = "#{diff}"
        value = "+#{value}" if diff > 0
        @data << "#{key}:#{value}|g"
      end

      def sets key, set_entry
        @data << "#{key}:#{set_entry}|s"
      end

      def publish host, port, mtu
        return if @data.empty?
        c = connection(host, port)
        build_packets(mtu).each {|p| c.send(p) }
      end

      private

      def connection host, port
        Rack::StatsdBatch::Connection.new(UDPSocket.new, host, port)
      end

      def build_packets mtu
        rv = []
        packet = ''
        while !data.empty?
          message = data.shift
          newline_length = packet.empty? ? 0 : 1
          if packet.length + message.length + newline_length > mtu
            rv << packet
            packet = ''
          end
          message = "\n#{message}" unless packet.empty?
          packet << message
        end
        (rv << packet) unless packet.empty?
        rv
      end
    end

    class Connection
      def initialize socket, *extra_params
        @socket = socket
        @extras = extra_params
      end

      def send data
        @socket.send(data, flags=0, *@extras)
      end
    end
  end
end
