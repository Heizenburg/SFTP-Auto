require 'net/sftp'

local_path = 'Q:\Retailer Service\External Clients\Shoprite\Shoprite Extractions'

remote_paths = {
  '3M'              => '/Clients/3M/Upload/Weekly',
  'Abbotts Lab'	    => '/Clients/Abbott Lab/Upload/Weekly',
  'ABV Brands'	    => '/Clients/ABV Brands/Upload/Weekly',
  'Action Classics'	=> '/Clients/Action Classics/Upload/Weekly'
}

puts "Connecting to the SFTP server"

Net::SFTP.start('host', 'username', :password => 'password') do |sftp|
  puts "Connected to SFTP server"
  
  remote_paths.each do |key, value| 
  
    regex = /(#{key})_[a-zA-Z]+_\d{8}_[a-zA-Z0-9- ]*.zip/gi
		matches = []
    
		# list the entries in a directory.
		sftp.dir.foreach(local_path) do |file|
				
			# Returns an array of files that need to be sent.
			if !!(file.to_s =~ regex)
				matches << file
			else 
				next
			end
				
			puts file.longname		
		end

		if matches.any?
			matches.each do |zip|
				puts "Sending #{zip} to #{value}"
				
				# Send the folders to the location.
				sftp.upload!(zip, value)  
			end
		end
		
		puts "Done sending available files", "Connection terminated"
	end
end

puts 'File transfer complete'