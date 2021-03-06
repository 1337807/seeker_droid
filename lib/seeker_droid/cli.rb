require 'io/console'
require 'seeker_droid/ansible'

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
        sleep 0.3
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

    def speak(multi_message = nil)
      puts "1: Bobo, 2: Robo, Space: Both - Esc to exit"
      device_selection = read_char
      puts "Selected #{device_selection}"

      if device_selection == "1"
        device = :bobo
      elsif device_selection == "2"
        device = :robo
      elsif device_selection == "\e"
        puts "Aborting message input"
        return
      else
        device = :both
      end

      puts "Device is #{device}"

      message = gets.chomp

      while message.strip == ""
        puts "If you're trying to quit just hit escape (and then enter)"
        message = gets.chomp
      end

      if message == "\e"
        "Aborting message input"
        return
      end

      if multi_message
        self.ansible.transmit(device, command: :speak, message: message)

        loop do
          message = gets.chomp

          if message == "\e"
            puts "Aborting message input"
            return
          end

          self.ansible.transmit(device, command: :speak, message: message)
        end
      else
        self.ansible.transmit(device, command: :speak, message: message)
      end
    end

    def forward(device)
      self.ansible.transmit(device, command: :forward)
    end

    def backward(device)
      self.ansible.transmit(device, command: :backward)
    end

    def right(device)
      self.ansible.transmit(device, command: :right)
    end

    def left(device)
      self.ansible.transmit(device, command: :left)
    end

    def music(device)
      self.ansible.transmit(device, command: :music)
    end

    def story(device)
      self.ansible.transmit(device, command: :story)
    end

    def introduction(device)
      self.ansible.transmit(device, command: :introduction)
    end

    def get_character
      c = read_char

      case c
      when "\r"
        speak
      when "\\"
        speak(true)
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

      when "m"
        music(:both)

      when "s"
        story(:both)

      when "i"
        introduction(:both)

      when /^.$/
        puts "SINGLE CHAR HIT: #{c.inspect}"
      else
        puts "SOMETHING ELSE: #{c.inspect}"
      end
    end
  end
end
