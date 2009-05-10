#!/usr/bin/env ruby	

# ruby-flashbake
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "rubygems"
require "#{File.dirname(__FILE__)}/../lib/rubyflashbake/options"
require "#{File.dirname(__FILE__)}/../lib/rubyflashbake/core"

# startup and read configuration
options = RubyFlashbakeOptions.new(ARGV)

# if options read successfull, go read configuration file
rfb = RubyFlashbake.new
rfb.load_file(options.config_file)
rfb.check_git_setup(Dir.pwd)
rfb.load_plugins
rfb.setup_watch_commits(Dir.pwd, true)
rfb.start_directory_watchers
puts "hit return to stop watching directory"
gets
rfb.stop_directory_watchers
