# frozen_string_literal: true

require 'yaml'
require_relative 'sftp/upload'

SFTPUploader.new.run
