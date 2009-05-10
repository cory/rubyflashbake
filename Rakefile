# Rakefile
# Copyright (c) 2009 Cory Ondrejka. All rights reserved.
# See License.txt for licensing details.
require 'rake'
require 'spec/rake/spectask'


desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  unless ENV['NO_RCOV']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--text-report', '--exclude', "spec/"]
  end
end