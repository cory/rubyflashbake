#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../lib/rubyflashbake/core"

describe RubyFlashbake do
  before :all do
    @testdirectory = "#{File.dirname(__FILE__)}/../../../rubyflashbake_testing"
    ENV["GIT_DIR"] = nil
    ENV["GIT_WORK_TREE"] = nil
    ENV["GIT_INDEX_FILE"] = nil
  end
  
  before :each do
    @stdout_orig = $stdout 
    $stdout = StringIO.new 
    FileUtils.rm_rf("#{@testdirectory}")
    FileUtils.mkdir("#{@testdirectory}")
  end
  
  after :each do
    $stdout = @stdout_orig
    FileUtils.rm_rf("#{@testdirectory}")
  end

  it "should print error message and exit if config file isn't found" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("notafile")
    rescue SystemExit => e
      $stdout.string.should == "Configuration file \"notafile\" not found!\nPlease make sure code path loads configuration before trying to load plugins.\n"
      e.status.should == 1
    end
  end
  
  it "should read in config file as YAML and return hash if file is found" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    test = YAML.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    test[:GIT_SETUP] = false
    test[:GITHUB_SETUP] = false
    
    rfb.configuration.should == test
  end
  
  it "should complain if git name and email address aren't filled in" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
  end
  
  it "should exit if you try to examine git config without loading config file" do
    begin
      rfb = RubyFlashbake.new
      rfb.configure_git("#{@testdirectory}")
    rescue SystemExit => e
      $stdout.string.should == "Configuration not loaded before trying to work with it\nPlease make sure code path loads configuration before trying to load plugins.\n"
      e.status.should == 1
    end
  end
  
  it "should exit with a useful error message if name and email aren't configured" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configure_git("#{@testdirectory}").should == false
    rescue SystemExit => e
      $stdout.string.should == "Can't configure git without git :NAME and :EMAIL configured in config file.\n"
      e.status.should == 1
    end
  end

  it "should configure git in watch directiory if name and email are setup and git not configured" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    rfb.configuration[:GIT][:NAME] = "Test Monkey"
    rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
    rfb.configure_git("#{@testdirectory}").should == true
    $stdout.string.scan("Initialized git").should_not == []
  end
  
  it "should be able to call configure_git multiple times once git is setup" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configure_git("#{@testdirectory}").should == true
      rfb.configure_git("#{@testdirectory}").should == true
    end
  end

  it "should find .git and .git/config files as signal that git was setup in directory before" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      Dir.mkdir("#{@testdirectory}/.git")
      File.open("#{@testdirectory}/.git/config", "w") {|file| file.puts "foo!"}
      rfb.configure_git("#{@testdirectory}").should == true
    end
  end

  it "should dump useful error message if uri, github id, and repository aren't setup and git not configured" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configure_git("#{@testdirectory}")
      rfb.configure_github("#{@testdirectory}")
    rescue SystemExit => e
      $stdout.string.should == "Initialized git in ./spec/rubyflashbake/../../../rubyflashbake_testing\nCan't configure github without :GITHUB_URI, :GITHUB_ID, and :GITHUB_REPOSITORY configured in config file.\n"
      e.status.should == 1
    end
  end

  it "should configure github if uri, github id, and repository are setup and git not configured" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configuration[:GIT][:USE_GITHUB] = true
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] = "git@github.com"
      rfb.configure_git("#{@testdirectory}")
      rfb.configure_github("#{@testdirectory}").should == true
    end
  end

  it "should fail if trying to configure github without first configuring git" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configuration[:GIT][:USE_GITHUB] = true
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] = "git@github.com"
      rfb.configure_github("#{@testdirectory}")
    rescue SystemExit => e
      $stdout.string.should == "Trying to configure github without previous call to config_git.\n"
    end
  end

  it "should find .git and .git/config files as signal that git was setup in directory before" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      Dir.mkdir("#{@testdirectory}/.git")
      File.open("#{@testdirectory}/.git/config", "w") {|file| file.puts "[remote origin]"}
      rfb.configure_git("#{@testdirectory}").should == true
    end
  end

  it "should be fine to repated configure github" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configuration[:GIT][:USE_GITHUB] = true
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] = "git@github.com"
      rfb.configure_git("#{@testdirectory}")
      rfb.configure_github("#{@testdirectory}").should == true
      rfb.configure_github("#{@testdirectory}").should == true
    end
  end

  it "should define a plugin directory" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    rfb.configuration[:PLUGIN_DIRECTORIES][0].should == "plugins"
  end
  
  it "should exit if you try to load plugins without loading config file" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_plugins
    rescue SystemExit => e
      $stdout.string.should == "Configuration not loaded before trying to work with it\nPlease make sure code path loads configuration before trying to load plugins.\n"
      e.status.should == 1
    end
  end
  
  it "should load files from the specified plugins directory" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    rfb.load_plugins
    files = Dir.glob("#{File.dirname(__FILE__)}/../../lib/rubyflashbake/#{rfb.configuration[:PLUGIN_DIRECTORIES]}/*.rb")
    files.each do |file|
      basename = File.basename(file, ".rb")
      RubyFlashbake.method_defined?("do_#{basename}").should == true
    end
  end
  
  it "should setup directory watchers as specified in the in config file" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    rfb.configuration[:GIT][:NAME] = "Test Monkey"
    rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
    rfb.configuration[:GIT][:USE_GITHUB] = true
    rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] = "fake"
    rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY] = "fake"
    rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] = "git@github.com"
    rfb.configuration[:DIRECTORY_MONITOR_INTERVAL] = 1
    rfb.configuration[:STABLE_INTERVALS] = 1
    rfb.configure_git("#{@testdirectory}")
    rfb.configure_github("#{@testdirectory}")
    rfb.load_plugins
    output = ""
    rfb.setup_directory_watchers("#{@testdirectory}") do |events, basedir, func|
      events.each do |event|
        if event.type == :stable
          output += "#{basedir} #{event}\n#{func}"
        end
      end
    end
    rfb.start_directory_watchers
    File.open("#{@testdirectory}/temp.txt", "w") {|file| file.puts "foo!"}
    File.open("#{@testdirectory}/temp2.txt", "w") {|file| file.puts "foo!"}
    sleep(10)
    File.open("#{@testdirectory}/temp3.txt", "w") {|file| file.puts "foo!"}
    File.delete("#{@testdirectory}/temp3.txt")
    File.delete("#{@testdirectory}/temp2.txt")
    File.delete("#{@testdirectory}/temp.txt")
    
    output.scan(/temp\.txt/).should_not == []
    output.scan(/temp2\.txt/).should_not == [] 
    output.scan(/temp3\.txt/).should == [] 

    rfb.stop_directory_watchers
  end
  
  it "should commit changes on stable files with the commit message" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    rfb.configuration[:GIT][:NAME] = "Test Monkey"
    rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
    rfb.configuration[:GIT][:USE_GITHUB] = true
    rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] = "fake"
    rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY] = "fake"
    rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] = "git@github.com"
    rfb.configuration[:DIRECTORY_MONITOR_INTERVAL] = 1
    rfb.configuration[:STABLE_INTERVALS] = 1
    rfb.configure_git("#{@testdirectory}")
    rfb.configure_github("#{@testdirectory}")
    rfb.load_plugins

    rfb.setup_watch_commits("#{@testdirectory}") 
    
    rfb.start_directory_watchers
    File.open("#{@testdirectory}/temp.txt", "w") {|file| file.puts "foo!"}
    File.open("#{@testdirectory}/temp2.txt", "w") {|file| file.puts "foo!"}
    sleep(10)
    File.open("#{@testdirectory}/temp3.txt", "w") {|file| file.puts "foo!"}
    File.open("#{@testdirectory}/temp3.txt", "a") {|file| file.puts "bar!"}
    File.delete("#{@testdirectory}/temp2.txt")
    sleep(10)
    
    rfb.stop_directory_watchers
    
    status = ""
    log = ""
    
    status = `git --git-dir=#{@testdirectory}/.git --work-tree=#{@testdirectory} status`
    $stderr.puts "status: #{status}"
    log = `git --git-dir=#{@testdirectory}/.git --work-tree=#{@testdirectory} log`
    $stderr.puts "log: #{log}"
    
    status.scan(/nothing to commit/).should_not == []
    log.scan(/commit/).length.should == 2
  end
end