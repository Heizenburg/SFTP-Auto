SFTP CSV uploads  
========================================

The directory contains instructions on how to automate Shoprite CSV file uploads via SFTP.

## Install

Ruby doesn't come bundled with the SFTP libraries from the get-go, so we’ll need to install the required [net-sftp](https://rubygems.org/gems/net-sftp/versions/2.1.2) gem using bundler.

```
$ bundle install
```

In the gemfile there are defined app's dependencies, which would make our Gemfile file look like this:

```
source 'https://rubygems.org'
gem 'net-sftp', '~> 2.8', '>= 2.8.1'
...
```

## Run

We'll use the environment variables `LOCAL_LOCATION`, `USERNAME` and `HOST` to obtain all the required information for connecting to an SFTP server.
Add an `.env` file to root with the aforementioned environment variables.

```
LOCAL_LOCATION=Your local location
USERNAME=Your username
HOST=Host 
```

Running the example will do the following:

 To `Analyze` remote files in remote location.

```
$ rake 
```
Or 

```
$ rake analyze 
```

 To `Upload` local files to remote location.

```
$ rake upload
```

You can specify the number of clients to analyze/upload by providing a range using a colon, hyphen, or a space, such as `10:20`, `10-20`, or `10 20`, respectively. This will loop through clients 10 to 20.

To analyze/upload clients from 1 to `n`, you can input any number that does not exceed the client list length. For example, entering `20` will analyze clients 1 to 20.

If you want to analyze/upload only one client, simply add a full stop after the client number, for example, `20.`.
<br />

And, to `List` all clients 

```
$ rake list
```

