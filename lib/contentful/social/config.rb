require 'hashie'
require 'yaml'

module Contentful
  module Social
    class Config
      DEFAULT_PORT = 34123
      DEFAULT_ENDPOINT = '/social'

      attr_reader :config

      def self.load(path)
        new(Hashie::Mash.load(path))
      end

      def initialize(config = {})
        @config = Hashie::Mash.new(config)

        @config.port = (ENV.key?('PORT') ? ENV['PORT'].to_i : DEFAULT_PORT) unless @config.port?
        @config.endpoint = DEFAULT_ENDPOINT unless @config.endpoint?

        fail 'Contentful Access Token not Configured' unless contentful_configured?
        fail 'No Social Media Configured' unless twitter_configured? || facebook_configured?
      end

      def port
        @config.port
      end

      def endpoint
        @config.endpoint
      end

      class_eval do
        [:contentful, :twitter, :facebook].each do |name|
          define_method(name) do
            @config.public_send(name)
          end

          define_method("#{name}?") do
            @config.public_send("#{name}?")
          end
        end
      end

      def twitter_configured?
        twitter? &&
          twitter.template? &&
          twitter.access_token? &&
          twitter.access_token_secret? &&
          twitter.consumer_key? &&
          twitter.consumer_secret?
      end

      def facebook_configured?
        facebook? &&
          facebook.template? &&
          facebook.access_token? # && facebook.app_secret? # not required
      end

      def contentful_configured?
        contentful? &&
          contentful.all? { |space_id, access_token| access_token }
      end
    end
  end
end
