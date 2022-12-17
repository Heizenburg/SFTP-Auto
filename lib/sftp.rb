# frozen_string_literal: true

require 'awesome_print'
require 'net/sftp'
require 'dotenv/load'
require 'logger'
require 'pry'
require 'pry-nav'
require 'pry-remote'
require 'tty-spinner'

class SFTP
  attr_reader :host, :username, :password

  def initialize(host, username, password = nil, port = 22)
    @host = host
    @user = username
    @port = port
    @password = password

    @session = Net::SFTP.start(
      @host,
      @user,
      password: @password,
      port: @port
    )

    @clients = 0

    puts <<~OPEN
      Connected to the SFTP server.

      Host: #{ENV['HOST']}
      Username: #{ENV['USERNAME']}\n
    OPEN
  rescue StandardError => e
    logger = Logger.new($stdout)
    logger.error("Failed to parse SFTP: #{e}\n".red)
  end

  # List all remote files.
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

  # Getter for clients count
  attr_reader :clients

  def increment_client
    @clients = @clients.succ
  end
end
