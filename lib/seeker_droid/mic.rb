module SeekerDroid
  class Mic
    SAMPLE_DURATION = 1
    SAMPLE_FILENAME = '/tmp/sample.wav'

    attr_reader :device_id

    def initialize
      @device_id = parse_device_id
    end

    def parse_device_id
      usb_device_line = `cat /proc/asound/cards`.split("\n").detect { |line| line.include? "USB" }

      if usb_device_line && usb_device_line.length > 1
        usb_device_line[1].to_i
      end
    end

    def current_noise_level
      record
      last_maximum_amplitude
    end

    def last_maximum_amplitude
      `/usr/bin/sox -t .wav #{SAMPLE_FILENAME} -n stat 2>&1`.match(/Maximum amplitude:\s+(.*)/m)
      $1.to_f
    end

    def record
      `/usr/bin/arecord -D plughw:#{self.device_id},0 -d #{SAMPLE_DURATION} -t wav #{SAMPLE_FILENAME} 2>/dev/null`
    end
  end
end
