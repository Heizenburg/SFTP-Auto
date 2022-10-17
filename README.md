SFTP CSV uploads  
========================================

The directory contains instructions for uploading Shoprite CSV files via SFTP.

## Install

Ruby doesn't come bundled with the SFTP libraries from the get-go, so we’ll need to install the required [net-sftp](https://rubygems.org/gems/net-sftp/versions/2.1.2) gem using bundler.

```
$ bundle install
```

In accordance with the 12 factor app cloud development methodology, you should explicitly define your app's dependencies, which would make our Gemfile file look like this:

```
source 'https://rubygems.org'
gem 'net-sftp', '~> 2.8', '>= 2.8.1'
...
```

## Run

We'll use the environment variables LOCAL_LOCATION, USERNAME and HOST to obtain all the required information for connecting to an SFTP server in a URI format: `sftp://user:password@host`.

Running the example will do the following:

 `Analyze` remote files in remote location.

```
$ rake 
```
Or 

```
$ ruby lib/upload.rb analyze 
```

 `Upload` local files to remote location.

```
$ rake upload
```
Or

```
$ ruby lib/upload.rb
```
