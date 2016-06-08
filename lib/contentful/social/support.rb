module Contentful
  module Social
    module Support
      def self.find_entry(contentful_client, webhook, include_level = 3)
        contentful_client.entries('sys.id' => webhook.id, include: include_level).find do |e|
          e.id == webhook.id
        end
      end
    end
  end
end
