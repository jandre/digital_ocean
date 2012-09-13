require 'digital_ocean/droplet'
require 'digital_ocean/client_error'


module DigitalOcean
  class Droplets < Hash

    def initialize(client)
      @client = client
      refresh
    end

    # refresh all droplets
    def refresh

      clear
      @client.request(:get, '/droplets/', {}) do |response| 
          response['droplets'].each do |droplet| 
            self[droplet['id']] = Droplet.new(@client, self, droplet) 
          end
        end

    end

    # get a droplet by id, with an optional refresh parameter
    def get(id, refresh=false)
      raise ClientError.new 'Missing <id>: You must provide a droplet id' unless id

      if !self.has_key?(id) || refresh

        droplet = Droplet.new(@client, self, {:id => id})
        droplet = droplet.refresh()
        self[id] = droplet

      end

      self[id]
    end

    # returns a list of droplets that match name
    def find_by_name(name) 
      droplets = []
      
      self.each do |key, droplet|
        droplets.push(droplet) if droplet.name == name
      end

      droplets
    end

    # create a new droplet
    def create(data={}, save=true)
      droplet = Droplet.new(@client, self, data)

      if save
        droplet.save() 
        self[droplet.id] = droplet
      end

      droplet
    end

  end
end
