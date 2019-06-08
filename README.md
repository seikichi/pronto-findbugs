# Pronto::Findbugs

[![Gem Version](https://badge.fury.io/rb/pronto-findbugs.svg)](http://badge.fury.io/rb/pronto-findbugs)
[![Build Status](https://travis-ci.org/seikichi/pronto-findbugs.svg?branch=master)](https://travis-ci.org/seikichi/pronto-findbugs)
[![Coverage Status](https://coveralls.io/repos/seikichi/pronto-findbugs/badge.svg?branch=master&service=github)](https://coveralls.io/github/seikichi/pronto-findbugs?branch=master)

[Pronto](https://github.com/mmozuras/pronto) runner for [findbugs](http://findbugs.sourceforge.net/) or [spotbugs](https://spotbugs.github.io/) reports.

## Configuration

You need to specify location of findbugs reports by passing `PRONTO_FINDBUGS_REPORTS_DIR` env variable e.g:

```bash
PRONTO_FINDBUGS_REPORTS_DIR=build/reports/spotbugs/ pronto run --index
```

See [seikichi/pronto-checkstyle-findbugs-example](https://github.com/seikichi/pronto-checkstyle-findbugs-example) for more details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pronto-findbugs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pronto-findbugs

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seikichi/pronto-findbugs.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
