require 'spec_helper'

class Contentful::Social::LocalTemplate < Contentful::Social::Template
  def contentful_find(field)
    case field
    when 'foo'
      'nyancat'
    when 'bar'
      'foodog'
    end
  end
end

class WebhookDouble
  def id
    '6be1uFO1WMcKIqQy8eMyKu'
  end
end

describe Contentful::Social::Template do
  let(:contentful) {
    vcr('client') {
      ::Contentful::Client.new(
        access_token: '7a23ea914d9411c517540ae7bac9a7811c52225ca81d3efc8bcc39a740dde6ab',
        space: 'i5mnoggqu8vx',
        dynamic_entries: :auto
      )
    }
  }
  let(:webhook) { WebhookDouble.new }
  let(:template) { "Entry '{{name}}': {{body}}" }
  subject { described_class.new(contentful, webhook, template) }

  describe 'instance attributes' do
    it ':contentful' do
      expect(subject.contentful).to eq(contentful)
    end

    it ':webhook' do
      expect(subject.webhook).to eq(webhook)
    end

    it ':template' do
      expect(subject.template).to eq(template)
    end
  end

  describe 'instance methods' do
    describe '#render' do
      it 'renders template if no field is present' do
        subject = described_class.new(contentful, webhook, "foobar")
        expect(subject.render).to eq("foobar")
      end

      it 'calls contentful when asked for fields' do
        expect(subject).to receive(:contentful_find).twice

        subject.render
      end

      it 'renders the content' do
        vcr('template/render') {
          expect(subject.render).to eq("Entry 'Test': My Lovely Test")
        }
      end

      it 'can render nested elements' do
        vcr('template/render') {
          subject = described_class.new(contentful, webhook, "{{image.title}}")

          expect(subject.render).to eq("TestImage")
        }
      end
    end
  end
end

describe Contentful::Social::LocalTemplate do
  let(:contentful) { nil }
  let(:webhook) { nil }
  let(:template) { "Hello Mr. {{foo}}. I'm {{bar}}." }
  subject { described_class.new(contentful, webhook, template) }

  it 'replaces properly data in template' do
    expect(subject.render).to eq "Hello Mr. nyancat. I'm foodog."
  end
end
