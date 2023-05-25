# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

task default: %w[analyze]

task :upload do
  ruby 'lib/sftp_upload.rb upload'
end

task :analyze do
  ruby 'lib/sftp_upload.rb analyze'
end

task :list do
  ruby 'lib/sftp/clients.rb'
end

task :benchmark do 
  ruby 'benchmarks.rb'
end

task :test do
  ruby 'test/upload_test.rb analyze'
end
