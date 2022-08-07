require 'net/sftp'
require 'dotenv/load'
require 'pry'
require 'pathname'

# This will be for the shoprite path
# Remember to -- Dir.pwd -- to see the distinct file location format
local = '/mnt/c/Users/sello/Dropbox/PC/Documents/Testing'

remote = {
  '3M'              => '/Clients/Test',
  'Abbotts Lab'	    => '/Clients/Test'
}

binding.pry

# Connection to the SFTP server. 
# Removing password parameter is safer as it prompts the password in the terminal 
Net::SFTP.start(ENV['HOST'], ENV['USERNAME'], ENV['PASSWORD']) do |sftp|
  puts "Connected to SFTP server"

  remote.each do |key, value|
		matches = []
		
    extract = /(#{key})_[a-zA-Z]+_\d{8}_([a-zA-Z0-9 | K_NECT])*.zip/
		distribution = /(#{key})_(Reginal|Distribution)_20220710.zip/

		# Go through all files in directory and find client files.
		Dir.each_child(local) do |file|
			puts "#{file} is a directory" if File.directory?(file)
			next if File.directory?(file) || file == '.' || file == '..'

			# Returns an array of files that need to be sent.
			if !!(file =~ extract || file =~ distribution)
				matches << file
			else
				next 
			end
		end

		if matches.any?
			matches.each do |zip|
				puts "Sending #{zip} to #{value}"
				
				# Send the folders to the location.
				sftp.upload!(local + "/" + zip, value)
				matches.each { |match| match.wait } 
			end
		end

		puts "#{matches.length} files for #{key} sent to #{value}"
	end

	puts "Done sending available files", "Connection terminated"
end
