require 'seeker_droid/droid'

module SeekerDroid
  def self.seek
    @droid = SeekerDroid::Droid.new

    loop do
      @droid.forward(50) if @droid.done?
      sleep 1
    end
  end
end
