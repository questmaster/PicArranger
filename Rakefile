require 'rake/testtask'

desc 'Run unit tests'
task :test do
  Rake::TestTask.new do |t|
#  t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
  end
end
task :default => :test


