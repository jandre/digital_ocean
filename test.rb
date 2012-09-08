require 'rubygems'

$:<< './lib'
require 'digital_ocean'


client = DigitalOcean::Client.new('4WhguuLiYGzYPLhBq0HZz','3z8rnRYv3xcOoBH3IyXQDJQ36Ni61mosZ6wPL81vB')

puts client.droplets

