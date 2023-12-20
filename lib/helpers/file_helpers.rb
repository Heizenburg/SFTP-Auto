# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'date'
require 'net/sftp'

require_relative '../sftp/sftp'

include InternalLogMethods

DAYS_LIMIT = 6

# Returns true for a file extention input.
def file_extension?(file, ext)
  File.extname(file) == ext
end

def convert_bytes_to_kilobytes(bytes)
  "#{(bytes / 1024.0).ceil}KB".yellow
end

# Returns true if file is of a specific client.
def client_file?(file, client)
  file.match?(Regexp.new("^.*#{client}.*\\..+$", Regexp::IGNORECASE))
end

# Returns true if the file is not older than DAYS_LIMIT days.
def recent_file?(file)
  if file.respond_to?(:attributes) && file.attributes.respond_to?(:mtime)
    Time.at(file.attributes.mtime) > (Time.now - DAYS_LIMIT.days)
  else
    File.mtime(file) > (Time.now - DAYS_LIMIT.days)
  end
end

# Remove files older than a month.
def remove_old_files(sftp, remote_location, client, number_of_days)
  sftp.entries(remote_location) do |file|
    next unless file.file? && Time.at(file.attributes.mtime) < (Time.now - number_of_days.days)
    
    delete_spinner = TTY::Spinner.new(
      "[:spinner] Deleting #{file.name} from #{remote_location}",
      success_mark: '-',
      clear: true
    )
    delete_spinner.auto_spin

    begin
      remove_file_from_location(sftp, remote_location, file)
      delete_spinner.success
      @logger.info("Removed: #{file.longname} #{convert_bytes_to_kilobytes(file.attributes.size)} -- OLDER THAN 30 DAYS ".red)
    rescue StandardError => e
      log_error("Error deleting file #{file_to_delete}: #{e}".red)
    end
  end
  puts "\n"
end

def remove_file_from_location(session, remote_location, file)
  session.remove!(File.join(remote_location[1..-1], file.name))
end

def local_file_count(dir)
  Dir[File.join(dir, '*.zip')].length
end

def not_hidden_file?(file)
  !file.start_with?('.')
end
