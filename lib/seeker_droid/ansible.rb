require 'redis'
require 'json'

module SeekerDroid
  class Ansible
    REDIS_HOSTS = {
      'onering' => '10.0.0.2',
      '1337807' => '192.168.43.71'
    }

    attr_reader :redis

    def initialize
      @redis = Redis.new(host: get_host_ip, port: 6379)
    end

    def get_host_ip
      ssid = '1337807'
      # Doesn't work on OS X, equivalent?
      # ssid = `iwconfig | grep wlan0`.match(/ESSID\W*(\w*)/)[1]
      REDIS_HOSTS[ssid]
    end

    def receive(droid)
      Thread.new do
        self.redis.subscribe('both', droid.name) do |on|
          on.message do |channel, msg|
            parsed = JSON.parse(msg)

            if parsed['message']
              droid.send(parsed['command'], parsed['message'])
            else
              droid.send(parsed['command'])
            end
          end
        end
      end
    end

    def transmit(device, message)
      puts "Sending #{message} to #{device}"
      self.redis.publish device.to_s, message.to_json
    end
  end
end
