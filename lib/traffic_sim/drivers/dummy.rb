module TrafficSim
  module Drivers
    class Dummy
      def initialize

      end

      def step(map, driver_name)
        current_speed = map.vehicles[driver_name].speed
        return :increase_speed if current_speed == 0
        :launch
      end
    end
  end
end

