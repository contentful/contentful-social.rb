require 'contentful/webhook/listener/controllers/webhook_aware'
require 'contentful/social/twitter_handler'
require 'contentful/social/facebook_handler'

module Contentful
  module Social
    class Controller < ::Contentful::Webhook::Listener::Controllers::WebhookAware
      def publish
        return unless webhook.entry?
        return unless can_publish?(webhook)

        publish_to_twitter(webhook)
        publish_to_facebook(webhook)
      end

      def publish_to_twitter(webhook)
        return unless config.twitter_configured?

        ::Contentful::Social::TwitterHandler.new(config.twitter, contentful_client, webhook).tweet

        logger.debug 'Successfully published on Twitter'
      rescue StandardError => e
        logger.error "Error while trying to publish to Twitter: #{e}"
      end

      def publish_to_facebook(webhook)
        return unless config.facebook_configured?

        ::Contentful::Social::FacebookHandler.new(config.facebook, contentful_client, webhook).post

        logger.debug 'Successfully published on Facebook'
      rescue StandardError => e
        logger.error "Error while trying to publish to Facebook: #{e}"
      end

      def config
        ::Contentful::Social.config
      end

      def contentful_client
        if config.contentful[webhook.space_id]
          ::Contentful::Client.new(
            access_token: config.contentful[webhook.space_id],
            space: webhook.space_id,
            dynamic_entries: :auto,
            raise_errors: true,
            application_name: 'contentful-social',
            application_version: Contentful::Social::VERSION
          )
        else
          fail "Space '#{webhook.space_id}' not configured"
        end
      end

      def can_publish?(webhook)
        config.contentful[webhook.space_id]
      end
    end
  end
end
