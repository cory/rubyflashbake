#!/usr/bin/env ruby	

# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require 'net/http'
class RubyFlashbake
  def do_weather
    @configuration[:OUTPUT].push "No valid weather found"
    if @configuration[:PLUGIN][:WEATHER][:ACTIVE] && @configuration[:INTERNET_ALIVE]
      if @configuration[:LOCATION_CACHE]
        weather = Net::HTTP.get(URI.parse("http://www.google.com/ig/api?weather=#{@configuration[:LOCATION_CACHE]}"))
        if weather =~ /temp_f data=\"(\d+)\"/ && weather =~ /condition data=\"([\s\w]+)\"/
          @configuration[:OUTPUT].push "#{weather.scan(/temp_f data=\"(\d+)\"/)[0][0]} #{weather.scan(/condition data=\"([\s\w]+)\"/)[0][0]}"
        end
      end
    end
  end
end