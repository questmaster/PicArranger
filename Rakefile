require 'rake/testtask'
#require 'rcov/rcovtask'

#desc 'Run unit tests with coverage'
#task :test do
#  Rcov::RcovTask.new do  |t|
#    t.libs << "test"
#    t.test_files = FileList ['test/**/*_test.rb']
#    t.verbose = true
#  end
#end

desc 'Run unit tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
end

task :default => :test


