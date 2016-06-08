require 'spec_helper'

describe Contentful::Social::Controller do
  let(:server) { MockServer.new }
  let(:logger) { Contentful::Webhook::Listener::Support::NullLogger.new }
  let(:timeout) { 10 }
  let(:headers) { {'X-Contentful-Topic' => 'ContentfulManagement.Entry.publish', 'X-Contentful-Webhook-Name' => 'SomeName'} }
  let(:body) {
    {
      sys: {
        id: 'foo',
        space: {
          sys: {
            id: 'i5mnoggqu8vx'
          }
        },
        contentType: {
          sys: {
            id: 'post'
          }
        }
      },
      fields: {
        author_field: { 'en-US' => nil },
        reviewer_field: { 'en-US' => nil }
      }
    }
  }
  subject { described_class.new server, logger, timeout }

  before :each do
    Contentful::Social.config = Contentful::Social::Config.load(File.join(Dir.pwd, 'spec', 'fixtures', 'yml_fixtures', 'config.yml'))
  end

  describe 'controller methods' do
    describe ':publish' do
      describe 'does nothing' do
        it 'when webhook is asset' do
          headers['X-Contentful-Topic'] = 'ContentfulManagement.Asset.publish'
          webhook = Contentful::Webhook::Listener::WebhookFactory.new(RequestDummy.new(headers, body)).create

          expect(webhook.asset?).to be_truthy
          expect(webhook.entry?).to be_falsey

          expect(subject).not_to receive(:publish_to_twitter)
          expect(subject).not_to receive(:publish_to_facebook)
          subject.respond(RequestDummy.new(headers, body), MockResponse.new).join
        end

        it 'when webhook is content type' do
          headers['X-Contentful-Topic'] = 'ContentfulManagement.ContentType.publish'
          webhook = Contentful::Webhook::Listener::WebhookFactory.new(RequestDummy.new(headers, body)).create

          expect(webhook.content_type?).to be_truthy
          expect(webhook.entry?).to be_falsey

          expect(subject).not_to receive(:publish_to_twitter)
          expect(subject).not_to receive(:publish_to_facebook)
          subject.respond(RequestDummy.new(headers, body), MockResponse.new).join
        end
      end

      describe 'twitter' do
        before do
          allow(subject.config).to receive(:facebook_configured?) { false }
        end

        it 'does not call TwitterHandler when twitter not configured' do
          expect(subject.config).to receive(:twitter_configured?) { false }
          expect(subject).to receive(:publish_to_twitter).and_call_original

          expect(::Contentful::Social::TwitterHandler).not_to receive(:new)

          subject.respond(RequestDummy.new(headers, body), MockResponse.new).join
        end

        it 'tweets when configured' do
          twitter = Object.new
          expect(twitter).to receive(:tweet)
          expect(::Contentful::Social::TwitterHandler).to receive(:new) { twitter }

          vcr('client') {
            subject.respond(RequestDummy.new(headers, body), MockResponse.new).join
          }
        end
      end

      describe 'facebook' do
        before do
          allow(subject.config).to receive(:twitter_configured?) { false }
        end

        it 'does not call FacebookHandler when facebook not configured' do
          expect(subject.config).to receive(:facebook_configured?) { false }
          expect(subject).to receive(:publish_to_facebook).and_call_original

          expect(::Contentful::Social::FacebookHandler).not_to receive(:new)

          vcr('client') {
            subject.respond(RequestDummy.new(headers, body), MockResponse.new).join
          }
        end

        it 'posts when configured' do
          facebook = Object.new
          expect(facebook).to receive(:post)
          expect(::Contentful::Social::FacebookHandler).to receive(:new) { facebook }

          vcr('client') {
            subject.respond(RequestDummy.new(headers, body), MockResponse.new).join
          }
        end
      end
    end
  end

  describe 'instance methods' do
    let(:webhook) { Contentful::Webhook::Listener::WebhookFactory.new(RequestDummy.new(headers, body)).create }

    it ':config' do
      expect(subject.config).to eq Contentful::Social.config
    end

    describe '#can_publish?' do
      it 'true when space properly configured' do
        webhook = Contentful::Webhook::Listener::WebhookFactory.new(RequestDummy.new(headers, body)).create

        expect(subject.can_publish?(webhook)).to be_truthy
      end

      it 'false when space not present' do
        body[:sys][:space][:sys][:id] = 'foobar'
        webhook = Contentful::Webhook::Listener::WebhookFactory.new(RequestDummy.new(headers, body)).create

        expect(subject.can_publish?(webhook)).to be_falsey
      end
    end
  end
end
