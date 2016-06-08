require 'spec_helper'

class WebhookDouble
  def id
    '6be1uFO1WMcKIqQy8eMyKu'
  end
end

describe Contentful::Social::FacebookHandler do
  let(:facebook_config) {
    Hashie::Mash.new(
      template: 'hey {{name}}',
      access_token: 'foo',
      app_secret: 'foo_secret'
    )
  }
  let(:contentful_client) {
    vcr('client') {
      ::Contentful::Client.new(
        access_token: '7a23ea914d9411c517540ae7bac9a7811c52225ca81d3efc8bcc39a740dde6ab',
        space: 'i5mnoggqu8vx',
        dynamic_entries: :auto
      )
    }
  }
  let(:webhook) { WebhookDouble.new }
  subject { described_class.new(facebook_config, contentful_client, webhook) }

  describe 'instance attributes' do
    it ':template' do
      expect(subject.template).to eq(facebook_config.template)
    end

    it ':facebook' do
      expect(subject.facebook).to be_a(::Koala::Facebook::API)
    end

    it ':contentful' do
      expect(subject.contentful).to eq(contentful_client)
    end

    it ':webhook' do
      expect(subject.webhook).to eq(webhook)
    end
  end

  describe 'instance methods' do
    describe '#post' do
      it 'renders the template and tweets it' do
        vcr('template/render') {
          expect(subject.facebook).to receive(:put_connections).with('me', 'feed', message: 'hey Test')

          subject.post
        }
      end
    end
  end
end

