#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/core"
require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/plugins/internet"

describe RubyFlashbake do
  it "should set up @configuration[:INTERNET_ALIVE] to true if computer can ping the net" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:OUTPUT] = []
      rfb.do_internet
      unless rfb.configuration[:OUTPUT][0] == "offline"
        rfb.configuration[:INTERNET_ALIVE].should == true
      end
    end
  end

  it "should set up @configuration[:INTERNET_ALIVE] to false if computer can't ping the net" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:PLUGIN][:INTERNET][:OPTIONAL_HASH][:INTERNET_TEST_URI] = "notavalidwebaddressatall.ca"
      rfb.configuration[:OUTPUT] = []
      rfb.do_internet
      rfb.configuration[:INTERNET_ALIVE].should == false
    end
  end
end