module DigitalOcean
  class Droplet

    attr_accessor :name, :size_id, :image_id, :region_id, :ip_address
    attr_accessor :id, :backups_active, :status_id

    def initialize(client, container, data={})
      @client = client
      @container = container

      if data
        # TODO: validate 
        data.each do |key,value|
          send("#{key}=",value) if respond_to?(key.to_sym) 
        end
      end

    end
   
    def command(action)
      raise 'You do not have a droplet id. Have you called save() on your object?' unless @id

      response = @client.request(
        :get,
        "/droplets/#{@id}/#{action}"
      )

      raise "There was a failure performing `#{action}` on droplet=#{id}.  response=#{response}'" unless response["event_id"]

    end

    def reboot
      command('reboot')
    end

    def power_cycle
      command('power_cycle')
    end

    def shut_down
      command('shut_down')
    end
    
    def power_off
      command('power_off')
    end

    def power_on
      command('power_on')
    end

    def reset_root_password
      command('reset_root_password')
    end

    def resize(size_id)
      #TODO
    end

    def snapshot(snapshot_name)
      # TODO
    end

    def restore(image_id)
      # TODO
    end

    def rebuild(image_id)
      # TODO
    end

    def enable_backups
      command('enable_backups')
    end

    def disable_backups
      command('disable_backups')
    end

    def destroy!

      if @id
        command('destroy')
        @container.delete(@id)
        @id = nil
      end
    end

    def refresh
      raise 'No id has been set.  Cannot refresh.  Have you called save() on this droplet?' unless @id
      
      response = @client.request(:get, "/droplets/#{id}")

      if !response['droplet']
        puts "No droplet fetched for id=#{id}"
        return nil
      end

      # TODO: validate 
      response['droplet'].each { |key,value| send("#{key}=",value) if respond_to?(key) } 

      self
    end

    def save

      #TODO: validate
      if !@id
        
        response = @client.request(
          :get,
          '/droplets/new',
          {
            'name' => @name,
            'size_id' => @size_id,
            'image_id' => @image_id,
            'region_id'=> @region_id
          }
        )

        if !response["droplet"]
          puts "No droplet fetched for id=#{id}"
          return nil
        end

        @id = response["droplet"]["id"] 
        @container[@id] = self
      else
        raise 'Already created.'
      end

    end
    
  end
end
