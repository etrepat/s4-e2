module TrafficSim
  class Map
    InvalidDirection = Class.new(StandardError)

    DIRECTIONS = [:north, :south, :east, :west]
    ASTEROID   = :asteroid
    EMPTY      = :empty

    def initialize(filename)
      @vehicles = {}
      @data     = parse_map_from_file(filename)
    end

    attr_reader :vehicles

    def [](row, col)
      @data.fetch(row).fetch(col)
    rescue IndexError
      raise ArgumentError, "[#{row}, #{col}] is out of bounds"
    end

    def []=(row, col, val)
      @data[row][col] = val if self[row, col] # w/bounds check
    end

    def rows
      data
    end

    def columns
      data.transpose
    end

    def empty?(point)
      self[*point] == EMPTY
    end

    def destination(params)
      raise ArgumentError, 'point of origin is required' unless params[:origin]
      row, col  = params.fetch(:origin)
      distance  = params.fetch(:distance, Vehicle::MIN_SPEED+1)
      direction = params.fetch(:direction, DIRECTIONS.first)
      raise InvalidDirection, "unrecognized #{direction} as direction" \
        unless DIRECTIONS.include?(direction)

      dest_point = case direction
      when :north
        [row - distance, col]
      when :south
        [row + distance, col]
      when :east
        [row, col + distance]
      when :west
        [row, col - distance]
      end

      return nil if row < 0 || row >= rows.length
      return nil if col < 0 || col >= columns.length

      dest_point
    end

    def clear_path?(a,b)
      row_a, col_a = a
      row_b, col_b = b

      case
      when row_a == row_b
        start_col, end_col = [col_a, col_b].sort
        rows[row_a][start_col..end_col].none? { |e| e == ASTEROID }
      when col_a == col_b
        start_row, end_row = [row_a, row_b].sort
        columns[col_a][start_row..end_row].none? { |e| e == ASTEROID }
      else
        raise ArgumentError
      end
    end

    def to_s
      data.map do |row|
        output = row.map do |obj|
          case obj
          when EMPTY
            " "
          when ASTEROID
            "#"
          when Vehicle
            obj.driver_name
          when Dock
            obj.owner.upcase
          end
        end

        output.join
      end.join("\n")
    end

    private

    attr_reader :data

    def parse_map_from_file(filename)
      File.read(filename).lines.map.with_index do |row, row_i|
        row.chomp.chars.map.with_index do |symbol, col_i|
          convert_symbol(symbol, [row_i, col_i])
        end
      end
    end

    def convert_symbol(symbol, position)
      case symbol
      when "#"
        ASTEROID
      when /[A-Z]/
        Dock.new(symbol.downcase)
      when /[a-z]/
        vehicles[symbol] = Vehicle.new(symbol, position)
      when " "
        EMPTY
      else
        raise
      end
    end
  end
end

