# frozen_string_literal: true

require_relative 'terminal'
require_relative 'sftp'

# This will ultimately be for the shoprite path.
# Remember to -- Dir.pwd -- to see the distinct file location format.
local = ENV['LOCAL_LOCATION']

remote = {
  '3M' => '/Clients/3M/Upload/Weekly',
  'Abbotts Lab' => '/Clients/Abbott Lab/Upload/Weekly',
  'ABV Brands' => '/Clients/ABV Brands/Upload/Weekly',
  'Action Classics' => '/Clients/Action Classics/Upload/Weekly',
  'Aerosol' => '/Clients/Aerosol & Cosmetics/Upload/Weekly',
  'African Extracts' => '/Clients/African Extracts/Upload/Shoprite/Weekly',
  'AJ Products' => '/Clients/AJ Products/Upload/Weekly',
  'ALBION BRANDS' => '/Clients/Albion Brands/Upload/Weekly',
  'All Joy' => '/Clients/All Joy/Upload/Weekly',
  'ALTAS TUISGEBAK' => '/Clients/Altas Tuisgebak/Upload/Weekly',
  'Aquelle' => '/Clients/aQuelle/Upload',
  'B M FOODS' => '/Clients/B M Foods/Uploads/Weekly',
  'Bavaria' => '/Clients/Bavaria/Upload/Weekly',
  'BBH' => '/Clients/BBH/Upload/Weekly',
  'Bennett' => '/Clients/Bennett/Upload/Weekly',
  'Bic' => '/Clients/BIC/Upload',
  'Bliss Chemicals' => '/Clients/Bliss Chemicals/Upload/Raw Data/Weekly',
  'BOS' => '/Clients/BOS/Upload/Weekly',
  'Brands 2 Africa' => '/Clients/Brands 2 Africa/Upload/Weekly',
  'Brother Bees' => '/Clients/Brother Bees/Upload/Weekly',
  'ButtaNutt' => '/Clients/Buttanutt Tree/Uploads',
  'Caffeluxe' => '/Clients/Caffeluxe/Upload/Weekly',
  'CBC' => '/Clients/CBC/Upload/Weekly',
  'Cerebos' => '/Clients/Cerebos/Upload/Weekly',
  'Chet' => '/Clients/Chet/Upload/Weekly',
  'Chill Beverages' => '/Clients/Chill Beverages/Upload/Weekly',
  'Cleopatra Tissue' => '/Clients/Cleopatra Tissue/Upload',
  'Continental Biscuits' => '/Clients/Continental Biscuits/Upload/Weekly',
  'CTP' => '/Clients/Flip File/Upload/Weekly',
  'D&A Cosmetics' => '/Clients/D&A Cosmetics/Uploads/Weekly',
  'Darling' => '/Clients/Darling Romery/Upload/Weekly',
  'Denny Mushrooms' => '/Clients/Denny Mushrooms/Uploads/Weekly',
  'DGB' => '/Clients/DGB/Upload',
  'Diageo' => '/Clients/Diageo 1/Upload/Shoprite',
  'DIPLOMAT DISTRIBUTORS' => '/Clients/Diplomat Distributors/Upload/Weekly',
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
  'Frimax' => '/Clients/Frimax/Upload',
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
  'Hulley & Rice' => '/Clients/Hulley&Rice/Uploads',
  'Icon3sixty' => '/Clients/Icon3sixty/Upload/Weekly',
  'Jimmys Sauces' => '/Clients/Jimmys Sauces/Upload/Weekly',
  'JnJ' => '/Clients/Mentholatum/Upload/Shoprite',
  'KD Foods' => '/Clients/KD Foods/Upload/Weekly',
  'Kelloggs Co' => '/Clients/Kelloggs/Upload/Weekly',
  'Koni' => '/Clients/Koni/Upload/Weekly',
  'Kunye Services' => '/Clients/KunyeServices/Upload/Weekly',
  'KWV' => '/Clients/KWV/Upload',
  'L & D Bakeries' => '/Clients/L&D Bakeries/Upload/Weekly',
  'Litha Pharma Co' => '/Clients/Litha Pharma (Acino)/Uploads/Weekly',
  'Libstar' => '/Clients/Libstar/Upload/Weekly',
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
  'Normandien Farms' => '/Clients/Normandien Farms/Upload',
  'NSP Unsgaard' => '/Clients/Nsp Unsgaard/Upload/Weekly',
  'Okin' => '/Clients/Okin/Upload',
  'Omnings' => '/Clients/Omnings/Upload/Weekly',
  'Paarman Foods' => '/Clients/Paarman/Upload/Weekly',
  'PB Liquor' => '/Clients/PB Liquor/Upload/Weekly',
  'Permark' => '/Clients/Permark/Upload/Shoprite/Weekly',
  'Pernod Ricard' => '/Clients/Pernod Ricard/Upload',
  'Pioneer' => '/Clients/Pioneer Foods/Upload',
  'Plush' => '/Clients/Plush/Upload/Weekly',
  'Pouyoukas Foods' => '/Clients/Pouyoukas/Upload/Weekly',
  'Premier Foods' => '/Clients/Premier Foods/Uploads',
  'Prima Pasta' => '/Clients/Prima Pasta/Upload/Weekly',
  'Quantum' => '/Clients/Quantum Foods/Uploads/Weekly',
  'RCL Food Consumers' => '/Clients/RCL Foods/Upload/Raw Data Extracts/Shoprite Extracts/Latest Data',
  'RCLFood Consumers' => '/Clients/RCL Foods/Upload/Raw Data Extracts/Shoprite Extracts/Latest Data',
  'RGBC' => '/Clients/RGBC/Uploads/Weekly',
  'Rymco' => '/Clients/Rymco/Upload/Weekly',
  'Sally Williams' => '/Clients/SallyWilliams/Upload/Weekly',
  'SALPURA' => '/Clients/Salpura/Upload/Weekly',
  'Serfie' => '/Clients/Serfie/Uploads/Weekly',
  'Sams Tissue Products' => '/Clients/Sams Tissue/Upload/Weekly',
  'Shield Chemicals' => '/Clients/Shield Chemicals/Upload/Weekly',
  'Signal Hill' => '/Clients/Signal Hill/Upload/Weekly',
  'Siqalo' => '/Clients/RCL Foods/Upload/Raw Data Extracts/Shoprite Extracts/Siqalo',
  'Sir Juice' => '/Clients/Sir Juice/Upload/Weekly',
  'Southern Oil' => '/Clients/Southern Oil/Uploads',
  'Spice Mecca' => '/Clients/Spice Mecca/Upload',
  'Stetson Butter' => '/Clients/Stetson Butter/Upload',
  'Strawberry Shortcake' => '/Clients/Strawberry Shortcake/Upload',
  'Sunnyfield' => '/Clients/Sunnyfield Group/Upload',
  'Sunpac' => '/Clients/Sunpac/Upload',
  'Suntory' => '/Clients/Suntory/Upload/Weekly',
  'Swartkops Sea Salt' => '/Clients/Swartkops Sea Salt/Upload/Weekly',
  'Tacoma' => '/Clients/Tacoma/Upload',
  'The Himalaya Drug Co' => '/Clients/Himalaya Drug Co/Upload/Shoprite',
  'Thokoman Foods' => '/Clients/Thokoman Foods/Upload/Weekly',
  'Trade Model Seven' => '/Clients/Trade Model Seven/Uploads/Weekly',
  'Transem' => '/Clients/Transem/Upload',
  'Tuffy' => '/Clients/Tuffy/Upload/Weekly',
  'Unilever SA' => '/Clients/Unilever/Upload/Shoprite/Weekly',
  'Universal Paper' => '/Clients/Universal Paper/Upload/Weekly',
  'Urban Labs International' => '/Clients/Urban Lab Int/Upload/Weekly',
  'Vegeworth' => '/Clients/Vegeworth/Upload',
  'Willow Creek Products' => '/Clients/Willow Creek Products/Uploads/Weekly',
  'Willowton' => '/Clients/Willowton/Upload/Weekly',
  'Woodlands Dairy' => '/Clients/Woodlands Dairy/Upload/Weekly',
  'Woodys' => '/Clients/Woodys/Upload/Weekly',
  'Yellow Fern' => '/Clients/Yellow Fern Trading/Upload/Weekly',
  'Uhrenholt Co' => '/Clients/Urenholt/Uploads/Weekly'
}

