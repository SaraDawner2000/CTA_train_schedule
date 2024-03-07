require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "csv"

get("/") do
  stops_array = CSV.read("stops.csv")
  parent_stations_array = stops_array.select {|stop| stop[0].match(/^4\d{4}$/)}
  sorted_parent_stations_array = parent_stations_array.sort {|a, b| a[2] <=> b[2]}
  @parent_stations_hash = sorted_parent_stations_array.to_h {|stop| [stop[0], stop[2]]}
  erb(:landing_page)
end
get("/result") do
  erb(:result)
end
