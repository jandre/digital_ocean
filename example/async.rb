require 'rubygems'
$:<< '../lib' << 'lib'
require 'digital_ocean'
require 'eventmachine'
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
                                 :async => true
                                 )

EventMachine.run do 

    client.droplets do |droplets|
      droplets.each do |droplet_id, droplet|
        puts droplet

        droplet.refresh do |refreshed_droplet, err|

          puts "refreshed droplet: #{refreshed_droplet}"

        end
      end 
    end

    # EventMachine.stop

end







