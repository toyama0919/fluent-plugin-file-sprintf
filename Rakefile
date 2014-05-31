require 'bundler'
require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/plugin/*.rb']
  test.verbose = true
end

task :coverage do |_t|
  ENV['COVERAGE'] = '1'
  Rake::Task['test'].invoke
end

task :run do |_t|
  sh 'fluentd -p lib/fluent/plugin -c sample/fluent.conf'
end

task default: [:build]
