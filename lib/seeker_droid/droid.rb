RUNNING_ON_PI = File.exists? '/proc'

require 'robolove'
require 'seeker_droid/pi_piper_monkey_patch' unless RUNNING_ON_PI
require 'pi_piper'

module SeekerDroid
  class Droid
    include PiPiper if RUNNING_ON_PI

    attr_reader :bot, :directions
    attr_accessor :current_action, :last_action_alerted

    def initialize(bot = nil)
      @bot = bot || Robolove::Bot.new
      @directions = []
      @current_action = nil
      @last_action_alerted = false

      setup_sensors if RUNNING_ON_PI
    end

    def kill_current result = nil
      self.last_action_alerted = (result == :alert)
      self.current_action.kill if @current_action
    end

    def forward
      kill_current
      set_direction :forward
      self.current_action = Thread.new { @bot.forward }
    end

    def backward
      kill_current
      set_direction :backward
      self.current_action = Thread.new { @bot.backward }
    end

    def right
      kill_current
      set_direction :right
      self.current_action = Thread.new { @bot.right }
    end

    def left
      kill_current
      set_direction :left
      self.current_action = Thread.new { @bot.left }
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

    def setup_sensors
      #front sensors
      watch(pin: 22) do
        #horizontal
        red_alert if value == 1
      end
      watch(pin: 23) do
        #vertical
        red_alert if value == 0
      end

      #rear sensors
      watch(pin: 24) do
        #horizontal
        red_alert if value == 1
      end
      watch(pin: 25) do
        #vertical
        red_alert if value == 0
      end
    end
  end
end
