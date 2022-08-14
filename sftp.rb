require 'net/sftp'
require 'dotenv/load'
require 'pry'
require 'pathname'
require 'tty-spinner'

require_relative 'helpers/terminal'

# This will ultimately be for the shoprite path.
# Remember to -- Dir.pwd -- to see the distinct file location format.
local = '/mnt/c/Users/sello/Dropbox/PC/Documents/Testing'

remote = {
  '3M'                        => '/Clients/Test', 
  'Abbotts Lab'	              => '/Clients/Test',
  'ABV Brands'	              => '/Clients/Test',
  'Action Classics'	          => '/Clients/Test',
  'Aerosol'	                  => '/Clients/Test',
  'African Extracts'	        => '/Clients/Test',
  'AJ Products'	              => '/Clients/Test',
  'All Joy'	                  => '/Clients/Test',
  'Aquelle'	                  => '/Clients/Test',
  'B M FOODS'	                => '/Clients/Test',
  'Bavaria'	                  => '/Clients/Test',
  'BBH'	                      => '/Clients/Test',
  'Bic'	                      => '/Clients/Test',
  'Bliss Chemicals'	          => '/Clients/Test',
  'BOS'	                      => '/Clients/Test',
  'Brands 2 Africa'	          => '/Clients/Test',
  'Brother Bees'	            => '/Clients/Test',
  'ButtaNutt'	                => '/Clients/Test',
  'Caffeluxe'	      		      => '/Clients/Test',
	'CBC'                       => '/Clients/Test',
	'Cerebos'                   => '/Clients/Test',
	'Chet'                      => '/Clients/Test',
	'Chill Beverages'           => '/Clients/Test',
	'Cleopatra Tissue'          => '/Clients/Test',
	'Continental Biscuits'      => '/Clients/Test',
	'Darling Romery'            => '/Clients/Test',
	'Denny Mushroom'            => '/Clients/Test',
	'DGB'                       => '/Clients/Test',
	'Diageo 1'                  => '/Clients/Test',
	'DuToitskloof'              => '/Clients/Test',
	'Distell'                   => '/Clients/Test',
	'Dynamic Brands'            => '/Clients/Test',
	'Dynamic Brands' 		        => '/Clients/Test',
	'East Rand Plastics'        => '/Clients/Test',
	'Efekto Care'               => '/Clients/Test',
	'Epic Foods'                => '/Clients/Test',
	'Eskort'                    => '/Clients/Test',
	'Feinschmecker'             => '/Clients/Test',
	'Flip File'                 => '/Clients/Test',
	'Freezerlink'               => '/Clients/Test',
	'Future Life'               => '/Clients/Test',
	'Fruzo'                     => '/Clients/Test',
	'Georgios Biscuit Factory'  => '/Clients/Test',
	'Global Coffee'             => '/Clients/Test',
	'Grassroots'                => '/Clients/Test',
	'GWK'                       => '/Clients/Test',
	'Halewood International'    => '/Clients/Test',
	'Heartland Foods'           => '/Clients/Test',
	'Heineken'                  => '/Clients/Test',
	'Herbex'                    => '/Clients/Test',
	'Himalaya Drug Co'          => '/Clients/Test',
	'Hulletts'                  => '/Clients/Test',
	'Icon3sixty'                => '/Clients/Test',
	'Jimmys Sauces'             => '/Clients/Test',
	'JNJ'              					=> '/Clients/Test',
	'Jumbo Brands'              => '/Clients/Test'
}

# Connection to the SFTP server. 
# Removing password parameter is safer as it prompts the password within terminal. 
Net::SFTP.start(ENV['HOST'], ENV['USERNAME']) do |sftp|

	puts opening = <<~OPEN
		Connected to the SFTP server.
		
		Host: #{ENV['HOST']}
		Username: #{ENV['USERNAME']}\n
	OPEN

  remote.each_with_index do |(key, value), index|
		matches = []
  
		# Go through all files in directory to find client files.
		Dir.each_child(local) do |file|
			next if File.directory?(file) || file == '.' || file == '..'
			
			# Adds client to matches if the file matches the regex.
			# Matches for respective client files. 
			if !!(file =~ /(#{key}).*\.zip$/)
				matches << file
			else
				next 
			end
		end

		if matches.any?
			puts "Client[#{index.next}]: #{key}".yellow

			matches.map do |zip_file|
				file_location = "/" + zip_file
					
				spinner = TTY::Spinner.new(
					"[:spinner] Copying #{zip_file} to #{value}",
					success_mark: "+",
					clear: true
				)
				spinner.auto_spin 

				# Send the files to their respective clients folders.
				sftp.upload!(local + file_location, value + file_location) 
				spinner.success("Sent".green) 
			end
		end

		files_sent = "#{matches.length} #{key} files sent to #{value}\n"
		puts (matches.length < 17 || matches.length > 19 ? files_sent.red : files_sent.green) 
	end

	puts "Done copying available files\n", "Connection terminated"
end
