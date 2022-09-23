# frozen_string_literal: true

class Extract
  attr_accessor :host, :username, :password

  def initialize(host, username)
    @host         = host
    @user         = username
    @password     = password

    @session      = Net::SFTP.start(
      @host,
      @user,
      password: @password
    )

    @clients = 0

    puts <<~OPEN
      Connected to the SFTP server.

      Host: #{ENV['HOST']}
      Username: #{ENV['USERNAME']}\n
    OPEN
  rescue Exception => e
    puts "Failed to parse SFTP: #{e}\n"
  end

  # List all files
  # Requires remote read permissions.
  def list_files(remote_dir)
    @session.dir.foreach(remote_dir) do |entry|
      puts recent_file?(entry) ? entry.longname.yellow : entry.longname
    end
    puts "\n"
  end

  def entries(remote_dir, &block)
    @session.dir.foreach(remote_dir, &block)
  end

  # Get remote file directly to a buffer
  # Requires remote read permissions.
  def get(remote_file)
    download(remote_file, nil, options)
  end

  # Open a remote file to a pseudo-IO with the given mode (r - read, w - write)
  # Requires remote read permissions.
  def open(remote_file, flags = 'r', &block)
    @session.file.open(remote_file, flags, &block)
  end

  # Upload local file to remote file
  # Requires remote write permissions.
  def upload(local_file, remote_file, options = {})
    @session.upload!(local_file, remote_file, options)
  end

  # Download local file to remote file
  # Requires remote read permissions.
  def download(remote_file, local_file, options = {})
    @session.download!(remote_file, local_file, options)
  end

  # Returns true if the file is not older than 7 days.
  def recent_file?(file)
    Time.at(file.attributes.mtime) > (Time.now - 7.days)
  end

  def increment_clients
    @clients += 1
  end

  attr_reader :clients

  # List all remote files  copied.
  def files_sent(array, client, remote_location)
    message = if array.empty?
                "0 #{client} files copied. Remote Location: #{remote_location}\n".red
              else
                "#{array.size} #{client} files copied to #{remote_location}\n".green
              end

    puts message
  end
end
