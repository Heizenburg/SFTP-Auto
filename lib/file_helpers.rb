# frozen_string_literal: true

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
  file.match(/(#{client}).*\.zip$/)
end

# Returns true if the file is not older than 6 days.
def recent_file?(file)
  Time.at(file.attributes.mtime) > (Time.now - 1.days)
end

# Counts zip files on local dir.
def local_file_count(dir)
  Dir.glob("#{dir}/*.zip").length
end

def hidden_file?(file)
  %w[. ..].include?(file)
end
