# spec/upload_spec.rb

require_relative '../lib/sftp/upload'
require 'rspec'

RSpec.describe SFTPUploader do
  let(:directory) { 'test_directory' }
  let(:clients) { ['client1', 'client2'] }
  let(:sftp_uploader) { SFTPUploader.new(directory, clients) }

  describe '#initialize' do
    it 'initializes the SFTPUploader object with the correct attributes' do
      expect(sftp_uploader.instance_variable_get(:@directory)).to eq(directory)
      expect(sftp_uploader.instance_variable_get(:@clients)).to eq(clients)
      expect(sftp_uploader.instance_variable_get(:@session)).to be_a(SFTP)
      expect(sftp_uploader.instance_variable_get(:@prompt)).to be_a(TTY::Prompt)
    end
  end

  describe '#validate_local_directory' do
    context 'when the local directory is specified' do
      it 'does not raise an error' do
        expect { sftp_uploader.send(:validate_local_directory) }.not_to raise_error
      end
    end

    context 'when the local directory is not specified' do
      it 'raises an error' do
        sftp_uploader.instance_variable_set(:@directory, nil)
        expect { sftp_uploader.send(:validate_local_directory) }.to raise_error(RuntimeError, 'Error: local directory is not specified.')
      end
    end
  end

  describe '#clients_to_cycle' do
    it 'returns the entire client list when no arguments are provided' do
      expect(sftp_uploader.send(:clients_to_cycle, clients)).to eq(clients)
    end

    it 'returns a subset of the client list based on the provided arguments' do
      allow(sftp_uploader).to receive(:arguments?).and_return(true)
      allow(sftp_uploader).to receive(:arguments?).and_return(true)
      expect(sftp_uploader.send(:clients_to_cycle, clients)).to eq(clients.take(2))
    end
  end

end
