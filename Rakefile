# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

task default: %w[analyze]

task :upload do
  ruby 'lib/upload.rb'
end

task :download do
  ruby 'lib/download.rb'
end

task :analyze do 
  ruby 'lib/upload.rb analyze'
end 

task :test do
  ruby 'test/upload_test.rb'
end
