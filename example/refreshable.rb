require 'rubygems'
$:<< '../lib' << 'lib'
require 'digital_ocean'

# this example creates a new droplet, then destroys it after its been started.


unless ARGV.length == 2
  puts "usage: ruby example.rb <client_id> <api_key>"
  exit
end

client_id, api_key = ARGV[0], ARGV[1]

client = DigitalOcean::Client.new(client_id, api_key, 
                                 :debug => true,
                                 :cache => true,
                                 :cache_seconds => 10,

                                 )

puts "-- my current droplets: --"

client.droplets.each do |droplet_id, droplet|
  puts droplet
end

puts "-- no refresh --"

client.droplets.each do |droplet_id, droplet|
  puts droplet
end

sleep 15
puts '-- refresh --'
client.droplets.each do |droplet_id, droplet|
  puts droplet
end

puts '-- force refresh --'
client.droplets('true').each do |droplet_id, droplet|
  puts droplet
end






