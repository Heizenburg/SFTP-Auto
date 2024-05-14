# frozen_string_literal: true

require_relative '../helpers/file_helpers'

class FileEntry
  include InternalLogMethods

  attr_reader :entry, :file_size_kb, :file_size_mb, :client

  def initialize(entry, client)
    @entry = entry
    @file_size_kb = convert_bytes(entry.attributes.size, :KB)
    @file_size_mb = convert_bytes(entry.attributes.size, :MB)
    @client = client
  end

  def directory?
    entry.attributes.directory?
  end
end
