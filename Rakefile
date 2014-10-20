require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs = ["spec"]
  t.test_files = FileList['spec/features/*.rb']
  t.verbose = true
end