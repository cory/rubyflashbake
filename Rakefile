require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rubyflashbake"
    gem.summary = "A Ruby project inspired by Thomas Gideon's python Flashbake project."
    gem.email = "cory.ondrejka@gmail.com"
    gem.homepage = "http://github.com/cory/rubyflashbake"
    gem.authors = ["Cory Ondrejka"]
    gem.version = "0.1.2" 
    gem.homepage = "http://cory.github.com" 
    gem.platform = Gem::Platform::RUBY 
    gem.required_ruby_version = '>=1.8' 
    gem.files = Dir['**/**'] 
    gem.executables = [ 'rubyflashbake' ] 
    gem.test_files = Dir["spec/rspec_suite.rb"] 
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubyflashbake #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  unless ENV['NO_RCOV']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--text-report', '--exclude', "spec/"]
  end
end