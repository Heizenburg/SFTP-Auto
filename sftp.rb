require 'net/sftp'
require 'dotenv/load'
require 'pry'
require 'pathname'
require 'tty-spinner'

require_relative 'terminal'

# This will ultimately be for the shoprite path.
# Remember to -- Dir.pwd -- to see the distinct file location format.
local = '/mnt/c/Users/sello/Dropbox/PC/Documents/Testing'

remote = {
  '3M'                  => '/Clients/Test', 
  'Abbotts Lab'	        => '/Clients/Test',
  'ABV Brands'	        => '/Clients/Test',
  'Action Classics'	    => '/Clients/Test',
  'Aerosol'	            => '/Clients/Test',
  'African Extracts'	  => '/Clients/Test',
  'AJ Products'	        => '/Clients/Test',
  'All Joy'	            => '/Clients/Test',
  'Aquelle'	            => '/Clients/Test',
  'B M FOODS'	          => '/Clients/Test',
  'Bavaria'	            => '/Clients/Test',
  'BBH'	                => '/Clients/Test',
  'Bic'	                => '/Clients/Test',
  'Bliss Chemicals'	    => '/Clients/Test',
  'BOS'	                => '/Clients/Test',
  'Brands 2 Africa'	    => '/Clients/Test',
  'Brother Bees'	      => '/Clients/Test',
  'ButtaNutt'	          => '/Clients/Test',
  'Caffeluxe'	      		=> '/Clients/Test'
}

# Connection to the SFTP server. 
# Removing password parameter is safer as it prompts the password within terminal. 
Net::SFTP.start(ENV['HOST'], ENV['USERNAME'], password: '@Cellz911##') do |sftp|
  puts "Connected to SFTP server"

  remote.each do |key, value|
		client_matches = []
		
    extract = /(#{key})_[a-zA-Z]+_\d{8}_([a-zA-Z0-9 | K_NECT | K'NECT])*.zip/
		distribution = /(#{key})_(Regional|Distribution)_\d{8}.zip/

		# Go through all files in directory and find client files.
		Dir.each_child(local) do |file|
			puts "#{file} is a directory" if File.directory?(file)
			next if File.directory?(file) || file == '.' || file == '..'

			# Returns an array of files that need to be sent.
			# Add client_matches in an array. 
			if !!(file =~ extract || file =~ distribution)
				client_matches << file
			else
				next 
			end
		end

		if client_matches.any?
			puts "Client: #{key}".yellow

			client_matches.map do |zip_file|
				file_location = "/" + zip_file
					
				spinner = TTY::Spinner.new(
					"[:spinner] Sending #{zip_file} to #{value}",
					success_mark: "+"
				)
				spinner.auto_spin # Automatic animation with default interval

				# Send the folders to the location.
				sftp.upload!(local + file_location, value + file_location)
				spinner.success("Sent".green) # Stop spinner animation on success
			end
		end

		puts "#{client_matches.length} #{key} files sent to #{value}\n".green
	end

	puts "Done sending available files", "Connection terminated"
end
