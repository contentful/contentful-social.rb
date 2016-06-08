module Contentful
  module Social
    class Template
      attr_reader :contentful, :webhook, :template

      def initialize(contentful_client, webhook, template)
        @contentful = contentful_client
        @webhook = webhook
        @template = template
      end

      def render
        template.gsub(/\{\{([\w|\.]+)\}\}/) do |match|
          contentful_find(match.gsub('{{', '').gsub('}}', ''))
        end
      end

      protected

      def contentful_find(field)
        entry = Support.find_entry(contentful, webhook)

        if field.include?('.')
          result = entry
          field.split('.').each do |partial|
            result = result.public_send(partial)
          end

          result
        else
          entry.public_send(field)
        end
      end
    end
  end
end
