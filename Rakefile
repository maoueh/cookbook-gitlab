require 'mixlib/shellout'

$stdout.sync = true

task :default => :tests

desc 'Runs linters and unit tests'
task :tests => [:foodcritic, :rubocop, :chefspec]

desc 'Runs linters and unit tests'
task :test => [:foodcritic, :rubocop, :chefspec]

desc 'Runs foodcritic, a chef linter'
task :foodcritic do
  error = run('foodcritic --epic-fail any --exclude test --exclude spec .')

  abort("Chef Cookbook Linter Failures! Please fix them.") if error
end

desc 'Runs rubocop, a ruby linter'
task :rubocop do
  sources = ['attributes', 'libraries', 'providers', 'recipes', 'resources', 'spec', 'test']
  arguments = sources.map do |source|
    "#{source}/**/*.rb"
  end

  error = run("rubocop #{arguments.join(' ')}")

  abort("Ruby Linter Failures! Please fix them.") if error
end

desc 'Runs rspec tests (via chefspec)'
task :chefspec do
  error = run('chef exec rspec --color --tty --no-fail-fast', live_stream: $stdout)

  abort("ChefSpec Failures! Please fix them.") if error
end

def run(command, options = {})
  process = Mixlib::ShellOut.new(command, options)
  process.run_command

  puts process.stderr if process.exitstatus != 0 && options[:live_stream].nil? && process.stderr
  puts process.stdout if process.exitstatus != 0 && options[:live_stream].nil? && process.stdout

  process.error?
end
