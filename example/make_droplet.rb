require 'rubygems'
$:<< '../lib' << 'lib'
require 'digital_ocean'

# this example creates a new droplet, then destroys it after its been started.


unless ARGV.length == 2
  puts "usage: ruby make_droplet.rb <client_id> <api_key>"
  exit
end

client_id, api_key = ARGV[0], ARGV[1]

client = DigitalOcean::Client.new(client_id, api_key, :debug => true)


puts '-- creating a new droplet --'

image_id = client.images.find_by_name("Ubuntu 10.04 x32 Server").first.id

size_id = client.sizes.find_by_name("256MB").first

region_id = client.regions.find_by_name("New York 1").first

droplet = client.droplets.create({ image_id: image_id, 
                                   size_id: size_id, region_id: region_id, name: 'specialsauce'})
puts "created: #{droplet}"

while droplet.status != 'active'

  puts "waiting to build... current status: #{droplet.status}"
  droplet.refresh
  client.droplets.refresh
  sleep 10  
end

puts 'Droplet creation complete! let us now destroy something beautiful...'

droplet.destroy!



