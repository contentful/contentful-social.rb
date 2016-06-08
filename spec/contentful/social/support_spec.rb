require 'spec_helper'

class WebhookDouble
  def id
    '6be1uFO1WMcKIqQy8eMyKu'
  end
end

describe Contentful::Social::Support do
  let(:client) {
    vcr('client') {
      ::Contentful::Client.new(
        access_token: '7a23ea914d9411c517540ae7bac9a7811c52225ca81d3efc8bcc39a740dde6ab',
        space: 'i5mnoggqu8vx',
        dynamic_entries: :auto
      )
    }
  }
  let(:webhook) { WebhookDouble.new }
  subject { described_class }

  describe 'class methods' do
    describe '::find_entry' do
      it 'fetches the entry' do
        vcr('support/find_entry') {
          entry = subject.find_entry(client, webhook)

          expect(entry.id).to eq webhook.id
          expect(entry.name).to eq 'Test'
        }
      end
    end
  end
end
