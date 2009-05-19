#!/usr/bin/env ruby
      
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.

require "rubygems"
require "directory_watcher"

class RubyFlashbake
  attr_reader :configuration

  def initialize
    @configuration = nil
    @filename = nil
    @dw = []
    @plugins = []
  end
  
  def load_file(file)
    # load the configuration file
    @filename = file
    begin 
      @configuration = YAML.load_file(file)
      @configuration[:GIT_SETUP] = false
      @configuration[:GITHUB_SETUP] = false
    rescue SystemCallError => e
      puts "Configuration file \"#{file}\" not found!"
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
  
  def configure_git(dir)
    check_config
    unless @configuration[:GIT_SETUP] == true
      if File.directory?("#{dir}/.git") && File.exists?("#{dir}/.git/config")
        @configuration[:GIT_SETUP] = true
      else
        if (@configuration[:GIT][:NAME] && @configuration[:GIT][:EMAIL])
          Dir.chdir("#{dir}") do
            system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} init")
            system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} config user.name \"#{@configuration[:GIT][:NAME]}\"")
            system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} config user.email \"#{@configuration[:GIT][:EMAIL]}\"")
            File.open(".gitignore", "w")  do |file| 
              file.puts ".DS_Store\n.message.tmp\n"
            end
            puts "Initialized git in #{dir}"
            @configuration[:GIT_SETUP] = true
          end
        else
          puts "Can't configure git without git :NAME and :EMAIL configured in config file."
          exit 1
        end
      end
    end
    return true
  end
  
  def configure_github(dir)
    check_config
    unless @configuration[:GIT_SETUP] == true
      puts "Trying to configure github without previous call to config_git."
      exit 1
    end
    unless @configuration[:GITHUB_SETUP] == true
      if File.exists?("#{dir}/.git/config")
        contents = File.read("#{dir}/.git/config")
      end
      if contents =~ /\[remote \"origin\"\]/
        @configuration[:GITHUB_SETUP] = true
      else
        Dir.chdir("#{dir}") do
          if !@configuration[:GITHUB_SETUP] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_URI] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_ID] && @configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY]
            system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} remote add origin #{configuration[:GIT][:GITHUB_DATA][:GITHUB_URI]}:#{@configuration[:GIT][:GITHUB_DATA][:GITHUB_ID]}/#{@configuration[:GIT][:GITHUB_DATA][:GITHUB_REPOSITORY]}.git")
            puts "Initialized github in #{dir}"
            @configuration[:GITHUB_SETUP] = true
          else
            puts "Can't configure github without :GITHUB_URI, :GITHUB_ID, and :GITHUB_REPOSITORY configured in config file."
            exit 1
          end
        end
      end
    end
    Dir.chdir("#{dir}") do
      system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} pull origin master")
    end
    return true
  end

  def git_commit(dir, message)
    if @configuration[:GIT_SETUP] == true
      Dir.chdir("#{dir}") do
        File.open(".message.tmp", "w") {|file| file.puts message}
        system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} add .")
        system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} commit -a --file=.message.tmp")
        File.delete(".message.tmp")
        if @configuration[:INTERNET_ALIVE] && @configuration[:GIT][:USE_GITHUB] && @configuration[:GITHUB_SETUP]
          system("git --git-dir=#{Dir.pwd}/.git --work-tree=#{Dir.pwd} push origin master")
        end
      end
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

    @configuration[:PLUGIN_CALL_ORDER].each {|p| @plugins.push p }
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

  def setup_watch_commits(bdir)
    setup_directory_watchers(bdir) do |events, basedir, func|
      events.each do |event|
        if event.type == :stable
          puts "#{event}" if @configuration[:VERBOSE]
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
  
  def do_plugins
    @plugins.each do |p|
      send "do_#{p.to_s.downcase}"
    end
  end
  
  def checkin_comment
    @configuration[:OUTPUT] = []
    do_plugins
    @configuration[:OUTPUT].to_yaml
  end
end