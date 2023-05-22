# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

task default: %w[analyze]

task :upload do
  ruby 'lib/upload.rb upload'
end

task :analyze do
  ruby 'lib/upload.rb analyze'
end

task :list do
  ruby 'lib/clients.rb'
end

task :test do
  ruby 'test/upload_test.rb'
end
