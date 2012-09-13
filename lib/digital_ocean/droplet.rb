module DigitalOcean
  class Droplet

    attr_accessor :name, :size_id, :image_id, :region_id, :ip_address
    attr_accessor :id, :backups_active, :status

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

    def to_s
      return super.to_s +
              "{ id: #{id}, status: #{status}, name: #{name}, size_id: #{size_id}, image_id: #{image_id}, " +
             "region_id: #{region_id}, ip_address: #{ip_address}, backups_active: #{backups_active} "
    end

    def command(action)
      raise ValidateError.new('You do not have a droplet id. Have you called save() on your object?') unless @id

      response = @client.request(
        :get,
        "/droplets/#{@id}/#{action}/"
      )

      raise DigitalOcean::ClientError.new("There was a failure performing `#{action}` on droplet=#{id}.  response=#{response}'") unless response["event_id"]

    end

    # set an image
    def image=(value)
      if value.respond_to?(:id)
        @image_id = id
      end
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
      response = @client.request(:get, "/droplets/#{id}/resize/", { size_id: size_id } )

      if !response['event_id']
        msg = "Error resizing droplet for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
    end

    def snapshot(snapshot_name)
      response = @client.request(:get, "/droplets/#{id}/snapshot_name/", { name: snapshot_name } )

      if !response['event_id']
        msg = "Error snapshoting droplet with name=#{snapshot_name} for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
    end

    def restore(image_id)
      response = @client.request(:get, "/droplets/#{id}/restore/", { image_id: image_id } )

      if !response['event_id']
        msg = "Error restoring droplet to image_id=#{image_id} for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
    end

    def rebuild(image_id)
      response = @client.request(:get, "/droplets/#{id}/rebuild/", { image_id: image_id } )

      if !response['event_id']
        msg = "Error rebuilding droplet with image_id=#{image_id} for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
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
        msg = "No droplet fetched for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['droplet'].each { |key,value| send("#{key}=",value) if respond_to?(key) }

      self
    end


    def ready(max_seconds_wait=0, &block)

        tries = 0
        done = false
        while not done
          begin
            refresh
            done = true
          rescue => e
            puts "No droplet created yet... (#{e})"
            tries += 1
            if tries < max_seconds_wait || max_seconds_wait == 0
              sleep 1
            else
              done = true
            end
          end
        end
        refresh
        block.call(self) if block

    end

    def save

      if !@id

        raise ValidateError.new('Missing name') unless @name
        raise ValidateError.new('Missing size_id') unless @size_id
        raise ValidateError.new('Missing image_id') unless @image_id
        raise ValidateError.new('Missing region_id') unless @region_id

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
          raise DigitalOcean::ClientError.new("No droplet fetched for id=#{id}")
        end

        @id = response["droplet"]["id"]

        @container[@id] = self

        return self
      else
        raise DigitalOcean::ClientError.new('Your droplet was already created.')
      end

    end
  end
end
