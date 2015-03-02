require 'seeker_droid/voice'
require 'seeker_droid/story'
require 'seeker_droid/mic'

module SeekerDroid
  BOBO = ENV['BOBO']
  RUNNING_ON_PI = File.exists? '/proc' unless defined? RUNNING_ON_PI

  class Story
    attr_reader :voice, :script, :mic
    def initialize
      @voice = Voice.new
      @mic = Mic.new
      @script = File.read('story.txt')
    end

    def tell
      wait_for_quiet unless BOBO

      self.script.split("\n").each_with_index do |line, index|
        if BOBO
          next unless index.even?
          pitch = :high
        else
          next unless index.odd?
          pitch = :low
        end

        self.voice.send(pitch, line)
        wait_for_quiet
      end
    end

    def wait_for_quiet
      if RUNNING_ON_PI
        sleep 1
        Timeout::timeout(3) {
          sleep until (max = self.mic.last_maximum_amplitude) && max < 1.0
        }
      else
        sleep 4
      end
    end
  end
end
