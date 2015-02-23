require 'seeker_droid/droid'

module SeekerDroid
  def self.seek(speed = nil)
    @droid = SeekerDroid::Droid.new(speed || 50)

    loop do
      @droid.forward if @droid.done?
      sleep 1
    end
  end
end
