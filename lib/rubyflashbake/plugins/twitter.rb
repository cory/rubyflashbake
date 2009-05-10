#!/usr/bin/env ruby	

# time plug in
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require 'net/http'
require "hpricot"

class RubyFlashbake
  def do_twitter
    if @configuration[:PLUGIN][:TIME][:ACTIVE] && @configuration[:INTERNET_ALIVE] && @configuration[:PLUGIN][:TWITTER][:OPTIONAL_HASH][:TWITTER_ID]
      xml = Net::HTTP.get(URI.parse("http://twitter.com/statuses/user_timeline/#{@configuration[:PLUGIN][:TWITTER][:OPTIONAL_HASH][:TWITTER_ID]}.xml"))
      doc = Hpricot(xml)
      wrote = false
      (0..2).each do |i|
        if ((doc/"status"/"created_at")[i])
          wrote = true
          @configuration[:OUTPUT].push "Twitter: #{(doc/"status"/"created_at")[i].inner_html} #{(doc/"status"/"text")[i].inner_html}"
        end
      end
      @configuration[:OUTPUT] = ["Couldn't reach twitter"] unless wrote
    end
  end
end