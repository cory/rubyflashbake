#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "directory_watcher"

class RubyFlashbake
  attr_reader :configuration

  def initialize
    @configuration = nil
    @filename = nil
    @dw = []
  end
  
  def load_file(file)
    # load the configuration file
    @filename = file
    begin 
      @configuration = YAML.load_file(file)
      @configuration[:GIT_SETUP] = false
      @configuration[:GITHUB_SETUP] = false
    rescue SystemCallError => e
      puts "Configuration file \"#{file}\" not loaded before trying to work with it"
      puts "Please make sure code path loads configuration before trying to load plugins."
      exit 1
    end
  end
  
  def check_config
    unless @configuration
      puts "Configuration not loaded before trying to work with it"
      puts "Please make sure code path loads configuration before trying to load plugins."
      exit 1
    end
  end
  
  def git_configured_in_directory(dir)
    if @configuration[:GIT_SETUP] == true
      return true
    else
      if File.directory?("#{dir}/.git") && File.exists?("#{dir}/.git/config")
        return @configuration[:GIT_SETUP] = true
      else
        return false
      end
    end
  end
  
  def github_configured_in_directory(dir)
    if !git_configured_in_directory(dir)
      return false
    else
      if @configuration[:GITHUB_SETUP] == true
        return true
      else
        contents = File.read("#{dir}/.git/config")
        if contents.scan("\[remote \"origin\"\]") != []
          return @configuration[:GITHUB_SETUP] = true
        else
          return false
        end 
      end
    end
  end
  
  def configure_git(dir)
    if (@configuration[:GIT][:NAME] && @configuration[:GIT][:EMAIL])
      Dir.chdir("#{dir}") do
        puts `git init`
        puts `git config user.name "#{@configuration[:GIT][:NAME]}"`
        puts `git config user.email #{@configuration[:GIT][:EMAIL]}`
        File.open(".gitignore", "w")  do |file| 
          file.puts ".DS_Store\ncoverage/\n.message.tmp\n"
        end
        puts "Initialized git in #{dir}"
        @configuration[:GIT_SETUP] = true
      end
    else
      puts "Can't configure git without git :NAME and :EMAIL configured in config file."
      exit 1
    end
  end

  def configure_github(dir)
    if git_configured_in_directory(dir)
      Dir.chdir("#{dir}") do
        if !@configuration[:GITHUB_SETUP] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY]
          puts `git remote add origin #{configuration[:GIT][:GITHUB_DATA][:GITHUB_URI]}:#{@configuration[:GIT][:GITHUB_DATA][:GITHUB_ID]}/#{@configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY]}.git`
          puts "Initialized github in #{dir}"
          @configuration[:GITHUB_SETUP] = true
        else
          puts "Can't configure github without :GITHUB_URI, :GITHUB_ID, and :GITHUB_REPOSITORY configured in config file."
          exit 1
        end
      end
    else
      puts "Can't configure git without git :NAME and :EMAIL configured in config file."
      exit 1
    end
  end

  def git_commit(dir, message)
    if git_configured_in_directory(dir)
      Dir.chdir("#{dir}") do
        File.open(".message.tmp", "w") {|file| file.puts message}
        puts `git add .`
        puts `git commit -a --file=.message.tmp`
        File.delete(".message.tmp")
        if @configuration[:INTERNET_ALIVE] && @configuration[:GIT][:USE_GITHUB] && @configuration[:GIT_SETUP]
          puts `git push origin master`
        end
      end
    end
  end
        
  def check_git_setup(basedir)
    check_config
    
    unless @configuration[:GIT][:NAME] && @configuration[:GIT][:EMAIL]
      puts "#{@filename} does not have a valid name and email address"
      puts "Name and email address are needed for the git repository"
      puts "Please fix or use a different configuration file"
      exit 1
    end
    
    unless git_configured_in_directory("#{basedir}")
      configure_git("#{basedir}")
    end
  end

  def check_github_setup(basedir)
    check_git_setup(basedir)
    
    unless @configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY]
      puts "#{@filename} does not have a valid github uri, id, and repository"
      puts "They are needed to connect to github"
      puts "Please fix or use a different configuration file"
      exit 1
    end
    
    unless github_configured_in_directory("#{basedir}")
      configure_github("#{basedir}")
    end
  end

  def load_plugins
    check_config

    @configuration[:PLUGIN_DIRECTORIES].each do |dir|
      libdir = File.dirname(__FILE__)
      pattern = File.join(libdir, "#{dir}", "*.rb")
      Dir.glob(pattern).each do |file|
        require file
      end
    end
  end
  
  def setup_directory_watchers(basedir, &block)
    check_config
    
    dw = DirectoryWatcher.new("#{basedir}")
    dw.interval = @configuration[:DIRECTORY_MONITOR_INTERVAL]
    dw.stable = @configuration[:STABLE_INTERVALS]
    dw.glob = "**/*"

    dw.add_observer do |*events|
      block.call(events, basedir, checkin_comment)
    end
    @dw.push dw
  end

  def setup_watch_commits(bdir, verbose)
    setup_directory_watchers(bdir) do |events, basedir, func|
      events.each do |event|
        if event.type == :stable
          puts "#{event}" if verbose
          git_commit("#{basedir}", func)
        end
      end
    end
  end
  
  def start_directory_watchers
    @dw.each do |dw| 
      dw.start
    end
  end
  
  def stop_directory_watchers
    @dw.each {|dw| dw.stop}
  end
  
  def checkin_comment
    @configuration[:OUTPUT] = []
    do_internet
    do_location
    do_weather
    do_time
    do_twitter
    @configuration[:OUTPUT].to_yaml
  end
end