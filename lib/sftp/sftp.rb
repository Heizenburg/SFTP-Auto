# frozen_string_literal: true

require 'awesome_print'
require 'find'
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

  LOG_LEVELS.each do |level, method_name|
    define_method("log_#{level}") do |message|
      logger = Logger.new($stdout)
      logger.send(method_name, "#{message}\n")
    end

    private "log_#{level}"
  end
end

class SFTP
  include InternalLogMethods

  attr_reader :host, :username, :password, :clients

  def initialize(host, username, password = nil, port = 22)
    @host = host
    @user = username
    @port = port
    @password = password

    @logger = Logger.new($stdout)
    @clients = 0

    connect
  end

  def connect
    @session = Net::SFTP.start(
      @host,
      @user,
      password: @password,
      port: @port
    )

    log_message("Connected to the SFTP server.\nHost: #{@host}\nUsername: #{@user}\n")
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

  def method_missing(method_name, *args, &block)
    if @session.respond_to?(method_name)
      @session.send(method_name, *args, &block)
    else
      super
    end
  end
end
