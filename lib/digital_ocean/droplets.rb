require 'digital_ocean/droplet'

module DigitalOcean
  class Droplets < Hash

    def initialize(client)
      @client = client

      @client.request(
        :uri => '/droplets/',
        :block => Proc.new { |response| response['droplets'].each { |droplet| self[droplet['id']] = Droplet.new(@client, droplet) } }
      )
    end

    def get(id, refresh=false)
      raise 'Missing <id>: You must provide a droplet id' unless id

      if (!self.has_key(id) || refresh)

        droplet = Droplet.new(@client, {:id => id})
        droplet = droplet.refresh()
        self[id] = droplet

      end

      self[id]
    end


    def create(data={}, save=true)
      droplet = Droplet.new(@client, data)
      droplet.save() if save
      droplet
    end

  end
end
