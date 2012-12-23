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

    def command(action, &block)

      if @client.async && block_given?

        EventMachine.defer do
          begin

            raise ValidateError.new('You do not have a droplet id. Have you called save() on your object?') unless @id



            response = @client.request(
              :get,
              "/droplets/#{@id}/#{action}/"
            )

            raise DigitalOcean::ClientError.new("There was a failure performing `#{action}` on droplet=#{id}.  response=#{response}'") unless response["event_id"]

            block.call(true)

          rescue => e
            block.call(nil, e)
          end

        end
      else
        raise ValidateError.new('You do not have a droplet id. Have you called save() on your object?') unless @id

        response = @client.request(
          :get,
          "/droplets/#{@id}/#{action}/"
        ) 

        raise DigitalOcean::ClientError.new("There was a failure performing `#{action}` on droplet=#{id}.  response=#{response}'") unless response["event_id"]

        block.call(true, nil) if block_given?
      end
    end

    # set an image
    def image=(value)
      if value.respond_to?(:id)
        @image_id = id
      end
    end

    def reboot(&block)
      command('reboot', &block)
    end

    def power_cycle(&block)
      command('power_cycle', &block)
    end

    def shut_down(&block)
      command('shutdown', &block)
    end

    def power_off(&block)
      command('power_off', &block)
    end

    def power_on(&block)
      command('power_on', &block)
    end

    def reset_root_password(&block)
      command('reset_root_password',&block)
    end


    def _resize(size_id)

      response = @client.request(:get, "/droplets/#{id}/resize/", { size_id: size_id } )

      if !response['event_id']
        msg = "Error resizing droplet for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
      
    end


    def resize(size_id, &block)

      if @client.async && block_given?

        EventMachine.defer do
          begin

            response = _resize(size_id)
            block.call(response)

          rescue => e
            block.call(nil, e)
          end
        end
        return
      end

      return _resize(size_id)
    end


    def snapshot(snapshot_name, &block)

      if @client.async && block_given?

        EventMachine.defer do
          begin

            response = _snapshot(snapshot_name)
            block.call(response)

          rescue => e
            block.call(nil, e)
          end
        end
        return
      end

      return _snapshot(snapshot_name)

    end


    def _snapshot(snapshot_name)
      response = @client.request(:get, "/droplets/#{id}/snapshot_name/", { name: snapshot_name } )

      if !response['event_id']
        msg = "Error snapshoting droplet with name=#{snapshot_name} for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
    end

    def _restore(image_id)
      response = @client.request(:get, "/droplets/#{id}/restore/", { image_id: image_id } )

      if !response['event_id']
        msg = "Error restoring droplet to image_id=#{image_id} for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
    end


    def restore(image_id, &block)

      if @client.async && block_given?

        EventMachine.defer do
          begin

            response = _restore(image_id)
            block.call(response)

          rescue => e
            block.call(nil, e)
          end
        end
        return
      end

      return _restore(image_id)

    end



    def _rebuild(image_id)
      response = @client.request(:get, "/droplets/#{id}/rebuild/", { image_id: image_id } )

      if !response['event_id']
        msg = "Error rebuilding droplet with image_id=#{image_id} for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end

      response['event_id']
    end


    def rebuild(image_id, &block)

      if @client.async && block_given?

        EventMachine.defer do
          begin

            response = _rebuild(image_id)
            block.call(response)

          rescue => e
            block.call(nil, e)
          end
        end
        return
      end

      return _rebuild(image_id)

    end



    def enable_backups(&block)
      command('enable_backups', &block)
    end

    def disable_backups(&block)
      command('disable_backups', &block)
    end

    def destroy!(&block)

      if @id
        command('destroy') do |results, err|

          block.call(results, err) if block_given?
          
          @container.delete(@id)
          @id = nil

        end
      end
    end

    def _refresh
      raise 'No id has been set.  Cannot refresh.  Have you called save() on this droplet?' unless @id

      response = @client.request(:get, "/droplets/#{id}")

      if !response['droplet']
        msg = "No droplet fetched for id=#{id}"
        raise DigitalOcean::ClientError.new(msg)
      end
     
      response['droplet'].each do |key,value| 
        self.send("#{key}=",value) if respond_to?(key.to_sym) 
      end

      self
    end

    def refresh(&block)


      if block_given? && @client.async

        EventMachine.defer do
          begin

            result = _refresh
            block.call(result)

          rescue => e
            block.call(nil, e)
          end

        end
        
      else
        return _refresh
      end
    end


    def _ready(max_seconds_wait=0, &block)

        tries = 0
        done = false

        while (!done) && (tries <= max_seconds_wait)
          begin
            refresh
            done = (status == 'active' && ip_address != '')
          rescue => e
            puts "No droplet created yet... (#{e})"
          end

          if tries < max_seconds_wait 
            sleep 1
          end
          tries += 1 
        end

        block.call(self) if block_given?
        return done 

    end

    def ready(&block)
      if @client.async && block_given?
        EventMachine.defer do
          begin
            _ready(&block)
          rescue => e
            block.call(nil, e)
          end
        end
      else
        return _ready(&block)
      end
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
