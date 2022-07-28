require 'net/sftp'

local_path = 'Q:\Retailer Service\External Clients\Shoprite\Shoprite Extractions'

remote_paths = {
  '3M'              => '/Clients/3M/Upload/Weekly',
  'Abbotts Lab'	    => '/Clients/Abbott Lab/Upload/Weekly',
  'ABV Brands'	    => '/Clients/ABV Brands/Upload/Weekly'
}

puts "Connecting to the SFTP server"

Net::SFTP.start('secure.iriworldwide.co.za:22', 'tsello01', :password => 'password') do |sftp|
  puts "Connected to SFTP server"
  
  remote_paths.each do |key, value| 
		matches = []
		
    extract = /(#{key})_[a-zA-Z]+_\d{8}_[a-zA-Z0-9- ]*.zip/
		distribution = /(#{key})_[a-zA-Z]+_\d{8}.zip/

		# Go through all files in directory and find client files.
		sftp.dir.foreach(local_path) do |file|
				
			# Returns an array of files that need to be sent.
			if !!(file =~ (extract || distribution))
				matches << file
			else 
				next
			end
				
			puts file.longname		
		end

		if matches.any?
			matches.map do |zip|
				puts "Sending #{zip} to #{value}"
				
				# Send the folders to the location.
				sftp.upload!(zip, value)
				matches.each { |match| match.wait } 
			end
		end

		puts "#{matches.length} files for #{key} sent successfully"
	end

	puts "Done sending available files", "Connection terminated"
end

puts 'File transfer complete'