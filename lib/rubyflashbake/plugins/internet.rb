#!/usr/bin/env ruby	

# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require 'ping'

class RubyFlashbake
  def do_internet
    @configuration[:INTERNET_ALIVE] = false
    if @configuration[:PLUGIN][:INTERNET][:ACTIVE]
      @configuration[:INTERNET_ALIVE] = Ping.pingecho(@configuration[:PLUGIN][:INTERNET][:OPTIONAL_HASH][:INTERNET_TEST_URI],2,80)
      unless @configuration[:INTERNET_ALIVE]
        @configuration[:OUTPUT].push "offline"
      end
    end
  end
end