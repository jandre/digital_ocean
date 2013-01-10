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



