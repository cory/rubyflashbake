#!/usr/bin/env ruby	

# time plug in
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require 'net/http'

class RubyFlashbake
  def do_location
    if @configuration[:PLUGIN][:LOCATION][:ACTIVE] && @configuration[:INTERNET_ALIVE]
      location = Net::HTTP.get(URI.parse("http://j.maxmind.com/app/geoip.js"))
      location_array = location.scan(/return \'(.*)\'/)
      @configuration[:LOCATION_CACHE] = "#{location_array[2][0]},#{location_array[3][0]},#{location_array[0][0]}"
      @configuration[:OUTPUT].push "#{@configuration[:LOCATION_CACHE]} #{location_array[5][0]},#{location_array[6][0]}"
    end
  end
end