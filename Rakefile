require 'rake/testtask'

desc "Generate documentation"
task :doc do
  `rdoc --main lib/mips.rb`
end

namespace :doc do
  desc "Wipe generated documentation"
  task :clean do
    rm_r "doc", :force => true
  end
end

desc "Build gem"
task :gem do
  `gem build mips.gemspec`
end

desc "Publish to geminabox"
task :geminabox do
  `curl 'http://localhost:9292/gems/mips-0.0.1.gem' -H 'Content-Type: application/x-www-form-urlencoded' --data '_method=DELETE'`
  `gem inabox ./mips-0.0.1.gem`
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/mips/**/*.rb'
#  t.options = '-v'
  t.verbose = true
end

desc "Run tests"
task :default => :test
