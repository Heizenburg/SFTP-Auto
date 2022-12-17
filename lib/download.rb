# frozen_string_literal: true

require 'uri'

require_relative 'terminal'
require_relative 'sftp'

# File transfer protocol = SFTP-4
# Cryptographic protocol = SSH-2
# SSH implementation = CrushFTPSSHD
# Encryption algorithm = AES-128 SDCTR (AES-NI accelerated)
# Compression = No
# ------------------------------------------------------------
# Server host key fingerprints
# SHA-256 = ssh-rsa 1024 2LzN5B4hJT04EOX8ucTLaCFP90MHBdS64/1Mxl2P/s8=
# MD5 = ssh-rsa 1024 f6:f3:bf:b0:e0:c5:05:29:0e:3d:c8:3d:f0:db:95:da
# ------------------------------------------------------------
# Can change permissions = Yes
# Can change owner/group = Yes
# Can execute arbitrary command = No
# Can create symbolic/hard link = Yes/No
# Can lookup user groups = No
# Can duplicate remote files = No
# Can check available space = No
# Can calculate file checksum = No
# Native text (ASCII) mode transfers = Yes
# ------------------------------------------------------------
# Additional information
# The server supports these SFTP extensions:
#   newline="\r\n"
#   vendor-id=0x000000114A4144415054495645204C696D697465640000000D4D6176657269636B205353484400000006312E372E33310000000000000000

massmart_clients_credentials = {
  'adcock' => 'ZkAp3kST8NMqdVpwMO3n',
  'alpenfoods' => 'c34GbE76XsJ7j6bIDdLD',
  'bic' => 'L39WH3Q1fedCJMyJM3YL'
}

# Print files in remote directory.
def remote_entries(session, remote_location)
  session.entries(remote_location) do |entry|
    next if hidden_file?(entry.name)

    puts entry.longname.to_s
  end
end

# Loop through clients credentials hash and start a session for each one.
massmart_clients_credentials.each do |(username, password)|
  uri = URI("sftp://#{username}:#{password}@ftp.dataorbis.com:2222/")

  Net::SFTP.start(uri.host, uri.user, password: uri.password, port: uri.port) do |sftp|
    remote_entries(sftp, '/Makro')
  end
end
