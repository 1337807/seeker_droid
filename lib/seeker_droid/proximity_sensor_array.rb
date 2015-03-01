require 'seeker_droid/pi_piper_monkey_patch'
require 'pi_piper'

module SeekerDroid
  class ProximitySensorArray
    include PiPiper

    def initialize(droid)
      #front sensors
      after(pin: 22, goes: :low) do
        #horizontal
        droid.logger.debug "Sensor: pin 22 low, front horizontal"
        droid.red_alert
        sleep 0.3
      end
      after(pin: 23, goes: :high) do
        #vertical
        droid.logger.debug "Sensor: pin 23 high, front vertical"
        droid.red_alert
        sleep 0.3
      end

      #rear sensors
      after(pin: 25, goes: :low) do
        #horizontal
        droid.logger.debug "Sensor: pin 25 low, rear horizontal"
        droid.red_alert
        sleep 0.3
      end
      after(pin: 24, goes: :high) do
        #vertical
        droid.logger.debug "Sensor: pin 24 high, rear vertical"
        droid.red_alert
        sleep 0.3
      end
    end
  end
end
