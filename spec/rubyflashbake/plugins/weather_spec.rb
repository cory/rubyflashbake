#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/core"
require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/plugins/weather"

describe RubyFlashbake do
  it "should get weather data if @configuration[:INTERNET_ALIVE] is true" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:OUTPUT] = []
      rfb.do_internet
      rfb.do_location
      rfb.do_weather
      if rfb.configuration[:INTERNET_ALIVE]
        rfb.configuration[:LOCATION_CACHE].scan(/(.*),(.*),(.*)/).should_not == ""
        rfb.configuration[:OUTPUT][0].scan(/(.*),(.*),(.*) (.*),(.*)/).should_not == ""
        rfb.configuration[:OUTPUT][1].scan(/(\w+) (\w+)/).should_not == ""
      end
    end
  end

  it "should fail to get weather data if @configuration[:INTERNET_ALIVE] is false" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:PLUGIN][:INTERNET][:OPTIONAL_HASH][:INTERNET_TEST_URI] = "notavalidwebaddressatall.ca"
      rfb.configuration[:OUTPUT] = []
      rfb.do_internet
      rfb.do_location
      rfb.do_weather
      rfb.configuration[:LOCATION_CACHE].should == nil
      rfb.configuration[:OUTPUT][0].should == "offline"
    end
  end
end