# Returns true if its a csv file.
def csv?(file)
  File.extname(file) == '.csv'
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
  Time.at(file.attributes.mtime) > (Time.now - 6.days)
end
