# frozen_string_literal: true

require 'net/sftp'
require 'dotenv/load'
require 'pry'
require 'pathname'
require 'tty-spinner'

require_relative 'terminal'

# This will ultimately be for the shoprite path.
# Remember to -- Dir.pwd -- to see the distinct file location format.
local = ENV['LOCAL_LOCATION']

remote = {
  '3M' => '/Clients/3M/Upload/Weekly',
  'Abbotts Lab'	=> '/Clients/Abbott Lab/Upload/Weekly',
  'ABV Brands'	=> '/Clients/ABV Brands/Upload/Weekly',
  'Action Classics'	=> '/Clients/Action Classics/Upload/Weekly',
  'Aerosol'	=> '/Clients/Aerosol & Cosmetics/Upload/Weekly',
  'African Extracts'	=> '/Clients/African Extracts/Upload/Shoprite/Weekly',
  'AJ Products'	=> '/Clients/AJ Products/Upload/Weekly',
  'All Joy'	=> '/Clients/All Joy/Upload/Weekly',
  'Aquelle'	=> '/Clients/aQuelle/Upload',
  'B M FOODS'	=> '/Clients/B M Foods/Uploads/Weekly',
  'Bavaria'	=> '/Clients/Bavaria/Upload/Weekly',
  'BBH'	=> '/Clients/BBH/Upload/Weekly',
  'Bennett'	=> '/Clients/Bennett/Upload/Weekly',
  'Bic'	=> '/Clients/BIC/Upload',
  'Bliss Chemicals'	=> '/Clients/Bliss Chemicals/Upload/Raw Data/Weekly',
  'BOS'	=> '/Clients/BOS/Upload/Weekly',
  'Brands 2 Africa'	=> '/Clients/Brands 2 Africa/Upload/Weekly',
  'Brother Bees'	=> '/Clients/Brother Bees/Upload/Weeklys',
  'ButtaNutt'	=> '/Clients/Buttanutt Tree/Uploads',
  'Caffeluxe'	=> '/Clients/Caffeluxe/Upload/Weekly',
  'CBC' => '/Clients/CBC/Upload/Weekly',
  'Cerebos' => '/Clients/Cerebos/Upload/Weekly',
  'Chet' => '/Clients/Chet/Upload/Weekly',
  'Chill Beverages' => '/Clients/Chill Beverages/Upload/Weekly',
  'Cleopatra Tissue' => '/Clients/Cleopatra Tissue/Upload',
  'Continental Biscuits' => '/Clients/Continental Biscuits/Upload/Weekly',
  'CTP' => '/Clients/Flip File/Upload/Weekly',
  'Darling' => '/Clients/Darling Romery/Upload/Weekly',
  'Denny Mushrooms' => '/Clients/Denny Mushrooms/Uploads/Weekly',
  'DGB' => '/Clients/DGB/Upload',
  'Diageo' => '/Clients/Diageo 1/Upload/Shoprite',
  'Du Toitskloof Wines' => '/Clients/DuToitskloof/Upload/Weekly',
  'Distell' => '/Clients/Distell/Upload',
  'Dynamic Brands' => '/Clients/Dynamic Brands/Upload/Weekly',
  'East Rand Plastics' => '/Clients/East Rand Plastics/Upload',
  'Efekto' => '/Clients/Efekto Care/Upload/Shoprite Extracts/Weekly',
  'Epic Foods' => '/Clients/Epic Foods/Upload/Weekly',
  'Eskort' => '/Clients/Eskort/Upload/Weekly',
  'Feinschmecker' => '/Clients/Feinschmecker/Upload/Weekly',
  'Flip File' => '/Clients/Flip File/Upload/Weekly',
  'Freezerlink' => '/Clients/Freezerlink/Upload/Weekly',
  'Frimax'	=> '/Clients/Frimax/Upload',
  'Future Life' => '/Clients/Future Life/Upload/Weekly',
  'Fruzo' => '/Clients/Fruzo/Upload/Weekly',
  'Gentle Magic' => '/Clients/GentleMagic/Uploads/Weekly',
  'Georgios Biscuit Factory' => '/Clients/Georgios Biscuit Factory/Upload/Weekly',
  'Global Coffee' => '/Clients/Global Coffee/Upload/Weekly',
  'Grassroots' => '/Clients/Grassroots/Uploads/Weekly',
  'GWK' => '/Clients/GWK/Upload',
  'Halewood' => '/Clients/Halewood International/Upload/Weekly',
  'Heartland Foods' => '/Clients/Heartland Foods/Upload/Weekly',
  'Heineken' => '/Clients/Heineken/Upload/Shoprite Extraction/Weekly',
  'Herbex' => '/Clients/Herbex/Upload/Shoprite/Weekly',
  'Himalaya' => '/Clients/Himalaya Drug Co/Upload/Shoprite',
  'Huletts' => '/Clients/Hulletts/Upload/Shoprite/Weekly',
  'Hulley & Rice' => '/Clients/Hulley&Rice/Upload/Weekly',
  'Icon3sixty' => '/Clients/Icon3sixty/Upload/Weekly',
  'Jimmys Sauces' => '/Clients/Jimmys Sauces/Upload/Weekly',
  'JNJ' => '/Clients/Mentholatum/Upload/Shoprite',
  'KD Foods' => '/Clients/KD Foods/Upload/Weekly',
  'Koni' => '/Clients/Koni/Upload/Weekly',
  'Kunye Services' => '/Clients/KunyeServices/Upload/Weekly',
  'KWV' => '/Clients/KWV/Upload',
  'L & D Bakeries' => '/Clients/L&D Bakeries/Upload/Weekly',
  'Libster' => '/Clients/Libstar/Upload/Weekly',
  'Lion' => '/Clients/Lion/Upload/Weekly',
  'Lopac Tissue' => '/Clients/Lopac/Upload/Weekly',
  'Lucky Star' => '/Clients/Lucky Star/Upload/Weekly',
  'Marico' => '/Clients/Marico/Upload',
  'Marltons Pet' => '/Clients/Marltons/Upload/Shoprite Extracts',
  'Mars' => '/Clients/Mars/Upload/Weekly',
  'Mastertons' => '/Clients/Masterton/Upload/Weekly',
  'Meridian Wine' => '/Clients/Meridian Wines/Upload/Weekly',
  'Millennium Foods' => '/Clients/Millennium Foods/Upload',
  'Model Product' => '/Clients/Model Product/Upload/Weekly',
  'Mokate' => '/Clients/Mokate International/Upload',
  'Mondelez' => '/Clients/Mondelez/Upload/Weekly',
  'Montagu Foods' => '/Clients/Montagu Foods/Upload/Weekly',
  'Montagu' => '/Clients/Montagu/Upload',
  'Monteagle' => '/Clients/Monteagle/Upload/Weekly',
  'Nandos' => '/Clients/Nando\'s/Upload/Weekly',
  'National Pride' => '/Clients/National Pride/Upload/Weekly',
  'NaturesChoice' => '/Clients/Natures Choice Products/Upload/Weekly',
  'Normandien Farms' => '/Clients/Normandien Farms/Upload'
}

# Connection to the SFTP server.
# If no password was set, ssh-agent will be used to detect private/public key authentication.
Net::SFTP.start(ENV['HOST'], ENV['USERNAME']) do |sftp|
  puts opening = <<~OPEN
    Connected to the SFTP server.

    Host: #{ENV['HOST']}
    Username: #{ENV['USERNAME']}\n
  OPEN

  # Close connection if there are no file in local directory,
  # if sftp connection nor its session does not exist.
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
      next unless !!(file =~ /(#{key}).*\.zip$/)

      matches << file
    end

    if matches.any?
      puts "Client[#{index.next}]: #{key}".yellow

      matches.map do |file|
        spinner = TTY::Spinner.new(
          "[:spinner] Copying #{file} to #{value}",
          success_mark: '+',
          clear: true
        )
        spinner.auto_spin

        # Send the clients files to its respective folders.
        sftp.upload!("#{local}/#{file}", "#{value}/#{file}")
        spinner.success
      end
    end

    sent = "#{matches.size} #{key} files copied to #{value}\n"
    puts matches.empty? ? sent.red : sent.green
  end

  puts "Done copying available files\n".green, 'Connection terminated'
end
