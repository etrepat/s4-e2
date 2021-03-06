module TrafficSim
  module Drivers
    class Sample < TrafficSim::Driver
      def initialize(name, map)
        super(name, map)
        @movements = [:increase_speed, :move].cycle
      end

      def step
        @movements.next
      end
    end
  end
end

