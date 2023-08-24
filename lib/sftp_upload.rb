require 'yaml'
require_relative 'sftp/upload'

SFTPUploader.new(ENV['LOCAL_LOCATION'], YAML.load_file('lib/shoprite_clients.yml')).run