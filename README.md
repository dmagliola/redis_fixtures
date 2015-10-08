# redis_fixtures

[![Build Status](https://travis-ci.org/dmagliola/redis_fixtures.svg?branch=master)](https://travis-ci.org/dmagliola/redis_fixtures)
[![Coverage Status](https://coveralls.io/repos/dmagliola/redis_fixtures/badge.svg?branch=master&service=github)](https://coveralls.io/github/dmagliola/redis_fixtures?branch=master)
[![Code Climate](https://codeclimate.com/github/dmagliola/redis_fixtures/badges/gpa.svg)](https://codeclimate.com/github/dmagliola/redis_fixtures)
[![Inline docs](http://inch-ci.org/github/dmagliola/redis_fixtures.svg?branch=master&style=flat)](http://inch-ci.org/github/dmagliola/redis_fixtures)
[![Gem Version](https://badge.fury.io/rb/redis_fixtures.png)](http://badge.fury.io/rb/redis_fixtures)
[![Dependency Status](https://gemnasium.com/dmagliola/redis_fixtures.svg)](https://gemnasium.com/dmagliola/redis_fixtures)

Add fixtures to your Redis database, to test the parts of your code that need Redis to be more than a cache.

If you are using Redis for anything more interesting than a cache (and if you're not, get on it, Redis is awesome!),
RedisFixtures will help you test by guaranteeing a clean, well-known state of your Redis Database at the
start of each test.

RedisFixtures is designed to integrate seamlessly with gems like [FixtureBuilder](https://github.com/rdy/fixture_builder),
which take a snapshot of your database and dumps the data into fixture files. RedisFixtures will run at the end
of the fixture generation phase and do exactly the same with your Redis database, dumping all the keys into a
single fixture file. It will then reset your Redis DB to the state specified in that fixture.

If you are building your fixtures manually, you can also do that, more on that below, but that sounds like a lot of
work, I can't recommend FixtureBuilder enough to save you time, and most importantly, speed up your test suite if you're
using tools like FactoryGirl.

## Sample Use Cases / What is this good for?

Here are a few situations where we're using RedisFixtures to help our tests:

1. We do geo-location based on a user's IP using a Redis Sorted Set (populated with the IP ranges).
Testing that requires having some ranges in Redis.

2. We have a phone line rotation module (to be released soon) to send SMS doing a round-robin of multiple
phone lines. That module uses Redis very heavily for performance, and we need some sample phone lines in there
to test it.

3. Our localization feature stores dynamic string translations in Redis. Again, testing this requires
some sample translations in there.

It's much more convenient to have all these as the initial well-known state of every test case, rather than
having to set these up, particularly for our integration tests.


## Download

Gem:

`gem install redis_fixtures`

## Installation

Load the gem in the test environment in your GemFile.

  `gem "redis_fixtures", group: :test`


## Configuration

In your `test_helper.rb` file, call RedisFixtures.configure (after the setup of your Redis connection has run),
and set how RedisFixtures should connect to Redis:

```
RedisFixtures.configure do |config|
  # set one of :connection_pool, :connection_block, :connection_settings or :connection properties
  config.connection_pool = $RedisPool
end
```

You have 4 options to configure how RedisFixtures connects to your Redis database:

- If you are using the [connection_pool](https://github.com/mperham/connection_pool) gem, simply set
  `config.connection_pool = your_connection_pool`, and RedisFixtures will checkout connections from
  the pool as needed. If you're not using connection_pool, I really recommend it, it's awesome.
- If you already have a connection that you are reusing in your project, you can set
  `config.connection = your_connection` and RedisFixtures will use that.
- If you would like RedisFixtures to connect as needed, and you need some special magic to connect
  to redis, you can use `connection_proc` to specify how to connect. For example:
  `config.connection_proc = Proc.new{ your_magic_code_here }`. This proc should return a Redis object.
- Or, you can simply set `connection_settings` with the connection details, like:
  `config.connection_settings = {host: 'localhost', port: 1234}`, and RedisFixtures will connect on demand
  by passing that object to `Redis.new`.
- Finally, if you have a default Redis running in localhost in the default port, you don't need to set
  anything, RedisFixtures will connect to it automatically.

You can also configure the name of the fixture file generated (don't give it a .yml extension, it may get cleared
by tools like FixtureBuilder), and the path to your app's root, if you're not using Rails.

### Separate database for test

It's very convenient to use a separate DB for your dev environment and your test env. For example, we use db0 for
dev, and db1 for test. That way, running tests can reset the DB without ruining our work, if we're in the middle
of testing something manually.

Sample redis initializer to do this:

```
redis_connection = (ENV["REDISCLOUD_URL"] ? {url: ENV["REDISCLOUD_URL"]} : {host: 'localhost', port: 6379})
redis_connection[:driver] = :hiredis
redis_connection[:db] = 1 if Rails.env.test?
$RedisPool = ConnectionPool.new(size: redis_pool_size, timeout: 2) do
  Redis.new(redis_connection)
end
```

## Generating the Fixture File

There are two ways to generate the fixture file: Automagic or Manual.

If you are using a tool that automatically snapshots your database into fixture files, you want to call RedisFixtures
from it. Simply call `RedisFixtures.before_fixture_data_generation` before you generate your data into Redis, and
`RedisFixtures.save_fixtures` afterwards, and that's it! Every time fixtures get generated, a new Redis one will
show up.

For example, you can set FixtureBuilder like this:

```
FixtureBuilder.configure do |fbuilder|
  fbuilder.factory do
    RedisFixtures.before_fixture_data_generation
    SampleData.generate_test_data
    RedisFixtures.save_fixtures
  end
end
```

Other fixture building tools will be similar. If you're using one of them, I'd love to see a bit of sample code
to add here!


### Manual Fixture Generation

You can generate your Fixture manually in 2 ways:

1. Actually generate the YAML file manually. The YAML file contains an array with one entry per Redis key. Each
of those entries is an array that has several entries: The first one is the Redis command to create the key (:set, :zadd, etc),
the second one is the key, and the rest are whatever parameters you'd pass to the Redis client to populate that key.

2. A much more reasonable way is to use whatever tool you want to get Redis into the state you'd like to have it
(I really like [RDM](http://redisdesktop.com/) for fiddling with Redis), and then call RedisFixtures.save_fixtures from
the Rails Console (or irb, etc).

But really, try to use the automagic way, it's much more convenient.


## Running tests

If you are using Minitest, you're done! RedisFixtures will automatically reset your Redis DB to a known state before
each test.

If you are using RSpec... This is a great opportunity for you to submit a Pull Request! No, in all seriousness, I have plans
to add RSpec integration, but it may be easier for someone more experienced with RSpec.


## Version Compatibility and Continuous Integration

Tested with [Travis](https://travis-ci.org/dmagliola/redis_fixtures) using Ruby 1.9.3, 2.0, 2.1.1 and 2.1.5,
 and against redis 3.0.0 and 3.2.1.

To locally run tests do:

```
appraisal rake test
```

## Copyright

Copyright (c) 2015, Daniel Magliola

See LICENSE for details.


## Users

This gem is being used by:

- [MSTY](https://www.msty.com)
- You? please, let us know if you are using this gem.


## Changelog

### Version 1.0.0 (Oct 8th, 2015)
- Newly released gem

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Code your thing
1. Write and run tests:
        bundle install
        appraisal
        appraisal rake test
1. Write documentation and make sure it looks good: yard server --reload
1. Add items to the changelog, in README.
1. Commit your changes (`git commit -am "Add some feature"`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request
