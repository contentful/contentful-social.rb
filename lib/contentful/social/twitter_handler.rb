require 'twitter'
require 'open-uri'

module Contentful
  module Social
    class TwitterHandler
      attr_reader :template, :twitter, :contentful, :webhook

      def initialize(twitter_config, contentful_client, webhook)
        @possibly_sensitive = twitter_config.possibly_sensitive || false
        @location = twitter_config.location || Hashie::Mash.new
        @media = twitter_config.media || nil
        @template = twitter_config.template

        @webhook = webhook
        @contentful = contentful_client
        @twitter = create_twitter_client(twitter_config)
      end

      def tweet
        body = ::Contentful::Social::Template.new(
          contentful,
          webhook,
          template
        ).render

        options = {
          possibly_sensitive: @possibly_sensitive,
        }

        unless @location.empty?
          options[:lat] = @location.lat
          options[:lon] = @location.lon
        end

        if @media.nil?
          twitter.update(body, options)
        else
          twitter.update_with_media(body, fetch_media, options)
        end
      end

      def fetch_media
        media = Support.find_entry(contentful, webhook).public_send(@media) unless @media.nil?

        open("https:#{media.image_url}") if media
      end

      private

      def create_twitter_client(twitter_config)
        ::Twitter::REST::Client.new do |config|
          config.consumer_key = twitter_config.consumer_key
          config.consumer_secret = twitter_config.consumer_secret
          config.access_token = twitter_config.access_token
          config.access_token_secret = twitter_config.access_token_secret
        end
      end
    end
  end
end
