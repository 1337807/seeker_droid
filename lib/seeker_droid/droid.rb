require 'robolove'
require 'fileutils'
require 'logger'
require 'seeker_droid/proximity_sensor_array'
require 'seeker_droid/ansible'
require 'seeker_droid/voice'
require 'seeker_droid/story'

module SeekerDroid
  RUNNING_ON_PI = File.exists? '/proc' unless defined? RUNNING_ON_PI

  class Droid
    attr_reader :bot, :directions, :speed, :logger, :proximity_sensor_array, :ansible, :voice
    attr_accessor :current_action, :last_action_alerted, :music_action

    def initialize(speed = 100, bot = nil)
      @bot = bot || Robolove::Bot.new
      @directions = []
      @current_action = nil
      @music_action = nil
      @last_action_alerted = false
      @speed = speed
      @voice = Voice.new

      FileUtils.mkdir_p('log')
      @logger = Logger.new('log/seeker_droid.log', 'daily')

      if RUNNING_ON_PI
        @proximity_sensor_array = ProximitySensorArray.new(self) if false

        @ansible = Ansible.new
        self.ansible.receive(self)
      end

      self.logger.debug "Droid initialized"
      self.logger.debug "speed: #{self.speed}"
    end

    def name
      if ENV['BOBO']
        'bobo'
      else
        'robo'
      end
    end

    def stop
      self.proximity_sensor_array.implode
      self.bot.stop
      self.logger.debug "Full stop"
    end

    def kill_current result = nil
      self.last_action_alerted = (result == :alert)
      self.current_action.kill if self.current_action
    end

    def forward
      drive :forward
    end

    def backward
      drive :backward
    end

    def right
      drive :right
    end

    def left
      drive :left
    end

    def music
      self.music_action = Thread.new { `omxplayer /home/pi/final_countdown.mp3` }
    end

    def stop_music
      self.music_action.kill
      self.music_action = nil
    end

    def speak(message)
      self.voice.speak(message)
    end

    def story
      Story.new.tell
    end

    def introduction
      sleep 5 unless ENV['BOBO']
      speak("Hello Ruby on Ales, I'm #{ENV['BOBO'] ? 'Bobo' : 'Robo'}")
    end

    def command_group(*commands)
      commands.each do |command|
        drive command
        sleep until done?
      end
    end

    def drive(direction)
      kill_current
      set_direction direction
      self.logger.debug "New action: #{direction}"
      self.current_action = Thread.new { self.bot.send(direction) }
    end

    def set_direction direction
      self.directions << direction
    end

    def red_alert
      double_alert = self.last_action_alerted
      kill_current :alert

      msg = "Alert: #{self.directions.last}"
      msg << ", previous action (#{self.directions[-2]}) also caused an alert." if double_alert
      self.logger.debug msg

      case self.directions.last
      when :forward, :right
        if double_alert
          command_group(:right, :forward)
        else
          command_group(:backward, :right)
        end
      when :backward
        command_group(:forward, :right)
      when :left
        command_group(:backward, :left)
      end
    end

    def done?
      if self.current_action
        !self.current_action.alive?
      else
        true
      end
    end
  end
end
