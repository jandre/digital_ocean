module DigitalOcean
  class Regions < Hash 

    def initialize(client)
      @client = client
      refresh
    end


    def find_by_name(name) 
      values = []
      self.each do |k, v| 
        values.push(k) if v == name
      end

      values
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
