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

# Converts the given file size in bytes to the specified unit (KB or MB) and returns the formatted string.
def convert_bytes(bytes, to_unit = :KB)
  return 'Invalid input' if bytes.nil? || bytes <= 0

  case to_unit
  when :KB
    "#{(bytes / 1024.0).ceil}KB".yellow
  when :MB
    if bytes >= 1024 * 1024
      mb = bytes / (1024.0 * 1024.0)
      "#{format('%.1f', mb)}MB".cyan
    end
  end
end

# Returns true if file is of a specific client.
def client_file?(file, client)
  file.downcase.include?(client.downcase)
end

# Returns true if the file is not older than DAYS_LIMIT days.
def recent_file?(file)
  if file.respond_to?(:attributes) && file.attributes.respond_to?(:mtime)
    Time.at(file.attributes.mtime) > (Time.now - DAYS_LIMIT.days)
  else
    File.mtime(file) > (Time.now - DAYS_LIMIT.days)
  end
end

def remove_old_files(sftp, remote_location, _client, number_of_days)
  files_to_delete = sftp.dir.entries(remote_location).select do |file|
    file.file? && Time.at(file.attributes.mtime) < (Time.now - number_of_days.days)
  end

  return if files_to_delete.empty?

  files_to_delete.each do |file|
    delete_spinner = TTY::Spinner.new(
      "[:spinner] Deleting #{file.name} from #{remote_location}",
      success_mark: '-',
      clear: true
    )
    delete_spinner.auto_spin

    begin
      remove_file_from_location(sftp, remote_location, file)
      delete_spinner.success
      @logger.info("Removed: #{file.longname} #{convert_bytes(file.attributes.size)} -- OLDER THAN #{number_of_days} DAYS ".red)
    rescue StandardError => e
      log_error("Error deleting file #{files_to_delete}: #{e}".red)
    end
  end
  @logger.info("\n")
end

def remove_file_from_location(session, remote_location, file)
  session.remove!(File.join(remote_location.slice(1, remote_location.size), file.name))
end

def local_file_count(dir)
  Dir[File.join(dir, '*.zip')].length
end

def hidden_file?(file)
  file.start_with?('.')
end
