
require 'rack'
require 'webrick'
require 'thread'

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
      q = Queue.new
      @@server = Rack::Server.new(
        :server => :webrick,
        :Host => Airstream::Network.get_local_ip,
        :Port => AIRSTREAM_PORT,
        :app => Rack::File.new(@filename),
        :AccessLog => [], # stfu webrick
        :Logger => WEBrick::Log::new("/dev/null", 7),
        :StartCallback => Proc.new {
          q << 1
        }
      )
      Thread.start do
        @@server.start
      end
      q.pop
      "http://#{@@server.options[:Host]}:#{@@server.options[:Port]}"
    end
    private :host_file
  end
end
