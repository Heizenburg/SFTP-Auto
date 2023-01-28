# frozen_string_literal: true

require_relative 'terminal_helpers'
require_relative 'file_helpers'
require_relative 'sftp'

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
  'Campari' => '/Clients/Campari Extract/Upload',
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
  'Jumbo Brands' => '/Clients/Jumbo Brands/Upload/Weekly',
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
  'Orange River Cellars' => '/Clients/Oranjerivier Wynkelders Koop/Upload',
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

def main(local, remote)
  session = SFTP.new(ENV['HOST'], ENV['USERNAME'])

  def arguments?
    ARGV.any?
  end

  def analysis_mode?
    ARGV.at(0) == 'analyze'
  end

  def clients_to_cycle(array)
    first_arg, second_arg, third_arg = ARGV

    return array.cycle.take(first_arg.to_i) if arguments? && !analysis_mode?
    return array.cycle.take(second_arg.to_i) if arguments? && analysis_mode? && !second_arg.nil? && third_arg.nil?

    if arguments? && analysis_mode? && !second_arg.nil? && !third_arg.nil?
      first = second_arg.to_i.pred
      second = third_arg.to_i

      cycle = array.to_a[first...second]
      return cycle
    end

    array
  end

  # Print files in remote directory.
  def print_remote_entries(session, remote_location, client)
    session.entries(remote_location) do |entry|
      next if hidden_file?(entry.name)

      if entry.attributes.directory?
        puts "#{entry.longname} ----- FOLDER"
      elsif file_extention?(entry.name, '.csv')
        puts "#{entry.longname} ----- MANUAL EXTRACTION".light_blue
      elsif recent_file?(entry) && client_file?(entry.name, client)
        puts "#{entry.longname.green} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
      elsif recent_file?(entry) && !client_file?(entry.name, client)
        puts entry.longname.green + ' ----- NEW FILE DOES NOT BELONG HERE'.red
      elsif !recent_file?(entry) && !client_file?(entry.name, client)
        puts entry.longname.to_s + ' ----- FILE DOES NOT BELONG HERE'.red
      elsif client_file?(entry.name, client) && !recent_file?(entry)
        puts "#{entry.longname} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
      end
    end

    puts "\n"
  end

  clients_to_cycle(remote).each_with_index do |(client, remote_location), index|
    matches = Dir.children(local).select do |file|
      (file =~ /(#{client}).*.zip$/i) && !hidden_file?(file)
    end

    index = ARGV.at(2) ? index + ARGV.at(1).to_i : index.succ
    puts "[#{index}]: #{client}\n".yellow

    matches.compact.each_with_index do |file, index|
      next if analysis_mode?

      spinner = TTY::Spinner.new(
        "[:spinner] Copying #{file} to #{remote_location} -- (#{index.next}/#{matches.size})",
        success_mark: '+',
        clear: true
      )
      spinner.auto_spin
      session.upload("#{local}/#{file}", "#{remote_location}/#{file}")
      spinner.success
    end
    session.increment_client
    print_remote_entries(session, remote_location, client)
  end
end

local = ENV['LOCAL_LOCATION']
main(local, remote)
