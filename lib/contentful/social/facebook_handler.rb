require 'koala'

module Contentful
  module Social
    class FacebookHandler
      attr_reader :template, :facebook, :contentful, :webhook

      def initialize(facebook_config, contentful_client, webhook)
        @template = facebook_config.template
        @post_to = facebook_config.post_to || 'me'

        @webhook = webhook
        @contentful = contentful_client
        @facebook = create_facebook_client(facebook_config)
      end

      def post
        body = ::Contentful::Social::Template.new(
          contentful,
          webhook,
          template
        ).render

        facebook.put_connections(@post_to, 'feed', message: body)
      end

      private

      def create_facebook_client(facebook_config)
        Koala.config.api_version = 'v2.6'
        ::Koala::Facebook::API.new(
          facebook_config.access_token,
          facebook_config.app_secret
        )
      end
    end
  end
end
