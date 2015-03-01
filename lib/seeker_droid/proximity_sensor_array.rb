require 'seeker_droid/pi_piper_monkey_patch'
require 'pi_piper'

module SeekerDroid
  class ProximitySensorArray
    include PiPiper

    FRONT_VERTICAL_PIN = 22
    FRONT_HORIZONTAL_PIN = 23

    REAR_VERTICAL_PIN = 24
    REAR_HORIZONTAL_PIN = 25

    attr_reader :sensors

    def initialize(droid)
      @sensors = []

      #front sensors
      self.sensors << after(pin: FRONT_VERTICAL_PIN, goes: :high) do
        #vertical
        droid.logger.debug "Sensor: pin #{FRONT_VERTICAL_PIN} high, front vertical"
        droid.red_alert
        sleep 0.3
      end
      self.sensors << after(pin: FRONT_HORIZONTAL_PIN, goes: :low) do
        #horizontal
        droid.logger.debug "Sensor: pin #{FRONT_HORIZONTAL_PIN} low, front horizontal"
        droid.red_alert
        sleep 0.3
      end

      #rear sensors
      self.sensors << after(pin: REAR_VERTICAL_PIN, goes: :high) do
        #vertical
        droid.logger.debug "Sensor: pin #{REAR_VERTICAL_PIN} high, rear vertical"
        droid.red_alert
        sleep 0.3
      end
      self.sensors << after(pin: REAR_HORIZONTAL_PIN, goes: :low) do
        #horizontal
        droid.logger.debug "Sensor: pin #{REAR_HORIZONTAL_PIN} low, rear horizontal"
        droid.red_alert
        sleep 0.3
      end
    end

    def implode
      self.sensors.map(&:kill)
    end
  end
end
