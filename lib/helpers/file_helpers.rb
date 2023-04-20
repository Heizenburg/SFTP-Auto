# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'date'
require 'net/sftp'

# Returns true for a file extention input.
def file_extention?(file, ext)
  File.extname(file) == ext
end

def convert_bytes_to_kilobytes(bytes)
  kb = (bytes.to_f / 1024).ceil
  "#{kb}KB"
end

# Returns true if file is of a specific client.
def client_file?(file, client)
  client_regex = Regexp.new("#{client}.*\\.zip$", Regexp::IGNORECASE)
  file.match(client_regex)
end

# Returns true if the file is not older than 6 days.
def recent_file?(file)
  if file.respond_to?(:attributes) && file.attributes.respond_to?(:mtime)
    Time.at(file.attributes.mtime) > (Time.now - 6.days)
  else
    File.mtime(file) > (Time.now - 6.days)
  end
end

# Deletes files older than 20 days.
def delete_files(sftp, remote_location)
  sftp.entries(remote_location) do |file|
    if file.file? && Time.at(file.attributes.mtime) < (Time.now - 20.days)
      file_to_delete = remote_location[1..-1] + '/' + file.name
      spinner = TTY::Spinner.new(
        "[:spinner] Deleting #{file.name} from #{remote_location}",
        success_mark: '-',
        clear: true
      )
      spinner.auto_spin
      sftp.remove!(file_to_delete)
      spinner.success
      puts "Deleted: #{file.longname} #{convert_bytes_to_kilobytes(file.attributes.size)}".red
    end
  end
  puts "\n"
end

def local_file_count(dir)
  Pathname.new(dir).children.count { |child| child.extname == '.zip' }
end

def not_hidden_file?(file)
  !file.start_with?('.')
end
