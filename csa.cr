MAX_STATIONS = 100000.to_i
INF = UInt32::MAX

alias UI = UInt32
alias Connection = NamedTuple(
  departure_station:    UI,
  arrival_station:      UI,
  departure_timestamp:  UI,
  arrival_timestamp:    UI,
)
alias Timetable = Array(Connection)
  
def make_connection(s)
  tokens = s.strip.split(" ")
  return {
    departure_station:      tokens[0].as(String).to_u32,
    arrival_station:        tokens[1].as(String).to_u32,
    departure_timestamp:    tokens[2].as(String).to_u32,
    arrival_timestamp:      tokens[3].as(String).to_u32,
  }
end

def make_timetable
  res = [] of Connection
  loop do
    line = STDIN.gets
    break if !line || line.strip.empty?
    res << make_connection(line)
  end
  return res
end

struct CSA

  property timetable        : Timetable
  @in_connection          = [] of UI
  @earliest_arrival       = [] of UI
  property in_connection    : Array(UI)
  property earliest_arrival : Array(UI)

  def initialize
    @timetable              = make_timetable
    #puts "Timetable build succesfully ; #{@timetable.size} connections"
  end

  def main_loop(arrival_station)
    earliest = INF
    @timetable.each_with_index do |c, i|
      if c[:departure_timestamp] >= 
          @earliest_arrival[c[:departure_station]] && 
          c[:arrival_timestamp] < @earliest_arrival[c[:arrival_station]]

        @earliest_arrival[c[:arrival_station]] = c[:arrival_timestamp]
        @in_connection[c[:arrival_station]] = i.to_u32
        if c[:arrival_station] == arrival_station
          earliest = [earliest, c[:arrival_timestamp]].min
        end
      elsif c[:arrival_timestamp] > earliest
        return
      end
    end
  end

  def print_result(arrival_station)
    if @in_connection[arrival_station] == INF
      puts "NO_SOLUTION"
    else
      route = [] of Connection
      # We have to rebuild the route from the arrival station
      last_connection_index = @in_connection[arrival_station]
      while last_connection_index != INF
        connection = @timetable[last_connection_index]
        route << connection
        last_connection_index = @in_connection[connection[:departure_station]]
      end

      # And now print it out in the right direction
      route.reverse.each do |c|
        puts "#{c[:departure_station]} #{c[:arrival_station]} #{c[:departure_timestamp]} #{c[:arrival_timestamp]}"
      end
    end
    puts ""
    STDOUT.flush
  end

  def compute(departure_station, arrival_station, departure_time)
    @in_connection       = Array.new(MAX_STATIONS, INF)
    @earliest_arrival    = Array.new(MAX_STATIONS, INF)
    #puts "size #{@in_connection.size}"
    #puts "size #{@earliest_arrival.size}"

    @earliest_arrival[departure_station] = departure_time;

    if departure_station <= MAX_STATIONS && arrival_station <= MAX_STATIONS
      main_loop(arrival_station)
    end

    print_result(arrival_station)
  end
end

def main
  csa = CSA.new

  loop do
    line = STDIN.gets
    break if !line || line.strip.empty?
    tokens = line.split(" ")
    csa.compute(tokens[0].to_u32, 
                tokens[1].to_u32, 
                tokens[2].to_u32)
  end
end

main

