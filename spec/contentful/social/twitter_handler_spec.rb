require 'spec_helper'

class WebhookDouble
  def id
    '6be1uFO1WMcKIqQy8eMyKu'
  end
end

describe Contentful::Social::TwitterHandler do
  let(:twitter_config) {
    Hashie::Mash.new(
      template: 'hey {{name}}',
      access_token: 'foo',
      access_token_secret: 'foo_secret',
      consumer_key: 'bar',
      consumer_secret: 'bar_secret'
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
  subject { described_class.new(twitter_config, contentful_client, webhook) }

  describe 'instance attributes' do
    it ':template' do
      expect(subject.template).to eq(twitter_config.template)
    end

    it ':twitter' do
      expect(subject.twitter).to be_a(::Twitter::REST::Client)
    end

    it ':contentful' do
      expect(subject.contentful).to eq(contentful_client)
    end

    it ':webhook' do
      expect(subject.webhook).to eq(webhook)
    end
  end

  describe 'instance methods' do
    describe '#tweet' do
      it 'renders the template and tweets it' do
        vcr('template/render') {
          expect(subject.twitter).to receive(:update).with('hey Test', possibly_sensitive: false)

          subject.tweet
        }
      end

      it 'sends possibly sensitive if configured' do
        vcr('template/render') {
          subject = described_class.new(twitter_config.merge(possibly_sensitive: true), contentful_client, webhook)

          expect(subject.twitter).to receive(:update).with('hey Test', possibly_sensitive: true)

          subject.tweet
        }
      end

      it 'sends location if configured' do
        vcr('template/render') {
          subject = described_class.new(twitter_config.merge(location: Hashie::Mash.new(lat: -10, lon: 35.234)), contentful_client, webhook)

          expect(subject.twitter).to receive(:update).with('hey Test', possibly_sensitive: false, lat: -10, lon: 35.234)

          subject.tweet
        }
      end

      it 'uploads with media if media_field provided' do
        vcr('template/render') {
          subject = described_class.new(twitter_config.merge(media: 'image'), contentful_client, webhook)
          allow(subject).to receive(:fetch_media) { 'media' }

          expect(subject.twitter).to receive(:update_with_media).with('hey Test', 'media', possibly_sensitive: false)

          subject.tweet
        }
      end
    end

    describe '#fetch_media' do
      it 'returns nil if no media field is set' do
        vcr('template/render') {
          expect(subject.fetch_media).to be_nil
        }
      end

      it 'returns a file when media is set' do
        vcr('template/render') {
          vcr('hanlder/media') {
            subject = described_class.new(twitter_config.merge(media: 'image'), contentful_client, webhook)
            expect(subject.fetch_media).to be_a ::Tempfile
          }
        }
      end
    end
  end
end
