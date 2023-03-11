# frozen_string_literal: true

require 'yaml'

require_relative 'helpers/terminal_helpers'
require_relative 'helpers/file_helpers'
require_relative 'sftp'

include InternalLogMethods

remote = YAML.load_file('lib/shoprite_clients.yml')

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

  # Range when you are not on upload mode.
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

def main(local, remote)
  session = SFTP.new(ENV['HOST'], ENV['USERNAME'])
  clients_to_cycle(remote).each_with_index do |(client, remote_location), index|
    if local.nil?
      log_error('Error: local directory is not specified.'.red)
    else
      matches = Dir.children(local).select do |file|
        (file =~ /(#{client}).*.zip$/i) && !hidden_file?(file)
      end
    end

    index = ARGV.at(2) ? index + ARGV.at(1).to_i : index.succ
    puts "[#{index}: #{client}] #{remote_location}\n".yellow

    matches.compact.each_with_index do |file, index|
      next if analysis_mode?

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

    session.increment_client
    print_remote_entries(session, remote_location, client) unless remote_location.empty?
  end
end

local = ENV['LOCAL_LOCATION']
main(local, remote)
