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
You can also pass the number of clients to analyze by either providing a range, 
for instance a range seperated with a hyphen or a space like `10-20` or `10 20` respectively will loop through clients 10 to 20. 

In order to analyze 1 to `n` clients you will need to pass in any number that does not exceed the client list length.

<br />

 To `Upload` local files to remote location.

```
$ rake upload
``` 

And, to `List` all clients 

```
$ rake list
```

