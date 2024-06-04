# frozen_string_literal: true
class FileEntry
  include InternalLogMethods

  attr_reader :entry, :file_size_kb, :file_size_mb, :client

  def initialize(entry, client)
    @entry = entry
    @file_size_kb = convert_bytes(entry.attributes.size)
    @file_size_mb = convert_bytes(entry.attributes.size, :MB)
    @client = client
  end

  def directory?
    entry.attributes.directory?
  end
  
  private

  def convert_bytes(bytes, to_unit = :KB)
    return '0KB or Invalid input'.red if bytes.nil? || bytes <= 0

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
end
