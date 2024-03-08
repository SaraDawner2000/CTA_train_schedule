require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "csv"
require "http"

get("/") do
  stops_array = CSV.read("stops.csv")
  parent_stations_array = stops_array.select {|stop| stop[0].match(/^4\d{4}$/)}
  sorted_parent_stations_array = parent_stations_array.sort {|a, b| a[2] <=> b[2]}
  $parent_stations_hash = sorted_parent_stations_array.to_h {|stop| [stop[0], stop[2]]}
  erb(:landing_page)
end
get("/result") do
  direction = params["direction"]
  station_id = params["station"]
  @station = $parent_stations_hash
  @station_name = @station[station_id]
  api_url = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=#{ENV["CTA_API_KEY"]}&mapid=#{station_id}&outputType=JSON"
  raw_data = HTTP.get(api_url)
  raw_data_string = raw_data.to_s
  @parsed_data = JSON.parse(raw_data_string)
  eta_times = @parsed_data["ctatt"]["eta"]
  line_color = @parsed_data
  erb(:result)
end
