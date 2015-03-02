require 'redis'
require 'json'

module SeekerDroid
  class Ansible
    REDIS_HOSTS = {
      'onering' => '10.0.0.2'
    }

    attr_reader :redis

    def initialize
      @redis = Redis.new(host: get_host_ip, port: 6379)
    end

    def get_host_ip
      ssid = `iwconfig | grep wlan0`.match(/ESSID\W*(\w*)/)[1]
      REDIS_HOSTS[ssid]
    end

    def receive(droid)
      Thread.new do
        self.redis.subscribe('both', droid.name) do |on|
          on.message do |channel, msg|
            command = JSON.parse(msg)['command']
            droid.send(command)
          end
        end
      end
    end

    def transmit(device, command)
      puts "Sending #{command} to #{device}"
      self.redis.publish device.to_s, { :command => command }.to_json
    end
  end
end
