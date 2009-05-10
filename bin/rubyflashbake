#!/usr/bin/env ruby	

# ruby-flashbake
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../lib/rubyflashbake/options"
require "#{File.dirname(__FILE__)}/../lib/rubyflashbake/core"

# startup and read configuration
options = RubyFlashbakeOptions.new(ARGV)

# if options read successfull, go read configuration file
rfb = RubyFlashbake.new
rfb.load_file(options.config_file)
rfb.configure_git(Dir.pwd)
rfb.configure_github(Dir.pwd)
rfb.load_plugins
rfb.setup_watch_commits(Dir.pwd)
puts "startup commit and push"
rfb.git_commit(Dir.pwd, rfb.checkin_comment)
rfb.start_directory_watchers
puts "hit return to stop watching directory"
gets
rfb.stop_directory_watchers
puts "exit commit and push"
rfb.git_commit(Dir.pwd, rfb.checkin_comment)