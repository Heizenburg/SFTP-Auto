# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

task default: %w[analyze]

task :upload do
  sh 'ruby lib/sftp_upload.rb upload', verbose: false
end

task :analyze do
  sh 'ruby lib/sftp_upload.rb analyze', verbose: false
end

task :list do
  sh 'ruby lib/sftp/clients.rb', verbose: false
end

task :benchmark do
  sh 'ruby benchmarks.rb', verbose: false
end

task :test do
  sh 'ruby test/upload_test.rb analyze', verbose: false
end
