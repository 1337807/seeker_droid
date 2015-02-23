require 'seeker_droid/droid'

module SeekerDroid
  def self.seek
    @droid = SeekerDroid::Droid.new 50

    loop do
      @droid.forward if @droid.done?
      sleep 1
    end
  end
end
