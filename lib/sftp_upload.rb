# frozen_string_literal: true

require 'yaml'
require_relative 'sftp/upload'
require_relative 'sftp/prompt'

SFTPUploader.new.run
