require 'seeker_droid/droid'

module SeekerDroid
  def self.seek
    @droid = SeekerDroid::Bot.new

    loop do
      @droid.forward if @droid.done?
      sleep 0.3
    end
  end
end
