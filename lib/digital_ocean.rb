require 'rest_client'
require 'digital_ocean/version'

module DigitalOcean

  BASE_URL = "https://api.digitalocean.com"

  attr_accessor :client_id, :api_key

  def self.configure(client_id, api_key)
    @client_id = client_id
    @api_key = api_key
  end

  def self.request(type='get', uri='/', params={})
    url = BASE_URL + uri 
    params[:api_key] = @api_key
    params[:client_id] = @client_id
    RestClient.send(type.to_sym, url, params) 
  end


end
