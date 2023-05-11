# frozen_string_literal: true

require 'yaml'

require_relative 'helpers/terminal_helpers'
require_relative 'helpers/file_helpers'
require_relative 'sftp'

include InternalLogMethods

NUMBER_OF_DAYS = 30
remote = YAML.load_file('lib/shoprite_clients.yml')

def arguments?
  ARGV.any?
end

def analysis_mode?
  ARGV.at(0) == 'analyze'
end

def clients_to_cycle(client_list)
  first_arg, second_arg, third_arg = ARGV

  return client_list.cycle.take(first_arg.to_i) if arguments? && !analysis_mode?
  return client_list.take(second_arg.to_i) if arguments? && analysis_mode? && !second_arg.nil? && third_arg.nil?

  # Range when you are not on upload mode.
  if arguments? && analysis_mode? && !second_arg.nil? && !third_arg.nil?
    first = second_arg.to_i.pred
    second = third_arg.to_i

    cycle = client_list.to_a[first...second]
    return cycle
  end

  client_list
end

# Print files in remote directory.
def print_remote_entries(session, remote_location, client)
  session.entries(remote_location) do |entry|
    next unless not_hidden_file?(entry.name)

    if entry.attributes.directory?
      puts "#{entry.longname} ----- FOLDER".blue
    elsif file_extention?(entry.name, '.csv')
      puts "#{entry.longname} ----- MANUAL EXTRACTION"
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

  puts ''
end

# Get all files with the client name (prefix).
def get_matching_files(local, client)
  Dir.children(local).select do |file|
    (file =~ /(#{client}).*.zip$/i) && not_hidden_file?(file)
  end
end

# Ask user to specify range and files to delete. The former applies to analysis mode only.
def get_prompt_information(prompt, remote)
  if analysis_mode?
    range_answer = prompt.yes?("Do you want to provide a range?")

    if range_answer
      range = prompt.ask("Provide a range of clients between 1 and #{remote.size}:") { |q| q.in('1-142') }
      # Add the range elements to ARGV.
      range.split(/[\s\-]/).each { |e| ARGV << e }
    end
  end

  # Ask for a delete number of days regardless of the mode.
  delete_answer = prompt.yes?("Do you want to specify the number of days for a file to be deleted? (default: 30 days)?")

  if delete_answer
    days = prompt.ask("Enter the amount of days?") { |q| q.in('1-60') }.to_i
  end

  puts "\n"
end

def track_index(index, client, remote_location)
  ARGV.at(2) ? index += ARGV.at(1).to_i : index += 1
  
  puts "[#{index}: #{client}] #{remote_location}\n".yellow
end

# Uploads file to specified remote location. 
def upload_file(session, file, local, remote_location, index, matches)
  spinner = TTY::Spinner.new(
    "[:spinner] Copying #{file} to #{remote_location} -- (#{index.next}/#{matches.size})",
    success_mark: '+',
    clear: true
  )
  spinner.auto_spin

  begin
    session.upload("#{local}/#{file}", "#{remote_location}/#{file}")
    spinner.success
  rescue StandardError => e
    log_error("Error while uploading #{file}: #{e}".red)
  end
end

def main(local, remote)
  log_error('Error: local directory is not specified.'.red) if local.nil?

  session = SFTP.new(ENV['HOST'], ENV['USERNAME'])
  prompt  = TTY::Prompt.new

  get_prompt_information(prompt, remote)
  
  clients_to_cycle(remote).each_with_index do |(client, remote_location), index|
    matches = get_matching_files(local, client)
    track_index(index, client, remote_location)

    next if matches.compact.empty? 

    matches.compact.each_with_index do |file, index|
      next if analysis_mode?
      upload_file(session, file, local, remote_location, index, matches) unless remote_location.empty? 
    end

    session.increment_clients_count
    delete_files(session, remote_location, number_of_days: defined?(days) ? days : NUMBER_OF_DAYS)

    unless remote_location.empty? 
      print_remote_entries(session, remote_location, client)
    end
  end
end

local = ENV['LOCAL_LOCATION']
main(local, remote)
