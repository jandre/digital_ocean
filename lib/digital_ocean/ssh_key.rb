module DigitalOcean
  class SshKey

    attr_accessor :id, :name
    
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


    # TODO: this doesn't work.
    def save

      params = {
        :ssh_key => {
          :name => @name,
          :ssh_pub_key => @ssh_pub_key
      }}

      params[:ssh_key][:id] = @id if @id 
        
      response = @client.request(:post,
        "/ssh_key/#{@id}/edit/",
        params
      )
     
      # TODO: what does this return???
      puts response
    end

    def ssh_pub_key=(value=nil)
        @ssh_pub_key = value
    end

    def ssh_pub_key
      if not @ssh_pub_key 
        raise ValidateError.new('Unable to fetch key. No id set on this key.  Did you save it?') if not @id

        @client.request(:get, "/ssh_keys/#{@id}") do |response|
          @ssh_pub_key = response['ssh_key']['ssh_pub_key']
        end
      end

      @ssh_pub_key
    end


     
    
  end
end
