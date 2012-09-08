require 'digital_ocean/image'

module DigitalOcean
  class Images < Hash

    def initialize(client)
      @client = client
      refresh
    end

    # refresh all images 
    def refresh
      clear()
      @client.request(:get, '/images/', {}) do |response| 
          response['images'].each do |image| 
            self[image['id']] = Image.new(@client, self, image) 
          end
        end

    end


    def find_by_name
      # TODO
    end


  end
end
