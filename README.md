# digital_ocean

* [Homepage](https://rubygems.org/gems/digital_ocean)
* [Documentation](http://rubydoc.info/gems/digital_ocean/frames)
* [Email](mailto:jandre at gmail.com)

## Description

A ruby interface for the Digital Ocean API here: https://www.digitalocean.com/api.  
Supports (nearly) everything the API supports to create and manage your droplets.

## Examples

### Get a list of droplets

    require 'digital_ocean'
    client = DigitalOcean::Client.new(YOUR_CLIENT_ID, YOUR_API_KEY)
    client.droplets

### Get droplet information
    
    TODO

### Create a droplet
    
    TODO

### Reboot a droplet
    
    TODO

### Destroy a droplet
  
    TODO


## Requirements

   rest-client

## Known Issues

The ssh keys api does not work.

## Install

    $ gem install digital_ocean

    or 

    $ git clone git@github.com:jandre/digital_ocean.git
    $ cd digital_ocean && rake install

## Copyright

Copyright (c) 2012 Jen Andre

See {file:LICENSE.txt} for details.
