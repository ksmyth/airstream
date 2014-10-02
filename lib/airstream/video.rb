
require 'rack'
require 'webrick'
require 'monitor'

module Airstream
  class Video

    @@server = nil

    def initialize(video_file)
      @filename = video_file
    end

    def to_s
      File.basename(@filename, File.extname(@filename))
    end

    def url
      File.exists?(@filename) ? host_file : @filename
    end

    def host_file
      @@server.server.shutdown if @@server
      @@server = Rack::Server.new(
        :server => :webrick,
        :Host => Airstream::Network.get_local_ip,
        :Port => AIRSTREAM_PORT,
        :app => Rack::File.new(@filename),
        :AccessLog => [], # stfu webrick
        :Logger => WEBrick::Log::new("/dev/null", 7)
      )
      mon  = Monitor.new
      wait = @mon.new_cond
      Thread.start do
        @@server.start
        mon.synchronize do
          wait.signal
        end
      end
      mon.synchronize do
        wait.wait
      end
      sleep(0.5)
      "http://#{@@server.options[:Host]}:#{@@server.options[:Port]}"
    end
    private :host_file
  end
end
