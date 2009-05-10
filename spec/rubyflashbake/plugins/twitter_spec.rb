#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/core"
require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/plugins/twitter"

describe RubyFlashbake do
  it "should pull last 3 tweets from twitter account if @configuration[:INTERNET_ALIVE] is true and @configuration[:PLUGIN][:TWITTER][:OPTIONAL_HASH][:TWITTER_ID] is set" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:OUTPUT] = []
      rfb.configuration[:PLUGIN][:TWITTER][:OPTIONAL_HASH][:TWITTER_ID] = "github"
      rfb.do_internet
      rfb.do_twitter
      rfb.configuration[:OUTPUT][0].scan(/Twitter: .*/).should_not == ""
    end
  end

  it "should fail to get location data if @configuration[:INTERNET_ALIVE] is false or @configuration[:PLUGIN][:TWITTER][:OPTIONAL_HASH][:TWITTER_ID] is set" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:PLUGIN][:INTERNET][:OPTIONAL_HASH][:INTERNET_TEST_URI] = "notavalidwebaddressatall.ca"
      rfb.configuration[:OUTPUT] = []
      rfb.do_internet
      rfb.do_twitter
      rfb.configuration[:OUTPUT][0].should == "Couldn't reach twitter"
    end
  end
end