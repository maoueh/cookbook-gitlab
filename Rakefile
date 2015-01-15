require 'foodcritic'
require 'rspec/core/rake_task'

desc "Runs linters and unit tests"
task :tests => [:foodcritic, :spec]
task :test => [:foodcritic, :spec]

desc "Runs foodcritic, a chef linter"
FoodCritic::Rake::LintTask.new


desc "Runs rspec tests (via chefspec)"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = "--color --tty --no-fail-fast"
end


task :default => :tests
