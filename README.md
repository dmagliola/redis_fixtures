# redis_fixtures

[![Build Status](https://travis-ci.org/dmagliola/redis_fixtures.svg?branch=master)](https://travis-ci.org/dmagliola/redis_fixtures)
[![Coverage Status](https://coveralls.io/repos/dmagliola/redis_fixtures/badge.svg?branch=master&service=github)](https://coveralls.io/github/dmagliola/redis_fixtures?branch=master)
[![Code Climate](https://codeclimate.com/github/dmagliola/redis_fixtures/badges/gpa.svg)](https://codeclimate.com/github/dmagliola/redis_fixtures)
[![Inline docs](http://inch-ci.org/github/dmagliola/redis_fixtures.svg?branch=master&style=flat)](http://inch-ci.org/github/dmagliola/redis_fixtures)
[![Gem Version](https://badge.fury.io/rb/redis_fixtures.png)](http://badge.fury.io/rb/redis_fixtures)
[![Dependency Status](https://gemnasium.com/dmagliola/redis_fixtures.svg)](https://gemnasium.com/dmagliola/redis_fixtures)

Add fixtures to your Redis database, to test the parts of your code that need Redis to be more than a cache.


## Version Compatibility and Continuous Integration

Tested with [Travis](https://travis-ci.org/dmagliola/redis_fixtures) using Ruby 1.9.3, 2.0, 2.1.1 and 2.1.5,
 and against redis 3.0.0 and 3.2.1.

To locally run tests do:

````
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

### Version 1.0.0 (Jan 2nd, 2015)
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
