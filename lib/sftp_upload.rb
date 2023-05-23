require 'yaml'

require_relative 'sftp/upload'

# Load the list of clients from a YAML file.
clients = YAML.load_file('lib/shoprite_clients.yml')

# Call the main method in the upload.rb file
SFTP::Upload.main(ENV['LOCAL_LOCATION'], clients)