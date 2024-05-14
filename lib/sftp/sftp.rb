# frozen_string_literal: true

require 'awesome_print'
require 'net/sftp'
require 'dotenv/load'
require 'logger'
require 'pry'
require 'pry-nav'
require 'pry-remote'
require 'tty-spinner'
require 'tty-prompt'

module InternalLogMethods
  LOG_LEVELS = {
    error: :error,
    message: :info
  }.freeze

  def log_message(message)
    log(:info, message)
  end

  def log_error(message)
    log(:error, message)
  end

  private

  def log(level, message)
    logger = Logger.new($stdout)
    logger.formatter = proc do |severity, datetime, _, msg|
      formatted_datetime = datetime.strftime('%F %T')
      formatted_severity = severity.to_s[0..3].upcase.rjust(4)
      formatted_msg      = msg.to_s

      "#{formatted_datetime} [#{formatted_severity}] #{formatted_msg}\n"
    end

    logger.send(level, "#{message}\n")
  end
end

class SFTP
  include InternalLogMethods

  attr_reader :host, :username, :password, :clients

  def initialize(host, username, password = nil, port = 22)
    @host     = host
    @user     = username
    @port     = port
    @password = password
    @clients  = 0

    connect
  end

  def connect
    @session = Net::SFTP.start(
      @host,
      @user,
      password: @password,
      port: @port
    )

    log_message('Connected to the SFTP server'.green << ".\nHost: #{@host}\nUsername: #{@user}\n".yellow)
  rescue Net::SSH::ConnectionTimeout => e
    log_error("Timed out while trying to connect to the SFTP server: #{e}".red)
  rescue StandardError => e
    log_error("Failed to connect to the SFTP server: #{e}".red)
  end

  # Loops through all remote files.
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

  def increment_clients_count
    @clients += 1
  end

  private

  # A method to handle missing method calls by delegating to the @session object if the method is defined.
  # Otherwise falls back to the default behavior of the superclass.
  def method_missing(method_name, *args, &block)
    if @session.respond_to?(method_name)
      @session.send(method_name, *args, &block)
    else
      super
    end
  end
end
