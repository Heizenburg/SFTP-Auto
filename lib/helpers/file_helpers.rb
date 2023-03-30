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
  Time.at(file.attributes.mtime) > (Time.now - 6.days)
end

def delete_old_files(sftp, remote_location)
  sftp.entries(remote_location) do |file|
    if file.file? && Time.at(file.attributes.mtime) < (Time.now - 20.days)
      file_path = file.name
      spinner = TTY::Spinner.new(
        "[:spinner] Deleting #{file.longname} from #{remote_location}",
        success_mark: '-',
        clear: true
      )
      spinner.auto_spin
      sftp.remove!(remote_location + file_path)
      spinner.success
      puts "Deleted: #{file.longname} #{convert_bytes_to_kilobytes(file.attributes.size)}".red
    end
  end

  puts "\n"
end

def compare_local_to_remote(local_path, remote_path, local_file, remote_file, session)
  remote_file_size = session.stat("#{remote_path}/#{remote_file}").size
  local_file_size = File.size("#{local_path}/#{local_file}")
  
  remote_file_size == local_file_size
end

def local_file_count(dir)
  Pathname.new(dir).children.count { |child| child.extname == '.zip' }
end

def not_hidden_file?(file)
  !file.start_with?('.')
end
