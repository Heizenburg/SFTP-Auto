# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

task default: %w[run]

task :run do
  ruby 'lib/extract.rb'
end

task :test do
  ruby 'test/extract_test.rb'
end