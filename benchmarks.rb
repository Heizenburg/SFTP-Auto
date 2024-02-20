# frozen_string_literal: true

require 'benchmark'
require 'yaml'
require 'dotenv/load'
require 'pry'
require 'pry-nav'
require 'pry-remote'

def remove_file_from_location_v1(remote_location, file)
  File.join(remote_location[1..], file.name)
end

def remove_file_from_location_v2(remote_location, file)
  File.join(remote_location.slice(1, remote_location.size), file.name)
end

def remove_file_from_location_v3(remote_location, file)
  File.join(remote_location.drop(1), file.name)
end

# Sample data
remote_location = %w[root folder1 folder2 folder3]
file = OpenStruct.new(name: 'file.txt')

Benchmark.bm do |x|
  x.report('Method with [1..-1] x 1 000 000') do
    1_000_000.times do
      remove_file_from_location_v1(remote_location, file)
    end
  end

  x.report('Method with slice x 1 000 000') do
    1_000_000.times do
      remove_file_from_location_v2(remote_location, file)
    end
  end

  x.report('Method with drop(1) x 1 000 000') do
    1_000_000.times do
      remove_file_from_location_v3(remote_location, file)
    end
  end
end

def get_matching_files_entries(local, client)
  pattern = Regexp.new("(#{client}).*\\.(\\w+)$", Regexp::IGNORECASE)
  Dir.entries(local).select do |file|
    file.match(pattern)
  end
end

def get_matching_files_glob(local, client)
  pattern = Regexp.new("(#{client}).*\\.(\\w+)$", Regexp::IGNORECASE)
  Dir.glob(local.to_s).select do |file|
    file.match(pattern)
  end
end

def get_matching_files_dir(local, client)
  Dir.children(local).select do |file|
    file =~ /(#{client}).*\.\w+$/i
  end
end

def get_matching_files_includes(local, client)
  Dir.children(local).select do |file|
    File.file?(file) && file.downcase.include?(client.downcase)
  end
end

# Load the list of clients from a YAML file and take the first five.
clients = YAML.load_file('lib/shoprite_clients.yml').take(5)
local = ENV['LOCAL_LOCATION']

Benchmark.bm do |x|
  x.report('Dir.entries') { clients.each { |client| get_matching_files_entries(local, client) } }
  x.report('Dir.glob') { clients.each { |client| get_matching_files_glob(local, client) } }
  x.report('Dir.children - regex') { clients.each { |client| get_matching_files_dir(local, client) } }
  x.report('Dir.children - include?') { clients.each { |client| get_matching_files_includes(local, client) } }
end
