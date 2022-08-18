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
  '3M'                        => '/Clients/3M/Upload/Weekly', 
  'Abbotts Lab'	              => '/Clients/Abbott Lab/Upload/Weekly',
  'ABV Brands'	              => '/Clients/ABV Brands/Upload/Weekly',
  'Action Classics'	          => '/Clients/Action Classics/Upload/Weekly',
  'Aerosol'	                  => '/Clients/Aerosol & Cosmetics/Upload/Weekly',
  'African Extracts'	        => '/Clients/African Extracts/Upload/Shoprite/Weekly',
  'AJ Products'	              => '/Clients/AJ Products/Upload/Weekly',
  'All Joy'	                  => '/Clients/All Joy/Upload/Weekly',
  'Aquelle'	                  => '/Clients/aQuelle/Upload',
  'B M FOODS'	                => '/Clients/B M Foods/Uploads/Weekly',
  'Bavaria'	                  => '/Clients/Bavaria/Upload/Weekly',
  'BBH'	                      => '/Clients/BBH/Upload/Weekly',
	'Bennett'	                  => '/Clients/Bennett/Upload/Weekly',
  'Bic'	                      => '/Clients/BIC/Upload',
  'Bliss Chemicals'	          => '/Clients/Bliss Chemicals/Upload/Raw Data/Weekly',
  'BOS'	                      => '/Clients/BOS/Upload/Weekly',
  'Brands 2 Africa'	          => '/Clients/Brands 2 Africa/Upload/Weekly',
  'Brother Bees'	            => '/Clients/Brother Bees/Upload/Weeklys',
  'ButtaNutt'	                => '/Clients/Buttanutt Tree/Uploads',
  'Caffeluxe'	      		      => '/Clients/Caffeluxe/Upload/Weekly',
	'CBC'                       => '/Clients/CBC/Upload/Weekly',
	'Cerebos'                   => '/Clients/Cerebos/Upload/Weekly',
	'Chet'                      => '/Clients/Chet/Upload/Weekly',
	'Chill Beverages'           => '/Clients/Chill Beverages/Upload/Weekly',
	'Cleopatra Tissue'          => '/Clients/Cleopatra Tissue/Upload',
	'Continental Biscuits'      => '/Clients/Continental Biscuits/Upload/Weekly',
	'CTP'                       => '/Clients/Flip File/Upload/Weekly',
	'Darling Romery'            => '/Clients/Darling Romery/Upload/Weekly',
	'Denny Mushroom'            => '/Clients/Denny Mushrooms/Uploads/Weekly',
	'DGB'                       => '/Clients/DGB/Upload',
	'Diageo 1'                  => '/Clients/Diageo 1/Upload/Shoprite',
	'DuToitskloof'              => '/Clients/DuToitskloof/Upload/Weekly',
	'Distell'                   => '/Clients/Distell/Upload',
	'Dynamic Brands'            => '/Clients/Dynamic Brands/Upload/Weekly',
	'East Rand Plastics'        => '/Clients/East Rand Plastics/Upload',
	'Efekto Care'               => '/Clients/Efekto Care/Upload/Shoprite Extracts/Weekly',
	'Epic Foods'                => '/Clients/Epic Foods/Upload/Weekly',
	'Eskort'                    => '/Clients/Eskort/Upload/Weekly',
	'Feinschmecker'             => '/Clients/Feinschmecker/Upload/Weekly',
	'Flip File'                 => '/Clients/Flip File/Upload/Weekly',
	'Freezerlink'               => '/Clients/Freezerlink/Upload/Weekly',
	'Frimax'										=> '/Clients/Frimax/Upload',
	'Future Life'               => '/Clients/Future Life/Upload/Weekly',
	'Fruzo'                     => '/Clients/Fruzo/Upload/Weekly',
	'Georgios Biscuit Factory'  => '/Clients/Georgios Biscuit Factory/Upload/Weekly',
	'Global Coffee'             => '/Clients/Global Coffee/Upload/Weekly',
	'Grassroots'                => '/Clients/Grassroots/Uploads/Weekly',
	'GWK'                       => '/Clients/GWK/Upload',
	'Halewood International'    => '/Clients/Halewood International/Upload/Weekly',
	'Heartland Foods'           => '/Clients/Heartland Foods/Upload/Weekly',
	'Heineken'                  => '/Clients/Heineken/Upload/Shoprite Extraction/Weekly',
	'Herbex'                    => '/Clients/Herbex/Upload/Shoprite/Weekly',
	'Himalaya Drug Co'          => '/Clients/Himalaya Drug Co/Upload/Shoprite',
	'Hulletts'                  => '/Clients/Hulletts/Upload/Shoprite/Weekly',
	'Hulley&Rice'               => '/Clients/Hulley&Rice/Upload/Weekly',
	'Icon3sixty'                => '/Clients/Icon3sixty/Upload/Weekly',
	'Jimmys Sauces'             => '/Clients/Jimmys Sauces/Upload/Weekly',
	'JNJ'              					=> '/Clients/Mentholatum/Upload/Shoprite',
	'Jumbo Brands'              => '/Clients/Jumbo Brands/Upload/Weekly'
}

# Connection to the SFTP server. 
# Removing password parameter is safer as it prompts the password within terminal. 
Net::SFTP.start(ENV['HOST'], ENV['USERNAME']) do |sftp|

	puts opening = <<~OPEN
		Connected to the SFTP server.
		
		Host: #{ENV['HOST']}
		Username: #{ENV['USERNAME']}\n
	OPEN

	# Close connection if there are no file in local directory,
	# if sftp connection or session does not exist.
	if Dir.children(local).size.zero? || !sftp || !sftp.session
		puts closing = <<~CLOSE
			No files in local directory.
			Closing connection.
		CLOSE
		exit
	end

  remote.each_with_index do |(key, value), index|
		matches = []
  
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
				spinner = TTY::Spinner.new(
					"[:spinner] Copying #{zip_file} to #{value}",
					success_mark: "+",
					clear: true
				)
				spinner.auto_spin 

				# Send the files to their respective clients folders.
				sftp.upload!("#{local}/#{zip_file}", "#{value}/#{zip_file}")
				spinner.success
			end
		end

		files_sent = "#{matches.size} #{key} files copied to #{value}\n"
		puts (matches.empty? ? files_sent.red : files_sent.green) 
	end

	puts "Done copying available files\n", "Connection terminated"
end
