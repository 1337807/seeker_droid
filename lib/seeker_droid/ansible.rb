require 'redis'
require 'json'

module SeekerDroid
  class Ansible
    attr_reader :redis

    def initialize
      @redis = Redis.new
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
