# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

require_relative '../lib/upload'

class TestClientsToCycle < Minitest::Test
  def setup
    @remote = [
      ['client1', '/remote/location1'],
      ['client2', '/remote/location2'],
      ['client3', '/remote/location3']
    ]
    @local = '/local/location'
  end

  describe 'YAML file' do
    it 'should load the YAML file correctly' do
      expect(YAML.load_file('lib/shoprite_clients.yml')).to_not be_nil
    end
  end

  describe 'arguments?' do
    it 'should return true if there are any arguments' do
      ARGV.replace ['analyze']
      expect(arguments?).to be true
    end

    it 'should return false if there are no arguments' do
      ARGV.replace []
      expect(arguments?).to be false
    end
  end

  describe 'analysis_mode?' do
    it 'should return true if the first argument is "analyze"' do
      ARGV.replace ['analyze']
      expect(analysis_mode?).to be true
    end

    it 'should return false if the first argument is not "analyze"' do
      ARGV.replace ['upload']
      expect(analysis_mode?).to be false
    end
  end

  describe 'clients_to_cycle' do
    let(:client_list) do
      [%w[client1 remote_location1], %w[client2 remote_location2], %w[client3 remote_location3]]
    end

    it 'should return the first n clients if there are two arguments' do
      ARGV.replace %w[upload 2]
      expect(clients_to_cycle(client_list)).to eq([%w[client1 remote_location1], %w[client2 remote_location2]])
    end

    it 'should return the clients within the specified range if there are three arguments' do
      ARGV.replace %w[upload 2 3]
      expect(clients_to_cycle(client_list)).to eq([%w[client2 remote_location2], %w[client3 remote_location3]])
    end

    it 'should return all clients if there are no arguments' do
      ARGV.replace []
      expect(clients_to_cycle(client_list)).to eq(client_list)
    end
  end

  describe 'print_remote_entries' do
    let(:session) { double('session') }
    let(:remote_location) { 'remote_location' }
    let(:client) { 'client1' }
    let(:entry1) do
      double('entry1', name: 'file1', longname: 'file1',
                      attributes: double('attributes', directory?: false, size: 1024))
    end
    let(:entry2) do
      double('entry2', name: 'file2', longname: 'file2', attributes: double('attributes', directory?: true, size: 0))
    end
    let(:entry3) do
      double('entry3', name: 'file3', longname: 'file3',
                      attributes: double('attributes', directory?: false, size: 2048))
    end

    it 'should print the correct output for a recent client file' do
      allow(self).to receive(:recent_file?).with(entry1).and_return(true)
      allow(self).to receive(:client_file?).with('file1', client).and_return(true)
      expect { print_remote_entries(session, remote_location, client) }.to output(/file1.*1024/).to_stdout
    end

    it 'should print the correct output for a recent non-client file' do
      allow(self).to receive(:recent_file?).with(entry1).and_return(true)
      allow(self).to receive(:client_file?).with('file1', client).and_return(false)
      expect do
        print_remote_entries(session, remote_location, client)
      end.to output(/file1.*NEW FILE DOES NOT BELONG HERE/).to_stdout
    end

    it 'should print the correct output for a non-recent non-client file' do
      allow(self).to receive(:recent_file?).with(entry1).and_return(false)
      allow(self).to receive(:client_file?).with('file1', client).and_return(false)
      expect do
        print_remote_entries(session, remote_location, client)
      end.to output(/file1.*FILE DOES NOT BELONG HERE/).to_stdout
    end

    it 'should print the correct output for a client file that is not recent' do
      allow(self).to receive(:recent_file?).with(entry1).and_return(false)
      allow(self).to receive(:client_file?).with('file1', client).and_return(true)
      expect { print_remote_entries(session, remote_location, client) }.to output(/file1.*1024/).to_stdout
    end

    it 'should print the correct output for a directory' do
      expect { print_remote_entries(session, remote_location, client) }.to output(/file2.*FOLDER/).to_stdout
    end
  end

  describe 'get_matching_files' do
    let(:local) { 'spec/fixtures' }
    let(:client) { 'client1' }

    it 'should return the matching files' do
      expect(get_matching_files(local, client)).to eq(['client1_file1.txt', 'client1_file2.txt'])
    end
  end

  describe 'get_range' do
    let(:prompt) { double('prompt') }
    let(:clients) do
      [%w[client1 remote_location1], %w[client2 remote_location2], %w[client3 remote_location3]]
    end

    it 'should return nil if the user does not want to provide a range' do
      allow(prompt).to receive(:yes?).and_return(false)
      expect(get_range(prompt, clients)).to be_nil
    end

    it 'should return the range if the user provides a range' do
      allow(prompt).to receive(:yes?).and_return(true)
      allow(prompt).to receive(:ask).and_return('2-3')
      expect(get_range(prompt, clients)).to eq(%w[2 3])
    end
  end

  describe 'get_delete_days' do
    let(:prompt) { double('prompt') }
    let(:default_days) { 30 }

    it 'should return the default number of days if the user does not want to specify' do
      allow(prompt).to receive(:yes?).and_return(false)
      expect(get_delete_days(prompt, default_days)).to eq(default_days)
    end

    it 'should return the number of days specified by the user' do
      allow(prompt).to receive(:yes?).and_return(true)
      allow(prompt).to receive(:ask).and_return('15')
      expect(get_delete_days(prompt, default_days)).to eq(15)
    end
  end

  describe 'print_client_information' do
    let(:index) { 0 }
    let(:client) { 'client1' }
    let(:remote_location) { 'remote_location1' }

    it 'should print the correct output when there are two arguments' do
      ARGV.replace %w[upload 2]
      expect do
        print_client_information(index, client, remote_location)
      end.to output(/\[1: client1\] remote_location1/).to_stdout
    end

    it 'should print the correct output when there are three arguments' do
      ARGV.replace %w[upload 2 3]
      expect do
        print_client_information(index, client, remote_location)
      end.to output(/\[3: client1\] remote_location1/).to_stdout
    end
  end

  describe 'upload_file' do
    let(:session) { double('session') }
    let(:file) { 'file.txt' }
    let(:local) { 'spec/fixtures' }
    let(:remote_location) { 'remote_location1' }
    let(:index) { 0 }
    let(:matches) { ['file.txt'] }

    it 'should upload the file correctly' do
      spinner = double('spinner')
      allow(TTY::Spinner).to receive(:new).and_return(spinner)
      allow(spinner).to receive(:auto_spin)
      allow(spinner).to receive(:success)
      expect(session).to receive(:upload).with("#{local}/#{file}", "#{remote_location}/#{file}")
      upload_file(session, file, local, remote_location, index, matches)
    end
  end

  describe 'main' do
    let(:local_directory) { 'spec/fixtures' }
    let(:clients) do
      [%w[client1 remote_location1], %w[client2 remote_location2], %w[client3 remote_location3]]
    end

    it 'should run without errors' do
      expect { main(local_directory, clients) }.to_not raise_error
    end
  end
end
