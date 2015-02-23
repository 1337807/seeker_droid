require 'robolove'
require 'seeker_droid/pi_piper_monkey_patch'
require 'pi_piper'

module SeekerDroid
  class Droid
    attr_reader :bot
    attr_accessor :current_action

    def initialize(bot = nil)
      @bot = bot || Robolove::Bot.new
      @direction = nil
      @current_action = nil
    end

    def forward
      @direction = :forward
      @current_action = Thread.new { @bot.forward }
    end

    def backward
      @direction = :backward
      @current_action = Thread.new { @bot.backward }
    end

    def right
      @direction = :right
      @current_action = Thread.new { @bot.right }
    end

    def left
      @direction = :left
      @current_action = Thread.new { @bot.left }
    end

    def red_alert
      @current_action.kill

      case @direction
      when :forward, :right
        backward
        right
      when :backward
        forward
        right
      when :left
        backward
        left
      end
    end
  end
end
