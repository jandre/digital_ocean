require 'rubygems'
$:<< '../lib' << 'lib'
require 'digital_ocean'

# this example creates a new droplet, then destroys it after its been started.


unless ARGV.length == 2
  puts "usage: ruby example.rb <client_id> <api_key>"
  exit
end

client_id, api_key = ARGV[0], ARGV[1]

client = DigitalOcean::Client.new(client_id, api_key, :debug => true)

puts "-- my current droplets: --"

client.droplets.each do |droplet_id, droplet|
  puts droplet
end
client.droplets.refresh() # call refresh to refresh, otherwise they are cached.  you can also do client.droplets(true)

puts '-- my first images -- '

client.images.each do |image_id, image|
  puts image
end
# clients.images.refresh() # again, will refresh

puts '-- my sizes --'

puts client.sizes

puts '-- regions --'

puts client.regions

puts '-- creating a new droplet --'

image_id = client.images.find_by_name("Ubuntu 10.04 x32 Server").first.id

size_id = client.sizes.find_by_name("256MB").first

region_id = client.regions.find_by_name("New York 1").first

droplet = client.droplets.create({ image_id: image_id, 
                                   size_id: size_id, region_id: region_id, name: 'specialsauce'})

puts "created: #{droplet}"

while droplet.status != 'active'

  puts "waiting to build... current status: #{droplet.status}"
  sleep 10  
  droplet.refresh
end

puts 'Droplet creation complete! let us now destroy something beautiful...'

droplet.destroy!



