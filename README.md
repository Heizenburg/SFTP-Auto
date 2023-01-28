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

We'll use the environment variables LOCAL_LOCATION, USERNAME and HOST to obtain all the required information for connecting to an SFTP server.
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
$ ruby lib/upload.rb analyze 
```
You can also pass the number of clients to analyze (IE, below will analyze the first 10 clients remote locations):

```
$ ruby lib/upload.rb analyze 10
``` 
You can pass in a range of clients to analyze (IE, below will analyze files from the 10th the 100th clients remote locations)

```
$ ruby lib/upload.rb analyze 10 100
``` 
<br />

 To `Upload` local files to remote location.

```
$ rake upload
```
Or

```
$ ruby lib/upload.rb
```
You can also pass the number of clients to upload (IE, below will upload files for the first 10 clients remote locations):

```
$ ruby lib/upload.rb 10
``` 