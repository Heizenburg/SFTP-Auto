# frozen_string_literal: true

# Add your own tasks in files placed in src/tasks ending in .rake,
# for example src/tasks/capistrano.rake, and they will automatically
# be available to Rake.

task default: %w[analyze]

# Define a hash mapping task names to their corresponding commands
TASKS = {
  upload: 'ruby src/sftp_upload.rb upload',
  analyze: 'ruby src/sftp_upload.rb analyze',
  benchmark: 'ruby benchmarks.rb',
  test: 'ruby test/upload_test.rb analyze'
}.freeze

# Define tasks and their aliases
TASKS.each do |name, command|
  task name do
    sh command, verbose: false
  end

  alias_task = name.to_s[0] # Get the first letter of the task name
  Rake::Task.define_task(alias_task) do
    Rake::Task[name].invoke
  end
end

