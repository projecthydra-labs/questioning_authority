# frozen_string_literal: true
require 'faraday'

module Qa::Authorities
  ##
  # Mix-in to retreive and parse JSON content from the web with Faraday.
  module WebServiceBase
    ##
    # @!attribute [rw] raw_response
    attr_accessor :raw_response

    ##
    # Make a web request & retieve a JSON response for a given URL.
    #
    # @param url [String]
    # @return [Hash] a parsed JSON response
    def json(url)
      Rails.logger.info "Retrieving json for url: #{url}"
      r = response(url).body
      JSON.parse(r)
    end

    ##
    # Make a web request and retrieve the response.
    #
    # @param url [String]
    # @return [Faraday::Response]
    def response(url)
      Faraday.get(url) { |req| req.headers['Accept'] = 'application/json' }
    end
  end
end
