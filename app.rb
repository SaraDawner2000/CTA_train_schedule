require "sinatra/activerecord"
require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "csv"
require "http"
require "date"
get("/") do
  #read the stops.csv into stops_array variable
  stops_array = CSV.read("stops.csv")
  #select the parent stations into the parent_stations_array by checking if the first element, the station ID, matches the pattern defined in the official CTA API ("4****")
  parent_stations_array = stops_array.select {|stop| stop[0].match(/^4\d{4}$/)}
  #sort the array of arrays by the third element, the full name, alphabetically
  sorted_parent_stations_array = parent_stations_array.sort {|a, b| a[2] <=> b[2]}
  #hashify the array in a "station ID : full station name" format, and save it to a global variable
  $parent_stations_hash = sorted_parent_stations_array.to_h {|stop| [stop[0], stop[2]]}
  erb(:landing_page)
end
get("/result") do
  #create a hash that matches the line codes to a hash that matches the "1" and "5" direction codes to the names of the directions
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
  #create a hash that matches the line codes to the full names of the lines
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
  #pull the station ID from the params hash
  @station_id = params["station"]
  #select the station name from the parent stations hash
  @station = $parent_stations_hash
  @station_name = @station[@station_id]
  #store the station ID in cookies
  cookies.store("station", @station_id)
  #create the API url with the API key secret and the station ID
  api_url = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=#{ENV["CTA_API_KEY"]}&mapid=#{@station_id}&outputType=JSON"
  #get and parse the response
  raw_data = HTTP.get(api_url)
  raw_data_string = raw_data.to_s
  @parsed_data = JSON.parse(raw_data_string)
  #select the neccessary part of the response
  @eta_times = @parsed_data["ctatt"]["eta"]
  #pull all the different lines from the response once to a hash 
  @lines = @eta_times.collect{|instance| instance["rt"]}.uniq
  #hashify the response in a "line: {"1":results that match the line and direction, "5":results that match the line and direction}" format
  @lines_hashed = @lines.map{|line| [line, 
  {"1" => @eta_times.select {|instance| instance["rt"] == line && instance["trDr"] == "1"},
  "5" => @eta_times.select {|instance| instance["rt"] == line && instance["trDr"] == "5"}}
  ]}.to_h

  erb(:result)
end
