RUNNING_ON_PI = File.exists? '/proc'

require 'robolove'
require 'seeker_droid/pi_piper_monkey_patch' unless RUNNING_ON_PI
require 'pi_piper'
require 'logger'

module SeekerDroid
  class Droid
    include PiPiper if RUNNING_ON_PI

    attr_reader :bot, :directions, :speed, :logger
    attr_accessor :current_action, :last_action_alerted

    def initialize(speed = 100, bot = nil)
      @bot = bot || Robolove::Bot.new
      @directions = []
      @current_action = nil
      @last_action_alerted = false
      @speed = speed
      @logger = Logger.new('log/seeker_droid.log', 'daily')

      setup_sensors if RUNNING_ON_PI
    end

    def kill_current result = nil
      self.last_action_alerted = (result == :alert)
      self.current_action.kill if @current_action
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

    def drive(direction)
      kill_current
      set_direction direction
      self.logger.debug "New action: #{direction}"
      self.current_action = Thread.new { @bot.send(direction, self.speed) }
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
        backward unless double_alert
        right
        forward if double_alert
      when :backward
        forward
        right
      when :left
        backward
        left
      end
    end

    def done?
      if self.current_action
        !self.current_action.alive?
      else
        true
      end
    end

    def setup_sensors
      droid = self

      #front sensors
      after(pin: 22, goes: :low) do
        #horizontal
        droid.debug "Sensor: pin 22 low, front horizontal"
        droid.red_alert
        sleep 0.3
      end
      after(pin: 23, goes: :high) do
        #vertical
        droid.debug "Sensor: pin 23 high, front vertical"
        droid.red_alert
        sleep 0.3
      end

      #rear sensors
      after(pin: 25, goes: :low) do
        #horizontal
        droid.debug "Sensor: pin 25 low, rear horizontal"
        droid.red_alert
        sleep 0.3
      end
      after(pin: 24, goes: :high) do
        #vertical
        droid.debug "Sensor: pin 24 high, rear vertical"
        droid.red_alert
        sleep 0.3
      end
    end
  end
end
