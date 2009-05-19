#!/usr/bin/env ruby	

# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

class RubyFlashbake
  def do_time
    if @configuration[:PLUGIN][:TIME][:ACTIVE]
      @configuration[:OUTPUT].push "#{Time.now.ctime} #{Time.now.zone}"
    end
  end
end