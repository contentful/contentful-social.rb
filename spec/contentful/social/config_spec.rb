require 'spec_helper'

describe Contentful::Social::Config do
  let(:valid_params) { {
    contentful: {
      foo: 'foobar'
    },
    twitter: {
      template: 'something',
      access_token: 'foobar',
      access_token_secret: 'foobar_secret',
      consumer_key: 'baz',
      consumer_secret: 'baz_secret'
    }
  } }

  subject { described_class.new(valid_params) }

  describe 'initialization' do
    it 'requires contentful configuration' do
      expect { described_class.new }.to raise_error 'Contentful Access Token not Configured'
    end

    it 'requires at least one social media' do
      expect { described_class.new(contentful: {foo: 'bar'}) }.to raise_error 'No Social Media Configured'
    end

    it 'has all it needs' do
      expect { subject }.not_to raise_error
    end

    describe ':port' do
      it 'sets a default port' do
        expect(subject.port).to eq described_class::DEFAULT_PORT
      end

      it 'can be overridden with an environment variable' do
        ENV['PORT'] = '1234'
        expect(subject.port).to eq 1234
        ENV['PORT'] = nil
      end

      it 'can be set manually' do
        config = described_class.new(
          valid_params.merge(port: 123123)
        )
        expect(config.port).to eq 123123
      end
    end

    describe ':endpoint' do
      it 'sets a default endpoint' do
        expect(subject.endpoint).to eq described_class::DEFAULT_ENDPOINT
      end

      it 'can be set manually' do
        config = described_class.new(
          valid_params.merge(endpoint: '/foo')
        )
        expect(config.endpoint).to eq '/foo'
      end
    end
  end

  it 'can be loaded with a yaml file' do
    config = described_class.load(File.join(Dir.pwd, 'spec', 'fixtures', 'yml_fixtures', 'config.yml'))
    expect(config.contentful).to eq('i5mnoggqu8vx' => '7a23ea914d9411c517540ae7bac9a7811c52225ca81d3efc8bcc39a740dde6ab')
  end
end
