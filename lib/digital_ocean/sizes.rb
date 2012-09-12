module DigitalOcean
  class Sizes < Hash 

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
