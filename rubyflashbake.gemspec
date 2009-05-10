Gem::Specification.new do |s|
  s.name = %q{rubyflashbake}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cory Ondrejka"]
  s.date = %q{2009-04-04}
  s.default_executable = %q{rubyflashbake}
  s.email = ["cory.ondrejka@gmail.com"]
  s.executables = ["rubyflashbake"]
  s.files = ["bin/rubyflashbake.rb", 
             "lib/rubyflashbake", 
             "lib/rubyflashbake/core.rb", 
             "lib/rubyflashbake/options.rb", 
             "lib/rubyflashbake/plugins", 
             "lib/rubyflashbake/plugins/internet.rb", 
            "lib/rubyflashbake/plugins/location.rb", "lib/rubyflashbake/plugins/time.rb", "lib/rubyflashbake/plugins/twitter.rb", "lib/rubyflashbake/plugins/weather.rb", "License.txt", "Rakefile", "README.textile", "rubyflashbake.gemspec", "spec", "spec/rspec_suite.rb", "spec/rubyflashbake", "spec/rubyflashbake/core_spec.rb", "spec/rubyflashbake/options_spec.rb", "spec/rubyflashbake/plugins", "spec/rubyflashbake/plugins/internet_spec.rb", "spec/rubyflashbake/plugins/location_spec.rb", "spec/rubyflashbake/plugins/time_spec.rb", "spec/rubyflashbake/plugins/twitter_spec.rb", "spec/rubyflashbake/plugins/weather_spec.rb", "spec/rubyflashbake/testdata", "spec/rubyflashbake/testdata/testdir", "TODOS"]
  
  s.has_rdoc = false
  s.require_paths = ["lib"]
  s.summary = %q{rubyflashbake was inspired by Thomas Gideon's python Flashbake project.}
  s.test_files = ["spec/rspec_suite.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
    s.add_dependency(%q<directory_watcher>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<grit>, [">= 0"])
  end
end
