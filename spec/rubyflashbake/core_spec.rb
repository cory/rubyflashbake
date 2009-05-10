#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "#{File.dirname(__FILE__)}/../../lib/rubyflashbake/core"

describe RubyFlashbake do
  before :each do
    @stdout_orig = $stdout 
    $stdout = StringIO.new 
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/.git")
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/testdata/testdir/.git")
  end
  
  after :each do
    $stdout = @stdout_orig
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/.git")
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/testdata/testdir/.git")
  end

  it "should print error message and exit if config file isn't found" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("notafile")
    rescue SystemExit => e
      $stdout.string.should == "Configuration file \"notafile\" not loaded before trying to work with it\nPlease make sure code path loads configuration before trying to load plugins.\n"
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
      rfb.check_git_setup("#{File.dirname(__FILE__)}")
    rescue SystemExit => e
      $stdout.string.should == "Configuration not loaded before trying to work with it\nPlease make sure code path loads configuration before trying to load plugins.\n"
      e.status.should == 1
    end
  end
  
  it "should exit with a useful error message if name and email aren't configured" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.check_git_setup("#{File.dirname(__FILE__)}").should == false
    rescue SystemExit => e
      $stdout.string.should == "./spec/rubyflashbake/../../lib/data/.rubyflashbake_example does not have a valid name and email address\nName and email address are needed for the git repository\nPlease fix or use a different configuration file\n"
      e.status.should == 1
    end
  end

  it "if name and email aren't setup and git not configured, dump useful error message and exit" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configure_git("#{File.dirname(__FILE__)}")
    rescue SystemExit => e
      $stdout.string.should == "Can't configure git without git :NAME and :EMAIL configured in config file.\n"
      e.status.should == 1
    end
  end

  it "if name and email are setup and git not configured, configure git in watch directory" do
    rfb = RubyFlashbake.new
    rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
    rfb.configuration[:GIT][:NAME] = "Test Monkey"
    rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
    rfb.configure_git("#{File.dirname(__FILE__)}")
    $stdout.string.scan("Initialized empty Git repository").should_not == []
    rfb.git_configured_in_directory("#{File.dirname(__FILE__)}").should == true
  end
  
  it "if uri, github id, and repository aren't setup and git not configured, dump useful error message and exit" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configure_git("#{File.dirname(__FILE__)}")
      rfb.configure_github("#{File.dirname(__FILE__)}")
    rescue SystemExit => e
      $stdout.string.should == "Initialized empty Git repository in /Users/cory/opensource/rubyflashbake/spec/rubyflashbake/.git/\n\n\nInitialized git in ./spec/rubyflashbake\nCan't configure github without :GITHUB_URI, :GITHUB_ID, and :GITHUB_REPOSITORY configured in config file.\n"
      e.status.should == 1
    end
  end

  it "if uri, github id, and repository are setup and git not configured, configure github in watch directory" do
    begin
      rfb = RubyFlashbake.new
      rfb.load_file("#{File.dirname(__FILE__)}/../../lib/data/.rubyflashbake_example")
      rfb.configuration[:GIT][:NAME] = "Test Monkey"
      rfb.configuration[:GIT][:EMAIL] = "mokey@fake.fake"
      rfb.configuration[:GIT][:USE_GITHUB] = true
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY] = "fake"
      rfb.configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] = "git@github.com"
      rfb.configure_git("#{File.dirname(__FILE__)}")
      rfb.configure_github("#{File.dirname(__FILE__)}")
      rfb.github_configured_in_directory("#{File.dirname(__FILE__)}").should == true
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
    rfb.configure_git("#{File.dirname(__FILE__)}/testdata/testdir/")
    rfb.configure_github("#{File.dirname(__FILE__)}/testdata/testdir/")
    rfb.load_plugins
    output = ""
    rfb.setup_directory_watchers("#{File.dirname(__FILE__)}/testdata/testdir/") do |events, basedir, func|
      events.each do |event|
        if event.type == :stable
          output += "#{basedir} #{event}\n#{func}"
        end
      end
    end
    rfb.start_directory_watchers
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp.txt", "w") {|file| file.puts "foo!"}
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp2.txt", "w") {|file| file.puts "foo!"}
    sleep(10)
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp3.txt", "w") {|file| file.puts "foo!"}
    File.delete("#{File.dirname(__FILE__)}/testdata/testdir/temp3.txt")
    File.delete("#{File.dirname(__FILE__)}/testdata/testdir/temp2.txt")
    File.delete("#{File.dirname(__FILE__)}/testdata/testdir/temp.txt")
    
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
    rfb.configure_git("#{File.dirname(__FILE__)}/testdata/testdir/")
    rfb.configure_github("#{File.dirname(__FILE__)}/testdata/testdir/")
    rfb.load_plugins

    rfb.setup_watch_commits("#{File.dirname(__FILE__)}/testdata/testdir", true) 
    
    rfb.start_directory_watchers
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp.txt", "w") {|file| file.puts "foo!"}
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp2.txt", "w") {|file| file.puts "foo!"}
    sleep(10)
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp3.txt", "w") {|file| file.puts "foo!"}
    File.open("#{File.dirname(__FILE__)}/testdata/testdir/temp3.txt", "a") {|file| file.puts "bar!"}
    File.delete("#{File.dirname(__FILE__)}/testdata/testdir/temp2.txt")
    sleep(10)
    
    rfb.stop_directory_watchers
    
    status = ""
    log = ""
    
    Dir.chdir("#{File.dirname(__FILE__)}/testdata/testdir/") do
      status = `git status`
      log = `git log`
    end
    
    File.delete("#{File.dirname(__FILE__)}/testdata/testdir/temp3.txt")
    File.delete("#{File.dirname(__FILE__)}/testdata/testdir/temp.txt")
    
    status.should == "# On branch master\nnothing to commit (working directory clean)\n"
    log.scan(/commit/).length.should == 2
  end
end