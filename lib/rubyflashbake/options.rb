#!/usr/bin/env ruby	

# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "optparse"

class RubyFlashbakeOptions
  DEFAULT_CONFIG_FILE = ".rubyflashbake"
  attr_reader :config_file
  
  def initialize(argv)
    @config_file = DEFAULT_CONFIG_FILE
    parse(argv)
  end
  
  def test(val)
    [:config_file => @config_file] == val
  end
  
  private
  def parse(argv)
    OptionParser.new do |opts|
      opts.banner = "Usage: rubyflashbake [ options ]"
      
      opts.on("-c [file]", "--config [file]", "Use config file [file]") do |file|
        @config_file = file if file
      end
      
      opts.on("-e", "--example", "Dump an example, annotated config file to stdout and exit") do
        example = File.read("#{File.dirname(__FILE__)}/../data/.rubyflashbake_example")
        puts example
        exit
      end
            
      opts.on("-v", "--version", "Dump version number") do
        yml = YAML.load(File.read(File.join(File.dirname(__FILE__), *%w[.. .. VERSION.yml])))
        puts "rubyflashbake #{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
        exit
      end

      opts.on("-h", "--help", "You're looking at it.  Functionality documented in config file and on first run.") do
        puts opts
        exit
      end
      
      begin
        opts.parse!(argv)
      rescue OptionParser::ParseError => e
        puts opts
        exit(1)
      end
    end
  end
end
