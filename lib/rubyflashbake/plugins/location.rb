#!/usr/bin/env ruby	

# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require 'net/http'

class RubyFlashbake
  def do_location
    if @configuration[:PLUGIN][:LOCATION][:ACTIVE] && @configuration[:INTERNET_ALIVE]
      location = Net::HTTP.get(URI.parse("http://j.maxmind.com/app/geoip.js"))
      location_array = location.scan(/return \'(.*)\'/)
      @configuration[:LOCATION_CITY] = "#{location_array[2][0]}"
      @configuration[:LOCATION_STATE] = "#{location_array[3][0]}"
      @configuration[:LOCATION_COUNTRY] = "#{location_array[0][0]}"
      if @configuration[:LOCATION_COUNTRY] == "US"
        @configuration[:LOCATION_CACHE] = "#{@configuration[:LOCATION_CITY]},#{@configuration[:LOCATION_STATE]},#{@configuration[:LOCATION_COUNTRY]}"
      else
        @configuration[:LOCATION_CACHE] = "#{@configuration[:LOCATION_CITY]},#{@configuration[:LOCATION_COUNTRY]}"
      end
      @configuration[:OUTPUT].push "#{@configuration[:LOCATION_CACHE]} #{location_array[5][0]},#{location_array[6][0]}"
    end
  end
end