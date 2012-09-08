require 'digital_ocean/ssh_key'

module DigitalOcean
  class SshKeys < Hash

    def initialize(client)
      @client = client
      refresh
    end

    # refresh all ssh_keys 
    def refresh
      clear()
      @client.request(:get, '/ssh_keys/', {}) do |response| 
        response['ssh_keys'].each do |ssh_key| 
          self[ssh_key['id']] = SshKey.new(@client, self, ssh_key) 
        end
      end

    end

    def find_by_name
      keys = []
      each do |key, value|
        keys.push(value) if value.name == name
      end
      keys
    end

    def create
      # TODO
    end

  end
end
