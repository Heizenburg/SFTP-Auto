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

    @client_count = 0

    puts <<~OPEN
      Connected to the SFTP server.

      Host: #{ENV['HOST']}
      Username: #{ENV['USERNAME']}\n
    OPEN

  rescue Exception => e
    puts "Failed to parse SFTP: #{e}"
  end

  # List all files
  # Requires remote read permissions.
  def list_files(remote_dir)
    @session.dir.foreach(remote_dir) do |entry|
      puts entry.longname
    end
  end

  def entries(remote_dir)
    @session.dir.foreach(remote_dir) do |entry|
      yield entry
    end
  end

  # Get remote file directly to a buffer
  # Requires remote read permissions.
  def get(remote_file)
    download(remote_file, nil, options)
  end

  # Open a remote file to a pseudo-IO with the given mode (r - read, w - write)
  # Requires remote read permissions.
  def open(remote_file, flags = 'r')
    # File operations
    @session.file.open(remote_file, flags) do |io|
      yield io
    end
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

  def increment_client_count
    @client_count = @client_count.succ
  end 

  def client_count
    @client_count
  end
  
  def files_sent(array, client, remote_location)
    message = "#{array.size} #{client} files copied to #{remote_location}\n"

    puts matches.empty? ? message.red : message.green
  end
end

