#!/usr/bin/env ruby	

# time plug in
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require 'net/http'

class RubyFlashbake
  def do_weather
    if @configuration[:PLUGIN][:WEATHER][:ACTIVE] && @configuration[:INTERNET_ALIVE]
      unless @configuration[:LOCATION_CACHE]
        do_location
      end
      if @configuration[:LOCATION_CACHE]
        weather = Net::HTTP.get(URI.parse("http://www.google.com/ig/api?weather=#{@configuration[:LOCATION_CACHE]}"))
        $stderr.puts weather.scan(/temp_f data=\"(\d+)\"/)
        if (weather.scan(/temp_f data=\"(\d+)\"/) != [] && weather.scan(/condition data=\"([\s\w]+)\"/) != [])
          @configuration[:OUTPUT].push "#{weather.scan(/temp_f data=\"(\d+)\"/)[0][0]} #{weather.scan(/condition data=\"([\s\w]+)\"/)[0][0]}"
        else
          @configuration[:OUTPUT].push "No valid weather found"
        end
      end
    end
  end
end