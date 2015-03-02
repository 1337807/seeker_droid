require 'io/console'
require './lib/seeker_droid/ansible'

module SeekerDroid
  class Cli
    attr_reader :ansible
    attr_accessor :exit_prompt

    def initialize
      @exit_prompt = false
      @ansible = Ansible.new
    end

    def start
      while !self.exit_prompt
        get_character
      end
    end

    def read_char
      STDIN.echo = false
      STDIN.raw!

      input = STDIN.getc.chr
      if input == "\e" then
        input << STDIN.read_nonblock(3) rescue nil
        input << STDIN.read_nonblock(2) rescue nil
      end
    ensure
      STDIN.echo = true
      STDIN.cooked!

      return input
    end

    def speech_prompt
      puts "robots talk!"
    end

    def forward(device)
      self.ansible.transmit(device, :forward)
    end

    def backward(device)
      self.ansible.transmit(device, :backward)
    end

    def right(device)
      self.ansible.transmit(device, :right)
    end

    def left(device)
      self.ansible.transmit(device, :left)
    end

    def get_character
      c = read_char

      case c
      when "\r"
        speech_prompt
      when "\e"
        puts "ESCAPE"
        self.exit_prompt = true

      when "\e[A"
        forward(:both)
      when "\e[1;2A"
        forward(:bobo)
      when "\e\e[A"
        forward(:robo)

      when "\e[B"
        backward(:both)
      when "\e[1;2B"
        backward(:bobo)
      when "\e\e[B"
        backward(:robo)

      when "\e[C"
        right(:both)
      when "\e[1;2C"
        right(:bobo)
      when "\e\e[C"
        right(:robo)

      when "\e[D"
        left(:both)
      when "\e[1;2D"
        left(:bobo)
      when "\e\e[D"
        left(:robo)

      when /^.$/
        puts "SINGLE CHAR HIT: #{c.inspect}"
      else
        puts "SOMETHING ELSE: #{c.inspect}"
      end
    end
  end
end

c = SeekerDroid::Cli.new

class Fake
  def name
    'bobo'
  end
end

SeekerDroid::Ansible.new.receive(Fake.new)
c.start
