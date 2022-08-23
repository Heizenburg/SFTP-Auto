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
gem 'net-sftp', '~> 2.1', '>= 2.1.2'
...

```

## Run

We'll use the environment variable LOCAL_LOCATION, USERNAME and HOST to obtain all the required information for connecting to an SFTP server in a URI format: `sftp://user:password@host`.

Running the example will do the following:

 **Upload** the downloaded file to another remote copy.

```
$ rake 
```
Or 

```
$ rake run 
```
