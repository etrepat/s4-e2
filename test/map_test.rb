require_relative 'test_helper'

describe TrafficSim::Map do
  before(:each) do
    @map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")
  end

  describe '#initialize' do
    it 'should be able to create asteroids from a map file' do
      asteroid = TrafficSim::Map::ASTEROID

      assert @map.rows[0].all? { |e| e == asteroid }
      assert @map.rows[@map.rows.length - 1].all? { |e| e == asteroid }
      assert @map.columns[0].all? { |e| e == asteroid }
      assert @map.columns[@map.columns.length - 1].all? { |e| e == asteroid }
    end

    it 'should be able to create docks from a map file' do
      dest_a = @map[4,13]
      dest_b = @map[5,4]

      assert dest_a.owned_by?("a")
      assert !dest_a.owned_by?("b")

      assert dest_b.owned_by?("b")
      assert !dest_b.owned_by?("a")
    end

    it 'should be able to create vehicles from a map file' do
      vehicle_a = @map[11,6]
      vehicle_b = @map[9, 17]

      assert_equal "a", vehicle_a.driver_name
      assert_equal "b", vehicle_b.driver_name
    end

    it 'should be able to create empty spaces from a map file' do
      # empty spaces are the rest which are not :asteroid, Vehicle or Dock
      asteroid  = TrafficSim::Map::ASTEROID
      empty     = TrafficSim::Map::EMPTY

      num_cells = @map.rows.flatten.size
      num_empty_cells = @map.rows.flatten.select { |e| e == empty }.size
      num_occupied_cells = @map.rows.flatten.select do |e|
        e == asteroid || e.is_a?(TrafficSim::Vehicle) || e.is_a?(TrafficSim::Dock)
      end.size

      assert_equal num_empty_cells, num_cells - num_occupied_cells
    end
  end

  describe '#empty?' do
    it 'should return true if position is actually empty, false otherwise' do
      empty = TrafficSim::Map::EMPTY
      assert @map.empty?([1,1])
      assert @map.empty?([2,2])
      assert @map.empty?([3,3])
      refute @map.empty?([5,4])
    end
  end
end

