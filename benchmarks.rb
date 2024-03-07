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
  x.report('Method with [1..-1] x 1 000 000') { 1_000_000.times { remove_file_from_location_v1(remote_location, file) } }
  x.report('Method with slice x 1 000 000') { 1_000_000.times { remove_file_from_location_v2(remote_location, file) } }
  x.report('Method with drop(1) x 1 000 000') { 1_000_000.times { remove_file_from_location_v3(remote_location, file) } }
end

# Define the first method without regex
def is_client_file_includes(file, client)
  file.downcase.include?(client.downcase)
end

# Define the second method with regex
def is_client_file_regex(file, client)
  file.match?(Regexp.new("^.*#{client}.*\\..+$", Regexp::IGNORECASE))
end

# Benchmark the two methods
Benchmark.bm do |x|
  x.report("is_client_file includes? x  1 000 000") { 1_000_000.times { is_client_file_includes('example_client_file.txt', 'Client') } }
  x.report("is_client_file regex x 1 000 000") { 1_000_000.times { is_client_file_regex('example_client_file.txt', 'Client') } }
end

def get_matching_files_dir_entries(local, client)
  pattern = Regexp.new("(#{client}).*\\.(\\w+)$", Regexp::IGNORECASE)
  Dir.entries(local).select do |file|
    file.match(pattern)
  end
end

def get_matching_files_dir_glob(local, client)
  pattern = Regexp.new("(#{client}).*\\.(\\w+)$", Regexp::IGNORECASE)
  Dir.glob(local.to_s).select do |file|
    file.match(pattern)
  end
end

def get_matching_files_dir_children(local, client)
  Dir.children(local).select do |file|
    file =~ /(#{client}).*\.\w+$/i
  end
end

def get_matching_files_regex(local, client)
  Dir.children(local).select { |file| file =~ /^.*#{client}.*\..+$/i }
end

def get_matching_files_includes(local, client)
  Dir.children(local).select { |file| file.downcase.include?(client.first.downcase) }
end

# Load the list of clients from a YAML file and take the first five.
clients = YAML.load_file('lib/sftp/yaml_files/shoprite_clients.yml').take(5)
local = ENV['SHOPRITE']

def measure_time(func)
  Benchmark.measure { func.call }
end

def report_average(name, results)
  average_time = results.map(&:real).reduce(:+) / results.length
  puts "#{name}: #{format('%.2f', average_time)} seconds"
end

methods_calls = 
  [
    ['Dir.entries', method(:get_matching_files_dir_entries)],
    ['Dir.glob', method(:get_matching_files_dir_glob)],
    ['Dir.children - regex', method(:get_matching_files_dir_children)],
    ['Dir.children - regex (used)', method(:get_matching_files_regex)],
    ['Dir.children - include? and ext', method(:get_matching_files_includes)]
  ]

methods_calls.each do |name, method|
  results = Array.new(methods_calls.size) { measure_time(-> { clients.map { |client| method.call(local, client) } }) }
  report_average(name, results)
end