require 'digital_ocean/droplet'
require 'digital_ocean/client_error'


module DigitalOcean
  class Droplets < Hash

    def initialize(client)
      @client = client
      refresh
    end

    # refresh all droplets
    def refresh(&block)

      clear
      @client.request(:get, '/droplets/', {}) do |response| 
          response['droplets'].each do |droplet| 
            self[droplet['id']] = Droplet.new(@client, self, droplet) 
          end

          block.call(self) if block_given?
        end

    end

    # get a droplet by id, with an optional refresh parameter
    def get(id, should_refresh=false, &block)

      id = id.to_i
      if block_given? && @client.async

        EventMachine.defer do
          begin

            if !self.has_key?(id) || should_refresh

              droplet = Droplet.new(@client, self, {:id => id})
              droplet = droplet.refresh()
              self[id] = droplet

            end

            block.call(self[id])

          rescue => e
            block.call(nil, e)
          end


        end
        return
      end

      raise ClientError.new 'Missing <id>: You must provide a droplet id' unless id

      if !self.has_key?(id) || should_refresh

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
    def create(data={}, save=true, &block)


      if @client.async && block_given?

        EventMachine.defer do
         
          begin
            droplet = Droplet.new(@client, self, data)

            if save
              droplet.save() 
              self[droplet.id] = droplet
            end

            block.call(droplet)
          rescue => e
            block.call(nil, e)
          end

        end

      else

        droplet = Droplet.new(@client, self, data)

        if save
          droplet.save() 
          self[droplet.id] = droplet
        end

        droplet
      end
    end

  end
end
