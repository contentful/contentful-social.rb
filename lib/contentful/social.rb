require 'hashie'
require 'logger'
require 'contentful'
require 'contentful/webhook/listener'
require 'contentful/social/version'
require 'contentful/social/config'
require 'contentful/social/controller'
require 'contentful/social/support'
require 'contentful/social/template'

module Contentful
  module Social
    @@config = nil

    def self.config=(config)
      @@config ||= (config.is_a? ::Contentful::Social::Config) ? config : ::Contentful::Social::Config.new(config)
    end

    def self.config
      @@config
    end

    def self.start(config = {})
      fail "Social not configured" if config.nil? && !block_given?

      if block_given?
        yield(config) if block_given?
      end
      self.config = config

      logger = Logger.new(STDOUT)
      ::Contentful::Webhook::Listener::Server.start do |server_config|
        server_config[:port] = config.port
        server_config[:logger] = logger
        server_config[:endpoints] = [
          {
            endpoint: config.endpoint,
            controller: ::Contentful::Social::Controller,
            timeout: 0
          }
        ]
      end.join
    end
  end
end
