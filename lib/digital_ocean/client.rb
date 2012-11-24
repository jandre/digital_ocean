require 'rest_client'
require 'digital_ocean/droplets'
require 'digital_ocean/regions'
require 'digital_ocean/sizes'
require 'digital_ocean/images'
require 'digital_ocean/client_error'
require 'digital_ocean/ssh_keys'
require 'json'
require 'eventmachine'
require 'em-synchrony/em-http'

module DigitalOcean

  class Refreshable
    
    def initialize(options, &constructor)
   
      @debug = options.fetch(:debug, false)
      puts "DEBUG *** initialize options: #{options}" if @debug
      @next_refresh_time = Time.now().to_i
      @cache = options.fetch(:cache, false)
      @cache_time = options.fetch(:cache_seconds, 10 * 60)
      @constructor = constructor

    end
  
    protected


      def method_missing(name, *args, &block)
        self.target.send(name, *args, &block) if self.target.respond_to?(name)
      end

      def expired
        Time.now.to_i >= @next_refresh_time
      end

      def target

        if @cache && expired 
          @target = nil
          @next_refresh_time = Time.now.to_i + @cache_time
          puts "DEBUG: *** forcing refresh" if @debug
        end

        @target = @target || @constructor.call()
        @target 
      end
  end

  class Client

    BASE_URL = "https://api.digitalocean.com"

    attr_accessor :client_id, :api_key

    def initialize(client_id, api_key, options={})
      @client_id = client_id
      @api_key = api_key

      @debug = options.fetch(:debug, false)
      @cache = options.fetch(:cache, false)
      @options = options
      @async=options.fetch(:async, false)

    end

    def make_droplets
      return Droplets.new(self) unless @cache 
      return Refreshable.new(@options) do 
          Droplets.new(self)
      end
    end

   def request_async(type=:get, uri='/', params={}, &block)
      url = BASE_URL + uri 
      # params[:api_key] = @api_key
      # params[:client_id] = @client_id

      type = type.to_sym

      url += "?client_id=#{@client_id}&api_key=#{@api_key}"

      puts "DEBUG: url: #{url}" if @debug
      begin
        if type == :get
          http = EventMachine::HttpRequest.new(url).get(:query => params)
          response = http.response
        else
          http = EventMachine::HttpRequest.new(url).post(:body => params)
          response = http.response
        end
        # response = RestClient.send(type, url, params) 
      rescue => e
        puts "Error performing `#{type} #{url}` with parameters=`#{params}`, got `#{e}`"
        raise
      end

      puts "DEBUG: response: #{response}" if @debug

      response = JSON.parse(response)

      if response['status'] == "OK"
        if block
          return block.call(response) 
        else
          return response
        end

      end
     
      # otherwise, an error condition happened. 
      raise DigitalOcean::ClientError.new("Error performing `#{type} #{url}` with parameters=`#{params}`, got #{response}")
    end
    
    def request(type=:get, uri='/', params={}, &block)

      if @async
        return request_async(type, uri, params, &block) 
        
      else
        return request_sync(type, uri, params, &block)
      #  do |response|

          # block.call(response) if block_given?
        # end
      end
    end

    def request_sync(type=:get, uri='/', params={}, &block)
      url = BASE_URL + uri 
      params[:api_key] = @api_key
      params[:client_id] = @client_id

      type = type.to_sym

      if type == :get
        params = { :params => params }
        params[:api_key] = @api_key
        params[:client_id] = @client_id
      else
        url += "?client_id=#{client_id}&api_key=#{api_key}"
      end

      puts "DEBUG: url: #{url}" if @debug
      begin
        response = RestClient.send(type, url, params) 
      rescue => e
        puts "Error performing `#{type} #{url}` with parameters=`#{params}`, got `#{e}`"
        raise
      end

      puts "DEBUG: response: #{response}" if @debug

      response = JSON.parse(response)

      if response['status'] == "OK"
        if block
          return block.call(response) 
        else
          return response
        end

      end
     
      # otherwise, an error condition happened. 
      raise DigitalOcean::ClientError.new("Error performing `#{type} #{url}` with parameters=`#{params}`, got #{response}")
    end

    
    def droplets(refresh=false)
     
      @droplets = nil if refresh 
      @droplets = @droplets || make_droplets
      @droplets
    end

    def regions(refresh=false)
      @regions = nil if refresh
      @regions = @regions || Regions.new(self)
      @regions
    end
    
    def sizes(refresh=false)
      @sizes = nil if refresh
      @sizes = @sizes || Sizes.new(self)
      @sizes
    end

    def images(refresh=false)
      @images = nil if refresh
      @images = @images || Images.new(self)
      @images
    end

    def ssh_keys(refresh=false)
      @ssh_keys = nil if refresh
      @ssh_keys = @ssh_keys || SshKeys.new(self)
      @ssh_keys
    end
  end

end
