require 'rest_client'
require 'digital_ocean/droplets'
require 'digital_ocean/regions'
require 'digital_ocean/sizes'
require 'digital_ocean/images'
require 'digital_ocean/client_error'
require 'digital_ocean/ssh_keys'
require 'json'
require 'eventmachine'


module DigitalOcean

  class Refreshable
    
#   instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$|^new$|)/ }

    def initialize(options, &constructor)
   
      @debug = options.fetch(:debug, false)
      puts "DEBUG *** initialize options: #{options}" if @debug
      @next_refresh_time = Time.now().to_i
      @cache = options.fetch(:cache, false)
      @cache_time = options.fetch(:cache_seconds, 10 * 60)
      @constructor = constructor
      @async = options.fetch(:async, false)

    end
  
    protected


      def method_missing(name, *args, &block)

        begin
          self.target.send(name, *args, &block) if self.target.respond_to?(name)
        rescue => e
          puts "DigitalOcean error: #{e}" 
          if block_given && @async
            block.call(nil, e)
          else
            raise
          end

        end

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
    attr_reader :async

    def initialize(client_id, api_key, options={})
      @client_id = client_id
      @api_key = api_key

      @debug = options.fetch(:debug, false)
      @cache = options.fetch(:cache, false)
      @options = options
      @async = options.fetch(:async, false)

    end

    def make_droplets
      return Droplets.new(self) unless @cache 
      return Refreshable.new(@options) do 
          Droplets.new(self)
      end
    end
    
    def request(type=:get, uri='/', params={}, &block)
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
      response = nil
      begin
        response = RestClient.send(type, url, params) 
      rescue => e
        puts "Error performing `#{type} #{url}` with parameters=`#{params}`, got `#{e}`"
        if response
          puts "response #{response}"
        end
        raise
      end

      puts "DEBUG: response: #{response}" if @debug

      response = JSON.parse(response)

      if response['status'] == "OK"
        if block
          block.call(response)
          return
        else
          return response
        end

      end
     
      # otherwise, an error condition happened. 
      raise DigitalOcean::ClientError.new("Error performing `#{type} #{url}` with parameters=`#{params}`, got #{response}")
    end

    
    def droplets(refresh=false, &block)
     
      @droplets = nil if refresh

      if block_given? && @async

        EventMachine.defer do 
          @droplets = @droplets || make_droplets
          block.call(@droplets)
        end

      else
        @droplets = @droplets || make_droplets
        block.call(@droplets) if block_given?
        return @droplets
      end
    end

    def regions(refresh=false, &block)
      @regions = nil if refresh


      if block_given? && @async

        EventMachine.defer do 
          @regions = @regions || Regions.new(self)
          block.call(@regions)
        end

      else

        @regions = @regions || Regions.new(self)
        block.call(@regions) if block_given?
        return @regions
      end
    end
    
    def sizes(refresh=false, &block)
      @sizes = nil if refresh

      if block_given? && @async

        EventMachine.defer do 
          @sizes = @sizes || Sizes.new(self)
          block.call(@sizes)
        end

      else


        @sizes = @sizes || Sizes.new(self)
        block.call(@sizes) if block_given?
        return @sizes

      end


    end

    def images(refresh=false, &block)
      @images = nil if refresh
      if block_given? && @async

        EventMachine.defer do 
          @images = @images || Images.new(self)
          block.call(@images)
        end

      else

        @images = @images || Images.new(self)
        block.call(@images) if block_given?
        return @images

      end

    end

    def ssh_keys(refresh=false, &block)
      @ssh_keys = nil if refresh
      @ssh_keys = @ssh_keys || SshKeys.new(self)
      @ssh_keys
    end
  end

end
