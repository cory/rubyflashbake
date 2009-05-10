#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/core"
require "#{File.dirname(__FILE__)}/../../../lib/rubyflashbake/plugins/time"

describe RubyFlashbake do
  it "should pull time data" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../../lib/data/.rubyflashbake_example")
      rfb.load_plugins
      rfb.configuration[:OUTPUT] = []
      rfb.do_time
      # "Sat Apr 18 21:48:25 2009 PDT"
      rfb.configuration[:OUTPUT][0].scan(/(\w*) (\w*) (\d*) (\d*):(\d*):(\d*) (\d*) (\w*)/).should_not == ""
    end
  end
end