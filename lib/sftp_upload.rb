require 'yaml'
require_relative 'sftp/upload'
require_relative 'sftp/prompt'

SFTPUploader.new.run
