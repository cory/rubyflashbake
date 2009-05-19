#!/usr/bin/env ruby	

# options_spec
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../lib/rubyflashbake/options"

RubyFlashbakeOptionHelp = <<-EOF
Usage: rubyflashbake [ options ]
    -c, --config [file]              Use config file [file]
    -e, --example                    Dump an example, annotated config file to stdout and exit
    -v, --version                    Dump version number
    -h, --help                       You're looking at it.  Use --example to dump the config file.
EOF

describe RubyFlashbakeOptions do
  before :each do
    @stdout_orig = $stdout 
    $stdout = StringIO.new 
  end
  
  after :each do
    $stdout = @stdout_orig
  end
  
  it "should default to config file .rubyflashbake, example false" do
    RubyFlashbakeOptions.new([]).test([:config_file => ".rubyflashbake"]).should == true
  end
  
  it "should read from config file if -c given without a file" do
    RubyFlashbakeOptions.new(["-c"]).test([:config_file => ".rubyflashbake"]).should == true
  end

  it "should read from config file if --config given without a file" do
    RubyFlashbakeOptions.new(["--config"]).test([:config_file => ".rubyflashbake"]).should == true
  end

  it "should read from config file if -c foo option given" do
    RubyFlashbakeOptions.new(["-c", "foo"]).test([:config_file => "foo"]).should == true
  end

  it "should read from config file if --config foo option given" do
    RubyFlashbakeOptions.new(["--config", "foo"]).test([:config_file => "foo"]).should == true
  end

  it "should dump version and exit if -v option given" do
    begin
      RubyFlashbakeOptions.new(["-v"])
    rescue SystemExit => e
      $stdout.string.scan(/\d+\.\d+\.\d+/).should_not == []
      e.status.should == 0
    end
  end

  it "should dump version and exit if -v option given" do
    begin
      RubyFlashbakeOptions.new(["--version"])
    rescue SystemExit => e
      $stdout.string.scan(/\d+\.\d+\.\d+/).should_not == []
      e.status.should == 0
    end
  end

  it "should print out help when -h is requested or not input" do
    begin
      RubyFlashbakeOptions.new(["-h"])
    rescue SystemExit => e
      $stdout.string.should == RubyFlashbakeOptionHelp
      e.status.should == 0
    end
  end

  it "should print out help when --help is requested or not input" do
    begin
      RubyFlashbakeOptions.new(["--help"])
    rescue SystemExit => e
      $stdout.string.should == RubyFlashbakeOptionHelp
      e.status.should == 0
    end
  end

  it "should handle junk by dumping help and exiting" do
    begin
      RubyFlashbakeOptions.new(["-this is -junky junk"]).should == true
    rescue SystemExit => e
      $stdout.string.should == RubyFlashbakeOptionHelp
      e.status.should == 1
    end
  end

  it "should dump example config file to stdout if -e given" do
    begin
      RubyFlashbakeOptions.new(["-e"])
    rescue SystemExit => e
      $stdout.string.should == File.read("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      e.status.should == 0
    end
  end

  it "should dump example config file to stdout if --example given" do
    begin
      RubyFlashbakeOptions.new(["--example"])
    rescue SystemExit => e
      $stdout.string.should == File.read("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      e.status.should == 0
    end
  end
end
