spec = Gem::Specification.new do |s| 
  s.name = "rubyflashbake" 
  s.summary = "A Ruby project inspired by Thomas Gideon’s python Flashbake project" 
  s.description= File.read(File.join(File.dirname(__FILE__), 'README.textile')) 
  s.version = "0.1.0" 
  s.author = "Cory Ondrejka" 
  s.email = "cory.ondrejka@gmail.com" 
  s.homepage = "http://cory.github.com" 
  s.platform = Gem::Platform::RUBY 
  s.required_ruby_version = '>=1.8' 
  s.files = Dir['**/**'] 
  s.executables = [ 'rubyflashbake' ] 
  s.test_files = Dir["spec/rspec_suite.rb"] 
  s.has_rdoc = false 
end 