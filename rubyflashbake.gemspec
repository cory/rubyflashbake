spec = Gem::Specification.new do |s| 
  s.name = "rubyflashbake" 
  s.summary = "A Ruby project inspired by Thomas Gideon’s python Flashbake project" 
  s.version = "0.1.7"
  s.author = "Cory Ondrejka" 
  s.email = "cory.ondrejka@gmail.com" 
  s.homepage = "http://cory.github.com" 
  s.platform = Gem::Platform::RUBY 
  s.required_ruby_version = '>=1.8' 
  s.files = [
    "bin/rubyflashbake",
    "lib/data/.rubyflashbake_example",
    "lib/rubyflashbake/core.rb",
    "lib/rubyflashbake/options.rb",
    "lib/rubyflashbake/plugins/internet.rb",
    "lib/rubyflashbake/plugins/location.rb",
    "lib/rubyflashbake/plugins/time.rb",
    "lib/rubyflashbake/plugins/twitter.rb",
    "lib/rubyflashbake/plugins/weather.rb",
    "License.txt",
    "README.rdoc",
    "README.textile",
    "VERSION.yml",
    "spec/rspec_suite.rb",
    "spec/rubyflashbake/core_spec.rb",
    "spec/rubyflashbake/options_spec.rb",
    "spec/rubyflashbake/plugins/internet_spec.rb",
    "spec/rubyflashbake/plugins/location_spec.rb",
    "spec/rubyflashbake/plugins/time_spec.rb",
    "spec/rubyflashbake/plugins/twitter_spec.rb",
    "spec/rubyflashbake/plugins/weather_spec.rb",
    "spec/rubyflashbake/testdata/testdir/.gitignore",
    ]
  s.default_executable = %q{rubyflashbake}
  s.executables = [ 'rubyflashbake' ] 
end 