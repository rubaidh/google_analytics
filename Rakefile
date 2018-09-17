require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'
require 'rubyforge'

desc 'Default: run unit tests.'
task :default => :test

task :clean => [:clobber_rdoc, :clobber_package]

desc 'Test the google_analytics plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the google_analytics plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GoogleAnalytics'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

gem_spec = eval(File.read('google_analytics.gemspec'))

Gem::PackageTask.new(gem_spec) do |p|
  p.need_tar = false
  p.need_zip = false
end

desc 'Package and upload the release to rubyforge.'
task :release => [:clean, :package] do |t|
  rubyforge = RubyForge.new.configure
  rubyforge.login
  rubyforge.add_release gem_spec.rubyforge_project, gem_spec.name, gem_spec.version.to_s, "pkg/#{gem_spec.name}-#{gem_spec.version}.gem"
end

begin
  gem 'ci_reporter'
  require 'ci/reporter/rake/test_unit'
  task :bamboo => "ci:setup:testunit"
rescue LoadError
end

task :bamboo => [ :package, :test ]
