# frozen_string_literal: true

# spec/file_helpers_spec.rb

require_relative '../src/helpers/file_helpers'
require 'rspec'

RSpec.describe 'FileHelpers' do
  describe '#file_extension?' do
    it 'returns true for a file with the specified extension' do
      file = 'example.txt'
      ext = '.txt'
      expect(file_extension?(file, ext)).to eq(true)
    end

    it 'returns false for a file with a different extension' do
      file = 'example.jpg'
      ext = '.txt'
      expect(file_extension?(file, ext)).to eq(false)
    end
  end

  describe '#convert_bytes' do
    it 'converts bytes to kilobytes and returns the formatted string' do
      bytes = 2048
      # Yellow color code for KB - 33
      file_size = '2KB'
      expect(convert_bytes(bytes, :KB)).to eq("\e[1;33m#{file_size}\e[0m")
    end

    it 'converts bytes to megabytes and returns the formatted string' do
      bytes = 1_048_576
      # Cyan color code for MB - 36
      file_size = '1.0MB'
      expect(convert_bytes(bytes, :MB)).to eq("\e[1;36m#{file_size}\e[0m")
    end

    it 'returns "Invalid input" for nil bytes' do
      bytes = nil
      expect(convert_bytes(bytes, :KB)).to eq('Invalid input')
    end

    it 'returns "Invalid input" for zero or negative bytes' do
      bytes = 0
      expect(convert_bytes(bytes, :KB)).to eq('Invalid input')
    end
  end
end