# Connection to the SFTP server.
# If no password was set, ssh-agent will be used to detect private/public key authentication.
session = SFTP.new(ENV['HOST'], ENV['USERNAME'])

# Checks if arguments are passed to script.
def arguments?
  ARGV.any?
end

# Returns true if its on analysis mode.
def analysis_mode?
  ARGV.at(0) == 'analyze'
end

# Counts zip files on local dir.
def local_file_count(dir)
  Dir.glob(dir + '/*.zip').length 
end 

# Returns the number of clients that will be looped through in remote hash.
def clients_to_cycle(array)
  return array.cycle.take(ARGV[0].to_i) if arguments? && !analysis_mode?
  return array.cycle.take(ARGV[1].to_i) if arguments? && analysis_mode? && !ARGV[1].nil?

  array
end

# Terminates procedure if there are no files in local directory 
# and if it's not on analysis mode.
if local_file_count(local).zero? && !analysis_mode?
  puts <<~CLOSE
    No files in local directory.
    Closing connection.
  CLOSE

  exit
end

clients_to_cycle(remote).each_with_index do |(client, remote_location), index|
  matches = []

  Dir.each_child(local) do |file|
    # Skip clients files that do not match client file name or folders.
    next if (file =~ /(#{client}).*\.zip$/).nil? || File.directory?(file) || %w[. ..].include?(file)

    matches << file
  end

  puts "Client[#{index.next}]: #{client}\n".yellow
  unless matches.compact.empty?
    matches.each_with_index do |file, index|
      spinner = TTY::Spinner.new(
        "[:spinner] Copying #{file} to #{remote_location} -- (#{index.next}/#{matches.size})",
        success_mark: '+',
        clear: true
      )
      spinner.auto_spin

      # Upload files only when you are in upload mode
      # otherwise will only analyze remote files.
      session.upload("#{local}/#{file}", "#{remote_location}/#{file}") unless analysis_mode?
      spinner.success
    end

    session.increment_client
  end
  session.copied_files(matches, client, remote_location)
  session.remote_entries(remote_location, client)
end

if analysis_mode?
  puts !ARGV[1].nil? ? "Clients remote DIR analyzed - #{ARGV[1]}" : "Clients remote DIR analyzed - #{remote.size}"
else 
  puts "Clients copied: #{session.clients}", 'Connection terminated' 
end