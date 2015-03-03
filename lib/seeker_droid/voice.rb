module SeekerDroid
  RUNNING_ON_PI = File.exists? '/proc' unless defined? RUNNING_ON_PI

  class Voice
    def speak(phrase)
      if ENV['BOBO']
        low(phrase)
      else
        high(phrase)
      end
    end

    def low(phrase)
      if RUNNING_ON_PI
        `espeak "#{phrase}" -a 500 -s 140 2> /dev/null`
      else
        `say -v Alex "#{phrase}"`
      end
    end

    def high(phrase)
      if RUNNING_ON_PI
        `espeak "#{phrase}" -a 500 -s 140 -p 200 2> /dev/null`
      else
        `say -v Vicki "#{phrase}"`
      end
    end
  end
end
