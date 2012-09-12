module DigitalOcean
  class Image
    attr_accessor :id, :name, :distribution 
    
    def initialize(client, container, data={})
      @client = client
      @container = container

      if data
        data.each do |key,value|
          send("#{key}=",value) if respond_to?(key.to_sym) 
        end
      end
    end

    def to_s
      return super.to_s + ": { id: #{id}, name: #{name}, distribution: #{distribution} }"
    end

    def destroy
      raise ValidateError.new("No id exists for this image.  Was it already destroyed?") if not @id

      response = @client.request(
        :get,
        "/images/#{@id}/destroy",
      )

      raise ClientError.new("There was a failure performing `#{action}` on droplet=#{id}.  response=#{response}'") unless response["event_id"]
     
      @container.delete(@id)
      @id = nil
    end
      
  end
end
