module DigitalOcean
  class Sizes < Hash 

    def initialize(client)
      @client = client
      refresh
    end

    # refresh the sizes
    def refresh
      clear()
      @client.request(:get, '/sizes/', {}) do |response|
        response['sizes'].each do |size|
          self[size["id"]] = size["name"] 
        end
      end

    end
  end
end
