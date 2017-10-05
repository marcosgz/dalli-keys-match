# Dalli KeysMatch

This gem add to the [Dalli::Client](https://github.com/petergoldstein/dalli) methods to list/filter/delete keys using regexp or string patterns.

IMPORTANT: It's not recommended to use in production. Memcached binary protocol does not implement `stats cachedump` command. We are using telnet as workaround. And I recommend using it in the development environment or background jobs.

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
 => #<Dalli::Client:0x007fcb14afe830 @servers=["localhost:11211"], @options={}, @ring=nil>
> client.set('dalli-keys-match-1' , 1)
 => 10163216984091656192
>  client.set('dalli-keys-match-2' , 2)
 => 10235274578129584128
> client.keys(/dalli-keys-match-\d/)
 => ["dalli-keys-match-2", "dalli-keys-match-1"]
> client.keys('dalli-keys-match-')
 => ["dalli-keys-match-2", "dalli-keys-match-1"]
> client.delete_matched(/dalli-keys-match-1/)
 => 1
> client.keys(/dalli-keys-match-\d/)
 => ["dalli-keys-match-2"]
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
