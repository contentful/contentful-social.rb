# Contentful Social

Social Server listens for incoming publish webhooks from Contentful to manage social media publishing of entries.

## Contentful
[Contentful](http://www.contentful.com) is a content management platform for web applications,
mobile apps and connected devices. It allows you to create, edit & manage content in the cloud
and publish it anywhere via powerful API. Contentful offers tools for managing editorial
teams and enabling cooperation between organizations.

## What does `contentful-social` do?
The aim of `contentful-social` is to have developers setting up their Contentful
entries for publishing to multiple social media services.

### How does it work?

We'll explain this with a step-by-step example:

1. Create your content type in Contentful
2. Set up your social media templates (more on this later)
3. Set up your social media credentials
4. Start the `contentful_social` server
5. Create your entries in Contentful
6. Publish them
7. Watch your social accounts get updated

`contentful-social` provides a web endpoint to receive webhook calls from Contentful.

Every time the endpoint recieves an `Entry.publish` call it looks for you configured accounts and publishes to them.

### Writing Social Media Templates

This tool uses a very simplified templating system for handling your Contentful entries and delivering them to your social accounts.

Imagine you have the following (simplified) Contentful entry:

```json
{
  "fields": {
    "title": "MyTitle",
    "body": "Some well written text",
    "interestingLink": "http://veryinteresting.com"
  }
}
```

We want to send a tweet or Facebook post displaying `"MyTitle: Some well written text. More info on: http://veryinteresting.com"`.

You could very well write directly that in your template field, and every single one of your published posts will be THAT! But we don't
want that. We want to be able to follow that same pattern but for multiple entries with varying content.

To do so, we can use the templates:

```
{{title}}: {{body}}. More info on: {{interesting_link}}
```

As you might have noticed, it's simply a matter of surrounding the field name you want in place with double braces `{{field_name}}`. And
it is exactly that.

**Note:** `camelCased` field names need to be referenced as `snake_cased`. For Example, `interestingLink` will be referenced as `interesting_link`
inside our template.

#### Dealing with related entries

Many times in Contentful you will like to have linked entries, and you may want to pull content from them inside your templates.

Lets consider the following (simplified and with links resolved inside) entry:

```json
{
  "fields": {
    "title": "MyTitle",
    "body": "Some well written text",
    "interestingLink": "https://veryinteresting.com",
    "relatedThing": {
      "fields": {
        "name": "AmazingTitle"
      }
    }
  }
}
```

We can call fields on related entries too! (Only up to 3 levels of nesting). To do so:

```
{{title}}: {{body}}. Have you heard about {{related_thing.name}}?
```

#### Dealing with Arrays

Currently the template engine does not support Arrays, but you can still access the first element as if it were a related entry:

```
{{my_array.first}}
```

Or if the array is of related entries:

```
{{related_entries.first.some_field}}
```

## Requirements

At least one of the following:

* [Facebook Developer account](https://developers.facebook.com/)
* [Twitter Developer account](https://dev.twitter.com/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'contentful-social'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install contentful-social

## Usage

* Create your configuration file:

You can base your configuration file from [the example `config.yml`](./example/config.yml)

```yml
---

port: 34123 # defaults to 34123
endpoint: '/social' # defaults to /social

contentful: # your contentful spaces
  my_space_id: 'my_production_access_token'
  # you can add multiple spaces here
  # at least one is required

twitter: # your twitter config
  # required
  access_token: 'your_access_token'
  access_token_secret: 'your_access_token_secret'
  consumer_key: 'your_consumer_key'
  consumer_secret: 'your_consumer_secret'

  template: '{{body}} {{interesting_link}} {{related.title}}'

  # optional
  media: 'my_media_field' # defaults to nil
  possibly_sensitive: false # defaults to false
  location: #defaults to {}
    lat: 10.12341
    lon: -25.123123

facebook: # your facebook config
  # required
  access_token: 'your_access_token'

  template: '{{body}} {{interesting_link}} {{related.title}}'

  # optional
  app_secret: 'your_app_secret' # defaults to nil (the access token has an app_id already)
  post_to: 'feed_id' # defaults to 'me' which is your own timeline (can be a page's id or other user's id)
```

* Run the server:

```bash
$ contentful_social config.yml
```

* Configure the webhook in Contentful:

Under the space settings menu choose webhook and add a new webhook pointing to `http://YOUR_SERVER:33123/social`.

Keep in mind that if you modify the defaults, the URL should be changed to the values specified in the configuration.

## Running in Heroku

* Create a `Procfile` containing:

```
web: PORT=$PORT env bundle exec contentful_social config.yml
```

That will allow Heroku to set it's own Port according to their policy.

Then proceed to `git push heroku master`.

The URL for the webhook then will be on port 80, so you should change it to: `http://YOUR_APPLICATION/social`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/contentful/contentful-social.rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
