require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "csv"
require "http"
require "date"
get("/") do
  stops_array = CSV.read("stops.csv")
  parent_stations_array = stops_array.select {|stop| stop[0].match(/^4\d{4}$/)}
  sorted_parent_stations_array = parent_stations_array.sort {|a, b| a[2] <=> b[2]}
  $parent_stations_hash = sorted_parent_stations_array.to_h {|stop| [stop[0], stop[2]]}
  erb(:landing_page)
end
get("/result") do
  @line_direction_hash = {
    "Red" => {"1" => "Howard-bound", "5" => "95th/Dan Ryan-bound"},
    "P" => {"1" => "Linden-bound", "5" => "Howard- or Loop-bound"},
    "Y" => {"1" => "Skokie-bound", "5" => "Howard-bound"},
    "Blue" => {"1" => "O\'Hare-bound", "5" => "Forest Park-bound"},
    "Pink" => {"1" => "Loop-bound", "5" => "54th/Cermak-bound"},
    "G" => {"1" => "Harlem/Lake-bound", "5" => "Ashland/63rd- or Cottage Grove-bound"},
    "Org" => {"1" => "Loop-bound", "5" => "Midway-bound"},
    "Brn" => {"1" => "Kimball-bound", "5" => "Loop-bound"},
  }
  @line_name_hash = {
    "Red" => "Red Line",
    "P" => "Purple Line",
    "Y" => "Yellow Line",
    "Blue" => "Blue Line",
    "Pink" => "Pink Line",
    "G" => "Green Line",
    "Org" => "Orange Line",
    "Brn" => "Brown Line",
  }
  direction = params["direction"]
  @station_id = params["station"]
  @station = $parent_stations_hash
  @station_name = @station[@station_id]
  cookies.store("station", @station_name)
  api_url = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=#{ENV["CTA_API_KEY"]}&mapid=#{@station_id}&outputType=JSON"
  raw_data = HTTP.get(api_url)
  raw_data_string = raw_data.to_s
  @parsed_data = JSON.parse(raw_data_string)
  @eta_times = @parsed_data["ctatt"]["eta"]
  @lines = @eta_times.collect{|instance| instance["rt"]}.uniq

  @lines_hashed = @lines.map{|line| [line, 
  {"1" => @eta_times.select {|instance| instance["rt"] == line && instance["trDr"] == "1"},
  "5" => @eta_times.select {|instance| instance["rt"] == line && instance["trDr"] == "5"}}
  ]}.to_h

  erb(:result)
end
