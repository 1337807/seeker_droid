RUNNING_ON_PI = File.exists? '/proc'

require 'robolove'
require 'seeker_droid/pi_piper_monkey_patch' unless RUNNING_ON_PI
require 'pi_piper'

module SeekerDroid
  class Droid
    include PiPiper if RUNNING_ON_PI

    attr_reader :bot, :directions, :speed
    attr_accessor :current_action, :last_action_alerted

    def initialize(speed = 100, bot = nil)
      @bot = bot || Robolove::Bot.new
      @directions = []
      @current_action = nil
      @last_action_alerted = false
      @speed = speed

      setup_sensors if RUNNING_ON_PI
    end

    def kill_current result = nil
      self.last_action_alerted = (result == :alert)
      self.current_action.kill if @current_action
    end

    def forward
      kill_current
      set_direction :forward
      self.current_action = Thread.new { @bot.forward(self.speed) }
    end

    def backward
      kill_current
      set_direction :backward
      self.current_action = Thread.new { @bot.backward(self.speed) }
    end

    def right
      kill_current
      set_direction :right
      self.current_action = Thread.new { @bot.right(self.speed) }
    end

    def left
      kill_current
      set_direction :left
      self.current_action = Thread.new { @bot.left(self.speed) }
    end

    def set_direction direction
      self.directions << direction
    end

    def last_direction
      self.directions.last
    end

    def red_alert
      double_alert = self.last_action_alerted
      kill_current :alert

      case last_direction
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
        droid.red_alert
        sleep 0.3
      end
      after(pin: 23, goes: :high) do
        #vertical
        droid.red_alert
        sleep 0.3
      end

      #rear sensors
      after(pin: 25, goes: :low) do
        #horizontal
        droid.red_alert
        sleep 0.3
      end
      after(pin: 24, goes: :high) do
        #vertical
        droid.red_alert
        sleep 0.3
      end
    end
  end
end
