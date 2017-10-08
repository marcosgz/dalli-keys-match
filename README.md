# Dalli KeysMatch

This gem add to the [Dalli::Client](https://github.com/petergoldstein/dalli) methods to list/filter/delete keys using regexp or string patterns.

Memcached binary protocol does not implement `stats cachedump` command. This package is using telnet as workaround. It may not be performatic in an environment with high data volume. So It's not recommend using it in production. Useful for debugging or in background jobs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dalli-keys-match'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dalli-keys-match

## Usage
```
require 'dalli/keys_match'

> client = Dalli::Client.new('localhost:11211')
> client.set('dalli-keys-match-1' , 1)
> client.set('dalli-keys-match-2' , 2)
> client.keys(/dalli-keys-match-\d/)
 => ["dalli-keys-match-2", "dalli-keys-match-1"]
> client.keys('dalli-keys-match-')
 => ["dalli-keys-match-2", "dalli-keys-match-1"]
> client.delete_matched(/dalli-keys-match-1/)
 => 1
> client.keys(/dalli-keys-match-\d/)
 => ["dalli-keys-match-2"]
```

Gem also handles namespaces. Keys are normalized and filters are always optimized to only look into the namespace
```
> dc1 = Dalli::Client.new('localhost:11211')
> dc2 = Dalli::Client.new('localhost:11211', namespace: 'marcosgz')
> dc1.set('zimmermann', 'last-name')
> dc2.set('zimmermann', 'last-name')
> dc1.keys(/zimmermann/)
 => ["zimmermann", "marcosgz:zimmermann"]
> dc2.keys(/zimmermann/)
 => ["zimmermann"]
> dc2.keys_with_namespace(/zimmermann/)
 => ["marcosgz:zimmermann"]
> dc2.delete_matched(/^zimmermann/)
 => 1
> dc1.keys(/zimmermann/)
 => ["zimmermann"]
```


### Optional Configuration
```
Dalli::KeysMatch.config.telnet = {
  'Timeout' => 30,
  'Prompt' => /(^END$)/,
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcosgz/dalli-keys-match.
