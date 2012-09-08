module DigitalOcean
  class Regions < Hash 

    def initialize(client)
      @client = client
      refresh
    end

    # refresh the regions
    def refresh
      clear()
      @client.request(:get, '/regions/', {}) do |response|
        response['regions'].each do |region|
          self[region["id"]] = region["name"] 
        end
      end

    end
  end
end
