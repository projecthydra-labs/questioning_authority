require 'qa/authorities/linked_data/config/config_merge'.freeze
require 'qa/authorities/linked_data/config/term_config'.freeze
require 'qa/authorities/linked_data/config/search_config'.freeze
require 'json'

module Qa::Authorities
  module LinkedData
    class Config
      attr_reader :authority_name
      attr_reader :authority_config

      # Initialize to hold the configuration for the specifed authority.  Configurations are defined in config/authorities/linked_data.  See README for more information.
      # @param [String] the name of the configuration file for the authority
      # @return [Qa::Authorities::LinkedData::Config] instance of this class
      def initialize(auth_name)
        @authority_name = auth_name
        auth_config
      end

      class << self
        include Qa::Authorities::LinkedData::ConfigMerge
      end

      include Qa::Authorities::LinkedData::TermConfig
      include Qa::Authorities::LinkedData::SearchConfig

      # Return the full configuration for an authority
      # @return [String] the authority configuration
      def auth_config
        @authority_config ||= LINKED_DATA_AUTHORITIES_CONFIG[@authority_name]
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data authority #{@authority_name}" if @authority_config.nil?
        @authority_config
      end

      private

        def config_value(config, key)
          return nil if config.nil? || !(config.key? key)
          config[key]
        end

        def predicate_uri(config, key)
          pred = config_value(config, key)
          pred_uri = nil
          pred_uri = RDF::URI(pred) unless pred.nil? || pred.length <= 0
          pred_uri
        end

        def apply_replacements(url, config, replacements = {})
          return url unless config.size.positive?
          config.each do |param_key, rep_pattern|
            s_param_key = param_key.to_s
            value = replacements[param_key] || replacements[s_param_key] || rep_pattern[:default]
            url = replace_pattern(url, param_key, value)
          end
          url
        end

        def process_subauthority(url, subauth_pattern, subauthorities, subauth_key)
          pattern = subauth_pattern[:pattern]
          value = subauthorities[subauth_key] || subauth_pattern[:default]
          replace_pattern(url, pattern, value)
        end

        def replace_pattern(url, pattern, value)
          url.gsub("{?#{pattern}}", value)
        end
    end
  end
end