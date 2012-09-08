require 'rest_client'
require 'digital_ocean/droplets'
require 'json'

module DigitalOcean
  class Client

    BASE_URL = "https://api.digitalocean.com"

    attr_accessor :client_id, :api_key

    def initialize(client_id, api_key)
      @client_id = client_id
      @api_key = api_key
    end

   
    def XXX_remove_request(parameters) 
      type = parameters[:type] || :get
      uri = parameters[:uri] || '/'
      params = parameters[:params] || {}
      block = parameters[:block] || nil
      make_request(type, uri, params, &block)
    end

    
    def request(type=:get, uri='/', params={}, &block)
      url = BASE_URL + uri 
      params[:api_key] = @api_key
      params[:client_id] = @client_id

      puts "url: #{url}"
  
      type = type.to_sym

      if type == :get
        params = { :params => params }
      end

      response = RestClient.send(type, url, params) 
  
      puts "response: #{response}"
      response = JSON.parse(response)

      if response['status'] == "OK"
        if block
          return block.call(response) 
        else
          return response
        end

      end
     
      # TODO: otherwise, an error condition happened. 
      raise "Error performing `#{type} #{url}` with parameters=`#{params}`, got #{response}"
    end

    def droplets(refresh=false)
      
      @droplets = nil if refresh
      @droplets = @droplets || Droplets.new(self) 
      @droplets
    end

    

  end

end
