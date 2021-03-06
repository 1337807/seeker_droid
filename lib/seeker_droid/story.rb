require 'seeker_droid/voice'
require 'seeker_droid/story'
require 'seeker_droid/mic'

module SeekerDroid
  RUNNING_ON_PI = File.exists? '/proc' unless defined? RUNNING_ON_PI

  class Story
    attr_reader :voice, :script, :mic
    def initialize
      @voice = Voice.new
      @mic = Mic.new
      @script = File.read('story.txt')
    end

    def tell
      wait_for_quiet unless ENV['BOBO']

      self.script.split("\n").each_with_index do |line, index|
        if ENV['BOBO']
          next unless index.even?
        else
          next unless index.odd?
        end

        self.voice.speak line
        wait_for_quiet
      end
    end

    def wait_for_quiet
      if RUNNING_ON_PI
        sleep 2
        Timeout::timeout(3) {
          sleep until self.mic.current_noise_level < 0.02
        }
      else
        sleep 5
      end
    rescue Timeout::Error
    end
  end
end
