require 'net/http'

module Connectors
  class Connector
    def get(url)
      url = URI.parse(url)
      request = Net::HTTP::Get.new(url.path)
      response = Net::HTTP.start(url.host, url.port) do |http|
        http.get(url.request_uri)
      end      

      response.body
    end
  end
end